Flash Media Players:
Travis Beckham  
squidfingers.com

jQuery Plugin:
Alan Christopher Thomas
alanchristopherthomas.com

Audio Player
============

Version: 1.2  
LangVersion: ActionScript 3.0  
AppVersion CS4  
PlayerVersion: Flash 10  

FlashVars:

* __url:__ The url to an mp3. Required.
* __autoplay:__ Automatically start to play the audio. Defaults to false.
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.

Notes: The mp3 should be higher than 96 kbps to avoid a Flash bug where seeking causes Event.SOUND_COMPLETE to fire too early.

Video Player
============

Version: 1.2  
LangVersion: ActionScript 3.0  
AppVersion CS4  
PlayerVersion: Flash 10  

FlashVars:

* __url:__ The url to an mp4 or flv. Required.
* __poster:__ The url to a jpg or png poster image. Optional.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __buffertime:__ The number of seconds to buffer before the video will start to play. Defaults to 10.
* __border:__ The hexadecimal color of the border. If null, a border will not be displayed. Optional.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.

jQuery Plugin
=============

__Note:__ The jQuery plugin is still under development. Use for testing purposes only. It is not presently intended to be used in a production environment.

Depends on SWFObject ([http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js](http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js))

The jQuery plugin converts your alternate content (either HTML5 tags or links) to Flash media players. When Flash is unsupported, your alternate content will be displayed instead (degrading gracefully to HTML5-only platforms).

Installation
------------

Include SWFObject and the jQuery plugin in the `<head>` section of your HTML document:

    <script src="http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js" type="text/javascript"></script>
    <script src="media-players/jquery.mediaplayers.js" type="text/javascript"></script>

Embedding Audio
---------------

### Using HTML5 ###

With one source:

    <div class="audio">
        <audio src="audio/song.mp3" controls>
            No sound for you.
        </audio>
    </div>

With multiple sources (the first source found will be used in the Flash media player):

    <div class="audio">
        <audio controls>
            <source src="audio/song.mp3">
            <source src="audio/song.ogg">
            No sound for you.
        </audio>
    </div>

### Using Links ###

The href of the first link found will be used as the audio source.

    <div class="audio">
        <a href="audio/song.mp3">
            Download MP3
        </a>
    </div>

### Converting To Media Players ###

Use jQuery selectors to convert your content to media players:

    <script type="text/javascript">
        $(document).ready(function() {
            $('.audio').mediaplayer({
                type: 'audio',
                border: '#666666',
                bgcolor: '#ffffff',
                audioplayer: 'media-players/audioplayer.swf'
            });
        });
    </script>

Parameters:

* __type:__ The type of media player to use (either 'audio' or 'video'). Defaults to 'video'.
* __url:__ The url to an mp3. Defaults to media sniffed out from alternate content.
* __autoplay:__ Automatically start to play the audio. Defaults to false.
* __border:__ The hexadecimal color of the border. If omitted, a border will not be displayed. Optional.
* __audioplayer:__ The url to audioplayer.swf. Defaults to the same directory as the HTML file.

Embedding Video
---------------

### Using HTML5 ###

With one source:

    <div class="video">
        <video src="videos/video.mp4" poster="images/poster.jpg" controls>
            No video for you.
        </video>
    </div>

With multiple sources (the first source found will be used in the Flash media player):

    <div class="video">
        <video poster="images/poster.jpg" controls>
            <source src="videos/video.mp4">
            <source src="videos/video.ogg">
            <source src="videos/video.webm">
            No video for you.
        </video>
    </div>

### Using Links ###

The href of the first link found will be used as the video source. If it contains a nested image, this will be the video poster image.

    <div class="video">
        <a href="videos/video.mp4">
            <img src="images/poster.jpg" alt="No video for you">
        </a>
    </div>

### Converting To Media Players ###

Use jQuery selectors to convert your content to media players:

    <script type="text/javascript">
        $(document).ready(function() {
            $('.video').mediaplayer({
                type: 'video',
                border: '#000000',
                logo: 'graphics/logo.png',
                videoplayer: 'media-players/videoplayer.swf'
            });
        });
    </script>

Parameters:

* __type:__ The type of media player to use (either 'audio' or 'video'). Defaults to 'video'.
* __url:__ The url to an mp4 or flv. Defaults to media sniffed out from alternate content.
* __poster:__ The url to a jpg or png poster image. Defaults to poster image sniffed out from alternate content.
* __width:__ The width of the media player. Defaults to the width of the content it replaces.
* __height:__ The height of the media player. Defaults to the height of the content it replaces.
* __autoplay:__ Automatically start to play the video. Defaults to false.
* __buffertime:__ The number of seconds to buffer before the video will start to play. Defaults to 10.
* __border:__ The hexadecimal color of the border. If omitted, a border will not be displayed. Optional.
* __logo:__ The logo to be displayed over the top right corner of the video. Optional.
* __videoplayer:__ The url to videoplayer.swf. Defaults to the same directory as the HTML file.
