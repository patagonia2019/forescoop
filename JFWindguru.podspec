#
# check the pod using: 'pod lib lint JFWindGuru.podspec' to ensure this is a valid spec 
#

Pod::Spec.new do |s|
  s.name = "JFWindguru"
  s.version = "0.1.3"
  s.summary = "This is the JFWindguru library to use when building weather applications."
  s.homepage = "https://bitbucket.org/southfox/jfwindguru"
  s.license = 'None'
  s.authors = { "Javier Fuchs" => "javier.fuchs@gmail.com" }
  s.source = { :git => "https://bitbucket.org/southfox/jfwindguru.git", :branch => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.2'

  s.requires_arc = true

  s.source_files = 'JFWindguru/**/*.{h,m,swift}'

  s.dependency 'AlamofireObjectMapper', '~> 2.1'

end
