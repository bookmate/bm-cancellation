# frozen_string_literal: true

require 'bundler/setup'

require_relative 'setup/simplecov'
require_relative 'setup/rspec_formatters'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require_relative 'support/shared_examples'
