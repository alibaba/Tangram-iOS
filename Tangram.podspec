Pod::Spec.new do |s|

  s.name         = "Tangram"
  s.version      = "2.1.1"
  s.summary      = "Tangram is a modular UI solution for building native page dynamically & quickly."
  
  s.description  = <<-DESC
                   Tangram is a modular UI solution for building native page dynamically & quickly.
                   And Tangram 2.x with VirtualView can create & release UI component dynamically.
                   The solution also have an implementation for Andriod platform.
                   DESC

  s.homepage     = "https://github.com/alibaba/Tangram-iOS"
  s.license      = { :type => 'MIT' }
  s.author       = { "fydx"       => "lbgg918@gmail.com",
                     "HarrisonXi" => "gpra8764@gmail.com"}
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/alibaba/Tangram-iOS.git", :tag => "2.1.1" }
  s.resources    = 'Tangram/Resources/*'
  s.source_files = 'Tangram/**/*.{h,m}'
  
  s.dependency 'LazyScroll', '~> 1.0'
  s.dependency 'VirtualView', '~> 1.1'
  s.dependency 'SDWebImage', '~> 4.2'
  
end
