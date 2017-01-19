#
# Be sure to run `pod lib lint SynqUploader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SynqUploader'
  s.version          = '0.3.3'
  s.summary          = 'SynqUploader is a simple Objective-C library that enables upload of videos from an iOS device to the SYNQ API'
  s.description      = <<-DESC
This library was created to make it easy to integrate SYNQ video uploading into your app.
Please note: this pod is just an add-on to the SYNQ API and is of no use unless you already have created a service for accessing the API, either directly or by using one of our SDKs. (http://docs.synq.fm)
                       DESC

  s.homepage         = 'https://github.com/SYNQfm/synquploader-ios.git'
  s.social_media_url = 'http://twitter.com/synqfm'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kjartan Vestvik' => 'kjartan@synq.fm' }
  s.source           = { :git => 'https://github.com/SYNQfm/synquploader-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SynqUploader/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SynqUploader' => ['SynqUploader/Assets/*.png']
  # }

  s.public_header_files = 'SynqUploader/Classes/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'SynqHttpLib', '~> 0.1'

end
