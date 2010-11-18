// http://code.google.com/apis/youtube/flash_api_reference.html

package com.starkplayer.widgets {
	
	import com.starkplayer.utils.TimeUtil;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Security;
	//import flash.text.TextField;
	import flash.ui.Mouse;
	import fl.motion.Color;
	
	public class YouTubePlayer extends MovieClip {
		
		// ===================================================================
		// Constants
		// -------------------------------------------------------------------
		
		public const VIDEO_UNSTARTED:Number = -1;
		public const VIDEO_COMPLETE:Number = 0;
		public const VIDEO_PLAYING:Number = 1;
		public const VIDEO_PAUSED:Number = 2;
		public const VIDEO_BUFFERING:Number = 3;
		public const VIDEO_CUED:Number = 5;
				
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		protected var _initialized:Boolean;
		
		protected var _qualityLevels:Object = {'default':-1, 'small':0, 'medium':1, 'large':2, 'hd720':3};
		
		protected var _youTubeId:String;
		protected var _autoPlay:Boolean;
		protected var _borderColor:Number;
		protected var _suggestedQuality:String;
		protected var _logoURL:String;
		
		protected var _player:Object;
		protected var _apiLoader:Loader;
		protected var _logoLoader:Loader;
		
		protected var _screenWidth:Number;
		protected var _screenHeight:Number;
		protected var _screenCenterX:Number;
		protected var _screenCenterY:Number;
		
		protected var _origX:Number;
		protected var _origY:Number;
		
		protected var _volume:Number;
		protected var _volumeRestore:Number;
		protected var _stageScaleMode:String;
		protected var _stageAlign:String;
		protected var _hasBorder:Boolean;
		
		protected var _playing:Boolean;
		protected var _seeking:Boolean;
		protected var _seekTo:Number;
		
		protected var _counter:Number;
		
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var border_mc:MovieClip;
		public var error_mc:MovieClip;
		public var start_mc:MovieClip;
		public var spinner_mc:MovieClip;
		public var controller_mc:MovieClip;
		public var logo_mc:MovieClip;
		public var screen_mc:MovieClip;
		public var bkgd_mc:MovieClip;
		public var backdrop_mc:MovieClip;
		
		//public var debug_txt:TextField;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function YouTubePlayer():void {
			_initialized = false;
			hideChildren();
			try {
				Security.allowDomain('www.youtube.com');
			} catch (e:SecurityError) {
				showError(e.message);
			}
		}
		
		// ===================================================================
		// Public Properties
		// -------------------------------------------------------------------
		
		public function get initialized():Boolean {
			return _initialized;
		}
		
		// ===================================================================
		// Public Methods
		// -------------------------------------------------------------------
		
		public function load (p_youTubeId:String, p_screenWidth:Number = 320, p_screenHeight:Number = 240, p_autoPlay:Boolean = true, p_borderColor:Number = NaN, p_suggestedQuality:String = null, p_logoURL:String = null):void {
			
			dispose();
			
			// Save parameters
			_youTubeId = p_youTubeId;
			_screenWidth = p_screenWidth;
			_screenHeight = p_screenHeight;
			_autoPlay = p_autoPlay;
			_borderColor = p_borderColor;
			_suggestedQuality = p_suggestedQuality;
			_logoURL = p_logoURL;
			
			// Validate parameters
			if (_screenWidth < 320) _screenWidth = 320;
			if (_screenHeight < 180) _screenHeight = 180;
			if (_suggestedQuality) _suggestedQuality = _suggestedQuality.toLowerCase();
			if (_suggestedQuality == null || _qualityLevels[_suggestedQuality] == undefined) _suggestedQuality = 'default';
			
			// Initialize volume properties
			_volume = 100;
			_volumeRestore = _volume;
			
			// Determine center of video
			_screenCenterX = Math.round(_screenWidth / 2);
			_screenCenterY = Math.round(_screenHeight / 2);
			
			// Capture original position
			_origX = x;
			_origY = y;
			
			// Setup screen and background
			bkgd_mc.x = screen_mc.x = 0;
			bkgd_mc.y = screen_mc.y = 0;
			bkgd_mc.width = _screenWidth;
			bkgd_mc.height = _screenHeight;
			screen_mc.buttonMode = false;
			screen_mc.mouseChildren = false;
			
			// Setup controller
			controller_mc.y = _screenHeight;
			controller_mc.x = _screenCenterX;
			controller_mc.visible = false;
			controller_mc.alpha = 0;
			controller_mc.stream_mc.scaleX = 0;
			controller_mc.progress_mc.scaleX = 0;
			controller_mc.progressMarker_mc.x = controller_mc.progress_mc.x;
			controller_mc.time_txt.text = '0:00';
			controller_mc.duration_txt.text = '0:00';
			
			// Setup other children
			spinner_mc.x = start_mc.x = error_mc.x = _screenCenterX;
			spinner_mc.y = start_mc.y = error_mc.y = _screenCenterY;
			
			// Setup border
			_hasBorder = false;
			if ( ! isNaN(_borderColor)) {
				_hasBorder = true;
				border_mc.visible = true;
				var c = new Color();
				c.setTint(_borderColor, 1);
				border_mc.transform.colorTransform = c;
			}
			border_mc.visible = _hasBorder;
			
			// Position top border
			border_mc.top_mc.x = 0;
			border_mc.top_mc.y = 0;
			border_mc.top_mc.width = _screenWidth;
			
			// Position right border
			border_mc.right_mc.x = _screenWidth;
			border_mc.right_mc.y = 0;
			border_mc.right_mc.height = _screenHeight;
			
			// Position bottom border
			border_mc.bottom_mc.x = 0;
			border_mc.bottom_mc.y = _screenHeight;
			border_mc.bottom_mc.width = _screenWidth;
			
			// Position left border
			border_mc.left_mc.x = 0;
			border_mc.left_mc.y = 0;
			border_mc.left_mc.height = _screenHeight;
			
			// Setup start button
			start_mc.buttonMode = true;
			start_mc.mouseChildren = false;
			start_mc.hitArea = start_mc.hitArea_mc;
			start_mc.hitArea_mc.visible = false;
			
			// Setup play button
			controller_mc.play_mc.buttonMode = true;
			controller_mc.play_mc.mouseChildren = false;
			controller_mc.play_mc.hitArea = controller_mc.play_mc.hitArea_mc;
			controller_mc.play_mc.hitArea_mc.visible = false;
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
			
			// Setup rewind button
			//controller_mc.rewind_mc.buttonMode = true;
			//controller_mc.rewind_mc.mouseChildren = false;
			//controller_mc.rewind_mc.hitArea = controller_mc.rewind_mc.hitArea_mc;
			//controller_mc.rewind_mc.hitArea_mc.visible = false;
			
			// Setup mute button
			//controller_mc.mute_mc.buttonMode = true;
			//controller_mc.mute_mc.mouseChildren = false;
			//controller_mc.mute_mc.hitArea = controller_mc.mute_mc.hitArea_mc;
			//controller_mc.mute_mc.hitArea_mc.visible = false;
			//controller_mc.mute_mc.icon_mc.gotoAndStop(1);
			
			// Setup volume
			controller_mc.volume_mc.toggle_mc.buttonMode = true;
			controller_mc.volume_mc.toggle_mc.mouseChildren = false;
			controller_mc.volume_mc.toggle_mc.hitArea = controller_mc.volume_mc.toggle_mc.hitArea_mc;
			controller_mc.volume_mc.toggle_mc.hitArea_mc.visible = false;
			//controller_mc.volume_mc.track_mc.hitArea = controller_mc.volume_mc.track_mc.hitArea_mc;
			//controller_mc.volume_mc.track_mc.hitArea_mc.visible = false;
			controller_mc.volume_mc.track_mc.buttonMode = true;
			controller_mc.volume_mc.track_mc.mouseChildren = false;
			controller_mc.volume_mc.marker_mc.mouseEnabled = false;
			controller_mc.volume_mc.marker_mc.mouseChildren = false;
			
			// Setup fullscreen button
			controller_mc.fullScreen_mc.buttonMode = true;
			controller_mc.fullScreen_mc.mouseChildren = false;
			controller_mc.fullScreen_mc.hitArea = controller_mc.fullScreen_mc.hitArea_mc;
			controller_mc.fullScreen_mc.hitArea_mc.visible = false;
			
			// Setup progress
			controller_mc.track_mc.buttonMode = true;
			controller_mc.track_mc.mouseEnabled = true;
			controller_mc.track_mc.mouseChildren = false;
			controller_mc.stream_mc.mouseEnabled = false;
			controller_mc.stream_mc.mouseChildren = false;
			controller_mc.progress_mc.mouseEnabled = false;
			controller_mc.progress_mc.mouseChildren = false;
			controller_mc.progressMarker_mc.mouseEnabled = false;
			controller_mc.progressMarker_mc.mouseChildren = false;
			
			// Check for errors
			if (_youTubeId == null) {
				showError('YouTube ID Cannot be null.');
				return;
			}
			
			// Load logo image
			if (_logoURL) {
				_logoLoader = new Loader();
				_logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaderCompleteHandler, false, 0, true);
				_logoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, logoLoaderErrorHandler, false, 0, true);
				_logoLoader.load(new URLRequest(_logoURL));
			}
			
			// Load YouTube API
			_apiLoader = new Loader();
			_apiLoader.contentLoaderInfo.addEventListener(Event.INIT, apiLoaderInitHandler, false, 0, true);
			_apiLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, apiLoaderErrorHandler, false, 0, true);
			try {
				_apiLoader.load(new URLRequest('http://www.youtube.com/apiplayer?version=3'));
			} catch (e:SecurityError) {
				showError(e.message);
				return;
			}
			
			// Show spinner
			spinner_mc.visible = true;
			spinner_mc.play();
			
			_initialized = true;
		}
		public function dispose():void {
			
			_initialized = false;
			hideChildren();
			
			// Remove logo image
			if (_logoLoader) {
				_logoLoader.unload();
				if (logo_mc.contains(_logoLoader)) {
					logo_mc.removeChild(_logoLoader);
				}
				_logoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, logoLoaderCompleteHandler, false);
				_logoLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, logoLoaderErrorHandler, false);
			}
			
			// Remove player
			_playing = false;
			if (_player) {
				_player.stopVideo();
				_player.destroy();
				_player = null;
			}
			
			// Remove api loader
			if (_apiLoader) {
				_apiLoader.contentLoaderInfo.removeEventListener(Event.INIT, apiLoaderInitHandler, false);
				_apiLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, apiLoaderErrorHandler, false);
			}
			if (_apiLoader && screen_mc.contains(_apiLoader)) {
				_apiLoader.content.removeEventListener('onReady', videoReadyHandler, false);
				_apiLoader.content.removeEventListener('onError', videoErrorHandler, false);
				_apiLoader.content.removeEventListener('onStateChange', videoStateChangeHandler, false);
				_apiLoader.content.removeEventListener('onPlaybackQualityChange', videoPlaybackQualityChangeHandler, false);
			}
			_apiLoader = null;
			
			// Remove controller event handlers
			if (screen_mc.hasEventListener(MouseEvent.CLICK)) {
				screen_mc.removeEventListener(MouseEvent.CLICK, youTubeClickHandler, false);
				start_mc.removeEventListener(MouseEvent.CLICK, startClickHandler, false);
				controller_mc.play_mc.removeEventListener(MouseEvent.CLICK, playClickHandler, false);
				//controller_mc.rewind_mc.removeEventListener(MouseEvent.CLICK, rewindClickHandler, false);
				//controller_mc.mute_mc.removeEventListener(MouseEvent.CLICK, muteClickHandler, false);
				controller_mc.volume_mc.toggle_mc.removeEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false);
				controller_mc.volume_mc.track_mc.removeEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false);
				controller_mc.fullScreen_mc.removeEventListener(MouseEvent.CLICK, fullScreenClickHandler, false);
				controller_mc.removeEventListener(Event.ENTER_FRAME, controllerEnterFrameHandler, false);
				controller_mc.track_mc.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, false);
				controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false);
				controller_mc.progress_mc.removeEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false);
				stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false);
			}
			
			// Remove event handler to show/hide the controller
			if (hasEventListener(MouseEvent.MOUSE_MOVE)) {
				removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			}
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
			}
			
			// Debug
			//if (debug_txt.hasEventListener(Event.ENTER_FRAME)) {
			//	debug_txt.removeEventListener(Event.ENTER_FRAME, debugEnterFrameHandler, false);
			//}
		}
		
		// ===================================================================
		// Private Methods
		// -------------------------------------------------------------------
		
		private function hideChildren():void {
			controller_mc.visible = spinner_mc.visible = start_mc.visible = error_mc.visible = backdrop_mc.visible = false;
			spinner_mc.stop();
		}
		private function showController():void {
			Mouse.show();
			controller_mc.visible = true;
			_counter = 0;
			if ( ! hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			}
		}
		private function setVolume (p_volume:Number):void {
			if (_player) {
				_volume = Math.min(Math.max(Math.round(p_volume), 0), 100);
				_player.setVolume(_volume);
				//var t = controller_mc.volume_mc.track_mc;
				//var h = controller_mc.volume_mc.track_mc.hitArea_mc;
				//var m = controller_mc.volume_mc.marker_mc;
				//m.x = t.x + h.x + Math.round((_volume / 100) * h.width);
				
				// Note: substract 2 pixels to allow the volume marker shadow to extend beyond the track
				var markerWidth = controller_mc.volume_mc.marker_mc.width - 2;
				controller_mc.volume_mc.marker_mc.x = controller_mc.volume_mc.track_mc.x + Math.round((_volume / 100) * (controller_mc.volume_mc.track_mc.width - markerWidth));
			}
		}
		private function showError (p_message:String):void {
			//Console.log('ERROR:' + p_message);
			trace('ERROR:' + p_message);
			dispose();
			error_mc.visible = true;
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		// Loader
		
		private function apiLoaderInitHandler (p_event:Event):void {
			screen_mc.addChild(_apiLoader);
			_apiLoader.content.addEventListener('onReady', videoReadyHandler, false, 0, true);
			_apiLoader.content.addEventListener('onError', videoErrorHandler, false, 0, true);
			_apiLoader.content.addEventListener('onStateChange', videoStateChangeHandler, false, 0, true);
			_apiLoader.content.addEventListener('onPlaybackQualityChange', videoPlaybackQualityChangeHandler, false, 0, true);
		}
		private function apiLoaderErrorHandler (p_event:IOErrorEvent):void {
			showError(p_event.text);
		}
		
		// Logo
		
		private function logoLoaderCompleteHandler (p_event:Event):void {
			logo_mc.visible = true;
			logo_mc.addChild(_logoLoader);
			logo_mc.x = _screenWidth - logo_mc.width - 10;
			logo_mc.y = 10;
		}
		private function logoLoaderErrorHandler (p_event:IOErrorEvent):void {
			trace('ERROR: Unable to load logo image.');
		}
		
		// YouTube API
		
		private function videoReadyHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the player API ID
			// Console.log('READY:', Object(p_event).data);
			
			// Attach controller event handlers
			screen_mc.addEventListener(MouseEvent.CLICK, youTubeClickHandler, false, 0, true);
			start_mc.addEventListener(MouseEvent.CLICK, startClickHandler, false, 0, true);
			controller_mc.addEventListener(Event.ENTER_FRAME, controllerEnterFrameHandler, false, 0, true);
			controller_mc.play_mc.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			//controller_mc.rewind_mc.addEventListener(MouseEvent.CLICK, rewindClickHandler, false, 0, true);
			//controller_mc.mute_mc.addEventListener(MouseEvent.CLICK, muteClickHandler, false, 0, true);
			controller_mc.volume_mc.toggle_mc.addEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false, 0, true);
			controller_mc.volume_mc.track_mc.addEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false, 0, true);
			controller_mc.fullScreen_mc.addEventListener(MouseEvent.CLICK, fullScreenClickHandler, false, 0, true);
			controller_mc.track_mc.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false, 0, true);
			controller_mc.progress_mc.addEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false, 0, true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false, 0, true);
			
			// Attach event handler to show/hide the controller
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			showController();
			
			// Load YouTube video
			_player = _apiLoader.content;
			_player.setSize(_screenWidth, _screenHeight);
			if (_autoPlay) {
				_player.loadVideoById(_youTubeId, 0, _suggestedQuality);
			} else {
				_player.cueVideoById(_youTubeId, 0, _suggestedQuality);
			}
			setVolume(_volume);
			
			// Debug
			//debug_txt.addEventListener(Event.ENTER_FRAME, debugEnterFrameHandler, false, 0, true);
		}
		private function videoErrorHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the error code
			showError(Object(p_event).data);
		}
		private function videoStateChangeHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			// Console.log('STATE CHANGE:', Object(p_event).data);
			
			var playerState = parseInt(Object(p_event).data);
			switch (playerState) {
				case VIDEO_UNSTARTED:
					// Console.log('Video Unstarted');
					// Video unstarted
					break;
				case VIDEO_COMPLETE:
					// Console.log('Video Complete');
					// Video complete
					start_mc.visible = true;
					spinner_mc.visible = false;
					spinner_mc.stop();
					controller_mc.play_mc.icon_mc.gotoAndStop(1);
					break;
				case VIDEO_PLAYING:
					// Console.log('Video Playing');
					if (_seeking) return;// Ignore event if seeking
					// Video playing
					_playing = true;
					start_mc.visible = false;
					spinner_mc.visible = false;
					spinner_mc.stop();
					controller_mc.play_mc.icon_mc.gotoAndStop(2);
					break;
				case VIDEO_PAUSED:
					// Console.log('Video Paused');
					if (_seeking) return;// Ignore event if seeking
					// Video paused
					_playing = false;
					start_mc.visible = true;
					spinner_mc.visible = false;
					spinner_mc.stop();
					controller_mc.play_mc.icon_mc.gotoAndStop(1);
					break;
				case VIDEO_BUFFERING:
					// Console.log('Video Buffering');
					// Video buffering
					start_mc.visible = false;
					spinner_mc.visible = true;
					spinner_mc.play();
					break;
				case VIDEO_CUED:
					// Console.log('Video Cued');
					// Video cued
					start_mc.visible = true;
					spinner_mc.visible = false;
					spinner_mc.stop();
					controller_mc.play_mc.icon_mc.gotoAndStop(1);
					break;
			}
		}
		private function videoPlaybackQualityChangeHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the new video quality
			// Console.log('QUALITY CHANGE:', Object(p_event).data);
		}
		
		// Screen
		
		private function youTubeClickHandler (p_event:MouseEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				if (_playing) {
					_player.pauseVideo();
				}
				navigateToURL(new URLRequest(_player.getVideoUrl()), '_blank');
			}
		}
		
		// Controller
		
		private function mouseMoveHandler (p_event:MouseEvent):void {
			showController();
		}
		private function enterFrameHandler (p_event:Event):void {
			if (_counter == 0 && controller_mc.alpha < 1) {
				controller_mc.alpha += 0.1;
			} else {
				if (_counter++ > 80) {
					if (controller_mc.alpha > 0) {
						controller_mc.alpha -= 0.2;
					} else {
						controller_mc.visible = false;
						controller_mc.alpha = 0;
						removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
						if (stage.displayState == StageDisplayState.FULL_SCREEN) {
							Mouse.hide();
						}
					}
				}
			}
		}
		private function controllerEnterFrameHandler (p_event:Event):void {
			controller_mc.duration_txt.text = TimeUtil.format(_player.getDuration());
			controller_mc.time_txt.text = TimeUtil.format(_player.getCurrentTime());
		}
		private function startClickHandler (p_event:MouseEvent):void {
			if (_player.getPlayerState() != VIDEO_PLAYING) {
				_player.playVideo();
			}
			if (_player.getPlayerState() == VIDEO_BUFFERING) {
				_playing = true;
				start_mc.visible = false;
				controller_mc.play_mc.icon_mc.gotoAndStop(2);
			}
		}
		private function playClickHandler (p_event:MouseEvent):void {
			if (_playing) {
				_player.pauseVideo();
				if (_player.getPlayerState() == VIDEO_BUFFERING) {
					_playing = false;
					start_mc.visible = true;
					controller_mc.play_mc.icon_mc.gotoAndStop(1);
				}
			} else {
				_player.playVideo();
				if (_player.getPlayerState() == VIDEO_BUFFERING) {
					_playing = true;
					start_mc.visible = false;
					controller_mc.play_mc.icon_mc.gotoAndStop(2);
				}
			}
		}
		private function rewindClickHandler (p_event:MouseEvent):void {
			//_player.seekTo(0, false);
		}
		private function muteClickHandler (p_event:MouseEvent):void {
			//if (_player.isMuted()) {
			//	_player.unMute();
			//	controller_mc.mute_mc.icon_mc.gotoAndStop(1);
			//} else {
			//	_player.mute();
			//	controller_mc.mute_mc.icon_mc.gotoAndStop(2);
			//}
		}
		private function streamEnterFrameHandler (p_event:Event):void {
			var bStart = _player.getVideoStartBytes();
			var bLoaded = bStart + _player.getVideoBytesLoaded();
			var bTotal = bStart + _player.getVideoBytesTotal();
			if (_player.getVideoBytesTotal() > 0) {
				if (bLoaded == bTotal && controller_mc.stream_mc.scaleX < 1) {
					controller_mc.stream_mc.scaleX = 1;
					//controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false);
				} else {
					controller_mc.stream_mc.scaleX = bLoaded / bTotal;
				}
			}
		}
		private function progressEnterFrameHandler (p_event:Event):void {
			if (_player.getDuration() > 0) {
				if ( ! _seeking) {
					// Note: substract 2 pixels to allow the progress marker shadow to extend beyond the track
					var markerWidth = controller_mc.progressMarker_mc.width - 2;
					controller_mc.progressMarker_mc.x = controller_mc.track_mc.x + ((_player.getCurrentTime() / _player.getDuration()) * (controller_mc.track_mc.width - markerWidth));
					controller_mc.progress_mc.width = (controller_mc.progressMarker_mc.x - controller_mc.track_mc.x) + (markerWidth / 2);
					//controller_mc.progress_mc.scaleX = _player.getCurrentTime() / _player.getDuration();
				}
			}
		}
		private function trackMouseDownHandler (p_event:MouseEvent):void {
			// Set initial seek position
			var r = Math.min(Math.max(controller_mc.track_mc.mouseX / controller_mc.track_mc.width, 0), 1);
			var s = _player.getDuration() * r;
			_seekTo = s;
			_seeking = true;
			// Attach event handlers
			controller_mc.track_mc.addEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, trackMouseUpHandler, false, 0, true);
		}
		private function trackMouseUpHandler (p_event:MouseEvent):void {
			// Remove event handlers
			controller_mc.track_mc.removeEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, trackMouseUpHandler, false);
			// Allow seeking to unbuffered video
			_player.seekTo(_seekTo, true);
			// Play video if needed
			if (_playing) {
				_player.playVideo();
			}
			_seekTo = NaN;
			_seeking = false;
		}
		private function trackEnterFrameHandler (p_event:Event):void {
			if (_player.getDuration()) {
				var r = Math.min(Math.max(controller_mc.track_mc.mouseX / controller_mc.track_mc.width, 0), 1);
				//if (controller_mc.stream_mc.scaleX >= r) {
					var s = _player.getDuration() * r;
					if (s != _seekTo) _player.seekTo(s, false);
					_seekTo = s;
					// Update progress marker
					var markerWidth = controller_mc.progressMarker_mc.width - 2;
					var markerX = controller_mc.track_mc.x + controller_mc.track_mc.mouseX;
					var trackLeft = controller_mc.track_mc.x;
					var trackRight = controller_mc.track_mc.x + controller_mc.track_mc.width - markerWidth;
					controller_mc.progressMarker_mc.x = Math.min(Math.max(markerX, trackLeft), trackRight);
				//}
				// Pause video while seeking
				if (_player.getPlayerState() == VIDEO_PLAYING) {
					_player.pauseVideo();
				}
			}
		}
		private function volumeToggleClickHandler (p_event:MouseEvent):void {
			if (_player.getVolume() > 0) {
				_volumeRestore = _player.getVolume();
				setVolume(0);
			} else {
				setVolume(_volumeRestore);
			}
		}
		private function volumeTrackMouseDownHandler (p_event:MouseEvent):void {
			controller_mc.volume_mc.track_mc.addEventListener(Event.ENTER_FRAME, volumeTrackEnterFrameHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, volumeTrackMouseUpHandler, false, 0, true);
		}
		private function volumeTrackMouseUpHandler (p_event:MouseEvent):void {
			controller_mc.volume_mc.track_mc.removeEventListener(Event.ENTER_FRAME, volumeTrackEnterFrameHandler, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, volumeTrackMouseUpHandler, false);
		}
		private function volumeTrackEnterFrameHandler (p_event:Event):void {
			//var h = controller_mc.volume_mc.track_mc.hitArea_mc;
			var t = controller_mc.volume_mc.track_mc;
			var v = (t.mouseX / t.width) * 100;
			setVolume(v);
		}
		
		// Fullscreen
		
		private function fullScreenClickHandler (p_event:MouseEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		private function fullScreenHandler (p_event:FullScreenEvent):void {
			if (p_event.fullScreen) {
				
				// Set stage alignment
				_stageScaleMode = stage.scaleMode;
				_stageAlign = stage.align;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				// Determine the size of stage
				var w = stage.fullScreenWidth;
				var h = stage.fullScreenHeight;
				
				// Hide border
				if (_hasBorder) {
					border_mc.visible = false;
				}
				
				// Position self
				var pt = new Point(x,y);
				pt = MovieClip(parent).localToGlobal(pt);
				x = -pt.x;
				y = -pt.y;
				
				// Hide background
				bkgd_mc.visible = false;
				
				// Position backdrop
				backdrop_mc.visible = true;
				backdrop_mc.x = 0;
				backdrop_mc.y = 0;
				backdrop_mc.width = w;
				backdrop_mc.height = h;
				
				// Position screen
				var sx = w / _screenWidth;
				var sy = h / _screenHeight;
				screen_mc.scaleX = screen_mc.scaleY = Math.min(sx, sy);
				screen_mc.x = Math.round((w - screen_mc.width) / 2);
				screen_mc.y = Math.round((h - screen_mc.height) / 2);
				
				// Position logo
				if (logo_mc.visible) {
					logo_mc.x = screen_mc.x + screen_mc.width - logo_mc.width - 10;
				}
				
				// Position controller
				controller_mc.x = Math.round(w / 2);
				controller_mc.y = h;
				
				// Toggle fullscreen icon
				controller_mc.fullScreen_mc.icon_mc.gotoAndStop(2);
				
				// Center start button, spinner, and error
				start_mc.scaleX = start_mc.scaleY = 2;
				error_mc.scaleX = error_mc.scaleY = 2;
				start_mc.x = spinner_mc.x = error_mc.x = Math.round(w / 2);
				start_mc.y = spinner_mc.y = error_mc.y = Math.round(h / 2);
				
				// Set quality
				if (_qualityLevels[_suggestedQuality] < _qualityLevels.large) {
					_player.setPlaybackQuality('large');
				}
				
			} else {
				
				// Show cursor
				Mouse.show();
				
				// Reset stage alignment
				stage.scaleMode = _stageScaleMode;
				stage.align = _stageAlign;
				
				// Show border
				if (_hasBorder) {
					border_mc.visible = true;
				}
				
				// Reset self
				x = _origX;
				y = _origY;
				
				// Reset background
				bkgd_mc.visible = true;
				
				// Reset backdrop
				backdrop_mc.visible = false;
				backdrop_mc.scaleX = backdrop_mc.scaleY = 1;
				
				// Reset screen
				screen_mc.scaleX = screen_mc.scaleY = 1;
				screen_mc.x = 0;
				screen_mc.y = 0;
				
				// Reset logo
				if (logo_mc.visible) {
					logo_mc.x = _screenWidth - logo_mc.width - 10;
				}
				
				// Reset controller
				controller_mc.x = _screenCenterX;
				controller_mc.y = _screenHeight;
				
				// Reset fullscreen icon
				controller_mc.fullScreen_mc.icon_mc.gotoAndStop(1);
				
				// Reset start button, spinner, and error
				start_mc.scaleX = start_mc.scaleY = 1;
				error_mc.scaleX = error_mc.scaleY = 1;
				start_mc.x = spinner_mc.x = error_mc.x = _screenCenterX;
				start_mc.y = spinner_mc.y = error_mc.y = _screenCenterY;
				
				// Reset quality
				_player.setPlaybackQuality(_suggestedQuality);
			}
		}
		
		// Debug
		
		private function debugEnterFrameHandler (p_event:Event):void {
			//var playerState = 'Player State: ' + _player.getPlayerState();
			//var startBytes = 'Start Bytes: ' + _player.getVideoStartBytes();
			//var bytesLoaded = 'Bytes Loaded: ' + _player.getVideoBytesLoaded();
			//var bytesTotal = 'Bytes Total: ' + _player.getVideoBytesTotal();
			//var duration = 'Duration: ' + _player.getDuration();
			//var currentTime = 'Current Time: ' + _player.getCurrentTime();
			//debug_txt.text = playerState +'\n'+ startBytes +'\n'+ bytesLoaded +'\n'+ bytesTotal +'\n'+ duration +'\n'+ currentTime;
		}
				
		// -------------------------------------------------------------------
	}
}
