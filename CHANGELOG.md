
#CHANGLEOG

All notable changes to this project will be documented in this file.
***

##(Unreleased)

####Added:
* Set the value 'isDismissable' on an ABMediaView and it will add functionality to swipe down to dismiss a view instead of minimize it. This value supersedes 'isMinimizable' for the view, and can be utilized for content like images and GIFs, which don't necessarily need the minimizing functionality the same way that videos and audio do.
* 'resetMediaInView' which removes media from view while maintaining settings in view. ('resetVariables' removes both).
* 'customMusicButton' which specifies a custom play button to audio.
* Add delegate method 'mediaView:didSetImage:' to listen for when the 'image' property is set on the mediaView.
* Added option 'fileFromDirectory'. If set to true, then the file URL will be sourced from the Documents Directory when playing in the player.

####Fixed:
* Issue where isMinimizable was always set to true. Changed the function 'setCanMinimize' to 'setIsMinimizable', in order to avoid confusion with just setting the 'isMinimizable' value before and not getting the functionality.
* Issue where ABMediaView was not presenting from converted originRect in dynamic views. Using 'originRect' and 'setPresentFromOriginRect:' now works.
* Issue where audioURL and audioCache was not reset when 'resetVariables' is called.
* Calling 'setImageURL' now has the same effect as 'setImageURL:withCompletion' with nil completion.
* Made sure that 'image' property is being transferred to mediaView being presented from mediaView that is presenting.

####Removed:
* Removed the custom volumeView that replaced MPVolumeView. If the functionality is desired, check out the [ABVolumeControl](https://github.com/AndrewBoryk/ABVolumeControl) library, which provides the same functionality with much more customization.

##0.3.0 (2/4/17)
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



