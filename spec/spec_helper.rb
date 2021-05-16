# frozen_string_literal: true

require 'bundler/setup'

require_relative 'support/simplecov_start' unless ENV.fetch('SIMPLECOV', '').empty?

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require_relative 'support/shared_examples'
