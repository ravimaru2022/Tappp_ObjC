#
# Be sure to run `pod lib lint Tappp_ObjC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'Tappp_ObjC'
  spec.version          = '0.1.1'
  spec.summary          = 'A short description of Tappp_ObjC.'
  spec.description  = "This will be test description for inmplememting pod file."

  spec.homepage     = "https://github.com/ravimaru2022/Tappp_ObjC.git"
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "ravimaru2022" => "ravi.maru@tudip.com" }

  spec.ios.deployment_target = "13.0"

  spec.source           = { :git => 'https://github.com/ravimaru2022/Tappp_ObjC.git', :tag => spec.version }
  # spec.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.ios.deployment_target = '10.0'

  spec.source_files = 'Tappp_ObjC/*.{h,m}'
  
  spec.resource_bundles = {
    'Resources' => ['Assets/*.png',
                    'Tappp_ObjC/Resources/*.html', 
                    'Tappp_ObjC/Resources/*.js']
  }

  # spec.public_header_files = 'Pod/Classes/**/*.h'
  # spec.frameworks = 'UIKit', 'MapKit'
  # spec.dependency 'AFNetworking', '~> 2.3'
end
