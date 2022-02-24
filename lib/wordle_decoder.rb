# frozen_string_literal: true

require_relative "wordle_decoder/version"
require_relative "wordle_decoder/word_guess"
require_relative "wordle_decoder/word"

class WordleDecoder
  class Error < StandardError; end

  def initialize(answer_string, hint_string)
    @word_guesses = initialize_word_guesses(answer_string, hint_string)
  end

  attr_reader :word_guesses

  def words
    @word_guesses.map(&:to_s)
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
