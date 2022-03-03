# frozen_string_literal: true

require "cli/ui"

require_relative "wordle_decoder/version"
require_relative "wordle_decoder/word_search"
require_relative "wordle_decoder/word_position"
require_relative "wordle_decoder/word"
require_relative "wordle_decoder/guess"

class WordleDecoder
  class Error < StandardError; end

  def initialize(answer_str, hint_str)
    @answer_str = answer_str
    @hint_str = hint_str
    @word_positions = initialize_word_positions(answer_str, hint_str)
    validate_word_positions!
  end

  attr_reader :answer_str,
              :hint_str,
              :word_positions

  def to_terminal
    str = +"\n  {{underline:GUESSES}}   {{underline:CONFIDENCE SCORE}}\n\n"
    best_guess.words_with_scores.reverse_each do |word, guess_score|
      str << "  #{word.to_terminal}     #{word.confidence_score(guess_score)}\n"
    end
    str << "  {{green:#{answer_str}}}\n\n"
    CLI::UI.fmt(str)
  end

  def best_guess
    @best_guess ||= guesses.first
  end

  def guesses
    @guesses ||= initialize_and_sort_guesses
  end


  def inspect
    lines = ["<#{self.class.name} answer_str: #{answer_str}, hint_str: #{hint_str.inspect}"]
    lines.concat guesses.map(&:inspect)
    lines.last << ">"
    lines.join("\n")
  end

  private

  def initialize_and_sort_guesses
    first_word_position, *remaining_positions = word_positions.reverse
    guesses = first_word_position.words.map do |start_word|
      Guess.new(start_word, first_word_position, remaining_positions)
    end
    guesses.sort_by!(&:score)
    guesses.reverse!
    guesses
  end

  def initialize_word_positions(answer_str, hint_str)
    answer_str = answer_str.downcase
    hint_str = hint_str.downcase
    answer_chars = answer_str.split("")
    hint_lines = normalize_hint_lines(hint_str)
    hint_lines.map.with_index { |line, index| WordPosition.new(line, index, answer_chars) }
  end

  ANSWER_LINES = ["ggggg", "🟩🟩🟩🟩🟩"].freeze

  def normalize_hint_lines(hint_str)
    hint_lines = normalize_hint_lines_array(hint_str)
    validate_hint_lines!(hint_lines)
    hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
    hint_lines
  end

  def normalize_hint_lines_array(hint_str)
    return hint_str unless hint_str.is_a?(String)

    if hint_str.include?("\n")
      hint_str.split("\n")
    else
      hint_str.chars.each_slice(5).map(&:join)
    end
  end

  def validate_hint_lines!(hint_lines)
    return if hint_lines.is_a?(Array) && hint_lines.all? { |line| line.length == 5 }

    raise Error.new("The wordle share that you entered appears invalid")
  end

  def validate_word_positions!
    word_positions.map(&:words)
    return unless word_positions.any? { |wp| wp.words.empty? }

    raise Error.new("The wordle share that you entered appears made up")
  end
end
