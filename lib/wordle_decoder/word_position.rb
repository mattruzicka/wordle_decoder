# frozen_string_literal: true

class WordleDecoder
  class WordPosition
    def initialize(hint_line, answer_chars)
      @letter_positions = initialize_letter_positions(hint_line, answer_chars)
    end

    attr_reader :letter_positions

    def potential_words
      @potential_words ||= compute_potential_words
    end

    BASE_INCONFIDENCE = 0.05

    def guessable_score
      score = (100 * (1.0 / potential_words.count.to_f))
      (score - (score * BASE_INCONFIDENCE)).round
    end

    def green_letter_positions
      @green_letter_positions ||= select_letter_positions_by_hint("g")
    end

    def yellow_letter_positions
      @yellow_letter_positions ||= select_letter_positions_by_hint("y")
    end

    def black_letter_positions
      @black_letter_positions ||= select_letter_positions_by_hint("b")
    end

    private

    def compute_potential_words
      Word::COMMONALITY_OPTIONS.each do |commonality|
        words = compute_potential_words_from_hints(commonality) || Decoder.all
        return words if words.count == 1

        remove_not_potential_words(words, commonality)
        return words unless words.empty?
      end
    end

    def compute_potential_words_from_hints(commonality)
      words = nil
      [green_letter_positions, yellow_letter_positions].each do |letters|
        words = filter_by_potential_words(words, letters, commonality) if letters
      end
      words
    end

    def remove_not_potential_words(words, commonality)
      black_letter_positions&.each do |letter|
        words -= letter.not_potential_words(commonality)
      end
      words
    end

    def select_letter_positions_by_hint(hint_char)
      @letter_positions.select { |lg| lg.hint_char == hint_char }
    end

    def filter_by_potential_words(words, letters, commonality)
      letters.each do |letter|
        if words
          words &= letter.potential_words(commonality)
        else
          words = letter.potential_words(commonality)
        end
      end
      words
    end

    def initialize_letter_positions(hint_line, answer_chars)
      hint_line.each_char.map.with_index do |hint_char, index|
        LetterPosition.new(hint_char, answer_chars, index)
      end
    end

    class LetterPosition
      EMOJI_HINT_CHARS = { "⬛" => "b",
                           "🟨" => "y",
                           "🟩" => "g" }.freeze

      def initialize(hint_char, answer_chars, index)
        @hint_char = EMOJI_HINT_CHARS[hint_char] || hint_char
        @answer_chars = answer_chars
        @index = index
        @answer_char = @answer_chars[index]
      end

      attr_reader :hint_char,
                  :answer_char,
                  :index

      def potential_words(commonality)
        case hint_char
        when "g"
          Word.with_char_at_index(@answer_char, @index, commonality)
        when "y"
          chars = @answer_chars - [@answer_char]
          Word.with_chars_at_index(chars, @index, commonality)
        end
      end

      def not_potential_words(commonality)
        Word.with_chars_at_index(@answer_chars, @index, commonality)
      end
    end
  end
end
