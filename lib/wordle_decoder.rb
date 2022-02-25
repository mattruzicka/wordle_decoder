# frozen_string_literal: true

require "cli/ui"

require_relative "wordle_decoder/version"
require_relative "wordle_decoder/game_guess"
require_relative "wordle_decoder/word"
require_relative "wordle_decoder/word_position"
require_relative "wordle_decoder/word_search"

class WordleDecoder
  class Error < StandardError; end

  def initialize(answer_str, hint_str)
    @answer_str = answer_str
    @word_positions = initialize_word_positions(answer_str, hint_str)
  end

  attr_reader :word_positions

  def best_guess
    game_guess = game_guesses.max_by(&:score)
    best_guess = +"\n  {{underline:GUESSES}}   {{underline:CONFIDENCE SCORE}}\n\n"
    game_guess.best_words_with_scores_2d_array.each do |best_word, confidence_score|
      best_guess << "  #{best_word}     #{confidence_score}\n"
    end
    best_guess << "  {{green:#{@answer_str}}}\n\n"
    puts CLI::UI.fmt(best_guess)
  end

  def game_guesses
    first_word_position, *remaining_positions = word_positions
    first_word_position.words.map do |start_word|
      GameGuess.new(start_word, remaining_positions)
    end
  end

  def searched_words
    stats = +"\n  {{green:#{@answer_str}}}\n"
    word_positions.each do |word_position|
      words = word_position.words
      stats << "  #{words.join(", ")}\n"
    end
    puts CLI::UI.fmt(stats)
  end

  private

  def initialize_word_positions(answer_str, hint_str)
    answer_str = answer_str.downcase
    hint_str = hint_str.downcase
    answer_chars = answer_str.split("")
    hint_lines = normalize_hint_lines(hint_str)
    hint_lines.map { |line| WordPosition.new(line, answer_chars) }
  end

  ANSWER_LINES = ["ggggg", "🟩🟩🟩🟩🟩"].freeze

  def normalize_hint_lines(hint_str)
    hint_lines = normalize_hint_lines_array(hint_str)
    validate_hint_lines!(hint_lines)
    hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
    hint_lines.reverse!
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

    raise Error.new("The entered wordle hints are invalid")
  end
end
