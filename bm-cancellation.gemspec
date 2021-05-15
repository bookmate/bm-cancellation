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

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.1'
end
