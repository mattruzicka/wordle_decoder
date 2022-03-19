# frozen_string_literal: true

class WordleDecoder
  class Guess
    def initialize(start_word, first_word_position, word_positions)
      @start_word = start_word
      @first_word_position = first_word_position
      @word_positions = word_positions
    end

    def score
      @score ||= best_words_with_scores.sum(&:last)
    end

    def word_scores
      @word_scores ||= best_words_with_scores.map(&:last)
    end

    def words
      @words ||= best_words_with_scores.map { |w, _s| w.to_s }
    end

    def best_words_with_scores
      @best_words_with_scores ||= select_best_words_with_scores
    end

    def inspect
      "<#{self.class.name} score: #{score}, word_scores: #{word_scores}, words: #{words}>"
    end

    private

    def select_best_words_with_scores
      selected_words = [@start_word]
      selected_word_scores = [@start_word.score]
      seen_black_chars = @start_word.black_chars
      seen_yellow_chars = @start_word.yellow_chars
      seen_green_chars = @start_word.green_chars
      seen_yellow_char_index_pairs = @start_word.yellow_char_index_pairs
      @word_positions.each do |word_position|
        potential_words = word_position.potential_words
        potential_words = word_position.frequent_potential_words if potential_words.empty?
        words_with_score_array = potential_words.map do |word|
          word_score = word.score
          next([word, word_score]) if word_score.negative?
          next([word, -95]) unless (seen_black_chars & word.black_chars).empty?
          next([word, -90]) unless (seen_yellow_char_index_pairs & word.yellow_char_index_pairs).empty?

          word_score += (seen_yellow_chars & word.yellow_chars).count
          word_score += (seen_green_chars & word.yellow_chars).count
          word_score -= (word.yellow_chars - seen_yellow_chars - seen_green_chars).count
          word_score -= (word.green_chars - seen_green_chars).count
          [word, word_score]
        end

        best_word, best_score = words_with_score_array.max_by { _2 }
        selected_words << best_word
        selected_word_scores << best_score
        seen_black_chars.concat(best_word.black_chars)
        seen_yellow_chars.concat(best_word.yellow_chars)
        seen_green_chars.concat(best_word.green_chars)
        seen_yellow_char_index_pairs.concat(best_word.yellow_char_index_pairs)
      end

      selected_words.zip(selected_word_scores)
    end

    def normalize_confidence_score(word, score)
      (word.confidence_score + score).clamp(word.confidence_score, 99)
    end
  end
end
