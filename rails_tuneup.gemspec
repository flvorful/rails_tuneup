$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_tuneup/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name          = "rails_tuneup"
  spec.version       = RailsTuneup::VERSION
  spec.authors       = ["jake varghese", "FiveRuns Team"]
  spec.email         = ["jake3030@gmail.com"]
  spec.description   = %q{Rails 3.2+ port of FiveRuns awesome Tuneup panel}
  spec.summary       = %q{Rails 3.2+ port of FiveRuns awesome Tuneup panel}
  spec.homepage      = "http://github.com/flvorful/rails_tuneup"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "rails", "~> 3.2.10"

  spec.add_development_dependency "mysql2"
end
