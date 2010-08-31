package com.starkplayer.widgets {
	
	import com.starkplayer.media.VideoPlayback;
	import com.starkplayer.media.VideoPlaybackEvent;
	import com.starkplayer.media.VideoPlaybackErrorEvent;
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
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import fl.motion.Color;
		
	public class VideoPlayer extends MovieClip {
		// ===================================================================
		// Constants
		// -------------------------------------------------------------------
		
		public const ASPECT_RATIO_MAINTAIN:String = 'maintain';
		public const ASPECT_RATIO_STRETCH:String = 'stretch';
		//public const ASPECT_RATIO_ZOOM:String = 'zoom';
		
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		protected var _initialized:Boolean;
		
		protected var _videoURL:String;
		protected var _posterURL:String;
		protected var _autoPlay:Boolean;
		protected var _bufferTime:Number;
		protected var _aspectRatio:String;
		protected var _borderColor:Number;
		protected var _logoURL:String;
		
		protected var _stageScaleMode:String;
		protected var _stageAlign:String;
		
		protected var _video:VideoPlayback;
		protected var _volume:Number;
		protected var _volumeRestore:Number;
		protected var _posterLoader:Loader;
		protected var _logoLoader:Loader;
		protected var _hasBorder:Boolean;
		
		protected var _screenWidth:Number;
		protected var _screenHeight:Number;
		protected var _screenCenterX:Number;
		protected var _screenCenterY:Number;
		
		protected var _counter:Number;
		
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var border_mc:MovieClip;
		public var logo_mc:MovieClip;
		public var error_mc:MovieClip;
		public var start_mc:MovieClip;
		public var spinner_mc:MovieClip;
		public var controller_mc:MovieClip;
		public var screen_mc:MovieClip;
		public var backdrop_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function VideoPlayer():void {
			_initialized = false;
			hideChildren();
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
		
		public function load (p_videoURL:String, p_screenWidth:Number = 320, p_screenHeight:Number = 240, p_posterURL:String = null, p_autoPlay:Boolean = false, p_bufferTime:Number = 10, p_aspectRatio:String = null, p_borderColor:Number = NaN, p_logoURL:String = null):void {
			
			if (_initialized) dispose();
			
			// Save parameters
			_videoURL = p_videoURL;
			_screenWidth = p_screenWidth;
			_screenHeight = p_screenHeight;
			_posterURL = p_posterURL;
			_autoPlay = p_autoPlay;
			_bufferTime = p_bufferTime;
			_aspectRatio = p_aspectRatio;
			_borderColor = p_borderColor;
			_logoURL = p_logoURL;
			
			// Validate video dimensions
			if (_screenWidth < 320) _screenWidth = 320;
			if (_screenHeight < 240) _screenHeight = 240;
			
			// Validate aspect ratio
			if (_aspectRatio) _aspectRatio = _aspectRatio.toLowerCase();
			if (_aspectRatio != ASPECT_RATIO_MAINTAIN && _aspectRatio != ASPECT_RATIO_STRETCH) {// && _aspectRatio != ASPECT_RATIO_ZOOM
				_aspectRatio = ASPECT_RATIO_MAINTAIN;
			}
			
			// Initialize volume properties
			_volume = 1;
			_volumeRestore = _volume;
			
			// Determine center of video
			_screenCenterX = Math.round(_screenWidth / 2);
			_screenCenterY = Math.round(_screenHeight / 2);
			
			// Setup self
			x = 0;
			y = 0;
			
			// Setup screen
			screen_mc.x = 0;
			screen_mc.y = 0;
			screen_mc.bkgd_mc.width = screen_mc.video.width = _screenWidth;
			screen_mc.bkgd_mc.height = screen_mc.video.height = _screenHeight;
			
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
			spinner_mc.visible = start_mc.visible = error_mc.visible = false;
			logo_mc.visible = screen_mc.poster_mc.visible = false;
			spinner_mc.stop();
			
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
			
			// Setup fullscreen button
			controller_mc.fullScreen_mc.buttonMode = true;
			controller_mc.fullScreen_mc.mouseChildren = false;
			controller_mc.fullScreen_mc.hitArea = controller_mc.fullScreen_mc.hitArea_mc;
			controller_mc.fullScreen_mc.hitArea_mc.visible = false;
			
			// Setup progress
			controller_mc.track_mc.mouseEnabled = false;
			controller_mc.track_mc.mouseChildren = false;
			controller_mc.stream_mc.buttonMode = true;
			controller_mc.stream_mc.mouseChildren = false;
			controller_mc.progress_mc.mouseEnabled = false;
			controller_mc.progress_mc.mouseChildren = false;
			controller_mc.progressMarker_mc.mouseEnabled = false;
			controller_mc.progressMarker_mc.mouseChildren = false;
			
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
			
			// Setup screen
			screen_mc.video.visible = false;
			
			// Check for errors
			if (_videoURL == null) {
				error_mc.visible = true;
				return;
			}
			
			// Load poster image
			if (_posterURL) {
				_posterLoader = new Loader();
				_posterLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, posterLoaderCompleteHandler, false, 0, true);
				_posterLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, posterLoaderErrorHandler, false, 0, true);
				_posterLoader.load(new URLRequest(_posterURL));
			}
			
			// Load logo image
			if (_logoURL) {
				_logoLoader = new Loader();
				_logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaderCompleteHandler, false, 0, true);
				_logoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, logoLoaderErrorHandler, false, 0, true);
				_logoLoader.load(new URLRequest(_logoURL));
			}
			
			// Attach event handlers to controller buttons
			controller_mc.addEventListener(Event.ENTER_FRAME, controllerEnterFrameHandler, false, 0, true);
			controller_mc.play_mc.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			//controller_mc.rewind_mc.addEventListener(MouseEvent.CLICK, rewindClickHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false, 0, true);
			controller_mc.progress_mc.addEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false, 0, true);
			controller_mc.volume_mc.toggle_mc.addEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false, 0, true);
			controller_mc.volume_mc.track_mc.addEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false, 0, true);
			controller_mc.fullScreen_mc.addEventListener(MouseEvent.CLICK, fullScreenClickHandler, false, 0, true);
			
			// Attach event handler to screen
			screen_mc.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			
			// Attach event handler to start button
			start_mc.addEventListener(MouseEvent.CLICK, startClickHandler, false, 0, true);
			
			// Attach event handlers to fullscreen the video player
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false, 0, true);
			
			// Attach event handler to show/hide the controller
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			showController();
			
			// Load video and attach event handlers
			_video = new VideoPlayback(_videoURL, screen_mc.video, _bufferTime);
			_video.addEventListener(VideoPlaybackEvent.PLAY, videoPlayHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.PAUSE, videoPauseHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.START, videoStartHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.COMPLETE, videoCompleteHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.BUFFER_EMPTY, videoBufferEmptyHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.BUFFER_FULL, videoBufferFullHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.VOLUME_CHANGE, videoVolumeChangeHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackEvent.META_DATA, videoMetaDataHandler, false, 0, true);
			_video.addEventListener(VideoPlaybackErrorEvent.ERROR, videoErrorHandler, false, 0, true);
			_video.volume = _volume;
			
			// Either play the video, or show the start button...
			if (_autoPlay) {
				_video.play();
				spinner_mc.visible = true;
				spinner_mc.play();
			} else {
				start_mc.visible = true;
			}
			
			_initialized = true;
		}
		public function dispose():void {
			
			_initialized = false;
			hideChildren();
			
			// Remove poster image
			if (_posterLoader) {
				_posterLoader.unload();
				if (screen_mc.poster_mc.contains(_posterLoader)) {
					screen_mc.poster_mc.removeChild(_posterLoader);
				}
				_posterLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, posterLoaderCompleteHandler, false);
				_posterLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, posterLoaderErrorHandler, false);
			}
			
			// Remove logo image
			if (_logoLoader) {
				_logoLoader.unload();
				if (logo_mc.contains(_logoLoader)) {
					logo_mc.removeChild(_logoLoader);
				}
				_logoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, logoLoaderCompleteHandler, false);
				_logoLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, logoLoaderErrorHandler, false);
			}
			
			// Remove event handlers on controller buttons
			if (controller_mc.hasEventListener(Event.ENTER_FRAME)) {
				controller_mc.removeEventListener(Event.ENTER_FRAME, controllerEnterFrameHandler, false);
				controller_mc.play_mc.removeEventListener(MouseEvent.CLICK, playClickHandler, false);
				//controller_mc.rewind_mc.removeEventListener(MouseEvent.CLICK, rewindClickHandler, false);
				controller_mc.fullScreen_mc.removeEventListener(MouseEvent.CLICK, fullScreenClickHandler, false);
				controller_mc.stream_mc.removeEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false);
				controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false);
				controller_mc.progress_mc.removeEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false);
				controller_mc.volume_mc.toggle_mc.removeEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false);
				controller_mc.volume_mc.track_mc.removeEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false);	
			}
			
			// Remove event handler on screen
			if (screen_mc.hasEventListener(MouseEvent.CLICK)) {
				screen_mc.removeEventListener(MouseEvent.CLICK, playClickHandler, false);
			}
			
			// Remove event handler on start button
			if (start_mc.hasEventListener(MouseEvent.CLICK)) {
				start_mc.removeEventListener(MouseEvent.CLICK, startClickHandler, false);
			}
			
			// Remove event handlers to fullscreen the video player
			if (stage.hasEventListener(FullScreenEvent.FULL_SCREEN)) {
				stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false);
			}
			
			// Remove event handler to show/hide the controller
			if (hasEventListener(MouseEvent.MOUSE_MOVE)) {
				removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			}
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
			}
			
			// Remove video and event handlers
			if (_video) {
				_video.close();
				_video.removeEventListener(VideoPlaybackEvent.PLAY, videoPlayHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.PAUSE, videoPauseHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.START, videoStartHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.COMPLETE, videoCompleteHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.BUFFER_EMPTY, videoBufferEmptyHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.BUFFER_FULL, videoBufferFullHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.VOLUME_CHANGE, videoVolumeChangeHandler, false);
				_video.removeEventListener(VideoPlaybackEvent.META_DATA, videoMetaDataHandler, false);
				_video.removeEventListener(VideoPlaybackErrorEvent.ERROR, videoErrorHandler, false);
				_video = null;
			}
		}
		
		// ===================================================================
		// Private Methods
		// -------------------------------------------------------------------
		
		private function hideChildren():void {
			controller_mc.visible = spinner_mc.visible = start_mc.visible = error_mc.visible = border_mc.visible = false;
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
		private function scale (p_target:Object, p_width:Number, p_height:Number):void {
			var xsc, ysc, sc;
			switch (_aspectRatio) {
				case ASPECT_RATIO_MAINTAIN:
					xsc = _screenWidth / p_width;
					ysc = _screenHeight / p_height;
					sc = (xsc > ysc) ? ysc : xsc;
					p_target.width = Math.ceil(p_width * sc);
					p_target.height = Math.ceil(p_height * sc);
					p_target.x = Math.round(_screenCenterX - (p_target.width / 2));
					p_target.y = Math.round(_screenCenterY - (p_target.height / 2));
				break;
				case ASPECT_RATIO_STRETCH:
					p_target.width = _screenWidth;
					p_target.height = _screenHeight;
					p_target.x = 0;
					p_target.y = 0;
				break;
				//case ASPECT_RATIO_ZOOM:
				//	xsc = p_width / p_height;
				//	ysc = p_height / p_width;
				//	if ((_screenWidth / _screenHeight) >= xsc) {
				//		p_target.width = _screenWidth;
				//		p_target.height = ysc * _screenWidth;
				//	} else {
				//		p_target.width = xsc * _screenHeight;
				//		p_target.height = _screenHeight;
				//	}
				//	p_target.x = Math.round(_screenCenterX - (p_target.width / 2));
				//	p_target.y = Math.round(_screenCenterY - (p_target.height / 2));
				//break;
			}
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
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
			controller_mc.time_txt.text = TimeUtil.format(_video.time);
		}
		private function startClickHandler (p_event:MouseEvent):void {
			if ( ! _video.playing) _video.play();
		}
		private function playClickHandler (p_event:MouseEvent):void {
			_video[_video.playing ? 'pause' : 'play']();
		}
		//private function rewindClickHandler (p_event:MouseEvent):void {
		//	_video.seek(0);
		//}
		private function streamEnterFrameHandler (p_event:Event):void {
			var bLoaded = _video.bytesLoaded;
			var bTotal = _video.bytesTotal;
			if (bTotal > 0) {
				if (bLoaded == bTotal && controller_mc.stream_mc.scaleX < 1) {
					controller_mc.stream_mc.scaleX = 1;
					controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler);
				} else {
					controller_mc.stream_mc.scaleX = bLoaded / bTotal;
				}
			}
		}
		private function progressEnterFrameHandler (p_event:Event):void {
			if (_video.duration > 0) {
				// Note: substract 2 pixels to allow the progress marker shadow to extend beyond the track
				var markerWidth = controller_mc.progressMarker_mc.width - 2;
				controller_mc.progressMarker_mc.x = controller_mc.track_mc.x + (_video.time / _video.duration * (controller_mc.track_mc.width - markerWidth));
				controller_mc.progress_mc.width = (controller_mc.progressMarker_mc.x - controller_mc.track_mc.x) + (markerWidth / 2);
				//controller_mc.progress_mc.scaleX = _video.time / _video.duration;
			}
		}
		private function streamMouseDownHandler (p_event:MouseEvent):void {
			controller_mc.track_mc.addEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, streamMouseUpHandler, false, 0, true);
		}
		private function streamMouseUpHandler (p_event:MouseEvent):void {
			controller_mc.track_mc.removeEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, streamMouseUpHandler, false);
		}
		private function trackEnterFrameHandler (p_event:Event):void {
			if (_video.duration) {
				var r = Math.min(Math.max(controller_mc.track_mc.mouseX / controller_mc.track_mc.width, 0), 1);
				if (controller_mc.stream_mc.scaleX >= r) {
					var s = _video.duration * r;
					_video.seek(s);
				}
			}
		}
		private function volumeToggleClickHandler (p_event:MouseEvent):void {
			if (_video.volume > 0) {
				_volumeRestore = _video.volume;
				_video.volume = 0;
			} else {
				_video.volume = _volumeRestore;
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
			_video.volume = Math.min(Math.max((t.mouseX / t.width), 0), 1);
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
				
				// Smooth video
				_video.smoothing = true;
				
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
				
				// Reset video smoothing
				_video.smoothing = false;
			}
		}
		
		// Poster
		
		private function posterLoaderCompleteHandler (p_event:Event):void {
			screen_mc.poster_mc.visible = true;
			screen_mc.poster_mc.addChild(_posterLoader);
			scale(screen_mc.poster_mc, screen_mc.poster_mc.width, screen_mc.poster_mc.height);
		}
		private function posterLoaderErrorHandler (p_event:IOErrorEvent):void {
			trace('ERROR: Unable to load poster image.');
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
		
		// Video Playback
		
		private function videoPlayHandler (p_event:VideoPlaybackEvent):void {
			start_mc.visible = false;
			controller_mc.play_mc.icon_mc.gotoAndStop(2);
		}
		private function videoPauseHandler (p_event:VideoPlaybackEvent):void {
			start_mc.visible = true;
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
		}
		private function videoStartHandler (p_event:VideoPlaybackEvent):void {
			screen_mc.video.visible = true;
			//spinner_mc.visible = false;
			//spinner_mc.stop();
		}
		private function videoCompleteHandler (p_event:VideoPlaybackEvent):void {
			screen_mc.video.visible = false;
			spinner_mc.visible = false;
			spinner_mc.stop();
			start_mc.visible = true;
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
		}
		private function videoBufferEmptyHandler (p_event:VideoPlaybackEvent):void {
			spinner_mc.visible = true;
			spinner_mc.play();
		}
		private function videoBufferFullHandler (p_event:VideoPlaybackEvent):void {
			spinner_mc.visible = false;
			spinner_mc.stop();
		}
		private function videoVolumeChangeHandler (p_event:VideoPlaybackEvent):void {
			//var t = controller_mc.volume_mc.track_mc;
			//var h = controller_mc.volume_mc.track_mc.hitArea_mc;
			//var m = controller_mc.volume_mc.marker_mc;
			//m.x = t.x + h.x + Math.round(_video.volume * h.width);
			
			// Note: substract 2 pixels to allow the volume marker shadow to extend beyond the track
			var markerWidth = controller_mc.volume_mc.marker_mc.width - 2;
			controller_mc.volume_mc.marker_mc.x = controller_mc.volume_mc.track_mc.x + Math.round(_video.volume * (controller_mc.volume_mc.track_mc.width - markerWidth));
			_volume = _video.volume;
		}
		private function videoMetaDataHandler (p_event:VideoPlaybackEvent):void {
			controller_mc.duration_txt.text = TimeUtil.format(_video.duration);
			scale(screen_mc.video, _video.width, _video.height);
		}
		private function videoErrorHandler (p_event:VideoPlaybackErrorEvent):void {
			trace('ERROR: ' + p_event.text);
			dispose();
			error_mc.visible = true;
		}
			
		// -------------------------------------------------------------------
	}
}
