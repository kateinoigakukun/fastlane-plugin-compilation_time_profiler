describe CompilationStatisticsParser do
    describe '#parse' do
      it '#parse' do
        fixture = File.expand_path('../fixtures', __FILE__)
        parser = CompilationStatisticsParser.new
        log = File.read("#{fixture}/compilation_analyze.log")
        log.lines.each do |line|
            parser.parse(line)
        end
      end
    end
  end
  