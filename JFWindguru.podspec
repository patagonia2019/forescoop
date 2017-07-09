#
# Be sure to run `pod lib lint JFWindguru.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JFWindguru'
  s.version          = '0.1.0'
  s.summary = "This is the JFWindguru library to use when building weather applications."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Use this framework in Swift to get windGURU service for forecasting weather. Forecasts are based on data produced by weather forecast models. Windguru is able to provide forecast for any place on planet Earth. The main reason to create this framework in Swift language is to maintain an easy way to use inside an iOS app.
                       DESC

  s.homepage = "https://bitbucket.org/southfox/jfwindguru"
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { "Javier Fuchs" => "javier.fuchs@gmail.com" }
  s.source           = { :git => 'https://github.com/southfox/JFWindguru.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.2'

  s.source_files = 'JFWindguru/Classes/**/*'
  
  s.dependency 'AlamofireObjectMapper', '~> 4.0'
  s.dependency 'JFCore', '~> 0.1.0'

end
