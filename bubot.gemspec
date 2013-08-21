# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bubot/version'

Gem::Specification.new do |spec|
  spec.name          = "bubot"
  spec.version       = Bubot::VERSION
  spec.authors       = ["Micah Cooper", "Micah Woods"]
  spec.email         = ["mrmicahcooper@gmail.com", "micahwoods@gmail.com"]
  spec.description   = %q{Take action when methods take too long}
  spec.summary       = %q{Take action when methods take too long}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "pry"
end
