lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/upload_to_s3/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-upload_to_s3'
  spec.version       = Fastlane::UploadToS3::VERSION
  spec.author        = 'ov3rk1ll'
  spec.email         = 'overkillerror@gmail.com'

  spec.summary       = 'Upload any file to S3 or a S3-compatible host'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-upload_to_s3"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'aws-sdk', '~> 3.0'
end
