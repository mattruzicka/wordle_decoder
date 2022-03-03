# frozen_string_literal: true

class WordleDecoder
  class Word
    def initialize(word_str, word_position, commonality = nil)
      @word_str = word_str
      @word_position = word_position
      @commonality = commonality
    end

    def score
      @score ||= commonality_score + common_letter_score +
                 frequency_score - pentalty_score
    end

    def pentalty_score
      guessed_same_letter_twice? ? 100 : 0
    end

    def confidence_score(guess_score)
      position_score = @word_position.confidence_score
      (position_score + guess_score).clamp(position_score, 99).round
    end

    def chars
      @chars ||= @word_str.split("")
    end

    COMMON_LETTERS = %w[s e a o r i l t n].freeze
    PENALTY_LETTERS_COUNT = 5

    def common_letter_score
      if @word_position.line_index <= 1
        [(chars & COMMON_LETTERS).count, 3].min
      else
        letters_count = PENALTY_LETTERS_COUNT + @word_position.line_index
        -(black_chars & COMMON_LETTERS.first(letters_count)).count
      end
    end

    COMMONALITY_SCORES = { most: 2, less: 1, least: 0 }.freeze

    def commonality_score
      COMMONALITY_SCORES[@commonality] || 0
    end

    def frequency_score
      @frequency_score ||= WordSearch.frequency_score(@word_str)
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

    def possible?
      return true if yellow_chars.empty?

      answer_chars = @word_position.answer_chars.dup
      delete_green_chars!(answer_chars)

      yellow_chars.all? do |yellow_char|
        answer_char_index = answer_chars.index(yellow_char)
        answer_chars.delete_at(answer_char_index) if answer_char_index
      end
    end

    def to_s
      @word_str
    end

    def to_terminal
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

    def guessed_same_letter_twice?
      black_chars.count != black_chars.uniq.count || !(black_chars & yellow_chars).empty?
    end

    def delete_green_chars!(answer_chars)
      green_chars&.each do |green_char|
        answer_char_index = answer_chars.index(green_char)
        answer_chars.delete_at(answer_char_index) if answer_char_index
      end
    end

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
