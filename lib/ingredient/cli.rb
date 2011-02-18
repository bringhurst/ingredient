require 'thor'
require 'thor/actions'
require 'rubygems/user_interaction'
require 'rubygems/config_file'

module Ingredient
  class CLI < Thor
    include Thor::Actions

    def initialize(*)
      super
      the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
      Ingredient.ui = UI::Shell.new(the_shell)
      Ingredient.ui.debug! if options["verbose"]
      Gem::DefaultUserInteraction.ui = UI::RGProxy.new(Ingredient.ui)
    end

    check_unknown_options! unless ARGV.include?("exec") || ARGV.include?("config")

    default_task :help

    class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
    class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"

    def help(cli = nil)
      case cli
      when nil       then command = "ingredient"
      else command = "ingredient-#{cli}"
      end

      manpages = %w(ingredient)

      if manpages.include?(command)
        root = File.expand_path("../man", __FILE__)

        if have_groff? && root !~ %r{^file:/.+!/META-INF/jruby.home/.+}
          groff   = "groff -Wall -mtty-char -mandoc -Tascii"
          pager   = ENV['MANPAGER'] || ENV['PAGER'] || 'less'

          Kernel.exec "#{groff} #{root}/#{command} | #{pager}"
        else
          puts File.read("#{root}/#{command}.txt")
        end
      else
        super
      end
    end

    desc "avail", "List the ingredients available for loading"
    long_desc <<-D
      Avail will list all of the ingredients available to the current user. Each
      ingredient is listed in the order it has been placed in the ingredients directory
      structure unless options have been specified to display them in a different format.
     
      Ingredients that are currently loaded will be marked as such.
    D
    method_option "short", :type => :boolean, :banner =>
      "Display the available ingredients in a shorter format."
    method_option "long", :type => :boolean, :banner =>
      "Display the available ingredients in a longer format."
    def avail
        Ingredient.ui.error "List available ingredients here"
        exit 1
    end

    desc "load", "Load the specified ingredient"
    long_desc <<-D
      Avail will list all of the ingredients available to the current user. Each
      ingredient is listed in the order it has been placed in the ingredients directory
      structure unless options have been specified to display them in a different format.

      Ingredients that are currently loaded will be marked as such.
    D
    def load
        Ingredient.ui.error "Load the specified ingredient"
        exit 1
    end

    desc "taste", "Taste the specified ingredient"
    long_desc <<-D
      Avail will list all of the ingredients available to the current user. Each
      ingredient is listed in the order it has been placed in the ingredients directory
      structure unless options have been specified to display them in a different format.

      Ingredients that are currently loaded will be marked as such.
    D
    def taste
        Ingredient.ui.error "Taste the specified ingredient"
        exit 1
    end

    desc "nom", "Nom the specified ingredient"
    long_desc <<-D
      Avail will list all of the ingredients available to the current user. Each
      ingredient is listed in the order it has been placed in the ingredients directory
      structure unless options have been specified to display them in a different format.

      Ingredients that are currently loaded will be marked as such.
    D
    def nom
        Ingredient.ui.error "Nom the specified ingredient"
        exit 1
    end

    desc "mix", "Mix the specified ingredient"
    long_desc <<-D
      Avail will list all of the ingredients available to the current user. Each
      ingredient is listed in the order it has been placed in the ingredients directory
      structure unless options have been specified to display them in a different format.

      Ingredients that are currently loaded will be marked as such.
    D
    def mix
        Ingredient.ui.error "Mix the specified ingredient"
        exit 1
    end

  private
    def have_groff?
      !(`which groff` rescue '').empty?
    end
  end
end
