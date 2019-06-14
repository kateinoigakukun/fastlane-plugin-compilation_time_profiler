require 'fastlane/action'
require_relative '../helper/compilation_time_profiler_helper'

module Fastlane
  module Actions
    class CompilationTimeProfilerAction < Action
      def self.run(params)
        params[:project_paths].each do |project_path|
          backup_project(project_path)
          override_config(project_path)
        end
        params[:action].call()
        params[:project_paths].each do |project_path|
          restore_projects(project_path)
        end

        parser = CompilationStatisticsParser.new
        buildlog_file = Dir.glob("#{params[:buildlog_path]}/*.log").first
        File.read(buildlog_file).lines.each do |line|
          parser.parse(line)
        end
        parser.finalize
      end

      def self.override_config(project_path)
        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configurations.each do |config|
            config.build_settings['OTHER_SWIFT_FLAGS'] = '-Xfrontend -debug-time-compilation'
            config.build_settings['SWIFT_WHOLE_MODULE_OPTIMIZATION'] = 'YES'
          end
        end
        project.save(project_path)
      end

      def self.backup_project(project_path)
        FileUtils.remove_dir(backup_project_path(project_path), force: true)
        FileUtils.cp_r(project_path, backup_project_path(project_path))
      end

      def self.restore_projects(project_path)
        FileUtils.remove_dir(project_path)
        FileUtils.move(backup_project_path(project_path), project_path, force: true)
      end

      def self.backup_project_path(original_project_path)
        original_project = Pathname.new(original_project_path)
        backup_project_name = original_project.basename.sub(/(.+)\./) { "#{$1}_Profile." }
        original_project.dirname.join(backup_project_name).to_s
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :project_paths,
            description: "Project paths to profile",
            optional: false,
            is_string: false,
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :buildlog_path,
            description: "Path to xcodebuild.log",
            optional: false,
            is_string: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :action,
            description: "Build action to profile like scan",
            optional: false,
            is_string: false,
            type: Proc
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
        platform == :ios
      end
    end
  end
end
