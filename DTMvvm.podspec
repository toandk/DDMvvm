#
# Be sure to run `pod lib lint DTMvvm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DTMvvm'
  s.version          = '1.6.9'
  s.summary          = 'A MVVM library for iOS Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A MVVM library for iOS Swift, including interfaces for View, ViewModel and Model, DI and Services
                       DESC

  s.homepage         = 'https://github.com/toandk/DTMvvm.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ToanDK' => 'dkt204@gmail.com' }
  s.source           = { :git => 'https://github.com/toandk/DTMvvm.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DTMvvm/Classes/**/*'

  # s.resource_bundles = {
  #   'DTMvvm' => ['DTMvvm/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'

  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'Action'
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'ObjectMapper'
  s.dependency 'PureLayout'
  s.dependency 'Moya'
end
