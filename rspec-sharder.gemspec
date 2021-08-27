# frozen_string_literal: true

require_relative "lib/rspec-sharder/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-sharder"
  spec.version       = RSpec::Sharder::VERSION
  spec.authors       = ["Nick Dower"]
  spec.email         = ["nicholasdower@gmail.com"]

  spec.summary       = "A utility which shards specs."
  spec.description   = "A utility which shards specs."
  spec.homepage      = "https://github.com/nicholasdower/rspec-sharder"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nicholasdower/rspec-sharder"
  spec.metadata["changelog_uri"] = "https://github.com/nicholasdower/rspec-sharder/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   << 'rspec-sharder'
  spec.require_paths = ["lib"]

  spec.add_dependency 'rspec-core'
end
