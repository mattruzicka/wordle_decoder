# frozen_string_literal: true

class WordleDecoder
  class Word
    COMMONALITY_OPTIONS = %i[most less least].freeze

    class << self
      def with_char_at_index(char, index, commonality)
        case commonality
        when :most
          most_common_letter_to_words_arrays[index][char]
        when :less
          less_common_letter_to_words_arrays[index][char]
        when :least
          least_common_letter_to_words_arrays[index][char]
        end
      end

      def with_chars_at_index(chars, index, commonality)
        chars.uniq.flat_map { |c| with_char_at_index(c, index, commonality) }
      end

      def without_char_at_index(char, index, commonality)
        all - with_char_at_index(char, index, commonality)
      end

      private

      def most_common_letter_to_words_arrays
        @most_common_letter_to_words_arrays ||= build_letter_to_words_hashes("most_common_words.txt")
      end

      def less_common_letter_to_words_arrays
        @less_common_letter_to_words_arrays ||= build_letter_to_words_hashes("less_common_words.txt")
      end

      def least_common_letter_to_words_arrays
        @least_common_letter_to_words_arrays ||= build_letter_to_words_hashes("least_common_words.txt")
      end

      def build_letter_to_words_hashes(words_file_name)
        words = load_wordle_words(words_file_name)
        Array.new(5) { |index| words.group_by { |word| word[index] } }
      end

      def load_wordle_words(file_name)
        file_path = File.join(File.dirname(__FILE__), "..", file_name)
        File.read(file_path).split("\n")
      end
    end
  end
end
