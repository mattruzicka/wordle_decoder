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
  common_words = create_word_frequencies_file_and_return_sorted_wordle_words
  least_common_words = common_words.slice!(3000..-1)
  most_common_words, less_common_words = common_words.partition { |r| r.split("").uniq.count == 5 }
  File.write(lib_path("most_common_words.txt"), most_common_words.join("\n"))
  File.write(lib_path("less_common_words.txt"), less_common_words.join("\n"))
  File.write(lib_path("least_common_words.txt"), least_common_words.join("\n"))
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

def create_word_frequencies_file_and_return_sorted_wordle_words
  wordle_words = load_wordle_words("allowed_answers.txt")
  wordle_words.concat load_wordle_words("allowed_guesses.txt")
  frequency_file_name = "word_frequencies.txt"

  require "csv"
  word_frequencies = load_five_letter_word_frequencies
  wordle_words.sort_by! { |w| word_frequencies[w].to_i }
  wordle_words.reverse!
  word_frequencies_txt = +""
  wordle_words.each do |word|
    frequency = word_frequencies[word].to_i
    word_frequencies_txt << "#{word},#{frequency}\n"
  end
  File.write(lib_path(frequency_file_name), word_frequencies_txt)
  wordle_words
end

def load_five_letter_word_frequencies
  frequencies = {}
  CSV.foreach("unigram_freq.csv") { |r| frequencies[r[0]] = r[1] if r[0].length == 5 }
  frequencies
end

def load_wordle_words(file_name)
  file_path = File.join(File.dirname(__FILE__), file_name)
  File.read(file_path).split("\n")
end

def lib_path(file_name)
  File.join(File.dirname(__FILE__), "lib", file_name)
end
