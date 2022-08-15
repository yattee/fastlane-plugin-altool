require 'fastlane/action'
require_relative '../helper/altool_helper'

module Fastlane
  module Actions
    class AltoolAction < Action
      def self.run(params)
        altool = `xcrun -f altool`.chomp
        UI.message("altool binary doesn't exist at path: #{altool}") unless File.exist?(altool)

        UI.message(" ----altool binary exists on your machine----- ")

        altool_app_type = params[:altool_app_type]
        altool_ipa_path = "\"#{params[:altool_ipa_path]}\""
        altool_username = params[:altool_username]
        altool_output_format = params[:altool_output_format]

        ENV["ALTOOL_PASSWORD"] = params[:altool_password]
        altool_password = "@env:ALTOOL_PASSWORD"

        UI.message("========Validating and Uploading your IPA file to iTunes Connect=========")
        command = [
          altool,
          '--upload-app',
          '-t',
          altool_app_type,
          '-f',
          altool_ipa_path,
          '-u',
          altool_username,
          '-p',
          altool_password,
          '--output-format',
          altool_output_format
        ]
        Actions.sh(command.join(' '))
        UI.message("========It might take long time to fully upload your IPA file=========")
      end

      def self.description
        "Upload IPA to iTunes Connect using altool"
      end

      def self.authors
        ["Shashikant Jagtap"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin can be used for uploading ipa files to iTunes Connect using altool rather than using ITMSTransporter.. Currently Fastlane deliver upload an ipa file using iTMSTransporter tool. There is another slick command line too called altool that can be used to upload ipa files as well"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :altool_app_type,
                                    env_name: "ALTOOL_APP_TYPE",
                                    description: "Type or platform of application e.g osx, ios, appletvos ",
                                    default_value: "ios",
                                    is_string: true,
                                    optional: true),

          FastlaneCore::ConfigItem.new(key: :altool_ipa_path,
                                    env_name: "ALTOOL_IPA_PATH",
                                    description: "Path to IPA file ",
                                    is_string: true,
                                    default_value: Dir["*.ipa"].sort_by { |x| File.mtime(x) }.last,
                                    optional: false,
                                    verify_block: proc do |value|
                                      value = File.expand_path(value)
                                      UI.user_error!("Could not find file at path '#{value}'") unless File.exist?(value)
                                    end),

          FastlaneCore::ConfigItem.new(key: :altool_username,
                                    env_name: "ALTOOL_USERNAME",
                                    description: "Your Apple ID for iTunes Connects. This usually FASTLANE_USER environmental variable",
                                    is_string: true,
                                    default_value: ENV["FASTLANE_USER"],
                                    optional: false),

          FastlaneCore::ConfigItem.new(key: :altool_password,
                                    env_name: "ALTOOL_PASSWORD",
                                    description: "Your Apple ID Password for iTunes Connects. This usually FASTLANE_PASSWORD environmental variable",
                                    is_string: true,
                                    default_value: ENV["FASTLANE_PASSWORD"],
                                    optional: true),

          FastlaneCore::ConfigItem.new(key: :altool_output_format,
                                    env_name: "ALTOOL_OUTPUT_FORMAT",
                                    description: "Output formal xml or normal ",
                                    default_value: "normal",
                                    is_string: true,
                                    optional: true)

        ]
      end

      def self.example_code
        ['   altool(
            altool_username: ENV["FASTLANE_USER"],
            altool_password: ENV["FASTLANE_PASSWORD"],
            altool_app_type: "ios",
            altool_ipa_path: "./build/Your-ipa.ipa",
            altool_output_format: "xml",
        )
       ']
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
