# frozen_string_literal: true

require_relative "lib/dead_code_terminator/version"

Gem::Specification.new do |spec|
  spec.name          = "dead_code_terminator"
  spec.version       = DeadCodeTerminator::VERSION
  spec.authors       = ["Vlad Bokov"]
  spec.email         = ["vlad@razum2um.me"]

  spec.summary       = "Remove dead conditional branches"
  spec.description   = "Statically remove dead conditional branches, acts like webpack's DefinePlugin and minifier"
  spec.homepage      = "https://github.com/razum2um/dead_code_terminator"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/razum2um/dead_code_terminator"
  spec.metadata["changelog_uri"] = "https://github.com/razum2um/dead_code_terminator"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "parser", ">= 2.5.0.0"
end
