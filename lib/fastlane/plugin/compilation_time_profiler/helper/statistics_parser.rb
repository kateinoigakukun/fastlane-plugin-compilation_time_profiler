class CompilationStatisticsParser
  Summary    = Struct.new(:total, :total_clock)
  Row        = Struct.new(:user, :system, :user_system, :clock, :name)
  Table      = Struct.new(:target, :summary, :rows)

  Transition = Struct.new(:from, :to, :block)
  Pattern    = Struct.new(:regex, :state)

  module State
    INITIAL          = "INITIAL         " #1 << 0
    BUILDING         = "BUILDING        " #1 << 1
    HEADER_SEPARATOR = "HEADER_SEPARATOR" #1 << 2
    HEADER_TITLE     = "HEADER_TITLE    " #1 << 3
    RESULT_SUMMARY   = "RESULT_SUMMARY  " #1 << 4
    TABLE_COLUMN     = "TABLE_COLUMN    " #1 << 5
    TABLE_ROW        = "TABLE_ROW       " #1 << 6
    TABLE_LAST_ROW   = "TABLE_LAST_ROW  " #1 << 7
  end

  PATTERNS = [
    Pattern.new(
      /.+ \(in target: (.+)\)$/, # regex
      State::BUILDING           # state
    ),
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
      /^   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)  (Total)$/,
      State::TABLE_LAST_ROW
    ),
    Pattern.new(
      /^   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)   (.+) \(\s*(\d+\.\d)%\)  (.+)$/,
      State::TABLE_ROW
    ),
  ]

  def initialize
    @tables = []
    clear_state
    @transitions = [
      Transition.new(
        State::INITIAL,  # from
        State::BUILDING, # to
        proc do |match|
          @building_target = match[1]
        end
      ),
      Transition.new(
        State::BUILDING,
        State::BUILDING,
        proc do |match|
          @building_target = match[1]
        end
      ),
      Transition.new(
        State::BUILDING,
        State::HEADER_SEPARATOR,
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
      ),
      Transition.new(
        State::TABLE_ROW,
        State::TABLE_LAST_ROW,
        proc do |match|
          add_row(match)
          @tables.push(
            Table.new(@building_target, @summary, @rows)
          )
          clear_state
        end
      )
    ]
  end

  def clear_state
    @state = State::INITIAL
    @rows = []
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
      @state = new_state
      transition.block.call(match)
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
    @tables
  end
end
