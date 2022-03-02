# frozen_string_literal: true

class WordleDecoder
  class GameGuess
    def initialize(start_word, word_positions)
      @start_word = start_word
      @word_positions = word_positions
      @score = 0
    end

    attr_reader :score

    def best_words_with_scores_2d_array
      @best_words_with_scores_2d_array ||= select_best_words_with_scores_2d_array.reverse!
    end

    private

    #
    # Greatly penalize words that have multiple of the same black letters
    # Greatly penalize words that have the same black letters as any seen word
    # Greatly penalize words that have the same yellow letter/index pair as any seen word
    # Reward words that have yellow letters that match yellow letters in seen words, but in different positions
    # Reward words that have yellow letters that match green letters in seen words
    # Penalize words that have yellow letters that don't appear in seen words
    # Penalize words that have green letters that don't appear in seen words
    # Rewards words based on commonality
    # Reward/penalize words based on line indexes and common letters
    #
    def select_best_words_with_scores_2d_array
      selected_words = [@start_word]
      selected_scores = []
      seen_black_chars = @start_word.black_chars
      seen_yellow_chars = @start_word.yellow_chars
      seen_green_chars = @start_word.green_chars
      seen_yellow_char_index_pairs = @start_word.yellow_char_index_pairs

      @word_positions.each do |word_position|
        words_with_score_array = word_position.words.map do |word|
          next([word, -100]) if word.black_chars.count != word.black_chars.uniq.count
          next([word, -95]) unless (seen_black_chars & word.black_chars).empty?
          next([word, -90]) unless (seen_yellow_char_index_pairs & word.yellow_char_index_pairs).empty?

          word_score = 0
          word_score += (seen_yellow_chars & word.yellow_chars).count
          word_score += (seen_green_chars & word.yellow_chars).count
          word_score -= (word.yellow_chars - seen_yellow_chars - seen_green_chars).count
          word_score -= (word.green_chars - seen_green_chars).count
          word_score += word.commonality_score
          word_score += word.common_letter_score
          [word, word_score]
        end

        best_word, best_score = words_with_score_array.max_by { _2 }
        @score += best_score
        selected_words << best_word
        selected_scores << normalize_confidence_score(best_word, best_score)
        seen_black_chars.concat(best_word.black_chars)
        seen_yellow_chars.concat(best_word.yellow_chars)
        seen_green_chars.concat(best_word.green_chars)
        seen_yellow_char_index_pairs.concat(best_word.yellow_char_index_pairs)
      end

      selected_scores.unshift normalize_confidence_score(@start_word, @score)
      selected_words.zip(selected_scores)
    end

    def normalize_confidence_score(word, score)
      (word.confidence_score + score).clamp(word.confidence_score, 99)
    end
  end
end
