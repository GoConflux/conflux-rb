# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conflux/version'

Gem::Specification.new do |spec|
  spec.name          = "conflux"
  spec.version       = Conflux::VERSION
  spec.authors       = ["Ben Whittle"]
  spec.email         = ["benwhittle31@gmail.com"]
  spec.summary       = "Gem to fetch and make available Conflux configs on Rails boot."
  spec.homepage      = "https://www.github.com/GoConflux/conflux-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"

  spec.add_development_dependency "rails", "~> 4.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end