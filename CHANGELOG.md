
# CHANGLEOG

All notable changes to this project will be documented in this file.
***

## 0.4.2 (7/7/17)

#### Added:
* Setting the 'shouldDismissAfterFinish' variable on a mediaView will have it dismiss after it finished playing its video. This value take precedence over 'allowLooping' when mediaView is fullscreen.
* Utilize the 'mediaViewDidFinishVideo:withLooping' delegate method to take action after a mediaView has completed playing of its video. This delegate also lets you know whether the mediaView will loop (this delegate is called before the video loops).

#### Updated:
* Moved the following variables to public read-only so that they can be utilized:
  * 'minViewHeight' is the width the mediaView will be when fully minimized
  * 'minViewHeight' is the height the mediaView will be when fully minimized
  * 'maxViewOffset' is the maximum space between the top of the mediaView and the top of its superview, when fully minimized
  * 'offsetPercentage' is the fraction (0 to 1) by which the mediaView has completed minimization 
  * 'superviewWidth' is the width of view which presents the mediaView
  * 'superviewHeight' is the height of view which presents the mediaView
* Tune ups for caching

## 0.4.1 (3/4/17)

#### Added:
* Automated Caching for Images, GIFs and Videos, enabled by setting the variable 'setShouldCacheMedia' on the ABMediaView sharedManager.
* Ability to preload video and audio before being shown by calling 'preloadVideo' or 'preloadAudio' on a mediaView, or automatically handled by setting 'shouldPreloadVideoAndAudio' variable on the ABMediaView sharedManager.
* Ability to clear Documents directory and tmp directory cached files, by calling 'clearABMediaDirectory' class method of ABMediaView and providing one of the following:
  * 'VideoDirectoryItems' to remove cached videos on disk loaded from ABMediaView
  * 'AudioDirectoryItems' to remove cached audio on disk loaded from ABMedaiView
  * 'AllDirectoryItems' to remove cached videos and audio on disk loaded from ABMedaiView
  * 'TempDirectoryItems' to remove cached files in tmp directory folder
* Functionality to not have a play button be visible by setting 'playButtonHidden' on the ABMediaView. Usefull if one is looking to use ABMediaView in a video background.
* Tests added to ensure that caching is working properly.

#### Updated
* Media is checked to see if proper format is received from NSURL before downloading.
* Adjusted the following loader functions to seperate loading with a NSString and loading from a given NSURL (useful if specifying loading media from a location not on the web). Functions are available in ABCacheManager.
  * 'loadImage' with NSString, 'loadImageURL' with NSURL
  * 'loadVideo' with NSString, 'loadVideoURL' with NSURL
  * 'loadAudio' with NSString, 'loadAudioURL' with NSURL
  * 'loadGIF' with NSString, 'loadGIFURL' with NSURL
* Detects if the video/audio failed to load, and shows a failed indicator. A custom failed indicator can be set with 'setCustomFailedButton' on the ABMediaView.
* 'hideCloseButton' was changed to 'closeButtonHidden' to match the new 'playButtonHidden' variable better.
* 'videoIndicator' (the view which held the play button image) was changed to 'playIndicatorView' to better encompass that it is visible when both video and audio is in the mediaView.

#### Fixed
* Media looking to be downloaded from ipod-library is now properly loaded and cached is specified.
* AVURLAsset in exporting videos from stream changed to AVAsset.

## 0.3.1 (2/18/17)

#### Added:
* Set the value 'isDismissable' on an ABMediaView and it will add functionality to swipe down to dismiss a view instead of minimize it. This value supersedes 'isMinimizable' for the view, and can be utilized for content like images and GIFs, which don't necessarily need the minimizing functionality the same way that videos and audio do.
* 'resetMediaInView' which removes media from view while maintaining settings in view. ('resetVariables' removes both).
* 'customMusicButton' which specifies a custom play button to audio.
* Add delegate method 'mediaView:didSetImage:' to listen for when the 'image' property is set on the mediaView.
* Added option 'fileFromDirectory'. If set to true, then the file URL will be sourced from the Documents Directory when playing in the player.

#### Fixed:
* Issue where isMinimizable was always set to true. Changed the function 'setCanMinimize' to 'setIsMinimizable', in order to avoid confusion with just setting the 'isMinimizable' value before and not getting the functionality.
* Issue where ABMediaView was not presenting from converted originRect in dynamic views. Using 'originRect' and 'setPresentFromOriginRect:' now works.
* Issue where audioURL and audioCache was not reset when 'resetVariables' is called.
* Calling 'setImageURL' now has the same effect as 'setImageURL:withCompletion' with nil completion.
* Made sure that 'image' property is being transferred to mediaView being presented from mediaView that is presenting.

#### Removed:
* Removed the custom volumeView that replaced MPVolumeView. If the functionality is desired, check out the [ABVolumeControl](https://github.com/AndrewBoryk/ABVolumeControl) library, which provides the same functionality with much more customization.

## 0.3.0 (2/4/17)
#### Added:
* Play audio using ABMediaView
* Manage audio playback when ABMediaView is playing, using 'setPlaysAudioWhenPlayingMediaOnSilent' and 'setPlaysAudioWhenStoppingMediaOnSilent'
* Add 'Title' and 'Details' to display on the top of the ABMediaView
* Add a custom play button for media
* Functionality to set an ABMediaView with a video and image thumbnail, as well as a GIF preview. The user can press and hold on a ABMediaView to see the preview.
* Added delegates to knowing when an ABMediaView has changed values while minimizing, as well as knowing when minimization has ended.

#### Updated:
* Added 'topBuffer' variable, to adjust the buffer space between the top of the ABMediaView and content on the top of the view (closeButton, topOverly). Presets are available for spacing equal to UIStatusBar, UINavigationBar, UITabBar, etc.
* Added listeners to adjust UI when app is going from foreground to background, and viseversa.

#### Fixed:
* Issue where GIF from previous ABMediaView displayed was showing on the next ABMediaView
* Changed 'ABUtils' to 'ABCommons' to avoid conflicts when using the 'ABUtils' library seperately
* Issue where the screen was rotated, but the transition animation had not yet taken place, but the UI was adjusting as if it had.

## v0.2.4 (Includes all previous versions)
#### Added:
* Image, Video, and GIF display.
* Lazy loading for image, video, and GIFs
* Minimization of ABMediaView to the bottom right corner, and swipe away to dismiss
* Queue for displaying ABMediaViews



