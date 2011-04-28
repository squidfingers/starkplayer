/*\
*  Filename: jquery.starkplayer.js
*  Description: A jQuery plugin for Travis Beckham's starkplayer.
*  Project URL: http://github.com/squidfingers/starkplayer
*  Dependencies: SWFObject
*          (http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js
*
*  Author: Alan Christopher Thomas
*  Website: http://alanchristopherthomas.com
*  Email: alan.christopher.thomas@gmail.com
*
\*/

// Fix IE html5 tags
document.createElement('video');
document.createElement('audio');

(function($) {
    // Set global counters
    $.starkplayer = {
        counter: 0
    }

    // Extend jQuery with starkplayer plugin
    $.fn.extend({

        starkplayer: function(options) {
            // Replace elements with starkplayer

            // Set some reasonable defaults
            var defaults = {
                type: '',
                url: '',
                poster: '',
                youtubeid: '',
                width: '',
                height: '',
                autoplay: 'false',
                buffertime: '10',
                smoothing: 'false',
                border: '',
                bgcolor: '#ffffff',
                logo: '',
                quality: 'default',
                aspectratio: 'maintain',
                videoplayer: 'videoplayer.swf',
                audioplayer: 'audioplayer.swf',
                youtubeplayer: 'youtubeplayer.swf',
                embed_callback: function(obj, element, movie, params,
                        flash_vars, width, height) {
                    element.insertAfter(obj);
                    swfobject.embedSWF(movie, element.attr('id'),
                        width, height, '10.0.0', null, flash_vars,
                        params, {id: element.attr('id'),
                        name: element.attr('id')}, function(e) {
                            if (e.success)
                                obj.remove();
                            else
                                element.remove();
                        });
                }
            }

            // Override the defaults with user settings
            var options = $.extend(defaults, options);

            function get_absolute_url(url) {
                // Get the absolute path of a url (cross-browser compatible)
                var url = url.split('&').join('&amp;').split('<').join(
                        '&lt;').split('"').join('&quot;');
                var element = $('<div></div>').get(0);
                element.innerHTML = '<a href="' + url + '">link</a>';
                return element.firstChild.href;
            }

            // Apply plugin to each element
            return this.each(function() {
                var o = $.extend({}, options);
                var obj = $(this);

                // Hide the object temporarily
                obj.hide();

                // Create Starkplayer Flash video element
                var element = $('<div></div>').attr('id', 'starkplayer-' +
                    $.starkplayer.counter);
                $.starkplayer.counter ++;

                // Check for audio tag with src
                if (o.url == '' &&
                    (obj.get(0).tagName.toUpperCase() == 'AUDIO')) {
                    if (obj.attr('src'))
                        o.url = get_absolute_url(obj.attr('src'));
                    else {
                        var sources = obj.find('source');
                        if (sources.length > 0) {
                            var source = sources.first();
                            if (source.attr('src'))
                                o.url = get_absolute_url(source.attr('src'));
                        }
                    }
                    if (o.type == '')
                        o.type = 'audio';
                }

                // Check for video tag with src, poster, and dimensions
                if (o.url == '' &&
                    (obj.get(0).tagName.toUpperCase() == 'VIDEO')) {
                    if (o.poster == '' && obj.attr('poster'))
                        o.poster = get_absolute_url(obj.attr('poster'));
                    if (obj.attr('src'))
                        o.url = get_absolute_url(obj.attr('src'));
                    else {
                        var sources = obj.find('source');
                        if (sources.length > 0) {
                            var source = sources.first();
                            if (source.attr('src'))
                                o.url = get_absolute_url(source.attr('src'));
                        }
                    }
                    // Check for width/height
                    if (o.width == '' && obj.attr('width'))
                        o.width = obj.attr('width');
                    if (o.height == '' && obj.attr('height'))
                        o.height = obj.attr('height');
                    if (o.type == '')
                        o.type = 'video';
                }

                // Check for 'a' tag with href and poster image
                if (o.url == '' && obj.get(0).tagName.toUpperCase() == 'A') {
                    if (obj.attr('href'))
                        o.url = get_absolute_url(obj.attr('href'));
                    var imgs = obj.find('img');
                    if (imgs.length > 0) {
                        var img = imgs.first();
                        if (o.poster == '' && img.attr('src'))
                            o.poster = get_absolute_url(img.attr('src'));
                    }
                }

                // Check for iframe (used in html5 youtube embed code)
                if (o.url == '' &&
                    obj.get(0).tagName.toUpperCase() == 'IFRAME') {
                    if (obj.attr('src'))
                        o.url = get_absolute_url(obj.attr('src'));
                    // Check for width/height
                    if (o.width == '' && obj.attr('width'))
                        o.width = obj.attr('width');
                    if (o.height == '' && obj.attr('height'))
                        o.height = obj.attr('height');
                }

                // Sniff out media type based on url
                if (o.type == '' && o.url !== '') {
                    var ext = /[^\?\#]*\.(.*?)((\?|\#)+?.*)*$/i.exec(o.url)[1];
                    if (o.url.match(/^http\:\/\/(www\.){0,1}youtube\.com\//))
                        o.type = 'youtube';
                    else if (ext == 'mp4' || ext == 'm4v' || ext == 'flv' ||
                            ext == 'mpg' || ext == 'mpeg' || ext == 'mov' ||
                            ext == '3gp')
                        o.type = 'video';
                    else if (ext == 'mp3')
                        o.type = 'audio';
                }

                // Determine youtubeid
                if (o.youtubeid == '' && o.url !== '' && o.type == 'youtube')
                    o.youtubeid = /.*(\/embed\/|\/v\/|[\?\&\#\!]v\=)([a-zA-Z0-9\_\-]*).*$/i.exec(
                            o.url)[2];

                // Set audio player dimensions
                if (o.type == 'audio') {
                    if (o.width == '')
                        o.width = '260';
                    if (o.height == '')
                        o.height = '30';
                }
                
                obj.bind('starkplayer.ready', function() {
                    // Set up and embed the Flash object
                    if (o.type !== '' && (o.type !== 'youtube' &&
                            o.url !== '' || (o.type == 'youtube' &&
                                o.youtubeid !== ''))) {

                        // If no width/height are specified, use the object's
                        var obj_display = $(this).css('display');
                        $(this).css('display', 'block');
                        if (o.width == '' && (o.type == 'video' ||
                                    o.type == 'youtube'))
                            o.width = $(this).width();
                        if (o.height == '' && (o.type == 'video' ||
                                    o.type == 'youtube'))
                            o.height = $(this).height();
                        $(this).css('display', obj_display);

                        // Set the parameters depending on the media type
                        if (o.type == 'video') {
                            var player = o.videoplayer;
                            var flash_vars = {
                                url: o.url,
                                width: o.width,
                                height: o.height,
                                poster: o.poster,
                                autoplay: o.autoplay,
                                buffertime: o.buffertime,
                                smoothing: o.smoothing,
                                border: o.border,
                                logo: o.logo,
                                aspectratio: o.aspectratio
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
                        else if (o.type == 'youtube') {
                            var player = o.youtubeplayer;
                            var flash_vars = {
                                id: o.youtubeid,
                                autoplay: o.autoplay,
                                border: o.border,
                                quality: o.quality,
                                logo: o.logo
                            }
                            var params = {
                                allowFullScreen: 'true',
                                menu: 'false'
                            }
                        }

                        // Embed the player
                        o.embed_callback(obj, element, player, params,
                                flash_vars, o.width, o.height);
                        $(this).show();
                    }
                    else
                        $(this).show();
                });

                // Fire the embed event when ready
                if (o.type == 'video' && o.poster !== '' && (o.width == '' ||
                            o.height == '' || o.width < 0 || o.height < 0)) {
                    var image = $('<img></img>').attr('src', o.poster);
                    if (image.get(0).complete && image.get(0).width > 0) {
                        if (o.width == '' || o.width < 0)
                            o.width = image.get(0).width;
                        if (o.height == '' || o.height < 0)
                            o.height = image.get(0).height;
                        obj.trigger('starkplayer.ready');
                    }
                    else
                        image.load(function() {
                            if (o.width == '' || o.width < 0)
                                o.width = this.width;
                            if (o.height == '' || o.height < 0)
                                o.height = this.height;
                            obj.trigger('starkplayer.ready');
                        });
                }
                else if (o.type == 'youtube' &&
                        obj.get(0).tagName == 'IFRAME' &&
                        obj.get(0).document &&
                        obj.get(0).document.readyState !== 'complete')
                    obj.load(function() {
                        obj.trigger('starkplayer.ready');
                    });
                else
                    obj.trigger('starkplayer.ready');
            });
        }

    });

})(jQuery);
