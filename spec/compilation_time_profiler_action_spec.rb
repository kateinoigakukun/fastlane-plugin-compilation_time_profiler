describe Fastlane::Actions::CompilationTimeProfilerAction do
  describe '#run' do
    let(:buildlog_dir) { "/tmp/foo/bar" }
    it '#run' do
      fixture = File.expand_path('../fixtures', __FILE__)
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with("#{buildlog_dir}/xcodebuild.log").and_return('')
      Fastlane::Actions::CompilationTimeProfilerAction.run(
         project_paths: ["#{fixture}/ExampleProject/ExampleProject.xcodeproj"],
         buildlog_path: buildlog_dir,
         action: proc do
          config = {
            buildlog_path: buildlog_dir,
            scheme: "ExampleProject",
            workspace: "#{fixture}/ExampleWorkspace.xcworkspace",
          }
          Fastlane::Actions::RunTestsAction.run(config)
         end
      )
    end
  end
end
