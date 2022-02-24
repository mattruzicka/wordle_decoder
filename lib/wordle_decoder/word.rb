# frozen_string_literal: true

class WordleDecoder
  class Word
    class << self
      def with_char_at_index(char, index)
        letter_to_words_arrays[index][char]
      end

      def with_chars_at_index(chars, index)
        chars.flat_map { |c| with_char_at_index(c, index) }
      end

      def without_char_at_index(char, index)
        all - with_char_at_index(char, index)
      end

      private

      def letter_to_words_arrays
        @letter_to_words_arrays ||= Array.new(5) { |index| build_letter_to_words_hash(index) }
      end

      def build_letter_to_words_hash(index)
        decodable_words = load_wordle_words("decodable_words.txt")
        decodable_words.group_by { |word| word[index] }
      end

      def load_wordle_words(file_name)
        file_path = File.join(File.dirname(__FILE__), "..", file_name)
        File.read(file_path).split("\n")
      end
    end
  end
end
