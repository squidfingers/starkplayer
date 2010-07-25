/*\
*  Filename: jquery.mediaplayers.js
*  Description: A jQuery plugin for the squidfingers Flash media players by
*          Travis Beckham.
*  Project URL: http://github.com/squidfingers/Media-Players
*  Dependencies: SWFObject
*          (http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js
*
*  Author: Alan Christopher Thomas
*  Website: http://alanchristopherthomas.com
*  Email: alan.christopher.thomas@gmail.com
*
\*/

(function($) {
    // Set a global counter for mediaplayer ids
    $.mediaplayer_id_counter = 0;

    $.fn.extend({
        // Extend jQuery with mediaplayer plugin

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
                youtubeid: '',
                width: '',
                height: '',
                autoplay: 'false',
                buffertime: '10',
                border: '',
                bgcolor: '#ffffff',
                logo: '',
                quality: 'default',
                videoplayer: 'videoplayer.swf',
                audioplayer: 'audioplayer.swf',
                youtubeplayer: 'youtubeplayer.swf'
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

            return this.each(function() {
                // Apply plugin to each element
                var o = $.extend({}, options);
                var obj = $(this);

                // Put element inside of a wrapper div
                var wrapper = $('<div></div>').attr('id', 'mediaplayer-' +
                    $.mediaplayer_id_counter);
                obj.wrap(wrapper)
                $.mediaplayer_id_counter ++;

                // Check for video tag with src and poster
                if (o.url == '' && obj.get(0).tagName == 'VIDEO') {
                    if (obj.attr('poster'))
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
                    if (o.type == '')
                        o.type = 'video';
                }

                // Check for audio tag with src
                if (o.url == '' && obj.get(0).tagName == 'AUDIO') {
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

                // Check for 'a' tag with href and poster image
                if (o.url == '' && obj.get(0).tagName == 'A') {
                    if (obj.attr('href'))
                        o.url = get_absolute_url(obj.attr('href'));
                    var imgs = obj.find('img');
                    if (imgs.length > 0) {
                        var img = imgs.first();
                        if (img.attr('src'))
                            o.poster = get_absolute_url(img.attr('src'));
                    }
                }

                // Check for iframe (used in html5 youtube embed code)
                if (o.url == '' && obj.get(0).tagName == 'IFRAME')
                    if (obj.attr('src'))
                        o.url = get_absolute_url(obj.attr('src'));
                
                // Check for object (used in standard youtube embed code)
                if (o.url == '' && obj.get(0).tagName == 'OBJECT') {
                    var obj_params = obj.children('param');
                    obj_params.each(function() {
                        var param = $(this);
                        if (param.attr('name') == 'movie')
                            o.url = param.attr('value');
                    });
                    if (o.url == '') {
                        // Check for embeds
                        var embeds = obj.find('embed');
                        if (embeds.length > 0) {
                            var embed = embeds.first();
                            if (embed.attr('src'))
                                o.url = embed.attr('src');
                        }
                    }
                }

                if (o.type == '' && o.url !== '') {
                    // Sniff out media type based on url
                    var ext = /[^\?\#]*\.(.*?)((\?|\#)+?.*)*$/i.exec(o.url)[1];
                    if (o.url.match(/^http\:\/\/(www\.){0,1}youtube\.com\//))
                        o.type = 'youtube';
                    else if (ext == 'mp4' || ext == 'm4v' || ext == 'flv' ||
                            ext == 'mpg' || ext == 'mpeg')
                        o.type = 'video';
                    else if (ext == 'mp3')
                      o.type = 'audio';
                }

                // Determine youtubeid
                if (o.url !== '' && o.type == 'youtube')
                    o.youtubeid = /.*(\/embed\/|\/v\/|[\?\&\#\!]v\=)([a-zA-Z0-9]*).*$/i.exec(
                            o.url)[2];

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

                alert(o.type);
                alert(o.url);
                alert(o.youtubeid);

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
                else if (o.type == 'youtube') {
                    var player = o.youtubeplayer;
                    var flash_vars = {
                        id: o.youtubeid,
                        autoplay: o.autoplay,
                        border: o.border,
                        quality: o.quality
                    }
                    var params = {
                        allowFullScreen: 'true',
                        menu: 'false'
                    }
                }

                // Embed the player
                if (o.type !== '' && (o.type !== 'youtube' ||
                        (o.type == 'youtube' & o.youtubeid !== '')))
                    swfobject.embedSWF(player, wrapper.attr('id'),
                        o.width, o.height, '10.0.0', null, flash_vars, params,
                        {id: wrapper.attr('id'), name: wrapper.attr('id')});
            });
        }

    });

})(jQuery);
