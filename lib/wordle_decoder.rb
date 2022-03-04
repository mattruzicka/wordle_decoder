# frozen_string_literal: true

require_relative "wordle_decoder/version"
require_relative "wordle_decoder/word_search"
require_relative "wordle_decoder/word_position"
require_relative "wordle_decoder/word"
require_relative "wordle_decoder/guess"
require_relative "wordle_decoder/wordle_share"

class WordleDecoder
  class Error < StandardError; end

  def initialize(wordle_share)
    @wordle_share = wordle_share
  end

  def to_terminal
    @to_terminal ||= format_to_terminal
  end

  def best_guess
    @best_guess ||= guesses.first
  end

  def guesses
    @guesses ||= initialize_and_sort_guesses
  end

  def word_positions
    @word_positions ||= initialize_word_positions
  end

  def inspect
    lines = ["<#{self.class.name} "]
    lines << @wordle_share.inspect
    lines.concat guesses.map(&:inspect)
    lines.last << ">"
    lines.join("\n")
  end

  private

  def initialize_and_sort_guesses
    first_word_position, *remaining_positions = word_positions.reverse
    guesses = first_word_position.potential_words.map do |start_word|
      Guess.new(start_word, first_word_position, remaining_positions)
    end
    guesses.sort_by!(&:score)
    guesses.reverse!
    guesses
  end

  def initialize_word_positions
    @wordle_share.hint_lines.map.with_index do |line, index|
      WordPosition.new(line, index, @wordle_share.answer_chars)
    end
  end

  def format_to_terminal
    str = +"\n"
    best_guess.words_with_scores.reverse_each do |word, guess_score|
      str << "  #{word.to_terminal}        #{word.confidence_score(guess_score)}\n"
    end
    str << "  {{green:#{@wordle_share.answer_str}}}\n\n"
  end
end
