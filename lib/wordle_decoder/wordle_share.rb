# frozen_string_literal: true

class WordleDecoder
  class WordleShare
    ANSWER_LINES = ["🟩🟩🟩🟩🟩",
                    "ggggg",
                    ":large_green_square:" * 5,
                    ":large_orange_square:" * 5,
                    "🟧🟧🟧🟧🟧"].freeze

    def self.final_line?(input_lines)
      ANSWER_LINES.any? { input_lines.include?(_1) }
    end

    NEEDS_HELP_INPUTS = %w[help what wordle wat ? man okay yes no test].freeze

    def self.needs_help?(input)
      NEEDS_HELP_INPUTS.include?(input.strip.downcase)
    end

    EXIT_PROGRAM_INPUTS = %w[exit no nvm].freeze

    def self.exit_program?(input)
      EXIT_PROGRAM_INPUTS.include?(input.strip)
    end

    def self.help_to_terminal
      "\n  {{italic:Copy and paste those 🟨, 🟩, and ⬛" \
        " emojis from your wordle share.}} \n\n{{blue:>}} "
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
      return unless title_line

      game_day = title_line.match(GAME_DAY_REGEX).captures.first&.to_i
      self.answer = self.class.wordle_answers[game_day]
    end

    def answer_chars
      @answer_chars ||= answer&.strip&.chars
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
      input_lines.filter_map do |line|
        line = normalize_wordle_line(line)
        line if line.each_char.all? { |c| VALID_HINT_CHARS.include?(c) }
      end
    end

    def normalize_wordle_line(line)
      line = translate_emoji_shortcodes(line)
      line.each_grapheme_cluster.map { |cluster| cluster.codepoints.first }.pack("U*")
    end

    SHORTCODES_TO_EMOJIS = { ":black_large_square:" => "⬛",
                             ":white_large_square:" => "⬜",
                             ":large_green_square:" => "🟩",
                             ":large_yellow_square:" => "🟨",
                             ":large_orange_square:" => "🟧",
                             ":large_blue_square:" => "🟦" }.freeze

    def translate_emoji_shortcodes(line)
      SHORTCODES_TO_EMOJIS.reduce(line) { |acc, (key, val)| acc.gsub(key, val) }
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
