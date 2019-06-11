class CompilationStatisticsParser
  def initialize
    @state = State::INITIAL
    @matches = [
      Match.new(
        State::INITIAL,
        State::HEADER_SEPARATOR,
        proc do |match| end
      ),
      Match.new(
        State::HEADER_SEPARATOR,
        State::HEADER_TITLE,
        proc do |match| end
      ),
      Match.new(
        State::HEADER_TITLE,
        State::HEADER_SEPARATOR,
        proc do |match| end
      ),
      Match.new(
        State::HEADER_SEPARATOR,
        State::RESULT_SUMMARY,
        proc do |match|
	  puts "Summary"
          puts match[1]
        end
      ),
      Match.new(
        State::RESULT_SUMMARY,
        State::TABLE_COLUMN,
        proc do |match| end
      ),
      Match.new(
        State::TABLE_COLUMN,
        State::TABLE_ROW,
        proc do |match|
          puts match[6]
        end
      ),
      Match.new(
        State::TABLE_ROW,
        State::TABLE_ROW,
        proc do |match|
		puts match.captures.to_s
        end
      ),
    ]
  end

  Match = Struct.new(:old, :new, :block)

  module State
    INITIAL          = 1 << 0
    HEADER_SEPARATOR = 1 << 1
    HEADER_TITLE     = 1 << 2
    RESULT_SUMMARY   = 1 << 3
    TABLE_COLUMN     = 1 << 4
    TABLE_ROW        = 1 << 5
  end

  Pattern = Struct.new(:regex, :state)

  PATTERNS = [
    Pattern.new(
      /^===-------------------------------------------------------------------------===$/,
      State::HEADER_SEPARATOR
    ),
    Pattern.new(
      /^                               Swift compilation$/,
      State::HEADER_TITLE
    ),
    Pattern.new(
      /^  Total Execution Time: (.+) seconds \((.+) wall clock\)$/,
      State::RESULT_SUMMARY
    ),
    Pattern.new(
      /^   ---User Time---   --System Time--   --User\+System--   ---Wall Time---  --- Name ---$/,
      State::TABLE_COLUMN
    ),
    Pattern.new(
      /^   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)  (.+)$/,
      State::TABLE_ROW
    ),
  ]


  def parse(line)
    PATTERNS.each do |pattern|
      next unless match = pattern.regex.match(line)
      process(match, pattern.state)
      break
    end
  end

  def process(regex_match, new_state)
    @matches.each do |match|
      next unless @state == match.old && new_state == match.new
      match.block.call(regex_match)
      @state = match.new
      break
    end
  end
end

