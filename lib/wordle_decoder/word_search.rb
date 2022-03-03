# frozen_string_literal: true

require 'json'

class WordleDecoder
  class WordSearch
    COMMONALITY_OPTIONS = %i[most less least].freeze

    class << self
      def char_at_index(char, index, commonality)
        case commonality
        when :most
          most_common_letter_to_words_arrays[index][char]
        when :less
          less_common_letter_to_words_arrays[index][char]
        when :least
          least_common_letter_to_words_arrays[index][char]
        end
      end

      def chars_at_index(chars, index, commonality)
        chars.uniq.flat_map { |c| char_at_index(c, index, commonality) }
      end

      def frequency_score(word)
        words_to_frequency_score_hash[word]
      end

      def words_to_frequency_score_hash
        @words_to_frequency_score_hash ||= load_words_to_frequency_score_hash
      end

      def most_frequent_words_without_chars(without_chars, limit)
        regex = /#{without_chars.join("|")}/
        words = []
        words_to_frequency_score_hash.each_key.reverse_each do |str|
          words << str unless str.match?(regex)

          return(words) if words.count == limit
        end
      end

      private

      def load_words_to_frequency_score_hash
        JSON.parse(file_path("words_to_frequency_score.json"))
      end

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
        file_path(file_name).split("\n")
      end

      def file_path(file_name)
        file_path = File.join(File.dirname(__FILE__), "..", file_name)
        File.read(file_path)
      end
    end
  end
end
