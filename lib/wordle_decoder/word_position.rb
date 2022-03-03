# frozen_string_literal: true

class WordleDecoder
  class WordPosition
    def initialize(hint_line, line_index, answer_chars)
      @hint_chars = normalize_hint_chars(hint_line)
      @answer_chars = answer_chars
      @line_index = line_index
      @letter_positions = initialize_letter_positions(@hint_chars, @answer_chars)
    end

    attr_reader :hint_chars,
                :answer_chars,
                :line_index,
                :letter_positions

    def potential_words
      @potential_words ||= initialize_potential_words
    end

    def frequent_potential_words
      @frequent_potential_words ||= find_10_frequent_potential_words
    end

    BASE_INCONFIDENCE = 0.05

    def confidence_score
      return 1 if potential_words.empty?

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

    def initialize_potential_words
      potential_words = []
      WordSearch::COMMONALITY_OPTIONS.each do |commonality|
        word_strings = compute_words_from_hints(commonality)
        next if word_strings.empty?

        word_strings = remove_impossible_words(word_strings, commonality)
        next if word_strings.empty?

        new_words = word_strings.map! { |str| Word.new(str, self, commonality) }
        new_words.select!(&:possible?)
        potential_words.concat(new_words)
      end
      potential_words
    end

    def compute_words_from_hints(commonality)
      words = nil
      [green_letter_positions, yellow_letter_positions].each do |letters|
        words = filter_by_words(words, letters, commonality) if letters
      end
      words || []
    end

    def filter_by_words(words, letters, commonality)
      letters.each do |letter|
        if words
          words &= letter.potential_words(commonality)
        else
          words = letter.potential_words(commonality)
        end
      end
      words
    end

    def remove_impossible_words(words, commonality)
      black_letter_positions&.each do |letter|
        words -= letter.impossible_words(commonality)
      end
      words
    end

    def select_letter_positions_by_hint(hint_char)
      @letter_positions.select { |lg| lg.hint_char == hint_char }
    end

    def find_10_frequent_potential_words
      word_strings = WordSearch.most_frequent_words_without_chars(@answer_chars, 10)
      word_strings.map { |str| Word.new(str, self) }
    end

    EMOJI_HINT_CHARS = { "⬛" => "b",
                         "⬜" => "b",
                         "🟨" => "y",
                         "🟩" => "g" }.freeze

    def normalize_hint_chars(hint_line)
      hint_line.each_char.map { |c| EMOJI_HINT_CHARS[c] || c }
    end

    def initialize_letter_positions(hint_chars, answer_chars)
      hint_chars.each_with_index.map do |hint_char, index|
        LetterPosition.new(index, hint_char, hint_chars, answer_chars)
      end
    end

    class LetterPosition
      def initialize(index, hint_char, hint_chars, answer_chars)
        @index = index
        @hint_char = hint_char
        @hint_chars = hint_chars
        @answer_chars = answer_chars
        @answer_char = @answer_chars[index]
      end

      attr_reader :hint_char,
                  :answer_char,
                  :index

      def potential_words(commonality)
        case hint_char
        when "g"
          WordSearch.char_at_index(@answer_char, @index, commonality)
        when "y"
          if @hint_chars.count("g") == 3
            must_be_char_index = @hint_chars.index.with_index { |h, i| h != "g" && i != @index }
            must_be_char = @answer_chars[must_be_char_index]
            WordSearch.char_at_index(must_be_char, @index, commonality)
          else
            # TODO: if yellow char is in the word as green already, and there's only one isntance of it
            # in final word, can assume it's not that char.
            chars = @answer_chars - [@answer_char]
            WordSearch.chars_at_index(chars, @index, commonality)
          end
        end
      end

      def impossible_words(commonality)
        WordSearch.chars_at_index(@answer_chars, @index, commonality)
      end
    end
  end
end
