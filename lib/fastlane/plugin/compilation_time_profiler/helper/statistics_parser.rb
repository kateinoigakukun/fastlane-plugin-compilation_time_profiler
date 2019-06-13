class CompilationStatisticsParser
  Summary    = Struct.new(:total, :total_clock)
  Row        = Struct.new(:user, :system, :user_system, :clock, :name)
  Table      = Struct.new(:summary, :rows)

  Transition = Struct.new(:from, :to, :block)
  Pattern    = Struct.new(:regex, :state)

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
      /^===-------------------------------------------------------------------------===$/, # regex
      State::HEADER_SEPARATOR                                                              # state
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
    )
  ]

  def initialize
    @state = State::INITIAL
    @rows = []
    @transitions = [
      Transition.new(
        State::INITIAL,          # from
        State::HEADER_SEPARATOR, # to
        proc do end
      ),
      Transition.new(
        State::HEADER_SEPARATOR,
        State::HEADER_TITLE,
        proc do end
      ),
      Transition.new(
        State::HEADER_TITLE,
        State::HEADER_SEPARATOR,
        proc do end
      ),
      Transition.new(
        State::HEADER_SEPARATOR,
        State::RESULT_SUMMARY,
        proc do |match|
          @summary = Summary.new(
            match[1], # total
            match[2]  # total_clock
          )
        end
      ),
      Transition.new(
        State::RESULT_SUMMARY,
        State::TABLE_COLUMN,
        proc do end
      ),
      Transition.new(
        State::TABLE_COLUMN,
        State::TABLE_ROW,
        method(:add_row)
      ),
      Transition.new(
        State::TABLE_ROW,
        State::TABLE_ROW,
        method(:add_row)
      )
    ]
  end

  def parse(line)
    PATTERNS.each do |pattern|
      next unless match = pattern.regex.match(line)
      process(match, pattern.state)
      break
    end
  end

  def process(match, new_state)
    @transitions.each do |transition|
      next unless @state == transition.from && new_state == transition.to
      transition.block.call(match)
      @state = new_state
      break
    end
  end

  def add_row(match)
    @rows.push(
      Row.new(
        match[1], # user
        match[3], # system
        match[5], # user_system
        match[7], # clock
        match[9]  # name
      )
    )
  end

  def finalize
    Table.new(@summary, @rows)
  end
end
