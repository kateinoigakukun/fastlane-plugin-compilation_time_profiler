describe Fastlane::Actions::CompilationTimeProfilerAction do
  describe '#run' do
    it '#run' do
      fixture = File.expand_path('../fixtures', __FILE__)
      allow(Dir).to receive(:mktmpdir).and_return("/tmp/foo/bar")
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with("/tmp/foo/bar/xcodebuild.log").and_return('')
      Fastlane::Actions::CompilationTimeProfilerAction.run(
        scheme: "ExampleProject", build_configuration: "Debug",
         workspace: "#{fixture}/ExampleWorkspace.xcworkspace",
         project_paths: ["#{fixture}/ExampleProject/ExampleProject.xcodeproj"]
      )
    end
  end
end
