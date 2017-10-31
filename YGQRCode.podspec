Pod::Spec.new do |s|  
  s.name             = "YGQRCode"
  s.version          = "1.0.0"
  s.summary          = "A marquee view used on iOS."
  s.description      = <<-DESC  
                       It is a marquee view used on iOS, which implement by Objective-C.  
                       DESC
  s.homepage         = "https://github.com/rays77/YGQRCode"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  # s.license          = 'MIT'
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "wuyiguang" => "rays77@163.com" }
  s.source           = { :git => "https://github.com/rays77/YGQRCode.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'  

  s.platform     = :ios, '8.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true
  
  # "*" 表示匹配所有文件
  # "*.{h,m}" 表示匹配所有以.h和.m结尾的文件
  # "**" 表示匹配所有子目录
  s.source_files = 'YGQRCode/YGQRCode/**/*.{h,m}'
  # s.resources = 'Assets'
  
  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'  
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
  
end
