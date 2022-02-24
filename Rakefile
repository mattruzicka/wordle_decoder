# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]


task :create_decodable_words_file do
  # file_path = File.join(File.dirname(__FILE__), "allowed_answers.txt")
  # allowed_answers = File.read(file_path).split("\n")
  allowed_answers = load_wordle_words("allowed_answers.txt")
  decodable_words = allowed_answers.select { |r| r.split("").uniq.count == 5 }
  decodable_words.concat(load_wordle_words("common_guesses.txt"))
  decodable_words.sort!
  decodable_words_file_path = File.join(File.dirname(__FILE__), "lib", "decodable_words.txt")
  File.write(decodable_words_file_path, decodable_words.join("\n"))
end

def load_wordle_words(file_name)
  file_path = File.join(File.dirname(__FILE__), file_name)
  File.read(file_path).split("\n")
end
