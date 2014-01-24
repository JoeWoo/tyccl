# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tyccl/version'

Gem::Specification.new do |spec|
  spec.name          = "tyccl"
  spec.version       = Tyccl::VERSION
  spec.authors       = ["JoeWoo"]
  spec.email         = ["0wujian0@gmail.com"]
  spec.summary       = %q{"tools of analysing similarity between Chinese Words."}
  spec.description   = %q{"tyccl(同义词词林 哈工大扩展版) is a ruby gem that provides friendly functions to analyse similarity between Chinese Words."}
  spec.homepage      = "https://github.com/JoeWoo/tyccl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
