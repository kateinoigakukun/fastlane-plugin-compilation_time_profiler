describe CompilationStatisticsParser do
  describe '#parse' do
    it '#parse' do
      fixture = File.expand_path('../fixtures', __FILE__)
      parser = CompilationStatisticsParser.new
      log = File.read("#{fixture}/compilation_analyze.log")
      log.lines.each do |line|
        parser.parse(line)
      end
      tables = parser.finalize
      expect(tables.length).to eq(2)
      table = tables.first
      expect(table.target).to eq("OtherProject")
      expect(table.rows.length).to eq(12)
      expect(table.summary.total).to eq("0.0038")
      expect(table.summary.total_clock).to eq("0.0031")
      expect(table.rows.last.name).to eq("Total")
    end
  end
end
