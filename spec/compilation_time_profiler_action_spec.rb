describe Fastlane::Actions::CompilationTimeProfilerAction do
  describe '#run' do
    let(:buildlog_dir) { "/tmp/foo/bar" }
    let(:buildlog_file) { "#{buildlog_dir}/Scheme-Project.log" }
    it '#run' do
      fixture = File.expand_path('../fixtures', __FILE__)
      allow(Dir).to receive(:glob).with("#{buildlog_dir}/*.log").and_return([buildlog_file])
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(buildlog_file).and_return('')
      Fastlane::Actions::CompilationTimeProfilerAction.run(
        buildlog_path: buildlog_dir,
        action: proc do
          config = {
            buildlog_path: buildlog_dir,
            scheme: "ExampleProject",
            workspace: "#{fixture}/ExampleWorkspace.xcworkspace"
          }
          Fastlane::Actions::RunTestsAction.run(config)
        end
      )
    end
  end
end
