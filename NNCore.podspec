Pod::Spec.new do |s|

  s.name         = "NNCore"
  s.version      = "1.0.0"
  s.summary      = "NNCore"
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.description  = <<-DESC
                    Core functions for ios model development.
                   DESC
  s.homepage     = "http://github.com/rcio/NNCore"
  s.license      = "MIT"
  s.author       = { "gfwangfei" => "gfwangfei@oa.gf.com.cn" }
  s.source       = { :git => "https://github.com/rcio/NNCore.git", :tag => "1.0.0" }
  s.source_files  = "NNCore/*.{h,m}", "NNCore/**/*.{h,m}"
  s.prefix_header_contents = '#import "NNCore.h"'
  s.dependency   = "Reachability"
end
