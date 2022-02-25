# frozen_string_literal: true

class WordleDecoder
  class GameGuess
    def initialize(start_word, word_positions)
      @start_word = start_word
      @word_positions = word_positions
      @score = 0
    end

    attr_reader :score

    def best_words
      @best_words ||= select_best_words.reverse!
    end

    private

    #
    # Greatly penalize words that have the same black letters as any previous word
    # Greatly penalize words that have the same yellow letter/index pair as any previous word
    # Reward words that have yellow letters that match yellow letters in previous words, but in different positions
    # Reward words that have yellow letters that match green letters in previous words
    # Penalize words that have yellow letters that don't appear in previous words
    # Penalize words that have green letters that don't appear in previous words
    #
    def select_best_words
      selected_words = [@start_word]
      seen_black_chars = @start_word.black_chars
      seen_yellow_chars = @start_word.yellow_chars
      seen_green_chars = @start_word.green_chars
      seen_yellow_char_index_pairs = @start_word.yellow_char_index_pairs

      @word_positions.each do |word_position|
        words_with_score_array = word_position.words.map do |word|
          next([word, -100]) unless (seen_black_chars & word.black_chars).empty?
          next([word, -99]) if seen_yellow_char_index_pairs.include?(word.yellow_char_index_pairs)

          word_score = 0
          word_score += (seen_yellow_chars & word.yellow_chars).count
          word_score += (seen_green_chars & word.yellow_chars).count
          word_score -= (word.yellow_chars - seen_yellow_chars).count
          word_score -= (word.green_chars - seen_green_chars).count
          [word, word_score]
        end

        best_word, best_score = words_with_score_array.max_by { _2 }
        @score += best_score
        selected_words << best_word
        seen_black_chars.concat(best_word.black_chars)
        seen_yellow_chars.concat(best_word.yellow_chars)
        seen_green_chars.concat(best_word.green_chars)
        seen_yellow_char_index_pairs.concat(best_word.yellow_char_index_pairs)
      end

      selected_words
    end
  end
end
