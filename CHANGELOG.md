
#CHANGLEOG

All notable changes to this project will be documented in this file.
***

##0.3.0
####Added:
* Play audio using ABMediaView
* Manage audio playback when ABMediaView is playing, using 'setPlaysAudioWhenPlayingMediaOnSilent' and 'setPlaysAudioWhenStoppingMediaOnSilent'
* Add 'Title' and 'Details' to display on the top of the ABMediaView
* Add a custom play button for media
* Functionality to set an ABMediaView with a video and image thumbnail, as well as a GIF preview. The user can press and hold on a ABMediaView to see the preview.
* Added delegates to knowing when an ABMediaView has changed values while minimizing, as well as knowing when minimization has ended.

####Updated:
* Added 'topBuffer' variable, to adjust the buffer space between the top of the ABMediaView and content on the top of the view (closeButton, topOverly). Presets are available for spacing equal to UIStatusBar, UINavigationBar, UITabBar, etc.
* Added listeners to adjust UI when app is going from foreground to background, and viseversa.

####Fixed:
* Issue where GIF from previous ABMediaView displayed was showing on the next ABMediaView
* Changed 'ABUtils' to 'ABCommons' to avoid conflicts when using the 'ABUtils' library seperately
* Issue where the screen was rotated, but the transition animation had not yet taken place, but the UI was adjusting as if it had.

##v0.2.4 (Includes all previous versions)
####Added:
* Image, Video, and GIF display.
* Lazy loading for image, video, and GIFs
* Minimization of ABMediaView to the bottom right corner, and swipe away to dismiss
* Queue for displaying ABMediaViews



