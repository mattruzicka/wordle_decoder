# frozen_string_literal: true

require "test_helper"
require 'debug'

class TestWordleDecoder < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::WordleDecoder::VERSION
  end

  def test_that_a_wordle_share_can_be_initialized_with_string_input_and_answer
    string_input = "Wordle 258 3/6\n\nā¬ā¬šØā¬šØ\nā¬š©š©š©ā¬\nš©š©š©š©š©"
    share = WordleDecoder::WordleShare.new(string_input, "ahead")
    assert share.answer_chars == %w[a h e a d]
    assert share.hint_lines == ["ā¬ā¬šØā¬šØ", "ā¬š©š©š©ā¬"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_array_input_and_answer
    array_input = ["Wordle 258 3/6\n", "\n", "ā¬ā¬šØā¬šØ\n", "ā¬š©š©š©ā¬\n", "š©š©š©š©š©\n"]
    share = WordleDecoder::WordleShare.new(array_input, "ahead")
    assert share.answer_chars == %w[a h e a d]
    assert share.hint_lines == ["ā¬ā¬šØā¬šØ", "ā¬š©š©š©ā¬"]
  end

  def test_that_the_wordle_share_can_find_the_answer_from_the_string_input
    string_input = "Wordle 258 3/6\n\nā¬ā¬šØā¬šØ\nā¬š©š©š©ā¬\nš©š©š©š©š©"
    share = WordleDecoder::WordleShare.new(string_input)
    share.find_answer
    assert share.answer_chars == %w[a h e a d]
  end

  def test_that_the_wordle_share_can_find_the_answer_from_the_array_input
    array_input = ["Wordle 258 3/6\n", "\n", "ā¬ā¬šØā¬šØ\n", "ā¬š©š©š©ā¬\n", "š©š©š©š©š©\n"]
    share = WordleDecoder::WordleShare.new(array_input)
    share.find_answer
    assert share.answer_chars == %w[a h e a d]
  end

  def test_that_a_wordle_share_can_be_initialized_with_a_string_of_emoji_shortcodes
    string_input = "Wordle 258 3/6
    :black_large_square::black_large_square::large_yellow_square::black_large_square::large_yellow_square:
    :black_large_square::large_green_square::large_green_square::large_green_square::black_large_square:
    :large_green_square::large_green_square::large_green_square::large_green_square::large_green_square:"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["ā¬ā¬šØā¬šØ", "ā¬š©š©š©ā¬"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_high_contrast_mode_string
    string_input = "Wordle 273 4/6\n\nā¬ā¬ā¬ā¬ā¬\nā¬š¦ā¬ā¬ā¬\nā¬ā¬š§š§š§\nš§š§š§š§š§"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["ā¬ā¬ā¬ā¬ā¬", "ā¬š¦ā¬ā¬ā¬", "ā¬ā¬š§š§š§"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_high_contrast_mode_string_of_emoji_shortcodes
    string_input = "Wordle 273 4/6
    :black_large_square::black_large_square::black_large_square::black_large_square::black_large_square:
    :black_large_square::large_blue_square::black_large_square::black_large_square::black_large_square:
    :black_large_square::black_large_square::large_orange_square::large_orange_square::large_orange_square:
    :large_orange_square::large_orange_square::large_orange_square::large_orange_square::large_orange_square:"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["ā¬ā¬ā¬ā¬ā¬", "ā¬š¦ā¬ā¬ā¬", "ā¬ā¬š§š§š§"]
  end

  def test_that_weird_nonspacing_chars_in_share_strings_are_handled
    string_input = "Wordle 260 5/6*\n\nā¬ļøā¬ļøā¬ļøā¬ļøā¬ļø\nā¬ļøš©ā¬ļøā¬ļøā¬ļø\nā¬ļøš©š©šØā¬ļø\nš©š©š©ā¬ļøā¬ļø\nš©š©š©š©š©"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["ā¬ā¬ā¬ā¬ā¬", "ā¬š©ā¬ā¬ā¬", "ā¬š©š©šØā¬", "š©š©š©ā¬ā¬"]
  end

  def test_that_weird_nonspacing_chars_in_the_final_input_line_are_handled
    weird_final_input_line = ([129001, 65039] * 5).pack("U*")
    assert WordleDecoder::WordleShare.final_line?(weird_final_input_line)
  end

  def test_case_where_guess_contains_two_of_same_letter_which_appears_once_in_answer
    string_input = "šØšØšØā¬ā¬\nš©š©ā¬šØšØ\nš©š©ā¬š©ā¬\nš©š©š©š©š©"
    share = WordleDecoder::WordleShare.new(string_input, "lapse")
    assert share.decoder.best_guess
  end

  def test_that_it_works_when_the_answer_contains_an_x
    string_input = "ā¬ā¬ā¬ā¬ā¬\nšØā¬ā¬šØā¬\nā¬ā¬šØā¬ā¬\nā¬šØā¬ā¬ā¬\nš©š©š©š©š©"
    share = WordleDecoder::WordleShare.new(string_input, "epoxy")
    assert share.decoder.best_guess
  end
end
