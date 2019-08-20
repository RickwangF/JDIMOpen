#
# Be sure to run `pod lib lint JDIMOpen.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JDIMOpen'
  s.version          = '0.1.0'
  s.summary          = 'IM模块'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Just IM Module Of JD used for test
                       DESC

  s.homepage         = 'https://github.com/RickwangF/JDIMOpen
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'woshiwwy16@126.com' => 'woshiwwy16@126.com' }
  s.source           = { :git => 'https://github.com/RickwangF/JDIMOpen.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'JDIMOpen/Classes/**/*'
  s.resources = ['/JDIMOpen/Assets/images.bundle', '/JDIMOpen/Assets/animations.bundle', '/JDIMOpen/Assets/emojis.bundle']
  
  # s.resource_bundles = {
  #   'JDIMOpen' => ['JDIMOpen/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MJExtension'
  s.dependency 'SDWebImage'
  s.dependency 'NIMSDK_LITE'
  s.dependency 'ZSBaseUtil'
  s.dependency 'lottie-ios'
  s.dependency 'ZSPreViewSDK'
  s.dependency 'ZSToastUtil'
  s.dependency 'JDNetService'
  s.dependency 'JDIMService'
  s.dependency 'MJRefresh'
  s.dependency 'TZImagePickerController'
end
