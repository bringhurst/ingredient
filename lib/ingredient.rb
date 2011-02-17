require 'rbconfig'
require 'fileutils'
require 'pathname'

begin
  require 'psych'
rescue LoadError
end

require 'yaml'
require 'ingredient/version'

module Ingredient
  ORIGINAL_ENV = ENV.to_hash

  autoload :UI,                  'ingredient/ui'

  class IngredientError < StandardError
    def self.status_code(code = nil)
      define_method(:status_code) { code }
    end
  end

  class PathError        < IngredientError; status_code(13) ; end
  class DeprecatedError  < IngredientError; status_code(12) ; end
  class DslError         < IngredientError; status_code(15) ; end
  class InvalidOption    < DslError                      ; end

  NULL = "/dev/null"

  class << self
    attr_writer :ui, :ingredient_path

    def configure
      @configured ||= begin
        configure_ingredient_home_and_path
        true
      end
    end

    def ui
      @ui ||= UI.new
    end

    def ingredient_path
      @bin_path ||= begin
        path = settings[:bin] || "bin"
        path = Pathname.new(path).expand_path(root)
        FileUtils.mkdir_p(path)
        Pathname.new(path).expand_path
      end
    end

    def setup(*groups)
      # Just return if all groups are already loaded
      return @setup if defined?(@setup)

      if groups.empty?
        # Load all groups, but only once
        @setup = load.setup
      else
        @completed_groups ||= []
        # Figure out which groups haven't been loaded yet
        unloaded = groups - @completed_groups
        # Record groups that are now loaded
        @completed_groups = groups
        # Load any groups that are not yet loaded
        unloaded.any? ? load.setup(*unloaded) : load
      end
    end

    def require(*groups)
      setup(*groups).require(*groups)
    end

    def load
      @load ||= Runtime.new(root, definition)
    end

    def definition(unlock = nil)
      @definition = nil if unlock
      @definition ||= begin
        configure
        upgrade_lockfile
        Definition.build(default_gemfile, default_lockfile, unlock)
      end
    end

    def ruby_scope
      "#{Gem.ruby_engine}/#{Gem::ConfigMap[:ruby_version]}"
    end

    def cache
      bundle_path.join("cache/bundler")
    end

    def app_config_path
      ENV['BUNDLE_APP_CONFIG'] ?
        Pathname.new(ENV['BUNDLE_APP_CONFIG']).expand_path(root) :
        root.join('.bundle')
    end

    def app_cache
      root.join("vendor/cache")
    end

    def tmp
      user_bundle_path.join("tmp", Process.pid.to_s)
    end

    def settings
      @settings ||= Settings.new(app_config_path)
    end

    def requires_sudo?
      return @requires_sudo if @checked_for_sudo

      path = bundle_path
      path = path.parent until path.exist?
      sudo_present = !(`which sudo` rescue '').empty?

      @checked_for_sudo = true
      @requires_sudo = settings.allow_sudo? && !File.writable?(path) && sudo_present
    end

    def sudo(str)
      `sudo -p 'The ingredient has requested ROOT access to perform an action. Enter your password to continue: ' #{str}`
    end

    def read_file(file)
      File.open(file, "rb") { |f| f.read }
    end

    def load_gemspec(file)
      path = Pathname.new(file)
      # Eval the gemspec from its parent directory
      Dir.chdir(path.dirname.to_s) do
        contents = File.read(path.basename.to_s)
        begin
          Gem::Specification.from_yaml(contents)
          # Raises ArgumentError if the file is not valid YAML
        rescue ArgumentError, SyntaxError, Gem::EndOfYAMLException, Gem::Exception
          begin
            eval(contents, TOPLEVEL_BINDING, path.expand_path.to_s)
          rescue LoadError => e
            original_line = e.backtrace.find { |line| line.include?(path.to_s) }
            msg  = "There was a LoadError while evaluating #{path.basename}:\n  #{e.message}"
            msg << " from\n  #{original_line}" if original_line
            msg << "\n"

            if RUBY_VERSION >= "1.9.0"
              msg << "\nDoes it try to require a relative path? That doesn't work in Ruby 1.9."
            end

            raise GemspecError, msg
          end
        end
      end
    end

  private

    def configure_ingredient_home_and_path
      ENV['INGREDIENT_PATH'] = ''
      ENV['INGREDIENT_HOME'] = File.expand_path(bundle_path, root)
    end

  end
end
