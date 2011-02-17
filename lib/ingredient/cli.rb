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

    default_task :install
    class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
    class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"

    def help(cli = nil)
      case cli
      when nil       then command = "ingredient"
      else command = "ingredient-#{cli}"
      end

      manpages = %w(
          ingredient
          ingredient-avail
          ingredient-load
          ingredient-list)

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

  private
    def have_groff?
      !(`which groff` rescue '').empty?
    end
  end
end
