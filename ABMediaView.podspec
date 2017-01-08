#
# Be sure to run `pod lib lint ABMediaView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ABMediaView'
  s.version          = '0.1.1'
  s.summary          = 'UIImageView subclass which can display and load images & videos from the web, with fullscreen and minimized mode functionality.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ABMediaView can display images or videos. It subclasses UIImageView, and can also lazy-load images from the web. In addition, it can also display videos, downloaded via URL from disk or web. In addition, videos contain a player with timeline and scrubbing. A major added functionality is that this mediaView has a queue and can present mediaViews in fullscreen mode. There is functionality which allows the view to be minimized by swiping, where it sits in the bottom right corner as a thumbnail. Videos can continue playing and be heard from this position. The user can choose to swipe the view away to dismiss. There various different functionality that can be toggled on and off to customize the view to one's choosing.
DESC

  s.homepage         = 'https://github.com/andrewboryk/ABMediaView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Boryk' => 'andrewcboryk@gmail.com' }
  s.source           = { :git => 'https://github.com/andrewboryk/ABMediaView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ABMediaView/Classes/**/*'

  # s.resource_bundles = {
  #   'ABMediaView' => ['ABMediaView/Assets/PlayVideoButton.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
