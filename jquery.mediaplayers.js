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

    // Extend jQuery with videoplayer plugin
    $.fn.extend({
        mediaplayer: function(options) {
            // Define the plugin

            // Set some reasonable defaults
            var defaults = {
                type: 'video',
                url: '',
                poster: '',
                width: '',
                height: '',
                autoplay: 'false',
                buffertime: '10',
                border: 'false',
                bordercolor: '#666666',
                bgcolor: '#ffffff',
                videoplayer: 'videoplayer.swf',
                audioplayer: 'audioplayer.swf'
            }

            // Override the defaults with user settings
            var options = $.extend(defaults, options);

            return this.each(function(i) {
                // Apply plugin to each element
                var o = options;
                var obj = $(this);

                // Put children inside of a wrapper div
                var wrapper = $('<div></div>').attr('id', 'mediaplayer-' + i);
                obj.children().each(function() {
                    wrapper.append(this);
                })
                obj.append(wrapper);

                if (o.type == 'video' && o.url == '') {
                    // Check for video tag with src and poster
                    var videos = obj.find('video');
                    if (videos.length > 0) {
                        var video = videos.first();
                        if (video.attr('poster'))
                            o.poster = video.attr('poster');
                        if (video.attr('src'))
                            o.url = video.attr('src');
                        else {
                            var sources = video.find('source');
                            if (sources.length > 0) {
                                var source = sources.first();
                                if (source.attr('src'))
                                    o.url = source.attr('src');
                            }
                        }
                    }
                }

                if (o.type == 'audio' && o.url == '') {
                    // Check for audio tag with src
                    var audios = obj.find('audio');
                    if (audios.length > 0) {
                        var audio = audios.first();
                        if (audio.attr('src'))
                            o.url = audio.attr('src');
                        else {
                            var sources = audio.find('source');
                            if (sources.length > 0) {
                                var source = sources.first();
                                if (source.attr('src'))
                                    o.url = source.attr('src');
                            }
                        }
                    }
                }

                if (o.url == '') {
                    // Check for 'a' tag with href and poster image
                    var as = obj.find('a');
                    if (as.length > 0) {
                        var a = as.first();
                        if (a.attr('href'))
                            o.url = a.attr('href');
                        if (o.type == 'video') {
                            var imgs = a.find('img');
                            if (imgs.length > 0) {
                                var img = imgs.first();
                                if (img.attr('src'))
                                    o.poster = img.attr('src');
                            }
                        }
                    }
                }

                // If no width/height are specified, set them to match current
                if (o.width == '')
                    o.width = obj.width();
                if (o.height == '')
                    o.height = obj.height();
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
                        border: o.border
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
                        bgcolor: o.bordercolor
                    }
                    var params = {
                        menu: 'false',
                        bgcolor: o.bgcolor
                    }
                }

                // Embed the player
                swfobject.embedSWF(player, wrapper.attr('id'),
                    o.width, o.height, '10.0.0', null, flash_vars, params,
                    {id: wrapper.attr('id'), name: wrapper.attr('id')});
            });
        }
    });

})(jQuery);
