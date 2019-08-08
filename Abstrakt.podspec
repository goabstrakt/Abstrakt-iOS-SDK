#
# Be sure to run `pod lib lint Abstrakt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Abstrakt'
  s.version          = '0.1.0'
  s.summary          = 'Don\'t Reinvent The Wheel! We did the heavy lifting for you so you can skip the details and focus on your blockchain application.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Abstrakt's SDK, is a plug & play blockchain interface for your iOS application. Our SDK takes the responsibility of developing, managing, and maintaining much of the essential infrastructure critical from blockchain dapp development. For a high level overview of what Vault Engine offers, checkout https://goabstrakt.com/sdk/
                       DESC

  s.homepage         = 'https://github.com/goabstrakt/Abstrakt-iOS-SDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anxari' => 'ameed@vaultwallet.io' }
  s.source           = { :git => 'https://github.com/goabstrakt/Abstrakt-iOS-SDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.source_files = 'AbstraktSDK.framework/Headers/*.h'
  s.vendored_frameworks = '*.framework'
  

  s.ios.deployment_target = '10.0'
  s.swift_versions = '4.2'

  #s.source_files = 'Abstrakt/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Abstrakt' => ['Abstrakt/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'Charts', '~> 3.1.1'
  # s.dependency 'Floaty', '~> 4.1.0'
   s.dependency 'SwiftyJSON', '~> 4.1.0'
   s.dependency 'Auth0', '~> 1.13.0'
   s.dependency 'JWTDecode', '~> 2.1'
   s.dependency 'KeychainSwift', '~> 13.0'
   s.dependency 'CryptoSwift', '~> 0.13.1'
   s.dependency 'BigInt', '~> 3.1'
   s.dependency 'secp256k1.swift'
   s.dependency 'SocketRocket'
   s.dependency 'HockeySDK'
end
