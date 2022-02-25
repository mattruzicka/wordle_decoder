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
    best_guess = +"  "
    best_guess << game_guess.best_words.join("\n  ")
    best_guess << +"\n  #{colorize_answer}\n"

    puts CLI::UI.fmt(best_guess)
  end

  def game_guesses
    first_word_position, *remaining_positions = word_positions
    first_word_position.words.map do |start_word|
      GameGuess.new(start_word, remaining_positions)
    end
  end

  def guess_stats
    stats = +"\n#{colorize_answer(@answer_str.rjust(16))}\n"
    word_positions.each do |word_position|
      words = word_position.words
      stats << " #{word_position.guessable_score.to_s.ljust(2)} | #{words.count.to_s.ljust(2)} | #{words.join(", ")}\n"
    end
    puts CLI::UI.fmt(stats)
  end

  private

  def colorize_answer(text = nil)
    "{{green:#{text || @answer_str}}}"
  end

  def initialize_word_positions(answer_str, hint_str)
    answer_str = answer_str.downcase
    hint_str = hint_str.downcase
    answer_chars = answer_str.split("")
    hint_lines = normalize_hint_lines(hint_str)
    hint_lines.map { |line| WordPosition.new(line, answer_chars) }
  end

  ANSWER_LINES = ["ggggg", "🟩🟩🟩🟩🟩"].freeze

  def normalize_hint_lines(hint_str)
    hint_lines = hint_str.split("\n")
    hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
    hint_lines.reverse!
  end
end
