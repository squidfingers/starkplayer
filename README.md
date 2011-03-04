Travis Beckham  
[squidfingers.com](http://squidfingers.com/)

Audio Starkplayer
=================

Version: 0.9  
LangVersion: ActionScript 3.0  
AppVersion CS4  
PlayerVersion: Flash 10  

FlashVars:

* __url:__ The url to an mp3. Required.
* __autoplay:__ Automatically start to play the audio. Defaults to false.
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.

Notes:

* __Stage Size:__ 260 x 30

Video Starkplayer
=================

Version: 0.9  
LangVersion: ActionScript 3.0  
AppVersion CS4  
PlayerVersion: Flash 10  

FlashVars:

* __url:__ The url to an mp4 or flv. Required.
* __width__: The width the video player. Defaults to the Flash stage width.
* __height__: The height the video player. Defaults to the Flash stage height.
* __poster:__ The url to a jpg or png poster image. Optional.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __buffertime:__ The number of seconds to buffer before the video will start to play. Defaults to 10.
* __smoothing:__ Smooth the video. Defaults to false.
* __aspectratio:__ Adjust the aspect ratio of the video and poster image. Acceptable values are: maintain and stretch. Defaults to maintain.
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.

Notes:

* __Minimum Stage Size:__ 320 x 180

YouTube Starkplayer
===================

Version: 0.9  
LangVersion: ActionScript 3.0  
AppVersion CS4  
PlayerVersion: Flash 10  

FlashVars:

* __id:__ The id of the YouTube video. Required.
* __width__: The width the video player. Defaults to the Flash stage width.
* __height__: The height the video player. Defaults to the Flash stage height.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.
* __quality:__ The suggested quality of the video. Acceptable values are: default, small, medium, large, and hd720. If null, default will be used.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.

Notes:

* __Minimum Stage Size:__ 320 x 180

Gotchas
=======

The following items should be noted when using starkplayer.

* For audio, the mp3 should be __higher than 96 kbps__ to avoid a Flash bug where seeking causes Event.SOUND_COMPLETE to fire too early.
