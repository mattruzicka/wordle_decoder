# frozen_string_literal: true

class WordleDecoder
  class WordleShare
    ANSWER_LINES = ["🟩🟩🟩🟩🟩", "ggggg"].freeze

    def self.final_line?(input_lines)
      ANSWER_LINES.any? { input_lines.include?(_1) }
    end

    def initialize(input, answer_str = nil)
      @input = input
      self.answer_str = answer_str
    end

    attr_reader :input, :answer_str

    def answer_str=(val)
      @answer_str = normalize_answer_str(val)
    end

    def answer_chars
      @answer_chars ||= parse_answer_chars!
    end

    def hint_lines
      @hint_lines ||= parse_hint_lines
    end

    def wordle_lines
      @wordle_lines ||= parse_wordle_lines
    end

    def to_terminal
      str = +"{{blue:>}} #{wordle_lines.join("\n  ")}"
      str << "\n{{green:#{answer_str}}}" if answer_str
      str
    end

    def decoder
      @decoder ||= WordleDecoder.new(self)
    end

    def inspect
      "<#{self.class.name} input: #{input}, answer_str: #{answer_str}" \
        " answer_chars: #{answer_chars.inspect} hint_lines: #{hint_lines.inspect}>"
    end

    private

    def parse_answer_chars!
      @answer_str ||= lookup_answer_str!
      @answer_str.strip.split("")
    end

    def lookup_answer_str!
      # TODO: try to find word of the day from share text
      raise Error, "The word of the day is missing."
    end

    def parse_hint_lines
      hint_lines = wordle_lines.dup
      hint_lines.pop if ANSWER_LINES.include?(hint_lines.last)
      hint_lines
    end

    def parse_wordle_lines
      input_lines = parse_input_lines!
      input_lines = normalize_input_lines(input_lines)
      select_hint_lines(input_lines)
    end

    VALID_HINT_CHARS = WordPosition::EMOJI_HINT_CHARS.to_a.flatten.uniq

    def select_hint_lines(input_lines)
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

    def normalize_answer_str(val)
      val = val&.strip&.downcase
      val if val && val.length == 5 && val.each_char.all? { |c| VALID_ANSWER_CHARS.include?(c) }
    end
  end
end
