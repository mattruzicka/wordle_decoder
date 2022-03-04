# frozen_string_literal: true

class WordleDecoder
  class WordleShare
    ANSWER_LINES = ["🟩🟩🟩🟩🟩", "ggggg"].freeze

    def self.final_line?(input_lines)
      ANSWER_LINES.any? { input_lines.include?(_1) }
    end

    def self.wordle_answers
      @wordle_answers ||= load_worldle_ansers
    end

    def self.load_worldle_ansers
      file_path = File.join(File.dirname(__FILE__), "..", "wordle_answers.json")
      JSON.parse File.read(file_path)
    end

    def initialize(input, answer_input = nil)
      @input = input
      self.answer_input = answer_input
    end

    attr_reader :input,
                :answer_input

    attr_accessor :answer

    def answer_input=(val)
      @answer_input = val
      @answer = normalize_answer_input(val)
    end

    GAME_DAY_REGEX = /wordle\s(\d+)\s/i.freeze

    def find_answer
      title_line = input_lines.detect { |line| line.match?(GAME_DAY_REGEX) }
      game_day = title_line.match(GAME_DAY_REGEX).captures.first&.to_i
      self.answer = self.class.wordle_answers[game_day]
    end

    def answer_chars
      @answer_chars ||= answer&.strip&.split("")
    end

    def hint_lines
      @hint_lines ||= parse_hint_lines!
    end

    def wordle_lines
      @wordle_lines ||= parse_wordle_lines!
    end

    def input_lines
      @input_lines ||= normalize_input_lines(parse_input_lines!)
    end

    def to_terminal
      "{{blue:>}} #{wordle_lines.join("\n  ")}"
    end

    def decoder
      @decoder ||= WordleDecoder.new(self)
    end

    def inspect
      "<#{self.class.name} input: #{input}, answer_input: #{answer_input}" \
        " answer_chars: #{answer_chars.inspect} hint_lines: #{hint_lines.inspect}>"
    end

    private

    def parse_hint_lines!
      hint_lines = wordle_lines.dup
      hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
      hint_lines
    end

    VALID_HINT_CHARS = WordPosition::EMOJI_HINT_CHARS.to_a.flatten.uniq

    def parse_wordle_lines!
      input_lines.select do |line|
        line.each_char.all? { |c| VALID_HINT_CHARS.include?(c) }
      end
    end

    def parse_input_lines!
      case input
      when String
        convert_input_string_to_input_lines
      when Array
        input
      else
        raise Error, "Input must be a String or Array"
      end
    end

    def normalize_input_lines(input_lines)
      input_lines.filter_map do |input_line|
        line = input_line.strip
        line unless line.empty?
      end
    end

    def convert_input_string_to_input_lines
      hint_input = input.downcase
      if hint_input.include?("\n")
        hint_input.split("\n")
      else
        hint_input.chars.each_slice(5).map(&:join)
      end
    end

    VALID_ANSWER_CHARS = ("a".."z").freeze

    def normalize_answer_input(val)
      val = val&.strip&.downcase
      val if val && val.length == 5 && val.each_char.all? { |c| VALID_ANSWER_CHARS.include?(c) }
    end
  end
end
