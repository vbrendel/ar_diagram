$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ar_diagram/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ar_diagram"
  s.version     = ArDiagram::VERSION
  s.authors     = ["David Monagle"]
  s.email       = ["david.monagle@intrica.com.au"]
  s.homepage    = "http://www.intrica.com.au"
  s.summary     = "Database diagram tool for ActiveRecord on Rails."
  s.description = "Allows you to create graphical database diagrams of your ActiveRecord models from within your rails app."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "jquery-rails"
  s.add_dependency 'bootstrap-sass-rails'
  s.add_dependency 'font-awesome-sass-rails'
  s.add_dependency 'twitter_bootstrap_helper'
  s.add_dependency 'compass-rails'

  s.add_development_dependency "sqlite3"
end
