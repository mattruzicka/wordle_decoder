# frozen_string_literal: true

require_relative "lib/wordle_decoder/version"

Gem::Specification.new do |spec|
  spec.name = "wordle_decoder"
  spec.version = WordleDecoder::VERSION
  spec.authors = ["Matt Ruzicka"]
  spec.license = "CC-BY-NC-SA-2.0"
  spec.summary = "A wordle decoder that guesses your guesses."
  spec.description = "Given your Wordle share text, with some degree of confidence," \
                     "the decoder will spit back the five-letter words it thinks you played."
  spec.homepage = "https://github.com/mattruzicka/wordle_decoder"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables << "wordle_decoder"
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "cli-ui", "~> 1.5"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
