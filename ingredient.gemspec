lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ingredient/version'

Gem::Specification.new do |s|
  s.name        = "ingredient"
  s.version     = Ingredient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jon Bringhurst"]
  s.email       = ["jonb@lanl.gov"]
  s.summary     = %q{An environment configuration and testing utility}
  s.description = %q{Ingredient manages a user's environment and testing through ingredient files. Ingredient files contain information on how to test and configure the user's environment for each software package}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ingredient"

  s.add_development_dependency "ronn"
  s.add_development_dependency "rspec"

  # Man files are required because they are ignored by git
  man_files            = Dir.glob("lib/ingredient/man/**/*")
  s.files              = `git ls-files`.split("\n") + man_files
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = %w(ingredient)
  s.default_executable = "ingredient"
  s.require_paths      = ["lib"]
end
