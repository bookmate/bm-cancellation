# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.options = %w[
    --markup markdown
    --markup-provider redcarpet
  ]
end

RuboCop::RakeTask.new :rubocop do |t|
  formatters = %w[--format progress --format RuboCop::Formatter::CheckstyleFormatter]
  requires = %w[--require rubocop/formatter/checkstyle_formatter]
  out = %w[--out spec/reports/checkstyle/rubocop.xml]
  t.options = requires + formatters + out
end

task default: %i[spec]

task ci: %i[rubocop spec]

task :examples do
  Dir['examples/*.rb'].each { sh "ruby #{_1}" }
end
