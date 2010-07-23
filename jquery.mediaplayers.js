/*****************************************************************************\
*  Filename: jquery.mediaplayers.js                                           *
*  Description: A jQuery plugin for the squidfingers Flash media players by   *
*          Travis Beckham.                                                    *
*  Project URL: http://github.com/squidfingers/Media-Players                  *
*  Dependencies: SWFObject                                                    *
*          (http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js   *
*                                                                             *
*  Author: Alan Christopher Thomas                                            *
*  Website: http://alanchristopherthomas.com                                  *
*  Email: alan.christopher.thomas@gmail.com                                   *
*                                                                             *
\*****************************************************************************/

(function($) {
    // Set a global counter for mediaplayer ids
    $.mediaplayer_id_counter = 0;

    // Extend jQuery with videoplayer plugin
    $.fn.extend({
        mediaplayer: function(options) {
            // Define the plugin

            // Do nothing if there's no Flash support
            if (parseInt(swfobject.getFlashPlayerVersion()['major']) < 10)
                return;

            // Set some reasonable defaults
            var defaults = {
                type: '',
                url: '',
                poster: '',
                width: '',
                height: '',
                autoplay: 'false',
                buffertime: '10',
                border: '',
                bgcolor: '#ffffff',
                logo: '',
                videoplayer: 'videoplayer.swf',
                audioplayer: 'audioplayer.swf'
            }

            /*
             * Future youtube params:
             * - id
             * - autoplay false
             * - border #000000
             * - quality medium
            */

            // Override the defaults with user settings
            var options = $.extend(defaults, options);

            return this.each(function() {
                // Apply plugin to each element
                var o = $.extend({}, options);
                var obj = $(this);

                // Put children inside of a wrapper div
                var wrapper = $('<div></div>').attr('id', 'mediaplayer-' +
                    $.mediaplayer_id_counter);
                obj.children().each(function() {
                    wrapper.append(this);
                })
                obj.append(wrapper);
                $.mediaplayer_id_counter ++;

                // Check for video tag with src and poster
                var videos = obj.find('video');
                if (o.url == '' && videos.length > 0) {
                    var video = videos.first();
                    if (video.attr('poster'))
                        o.poster = video.get(0).poster;
                    if (o.poster == '' && video.attr('poster'))
                        o.poster = video.attr('poster');
                    if (video.attr('src'))
                        o.url = video.get(0).src;
                    else {
                        var sources = video.find('source');
                        if (sources.length > 0) {
                            var source = sources.first();
                            if (source.attr('src'))
                                o.url = source.get(0).src;
                        }
                    }
                    if (o.type == '')
                        o.type = 'video';
                }

                // Check for audio tag with src
                var audios = obj.find('audio');
                if (o.url == '' && audios.length > 0) {
                    var audio = audios.first();
                    if (audio.attr('src'))
                        o.url = audio.get(0).src;
                    else {
                        var sources = audio.find('source');
                        if (sources.length > 0) {
                            var source = sources.first();
                            if (source.attr('src'))
                                o.url = source.get(0).src;
                        }
                    }
                    if (o.type == '')
                        o.type = 'audio';
                }

                if (o.url == '') {
                    // Check for 'a' tag with href and poster image
                    var as = obj.find('a');
                    if (as.length > 0) {
                        var a = as.first();
                        if (a.attr('href'))
                            o.url = a.get(0).href;
                        var imgs = a.find('img');
                        if (imgs.length > 0) {
                            var img = imgs.first();
                            if (img.attr('src'))
                                o.poster = img.attr('src');
                            if (o.poster == '' && img.attr('src'))
                                o.poster = img.get(0).src;
                        }
                    }

                    if (o.type == '') {
                        // Sniff out media type based on url file extension
                        var ext = /[^\?\#]*\.(.*?)((\?|\#)+?.*)*$/i.exec(o.url)[1];
                        if (ext == 'mp4' || ext == 'm4v' || ext == 'flv' ||
                                ext == 'mpg' || ext == 'mpeg')
                            o.type = 'video';
                        else if (ext == 'mp3')
                            o.type = 'audio';
                    }
                }

                // If no width/height are specified, set them to match current
                if (o.width == '')
                    o.width = obj.width();
                if (o.height == '')
                    o.height = obj.height();

                // Set audio player dimensions
                if (o.type == 'audio') {
                    o.width = '320';
                    o.height = '70';
                }

                // Set the parameters depending on the player type
                if (o.type == 'video') {
                    var player = o.videoplayer;
                    var flash_vars = {
                        url: o.url,
                        poster: o.poster,
                        autoplay: o.autoplay,
                        buffertime: o.buffertime,
                        border: o.border,
                        logo: o.logo
                    }
                    var params =  {
                        allowFullScreen: 'true',
                        menu: 'false'
                    }
                }
                else if (o.type == 'audio') {
                    var player = o.audioplayer;
                    var flash_vars = {
                        url: o.url,
                        autoplay: o.autoplay,
                        border: o.border
                    }
                    var params = {
                        menu: 'false',
                        bgcolor: o.bgcolor
                    }
                }

                // Embed the player
                if (o.type !== '')
                    swfobject.embedSWF(player, wrapper.attr('id'),
                        o.width, o.height, '10.0.0', null, flash_vars, params,
                        {id: wrapper.attr('id'), name: wrapper.attr('id')});
            });
        }
    });

})(jQuery);
