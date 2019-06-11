class CompilationStatisticsParser
  Summary    = Struct.new(:total, :total_clock, keyword_init: true)
  Row        = Struct.new(:user, :system, :user_system, :clock, :name, keyword_init: true)
  Table      = Struct.new(:summary, :rows, keyword_init: true)

  Transition = Struct.new(:from, :to, :block, keyword_init: true)
  Pattern    = Struct.new(:regex, :state, keyword_init: true)

  module State
    INITIAL          = 1 << 0
    HEADER_SEPARATOR = 1 << 1
    HEADER_TITLE     = 1 << 2
    RESULT_SUMMARY   = 1 << 3
    TABLE_COLUMN     = 1 << 4
    TABLE_ROW        = 1 << 5
  end

  PATTERNS = [
    Pattern.new(
      regex: /^===-------------------------------------------------------------------------===$/,
      state: State::HEADER_SEPARATOR
    ),
    Pattern.new(
      regex: /^                               Swift compilation$/,
      state: State::HEADER_TITLE
    ),
    Pattern.new(
      regex: /^  Total Execution Time: (.+) seconds \((.+) wall clock\)$/,
      state: State::RESULT_SUMMARY
    ),
    Pattern.new(
      regex: /^   ---User Time---   --System Time--   --User\+System--   ---Wall Time---  --- Name ---$/,
      state: State::TABLE_COLUMN
    ),
    Pattern.new(
      regex: /^   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)  (.+)$/,
      state: State::TABLE_ROW
    ),
  ]


  def initialize
    @state = State::INITIAL
    @rows = []
    @matches = [
      Transition.new(
         from: State::INITIAL,
           to: State::HEADER_SEPARATOR,
        block: proc do |match| end
      ),
      Transition.new(
         from: State::HEADER_SEPARATOR,
           to: State::HEADER_TITLE,
        block: proc do |match| end
      ),
      Transition.new(
         from: State::HEADER_TITLE,
           to: State::HEADER_SEPARATOR,
        block: proc do |match| end
      ),
      Transition.new(
         from: State::HEADER_SEPARATOR,
           to: State::RESULT_SUMMARY,
        block: proc do |match|
          @summary = Summary.new(total: match[1], total_clock: match[2])
        end
      ),
      Transition.new(
         from: State::RESULT_SUMMARY,
           to: State::TABLE_COLUMN,
        block: proc do |match| end
      ),
      Transition.new(
         from: State::TABLE_COLUMN,
           to: State::TABLE_ROW,
        block: proc do |m|
          add_row m
        end
      ),
      Transition.new(
         from: State::TABLE_ROW,
           to: State::TABLE_ROW,
        block: proc do |m|
          add_row m
        end
      ),
    ]
  end


  def parse(line)
    PATTERNS.each do |pattern|
      next unless match = pattern.regex.match(line)
      process(match, pattern.state)
      break
    end
  end

  def process(regex_match, new_state)
    @matches.each do |match|
      next unless @state == match.from && new_state == match.to
      match.block.call(regex_match)
      @state = match.to
      break
    end
  end


  def add_row(match)
    @rows.push Row.new(
             user: match[1],
           system: match[3],
      user_system: match[5],
            clock: [7],
             name: match[9]
    )
  end

  def finalize
    Table.new(summary: @summary, rows: @rows)
  end
end

