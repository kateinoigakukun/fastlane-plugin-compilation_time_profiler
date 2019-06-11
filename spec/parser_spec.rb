describe CompilationStatisticsParser do
  describe '#parse' do
    it '#parse' do
      fixture = File.expand_path('../fixtures', __FILE__)
      parser = CompilationStatisticsParser.new
      log = File.read("#{fixture}/compilation_analyze.log")
      log.lines.each do |line|
        parser.parse(line)
      end
      table = parser.finalize
      expect(table.summary.total).to eq("0.3042")
      expect(table.summary.total_clock).to eq("0.3130")
      expect(table.rows.last.name).to eq("Total")
    end
  end
end
