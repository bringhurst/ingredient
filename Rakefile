$:.unshift File.expand_path("../lib", __FILE__)

require 'ingredient/gem_helper'
Ingredient::GemHelper.install_tasks

def sudo?
  ENV['INGREDIENT_SUDO_TESTS']
end

begin
  require 'rspec/core/rake_task'
  require 'ronn'

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(-fs --color)
    t.ruby_opts  = %w(-w)
  end
  task :spec => "man:build"

  begin
    require 'ci/reporter/rake/rspec'

    namespace :ci do
      desc "Run specs with Hudson output"
      RSpec::Core::RakeTask.new(:spec)
      task :spec => ["ci:setup:rspec", "man:build"]
    end

  rescue LoadError
    namespace :ci do
      task :spec do
        abort "Run `rake ci:deps` to be able to run the CI specs"
      end

      desc "Install CI dependencies"
      task :deps do
        sh "gem list ci_reporter | (grep 'ci_reporter' 1> /dev/null) || gem install ci_reporter --no-ri --no-rdoc"
      end
      task :deps => "spec:deps"
    end
  end

  namespace :spec do
    desc "Run the spec suite with the sudo tests"
    task :sudo => ["set_sudo", "clean", "spec"]

    task :set_sudo do
      ENV['INGREDIENT_SUDO_TESTS'] = '1'
    end

    task :clean do
      if sudo?
        system "sudo rm -rf #{File.expand_path('../tmp', __FILE__)}"
      else
        rm_rf 'tmp'
      end
    end

    namespace :rubygems do
      # Rubygems 1.3.5, 1.3.6, and HEAD specs
      rubyopt = ENV["RUBYOPT"]
      %w(master v1.3.6 v1.3.7 v1.4.0 v1.4.1 v1.5.0).each do |rg|
        desc "Run specs with Rubygems #{rg}"
        RSpec::Core::RakeTask.new(rg) do |t|
          t.rspec_opts = %w(-fs --color)
          t.ruby_opts  = %w(-w)
        end

        task "clone_rubygems_#{rg}" do
          unless File.directory?("tmp/rubygems")
            system("git clone git://github.com/rubygems/rubygems.git tmp/rubygems")
          end
          system("cd tmp/rubygems && git checkout #{rg}")
          system("git pull") if rg == "master"
          ENV["RUBYOPT"] = "-I#{File.expand_path("tmp/rubygems/lib")} #{rubyopt}"
        end

        task rg => "clone_rubygems_#{rg}"
        task "rubygems:all" => rg
      end
    end

    namespace :ruby do
      # Ruby 1.8.6, 1.8.7, and 1.9.2 specs
      task "ensure_rvm" do
        raise "RVM is not available" unless File.exist?(File.expand_path("~/.rvm/scripts/rvm"))
      end

      %w(1.8.6-p399 1.8.7-p302 1.9.2-p0).each do |ruby|
        ruby_cmd = File.expand_path("~/.rvm/bin/ruby-#{ruby}")

        desc "Run specs on Ruby #{ruby}"
        RSpec::Core::RakeTask.new(ruby) do |t|
          t.rspec_opts = %w(-fs --color)
          t.ruby_opts  = %w(-w)
        end

        task "ensure_ruby_#{ruby}" do
          raise "Could not find Ruby #{ruby} at #{ruby_cmd}" unless File.exist?(ruby_cmd)
        end

        task "ensure_ruby_#{ruby}" => "ensure_rvm"
        task ruby => "ensure_ruby_#{ruby}"
        task "ruby:all" => ruby
      end
    end

  end

rescue LoadError
  task :spec do
    abort "Run `rake spec:deps` to be able to run the specs"
  end

  namespace :spec do
    desc "Ensure spec dependencies are installed"
    task :deps do
      sh "gem list ronn | (grep 'ronn' 1> /dev/null) || gem install ronn --no-ri --no-rdoc"
      sh "gem list rspec | (grep 'rspec (2.0' 1> /dev/null) || gem install rspec --no-ri --no-rdoc"
    end
  end

end

namespace :man do
  directory "lib/ingredient/man"

  Dir["man/*.ronn"].each do |ronn|
    basename = File.basename(ronn, ".ronn")
    roff = "lib/ingredient/man/#{basename}"

    file roff => ["lib/ingredient/man", ronn] do
      sh "ronn --roff --pipe #{ronn} > #{roff}"
    end

    file "#{roff}.txt" => roff do
      sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
    end

    task :build_all_pages => "#{roff}.txt"
  end

  desc "Build the man pages"
  task :build => "man:build_all_pages"

  desc "Clean up from the built man pages"
  task :clean do
    rm_rf "lib/ingredient/man"
  end
end

namespace :vendor do
  desc "Build the vendor dir"
  task :build => :clean do
    sh "git clone git://github.com/wycats/thor.git lib/ingredient/vendor/tmp"
    sh "mv lib/ingredient/vendor/tmp/lib/* lib/ingredient/vendor/"
    rm_rf "lib/ingredient/vendor/tmp"
  end

  desc "Clean the vendor dir"
  task :clean do
    rm_rf "lib/ingredient/vendor"
  end
end

task :default => :spec
