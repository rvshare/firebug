# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebug/version'

Gem::Specification.new do |spec| # rubocop:disable BlockLength
  spec.name          = 'firebug'
  spec.version       = Firebug::VERSION
  spec.authors       = ['Aaron Frase']
  spec.email         = ['aaron@rvshare.com']

  spec.summary       = 'Gem for working with CodeIgniter sessions'
  spec.description   = 'Gem for working with CodeIgniter sessions'
  spec.homepage      = 'https://github.com/rvshare/firebug'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '~> 5.0'
  spec.add_dependency 'activerecord', '~> 5.0'
  spec.add_dependency 'ruby-mcrypt', '~> 0.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
