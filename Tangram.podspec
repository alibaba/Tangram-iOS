Pod::Spec.new do |s|

  s.name         = "Tangram"
  s.version      = "1.0.7"
  s.summary      = "Tangram is a UI Framework for building a fast and dynamic ScrollView."
  
  s.description  = <<-DESC
                   Tangram is a UI Framework for building a fast and dynamic ScrollView, with two platform support(Android & iOS)
                   DESC

  s.homepage     = "https://github.com/alibaba/tangram-ios"
  s.license      = { :type => 'MIT' }
  s.author       = { "fydx"       => "lbgg918@gmail.com",
                     "HarrisonXi" => "gpra8764@gmail.com"}
  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/alibaba/Tangram-iOS.git", :tag => "1.0.7" }
  s.resources    = 'Tangram/Resource/*.{plist,json}'
  s.source_files = 'Tangram/Source/**/*.{h,m}'
  
  s.dependency  'LazyScroll', '~>0.1.0'
  s.dependency  'SDWebImage', '~>4.2'
  
end
