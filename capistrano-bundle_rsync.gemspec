# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "capistrano-bundle_rsync"
  spec.version       = "0.5.2"
  spec.authors       = ["Naotoshi Seo", "tohae"]
  spec.email         = ["sonots@gmail.com", "tohaechan@gmail.com"]
  spec.description   = %q{Deploy an application and bundled gems via rsync}
  spec.summary       = %q{Deploy an application and bundled gems via rsync.}
  spec.homepage      = "https://github.com/sonots/capistrano-bundle_rsync"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', '>= 3.3.3'
  spec.add_dependency 'parallel'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3"
end
