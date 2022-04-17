Pod::Spec.new do |spec|

  spec.name          = "RB"
  spec.version       = ENV['LIB_VERSION'] || '1.0'
  spec.swift_version = "4.2"
  spec.summary       = "RB unified engine IOS SDK"
  spec.description   = "RB unified engine official IOS SDK"
  spec.platform      = :ios, '8.0'
  spec.ios.deployment_target = "10.0"
  spec.homepage      = "https://github.com/relevantbox/harray-ios-sdk"
  spec.license       = { :type => "MIT", :file => "LICENSE" }
  spec.author        = { "RB Development Team" => "developer@relevantbox.io" }
  spec.source        = { :git => "https://github.com/relevantbox/harray-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "harray-ios-sdk/**/*.{h,m,swift,xib}"
  spec.resources = ['harray-ios-sdk/**/*.png']
end
