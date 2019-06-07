require 'fastlane/action'
require_relative '../helper/compilation_time_profiler_helper'

module Fastlane
  module Actions
    class CompilationTimeProfilerAction < Action
      def self.run(params)
        params[:project_paths].each do |project_path|
          override_config(project_path)
        end

        Gym.run(
          workspace: params[:workspace],
          configuration: config[:build_configuration],
          scheme: config[:scheme],
          destination: 'platform=iOS Simulator,name=iPhone XS,OS=latest'
        )
      end
      
      def self.override_config(project_path)
        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          next unless targets.include?(target.name)
          UI.message("processing #{target.name}")
          target.build_configurations.each do |config|
            config.build_settings['OTHER_SWIFT_FLAGS'] = '-Xfrontend -debug-time-compilation'
            config.build_settings['SWIFT_WHOLE_MODULE_OPTIMIZATION'] = 'YES'
          end
        end
        project.save()
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :scheme,
            description: "Build Scheme",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_configuration,
            description: "Build Configuration",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :workspace,
            description: "Workspace to profile",
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_paths,
            description: "Projects to profile",
            optional: false,
            is_string: false,
            type: Array
          ),
        ]
      end

      def self.description
        "Profile Swift compilation time"
      end

      def self.authors
        ["kateinoigakukun"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
