describe Fastlane::Actions::CompilationTimeProfilerAction do
  describe '#run' do
    it '#run' do
      fixture = File.expand_path('../fixtures', __FILE__)
      Fastlane::Actions::CompilationTimeProfilerAction.run(
        scheme: "ExampleProject", build_configuration: "Debug",
         workspace: "#{fixture}/ExampleWorkspace.xcworkspace",
         project_paths: ["#{fixture}/ExampleProject.xcodeproj"]
      )
    end
  end
end
