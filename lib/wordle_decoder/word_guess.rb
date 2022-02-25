# frozen_string_literal: true

class WordleDecoder
  class WordGuess
    def initialize(hint_line, answer_chars)
      @letter_guesses = initialize_letter_guesses(hint_line, answer_chars)
    end

    attr_reader :letter_guesses

    def guessable_words
      @guessable_words ||= compute_guessable_words
    end

    BASE_INCONFIDENCE = 0.05

    def guessable_score
      score = (100 * (1.0 / guessable_words.count.to_f))
      (score - (score * BASE_INCONFIDENCE)).round
    end

    def green_letters
      letters_grouped_by_hint_char["g"]
    end

    def yellow_letters
      letters_grouped_by_hint_char["y"]
    end

    def black_letters
      letters_grouped_by_hint_char["b"]
    end

    private

    def compute_guessable_words
      Word::COMMONALITY_OPTIONS.each do |commonality|
        words = compute_guessable_words_from_hints(commonality) || Decoder.all
        return words if words.count == 1

        remove_not_guessable_words(words, commonality)
        return words unless words.empty?
      end
    end

    def compute_guessable_words_from_hints(commonality)
      words = nil
      [green_letters, yellow_letters].each do |letters|
        words = filter_by_guessable_words(words, letters, commonality) if letters
      end
      words
    end

    def remove_not_guessable_words(words, commonality)
      black_letters&.each do |letter|
        words -= letter.not_guessable_words(commonality)
      end
      words
    end

    def letters_grouped_by_hint_char
      @letters_grouped_by_hint_char ||= @letter_guesses.group_by(&:hint_char)
    end

    def filter_by_guessable_words(words, letters, commonality)
      letters.each do |letter|
        if words
          words &= letter.guessable_words(commonality)
        else
          words = letter.guessable_words(commonality)
        end
      end
      words
    end

    def initialize_letter_guesses(hint_line, answer_chars)
      hint_line.each_char.map.with_index do |hint_char, index|
        LetterGuess.new(hint_char, answer_chars, index)
      end
    end

    class LetterGuess
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

      def guessable_words(commonality)
        case hint_char
        when "g"
          Word.with_char_at_index(@answer_char, @index, commonality)
        when "y"
          chars = @answer_chars - [@answer_char]
          Word.with_chars_at_index(chars, @index, commonality)
        end
      end

      def not_guessable_words(commonality)
        Word.with_chars_at_index(@answer_chars, @index, commonality)
      end
    end
  end
end
