# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

require "./lib/wordle_decoder/word_search"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

task :create_word_search_files do
  sorted_words = load_words_sorted_by_frequency
  most_common_words = sorted_words.pop(3_000)
  most_common_words, less_common_words = most_common_words.partition { |r| r.split("").uniq.count == 5 }
  File.write(lib_path("most_common_words.txt"), most_common_words.join("\n"))
  File.write(lib_path("less_common_words.txt"), less_common_words.join("\n"))
  File.write(lib_path("least_common_words.txt"), sorted_words.join("\n"))
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

def load_words_sorted_by_frequency
  file_path = lib_path("words_to_frequency_score.json")
  if File.exist?(file_path)
    WordleDecoder::WordSearch.words_to_frequency_score_hash.keys
  else
    File.write(file_path, build_words_to_frequency_score_hash.to_json)
    build_words_to_frequency_score_hash.keys
  end
end

def build_words_to_frequency_score_hash
  words_by_freq_hash = JSON.parse(read_file("word_frequencies.json")).sort_by { _2 }
  words_by_freq_hash.each_with_index { |array, index| array[1] = index / 100_000.to_f }
  words_by_freq_hash.to_h
end

def load_wordle_words(file_name)
  read_file(file_name).split("\n")
end

def read_file(file_name)
  file_path = File.join(File.dirname(__FILE__), file_name)
  File.read(file_path)
end

def lib_path(file_name)
  File.join(File.dirname(__FILE__), "lib", file_name)
end
