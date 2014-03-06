# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'huemote/version'

Gem::Specification.new do |spec|
  spec.name          = "huemote"
  spec.version       = Huemote::VERSION
  spec.authors       = ["Kevin Gisi"]
  spec.email         = ["kevin@kevingisi.com"]
  spec.description   = %q{Huemote is a Ruby gem for managing Philips Hue lights}
  spec.summary       = %q{Huemote is a Ruby gem for managing Philips Hue lights}
  spec.homepage      = "https://github.com/gisikw/huemote"
  spec.license       = "MIT"
  spec.platform      = 'ruby'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
