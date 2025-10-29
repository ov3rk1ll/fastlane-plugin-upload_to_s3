module Fastlane
  module Actions
    module SharedValues
      S3_FILE_OUTPUT_PATH = :S3_FILE_OUTPUT_PATH
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class UploadToS3Action < Action
	  def self.add_slash(str)
	    safe_str = str || ""
		safe_str.empty? ? "" : "#{safe_str}/"
	  end
	  
      def self.run(params)

        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.verbose("Key: #{params[:key]}")
        UI.verbose("File: #{params[:file]}")
        UI.verbose("Bucket: #{params[:bucket]}")
        UI.verbose("ACL: #{params[:acl]}")

        # Pulling parameters for other uses
        s3_endpoint = params[:endpoint]
        s3_region = params[:region]
        s3_subdomain = params[:region] ? "s3-#{params[:region]}" : "s3"
        s3_access_key = params[:access_key]
        s3_secret_access_key = params[:secret_access_key]
        s3_bucket = params[:bucket]
        s3_key = params[:key]
        s3_body = params[:file]
        s3_acl = params[:acl]

        Actions.verify_gem!('aws-sdk')
        require 'aws-sdk'

        if s3_endpoint
		  UI.verbose("S3-Client with endpoint: #{s3_endpoint}")
          s3_client = Aws::S3::Client.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key,
            endpoint: s3_endpoint,
			region: "us-east-1"
          )
		elsif s3_region
		  UI.verbose("S3-Client with region: #{s3_region}")
          s3_client = Aws::S3::Client.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key,
            region: s3_region
          )
        else
		  UI.verbose("S3-Client with default region")
          s3_client = Aws::S3::Client.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
          )
        end

        File.open(s3_body, 'r') do |file|

          response = s3_client.put_object(
            acl: s3_acl,
            bucket: s3_bucket,
            key: s3_key,
            body: file
          )
        end
		
		UI.verbose("uploaded: #{s3_body} to #{s3_bucket}/#{s3_key}")

        Actions.lane_context[SharedValues::S3_FILE_OUTPUT_PATH] = "#{add_slash(params[:bucket_url])}#{s3_bucket}/#{s3_key}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uploads a binary file to s3."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
		  FastlaneCore::ConfigItem.new(key: :bucket_url,
                                       env_name: "S3_BUCKET_URL",
                                       description: "Endpoint for S3",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: true), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "S3_ENDPOINT",
                                       description: "Endpoint for S3",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: true), # the default value if the user didn't provide one
		  FastlaneCore::ConfigItem.new(key: :region,
                                       env_name: "S3_REGION",
                                       description: "Region for S3",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: true), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :access_key,
                                       env_name: "S3_ACCESS_KEY", # The name of the environment variable
                                       description: "Access Key for S3", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Access key for UploadToS3Action given, pass using `access_key: 'access_key'`".red unless (value and not value.empty?)
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                       env_name: "S3_SECRET_ACCESS_KEY", # The name of the environment variable
                                       description: "Secret Access for S3", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Secret Access for UploadToS3Action given, pass using `secret_access_key: 'secret_access_key'`".red unless (value and not value.empty?)
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                       env_name: "S3_BUCKET", # The name of the environment variable
                                       description: "Bucket for S3", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Bucket for UploadToS3Action given, pass using `bucket: 'bucket'`".red unless (value and not value.empty?)
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "",
                                       description: "Key to s3 bucket",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :acl,
                                       env_name: "",
                                       description: "Access level for the file",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: "private"),
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "", # The name of the environment variable
                                       description: "File to be uploaded for S3", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['S3_FILE_OUTPUT_PATH', 'URL of the uploaded file.']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["ov3rk1ll"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        true
      end
    end
  end
end