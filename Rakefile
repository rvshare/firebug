# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'firebug/version'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |task|
  task.options += ['--title', "Firebug #{Firebug::VERSION} Documentation"]
  task.options += ['--protected']
  task.options += ['--no-private']

  # has to be last
  extra_files = %w[CODE_OF_CONDUCT.md LICENSE.txt]
  task.options += ['-'] + extra_files
end

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end

task default: %i[rubocop spec]
