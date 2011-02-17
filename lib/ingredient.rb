require 'rbconfig'
require 'fileutils'
require 'pathname'

begin
  require 'psych'
rescue LoadError
end

require 'yaml'

module Ingredient
  ORIGINAL_ENV = ENV.to_hash

  #autoload :UI,                  'bundler/ui'

  class IngredientError < StandardError
    def self.status_code(code = nil)
      define_method(:status_code) { code }
    end
  end

  class PathError        < BundlerError; status_code(13) ; end
  class DeprecatedError  < BundlerError; status_code(12) ; end
  class DslError         < BundlerError; status_code(15) ; end
  class InvalidOption    < DslError                      ; end

  FREEBSD = RbConfig::CONFIG["host_os"] =~ /bsd/
  NULL    = WINDOWS ? "NUL" : "/dev/null"

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

  private

    def configure_ingredient_home_and_path
      ENV['INGREDIENT_PATH'] = ''
      ENV['INGREDIENT_HOME'] = File.expand_path(bundle_path, root)
    end

  end
end
