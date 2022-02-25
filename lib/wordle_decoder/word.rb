# frozen_string_literal: true

class WordleDecoder
  class Word
    def initialize(word_str, word_position)
      @word_str = word_str
      @word_position = word_position
    end

    def green_chars
      @green_chars ||= find_chars(@word_position.green_letter_positions)
    end

    def yellow_chars
      @yellow_chars ||= find_chars(@word_position.yellow_letter_positions)
    end

    def yellow_char_index_pairs
      @yellow_char_index_pairs ||= find_char_index_pairs(@word_position.yellow_letter_positions)
    end

    def black_chars
      @black_chars ||= find_chars(@word_position.black_letter_positions)
    end

    def confidence_score
      @word_position.confidence_score
    end

    def as_string
      @word_str
    end

    def to_s
      @word_position.letter_positions.map do |letter_position|
        char = @word_str[letter_position.index]
        case letter_position.hint_char
        when "g"
          "{{green:#{char}}}"
        when "y"
          "{{yellow:#{char}}}"
        else
          char
        end
      end.join
    end

    private

    def find_chars(letter_positions)
      return [] unless letter_positions

      letter_positions.map { |lp| @word_str[lp.index] }
    end

    def find_char_index_pairs(letter_positions)
      return [] unless letter_positions

      letter_positions.map { |lp| [@word_str[lp.index], lp.index] }
    end
  end
end
