require 'fastlane/action'
require_relative '../helper/compilation_time_profiler_helper'

module Fastlane
  module Actions
    class CompilationTimeProfilerAction < Action
      def self.run(params)
        if params[:project_paths]
          UI.deprecated("The 'project_paths' parameter is not used anymore. Please just remove it")
        end
        ENV["XCODE_XCCONFIG_FILE"] = File.expand_path("../../resources/profile.xcconfig", __FILE__)
        params[:action].call
        parser = CompilationStatisticsParser.new
        buildlog_file = Dir.glob("#{params[:buildlog_path]}/*.log").first
        File.read(buildlog_file).lines.each do |line|
          parser.parse(line)
        end
        parser.finalize
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :project_paths,
            description: "Project paths to profile",
            optional: true,
            is_string: false,
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :buildlog_path,
            description: "Path to xcodebuild.log",
            optional: false,
            is_string: true
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
