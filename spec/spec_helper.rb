# frozen_string_literal: true

require "simplecov"
SimpleCov.start

if ENV["CI"] && ENV["CODECOV_TOKEN"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "dead_code_terminator"
require "parser/current"
require "pry-byebug" unless ENV["CI"]

RSpec::Matchers.define :be_valid_ruby_code do
  match do |str|
    Parser::CurrentRuby.parse(str)
    true
  rescue Parser::SyntaxError
    false
  end

  failure_message do |str|
    "Expected #{str.inspect} to be valid Ruby code"
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
