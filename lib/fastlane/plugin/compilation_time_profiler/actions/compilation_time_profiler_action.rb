require 'fastlane/action'
require_relative '../helper/compilation_time_profiler_helper'
require_relative '../parser'

module Fastlane
  module Actions
    class CompilationTimeProfilerAction < Action
      def self.run(params)
        params[:project_paths].each do |project_path|
          override_config(project_path)
        end
        buildlog_dir = Dir.mktmpdir
        build_config = {
          workspace: params[:workspace],
          scheme: params[:scheme],
          clean: true,
          raw_buildlog: true,
          buildlog_path: buildlog_dir
        }
        XcbuildAction.run(build_config)
        params[:project_paths].each do |project_path|
          restore_projects(project_path)
        end

        buildlog_path = Pathname.new(buildlog_dir).join("xcodebuild.log").to_s

        parser = CompilationStatisticsParser.new
        File.read(buildlog_path).lines.each do |line|
          parser.parse(line)
        end
        parser.finalize
      end

      def self.override_config(project_path)
        project = Xcodeproj::Project.open(project_path)
        project.save(backup_project_path(project_path))
        project.targets.each do |target|
          UI.message("processing #{target.name}")
          target.build_configurations.each do |config|
            config.build_settings['OTHER_SWIFT_FLAGS'] = '-Xfrontend -debug-time-compilation'
            config.build_settings['SWIFT_WHOLE_MODULE_OPTIMIZATION'] = 'YES'
          end
        end
        project.save(project_path)
      end

      def self.restore_projects(project_path)
        FileUtils.remove_dir(project_path)
        FileUtils.mv(backup_project_path(project_path), project_path, force: true)
      end

      def self.backup_project_path(original_project_path)
        original_project = Pathname.new(original_project_path)
        backup_project_name = original_project.basename.sub(/(.+)\./) { "#{$1}_Profile." }
        original_project.dirname.join(backup_project_name).to_s
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
          )
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
