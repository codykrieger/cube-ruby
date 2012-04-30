# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cube/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Cody Krieger"]
  gem.email         = ["cody@codykrieger.com"]
  gem.description   = %q{A Cube client for Ruby (https://square.github.com/cube).}
  gem.summary       = %q{A Cube client for Ruby (https://square.github.com/cube).}
  gem.homepage      = "https://github.com/codykrieger/cube-ruby"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cube-ruby"
  gem.require_paths = ["lib"]
  gem.version       = Cube::VERSION

  gem.add_development_dependency "minitest"
end
