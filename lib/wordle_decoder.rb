# frozen_string_literal: true

require_relative "wordle_decoder/version"
require_relative "wordle_decoder/word_guess"
require_relative "wordle_decoder/word"

class WordleDecoder
  class Error < StandardError; end

  def initialize(answer_string, hint_string)
    @answer_string = answer_string
    @word_guesses = initialize_word_guesses(answer_string, hint_string)
  end

  attr_reader :word_guesses

  # TODO: rewards words that have yellow letters that match green letters in later words
  # TODO: reward guess words that have letters that were yellow in previous words in different indexes.
  # TODO: remove guess words that gave the same yellow letters at the same indexes
  # TODO: remove guesses that have missed letters that must overlap with a guess from a previous row

  def gues ses
    last_line_green_letter = []
    word_guesses.each do |guess|
    end
  end

  def guess_stats
    stats = +"\n#{@answer_string.rjust(16)}\n"
    word_guesses.each do |word_guess|
      words = word_guess.guessable_words
      stats << " #{word_guess.guessable_score.to_s.ljust(2)} | #{words.count.to_s.ljust(2)} | #{words.join(", ")}\n"
    end
    puts stats
  end

  private

  def initialize_word_guesses(answer_string, hint_string)
    answer_string = answer_string.downcase
    hint_string = hint_string.downcase
    answer_chars = answer_string.split("")
    hint_lines = normalize_hint_lines(hint_string)
    hint_lines.map { |line| WordGuess.new(line, answer_chars) }
  end

  ANSWER_LINES = ["ggggg", "🟩🟩🟩🟩🟩"].freeze

  def normalize_hint_lines(hint_string)
    hint_lines = hint_string.split("\n")
    hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
    hint_lines.reverse!
  end
end
