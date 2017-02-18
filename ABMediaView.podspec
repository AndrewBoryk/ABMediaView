#
# Be sure to run `pod lib lint ABMediaView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ABMediaView'
  s.version          = '0.3.1'
s.summary          = 'UIImageView subclass which can display and lazy-load images, videos, GIFs and audio easily, with fullscreen and minimized mode functionality'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ABMediaView can display images, videos, as well as now GIFs and Audio! It subclasses UIImageView, and has functionality to lazy-load images from the web. In addition, it can also display videos, downloaded via URL from disk or web. Videos contain a player with a timeline and scrubbing. GIFs can also be displayed in an ABMediaView, via lazy-loading from the web, or set via NSData. The GIF that is downloaded is saved as a UIImage object for easy storage. Audio can also be displayed in the player by simply providing a url from the web or on disk. A major added functionality is that this mediaView has a queue and can present mediaViews in fullscreen mode. There is functionality which allows the view to be minimized by swiping, where it sits in the bottom right corner as a thumbnail. Videos can continue playing and be heard from this position. The user can choose to swipe the view away to dismiss. There are various different functionality that can be toggled on and off to customize the view to one's choosing.


DESC

  s.homepage         = 'https://github.com/andrewboryk/ABMediaView'
  s.screenshots      = 'https://raw.githubusercontent.com/AndrewBoryk/ABMediaView/dev/ABMediaViewScreenshot.gif', 'https://raw.githubusercontent.com/AndrewBoryk/ABMediaView/dev/ABMediaViewScrubScreenshot.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Boryk' => 'andrewcboryk@gmail.com' }
  s.source           = { :git => 'https://github.com/andrewboryk/ABMediaView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/TrepIsLife'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ABMediaView/Classes/**/*'

  # s.resource_bundles = {
  #   'ABMediaView' => ['ABMediaView/Assets/PlayVideoButton.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
