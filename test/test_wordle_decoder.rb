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
    assert share.hint_lines == ["⬛⬛🟨⬛🟨", "⬛🟩🟩🟩⬛"]
  end
end
