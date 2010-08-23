__Flash Development:__  
Travis Beckham  
[squidfingers.com](http://squidfingers.com/)

__jQuery Plugin:__  
Alan Christopher Thomas  
[alanchristopherthomas.com](http://alanchristopherthomas.com/)

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
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.

Notes:

* __Minimum Stage Size:__ 320 x 240

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
* __quality:__ The suggested quality of the video. Acceptable values are: default, small, medium, large, and hd720. If null, default will be used. Optional.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.

Notes:

* __Minimum Stage Size:__ 320 x 240

jQuery Plugin
=============

Depends on SWFObject ([http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js](http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js))

The jQuery plugin replaces HTML alternate content with starkplayer. When Flash is unsupported, the alternate content will be displayed instead (degrading gracefully to HTML5-only platforms).

Installation
------------

Include SWFObject, jQuery, and the starkplayer jQuery plugin in the `<head>` section of your HTML document:

    <script src="http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js" type="text/javascript"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript"></script>
    <script src="starkplayer/jquery.starkplayer.min.js" type="text/javascript"></script>

Replacing Any Content With Starkplayer
--------------------------------------

### Example Content ###

    <div id="media-content">
        This is the alternate content that will be displayed if Flash is
        unsupported.
    </div>

### Audio ###

    <script type="text/javascript">
        $(document).ready(function() {
            $('#media-content').starkplayer({
                type: 'audio',
                url: 'audio/song.mp3',
                audioplayer: 'starkplayer/audioplayer.swf'
            });
        });
    </script>

Parameters:

* __type:__ The type of media to display ('audio', 'video', or 'youtube'). By default, type will be set to 'audio' for HTML5 audio or links to urls that have audio file extensions.
* __url:__ The url to an mp3. Defaults to media sniffed out from alternate content.
* __autoplay:__ Automatically start to play the audio. Defaults to false.
* __border:__ The hexadecimal color of the border. If omitted, a border will not be displayed.
* __bgcolor:__ The background color of the Flash player.
* __audioplayer:__ The url to audioplayer.swf. Defaults to the same directory as the HTML file.

### Video ###

    <script type="text/javascript">
        $(document).ready(function() {
            $('#media-content').starkplayer({
                type: 'video',
                url: 'videos/video.mp4',
                poster: 'images/poster.jpg',
                width: '640',
                height: '385',
                logo: 'graphics/logo.png',
                videoplayer: 'starkplayer/videoplayer.swf'
            });
        });
    </script>

Parameters:

* __type:__ The type of media to display ('audio', 'video', or 'youtube'). By default, type will be set to 'video' for HTML5 video or links to urls that have video file extensions.
* __url:__ The url to an mp4 or flv. Defaults to media sniffed out from alternate content.
* __poster:__ The url to a jpg or png poster image. Defaults to poster image sniffed out from alternate content.
* __width:__ The width of the player. Defaults to the width of the content it replaces.
* __height:__ The height of the player. Defaults to the height of the content it replaces.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __buffertime:__ The number of seconds to buffer before the video will start to play. Defaults to 10.
* __border:__ The hexadecimal color of the border. If omitted, a border will not be displayed.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.
* __videoplayer:__ The url to videoplayer.swf. Defaults to the same directory as the HTML file.

### YouTube ###

    <script type="text/javascript">
        $(document).ready(function() {
            $('.media').starkplayer({
                type: 'youtube',
                youtubeid: '[VIDEO_ID]',
                width: '640',
                height: '385',
                quality: 'hd720',
                logo: 'graphics/logo.png',
                youtubeplayer: 'starkplayer/youtubeplayer.swf'
            });
        });
    </script>

Parameters:

* __type:__ The type of media to display ('audio', 'video', or 'youtube'). By default, type will be set to 'youtube' for links or embed code with youtube urls.
* __youtubeid:__ The id of the YouTube video.
* __width:__ The width of the player. Defaults to the width of the content it replaces.
* __height:__ The height of the player. Defaults to the height of the content it replaces.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __border:__ The hexadecimal color of the border. If omitted, a border will not be displayed.
* __quality:__ The suggested quality of the video. Acceptable values are: default, small, medium, large, and hd720.
* __logo:__ The logo to be displayed over the top right corner of the video.
* __youtubeplayer:__ The url to youtubeplayer.swf. Defaults to the same directory as the HTML file.

Replacing HTML5 And Links With Starkplayer
------------------------------------------

The jQuery plugin is able to replace any element with starkplayer, but certain structures, when used, do not require all starkplayer parameters to be explicitly declared. The plugin will automatically sniff out media types and content for these structures, as documented below.

### Audio ###

#### Using HTML5 ####

With one source:

    <audio class="media" src="audio/song.mp3" controls>
        No sound for you.
    </audio>

With multiple sources (the first source found will be used in starkplayer):

    <audio class="media" controls>
        <source src="audio/song.mp3">
        <source src="audio/song.ogg">
        No sound for you.
    </audio>

#### Using Links ####

The href of the link will be used as the audio source.

    <a class="media" href="audio/song.mp3">
        Download MP3
    </a>

#### Replacing With Starkplayer ####

    <script type="text/javascript">
        $(document).ready(function() {
            $('.media').starkplayer({
                border: '#666666',
                bgcolor: '#ffffff',
                audioplayer: 'starkplayer/audioplayer.swf'
            });
        });
    </script>

### Video ###

#### Using HTML5 ####

With one source:

    <video class="media" src="videos/video.mp4" poster="images/poster.jpg"
            width="640" height="385" controls>
        No video for you.
    </video>

With multiple sources (the first source found will be used in starkplayer):

    <video class="media" poster="images/poster.jpg" width="640" height="385"
            controls>
        <source src="videos/video.mp4">
        <source src="videos/video.ogg">
        <source src="videos/video.webm">
        No video for you.
    </video>

#### Using Links ####

The href of the link will be used as the video source. If it contains a nested image, this will be the video poster image.

    <a class="media" href="videos/video.mp4"
            style="display: block; width: 640px; height: 385px;">
        <img src="images/poster.jpg" alt="No video for you.">
    </a>

#### Replacing With Starkplayer ####

    <script type="text/javascript">
        $(document).ready(function() {
            $('.media').starkplayer({
                border: '#000000',
                logo: 'graphics/logo.png',
                videoplayer: 'starkplayer/videoplayer.swf'
            });
        });
    </script>

### YouTube ###

#### Using HTML5 YouTube Embed Code ####

    <iframe class="media" width="640" height="385" frameborder="0"
            src="http://www.youtube.com/embed/[VIDEO_ID]"></iframe>

#### Using Links ####

The href of the link will be used as the YouTube video source.

    <a class="media" href="http://www.youtube.com/watch?v=[VIDEO_ID]"
            style="display: block; width: 640px; height: 385px;">
        Watch on YouTube
    </a>

#### Replacing With Starkplayer ####

    <script type="text/javascript">
        $(document).ready(function() {
            $('.media').starkplayer({
                border: '#000000',
                quality: 'hd720',
                youtubeplayer: 'starkplayer/youtubeplayer.swf'
            });
        });
    </script>

Gotchas
=======

The following items should be noted when using Starplayer.

* For audio, the mp3 should be __higher than 96 kbps__ to avoid a Flash bug where seeking causes Event.SOUND_COMPLETE to fire too early.
* Embedding `<source>` tags in HTML5 is unsupported by Safari for Windows, and these sources will not be sniffed by the jQuery plugin. When needed, the `url` parameter can be passed to the jQuery plugin to support Safari for Windows users.
