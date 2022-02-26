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

task :create_word_search_files do
  allowed_answers = load_wordle_words("allowed_answers.txt")
  most_common_words, less_common_words = allowed_answers.partition { |r| r.split("").uniq.count == 5 }
  most_common_words_path = common_words_path("most_common_words.txt")
  File.write(most_common_words_path, most_common_words.join("\n"))
  less_common_words_path = common_words_path("less_common_words.txt")
  File.write(less_common_words_path, less_common_words.join("\n"))
  least_common_words_path = common_words_path("least_common_words.txt")
  least_common_words = load_wordle_words("allowed_guesses.txt")
  File.write(least_common_words_path, least_common_words.join("\n"))
end

task :output_most_common_letters do
  words = load_wordle_words("allowed_answers.txt")
  words.concat load_wordle_words("allowed_guesses.txt")
  letter_count_tally = words.flat_map { _1.split("") }.tally
  letter_count_tally = letter_count_tally.sort_by { -_2 }
  puts letter_count_tally.first(10).map { _1.first }.join(" ")
end

task :output_most_common_letters_by_word_count do
  words = load_wordle_words("allowed_answers.txt")
  words.concat load_wordle_words("allowed_guesses.txt")
  word_count_tally = ("a".."z").map { |l| [l, words.count { |word| word.include?(l) }] }
  word_count_tally = word_count_tally.sort_by { -_2 }
  puts word_count_tally.first(10).map { _1.first }.join(" ")
end

def load_wordle_words(file_name)
  file_path = File.join(File.dirname(__FILE__), file_name)
  File.read(file_path).split("\n")
end

def common_words_path(file_name)
  File.join(File.dirname(__FILE__), "lib", file_name)
end
