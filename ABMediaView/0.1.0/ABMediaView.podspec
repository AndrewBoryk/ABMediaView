#
# Be sure to run `pod lib lint ABMediaView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ABMediaView'
  s.version          = '0.1.0'
  s.summary          = 'ABMediaView provides a view that can display an image and play a video.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'With ABMediaView, one can drop in a view that is able to display images or videos. The image lazy-loading is by the view, or can be implemented view datasource. The same applies for videos. In addition, videos contain a player with timeline and scrubbing.'

  s.homepage         = 'https://github.com/andrewboryk/ABMediaView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Boryk' => 'andrewcboryk@gmail.com' }
  s.source           = { :git => 'https://github.com/andrewboryk/ABMediaView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ABMediaView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ABMediaView' => ['ABMediaView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
