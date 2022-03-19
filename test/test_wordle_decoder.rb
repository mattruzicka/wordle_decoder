# frozen_string_literal: true

require "test_helper"

class TestWordleDecoder < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::WordleDecoder::VERSION
  end

  def test_that_a_wordle_share_can_be_initialized_with_string_input_and_answer
    string_input = "Wordle 258 3/6\n\n⬛⬛🟨⬛🟨\n⬛🟩🟩🟩⬛\n🟩🟩🟩🟩🟩"
    share = WordleDecoder::WordleShare.new(string_input, "ahead")
    assert share.answer_chars == %w[a h e a d]
    assert share.hint_lines == ["⬛⬛🟨⬛🟨", "⬛🟩🟩🟩⬛"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_array_input_and_answer
    array_input = ["Wordle 258 3/6\n", "\n", "⬛⬛🟨⬛🟨\n", "⬛🟩🟩🟩⬛\n", "🟩🟩🟩🟩🟩\n"]
    share = WordleDecoder::WordleShare.new(array_input, "ahead")
    assert share.answer_chars == %w[a h e a d]
    assert share.hint_lines == ["⬛⬛🟨⬛🟨", "⬛🟩🟩🟩⬛"]
  end

  def test_that_the_wordle_share_can_find_the_answer_from_the_string_input
    string_input = "Wordle 258 3/6\n\n⬛⬛🟨⬛🟨\n⬛🟩🟩🟩⬛\n🟩🟩🟩🟩🟩"
    share = WordleDecoder::WordleShare.new(string_input)
    share.find_answer
    assert share.answer_chars == %w[a h e a d]
  end

  def test_that_the_wordle_share_can_find_the_answer_from_the_array_input
    array_input = ["Wordle 258 3/6\n", "\n", "⬛⬛🟨⬛🟨\n", "⬛🟩🟩🟩⬛\n", "🟩🟩🟩🟩🟩\n"]
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
    assert share.hint_lines == ["⬛⬛🟨⬛🟨", "⬛🟩🟩🟩⬛"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_high_contrast_mode_string
    string_input = "Wordle 273 4/6\n\n⬛⬛⬛⬛⬛\n⬛🟦⬛⬛⬛\n⬛⬛🟧🟧🟧\n🟧🟧🟧🟧🟧"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["⬛⬛⬛⬛⬛", "⬛🟦⬛⬛⬛", "⬛⬛🟧🟧🟧"]
  end

  def test_that_a_wordle_share_can_be_initialized_with_high_contrast_mode_string_of_emoji_shortcodes
    string_input = "Wordle 273 4/6
    :black_large_square::black_large_square::black_large_square::black_large_square::black_large_square:
    :black_large_square::large_blue_square::black_large_square::black_large_square::black_large_square:
    :black_large_square::black_large_square::large_orange_square::large_orange_square::large_orange_square:
    :large_orange_square::large_orange_square::large_orange_square::large_orange_square::large_orange_square:"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["⬛⬛⬛⬛⬛", "⬛🟦⬛⬛⬛", "⬛⬛🟧🟧🟧"]
  end

  def test_that_weird_nonspacing_chars_in_share_strings_are_handled
    string_input = "Wordle 260 5/6*\n\n⬛️⬛️⬛️⬛️⬛️\n⬛️🟩⬛️⬛️⬛️\n⬛️🟩🟩🟨⬛️\n🟩🟩🟩⬛️⬛️\n🟩🟩🟩🟩🟩"
    share = WordleDecoder::WordleShare.new(string_input)
    assert share.hint_lines == ["⬛⬛⬛⬛⬛", "⬛🟩⬛⬛⬛", "⬛🟩🟩🟨⬛", "🟩🟩🟩⬛⬛"]
  end

  def test_that_weird_nonspacing_chars_in_the_final_input_line_are_handled
    weird_final_input_line = ([129001, 65039] * 5).pack("U*")
    assert WordleDecoder::WordleShare.final_line?(weird_final_input_line)
  end
end
