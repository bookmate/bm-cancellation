# frozen_string_literal: true

require_relative 'lib/bm/cancellation/version'

Gem::Specification.new do |spec|
  spec.name          = 'bm-cancellation'
  spec.version       = BM::Cancellation::VERSION
  spec.authors       = ['Dmitry Galinsky']
  spec.email         = ['dima@bookmate.com']

  spec.summary       = 'Provides tools for cooperative cancellation'
  spec.homepage      = 'https://github.com/bookmate/bm-cancellation'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://nexus.bookmate.services/repository/bookmate/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{\A(?:test|spec|features|benches|examples)/}) }
      .reject { |f| f.match(/\A(?:CODE_OF_CONDUCT|Gemfile|Rakefile)/) }
      .reject { |f| f.match(/\A\./) }
  end

  spec.extensions    = spec.files.grep(%r{/extconf\.rb\Z})
  spec.require_paths = ['lib']
end
