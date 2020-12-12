$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "querylet_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "querylet-rails"
  s.version     = QueryletRails::VERSION
  s.authors     = ["TeacherSeat"]
  s.email       = ["andrew@teacherseat.com"]
  s.homepage    = "https://teacherseat.com"
  s.summary     = 'Querylet Rails'
  s.description = 'Querylet Rails'
  s.license     = "MIT"

  s.files = Dir["{lib}/**/**/*", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'querylet'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
end

