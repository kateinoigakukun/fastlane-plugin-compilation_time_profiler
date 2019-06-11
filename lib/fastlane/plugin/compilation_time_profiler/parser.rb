module Fastlane
  module Actions
    class CompilationTimeProfilerAction
      class Parser
        def initialize(raw_log_path)
          @state = State::INITIAL
          @matches = [
            Match.new(
              State::INITIAL,
              State::HEADER_SEPARATOR,
              proc do |match|
                puts match
              end
            )
          ]
        end

        Pattern = Struct.new(:regex, :state)

        PATTERNS = [
          Pattern.new(/^===-------------------------------------------------------------------------===$/, State::HEADER_SEPARATOR)
          Pattern.new(/^                               Swift compilation$/,                                State::HEADER_TITLE)
          Pattern.new(/^  Total Execution Time: (.+) seconds \((.+) wall clock\)$/,                        State::RESULT_SUMMARY)
        ]

        Match = Struct.new(old, new, block)

        module State
          INITIAL          = 1 << 0
          HEADER_SEPARATOR = 1 << 1
          HEADER_TITLE     = 1 << 2
          RESULT_SUMMARY   = 1 << 3
        end

        def parse(line)
          PATTERNS.detect do |pattern|
            pattern.regex.match(line) do |match|
              process(match, pattern.state)
            end
          end
        end

        def match(old_state, state)
          if @state == state && new_state == state
        end

        def process(regex_match, new_state)
          @matches.detect do |match|
            next unless @state == match.old && new_state == match.new
            match.block(match)
          end
        end
      end
    end
  end
end
