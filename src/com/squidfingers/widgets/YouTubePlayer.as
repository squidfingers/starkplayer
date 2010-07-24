/**
 * YouTubePlayer
 * Version: 1.0
 * Last modified on July 24, 2010
 *
 * http://code.google.com/apis/youtube/flash_api_reference.html
 **/

package com.squidfingers.widgets {
	
	import com.squidfingers.utils.TimeUtil;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Security;
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
		
		protected var _youTubeId:String;
		protected var _autoPlay:Boolean;
		protected var _borderColor:Number;
		protected var _suggestedQuality:String;
		
		protected var _player:Object;
		protected var _loader:Loader;
		
		protected var _screenWidth:Number;
		protected var _screenHeight:Number;
		protected var _screenCenterX:Number;
		protected var _screenCenterY:Number;
		protected var _volume:Number;
		protected var _volumeRestore:Number;
		protected var _stageScaleMode:String;
		protected var _stageAlign:String;
		protected var _hasBorder:Boolean;
		
		protected var _seeking:Boolean;
		protected var _seekTo:Number;
		protected var _playingBeforeSeek:Boolean;
		
		protected var _counter:Number;
		
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var border_mc:MovieClip;
		public var error_mc:MovieClip;
		public var start_mc:MovieClip;
		public var spinner_mc:MovieClip;
		public var controller_mc:MovieClip;
		public var screen_mc:MovieClip;
		public var bkgd_mc:MovieClip;
		public var backdrop_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function YouTubePlayer():void {
			Security.allowDomain('www.youtube.com');
			hideChildren();
		}
		
		// ===================================================================
		// Public Methods
		// -------------------------------------------------------------------
		
		public function load (p_youTubeId:String, p_screenWidth:Number = 320, p_screenHeight:Number = 240, p_autoPlay:Boolean = true, p_borderColor:Number = NaN, p_suggestedQuality:String = 'medium'):void {
			
			dispose();
			
			// Save parameters
			_youTubeId = p_youTubeId;
			_screenWidth = p_screenWidth;
			_screenHeight = p_screenHeight;
			_autoPlay = p_autoPlay;
			_borderColor = p_borderColor;
			_suggestedQuality = p_suggestedQuality;
			
			// Validate video dimensions
			if (_screenWidth < 320) _screenWidth = 320;
			if (_screenHeight < 240) _screenHeight = 240;
			
			// Initialize volume properties
			_volume = 90;
			_volumeRestore = _volume;
			
			// Determine center of video
			_screenCenterX = Math.round(_screenWidth / 2);
			_screenCenterY = Math.round(_screenHeight / 2);
			
			// Setup self
			x = 0;
			y = 0;
			
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
			controller_mc.volume_mc.track_mc.hitArea = controller_mc.volume_mc.track_mc.hitArea_mc;
			controller_mc.volume_mc.track_mc.hitArea_mc.visible = false;
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
			controller_mc.track_mc.mouseEnabled = false;
			controller_mc.track_mc.mouseChildren = false;
			controller_mc.stream_mc.buttonMode = true;
			controller_mc.stream_mc.mouseChildren = false;
			controller_mc.progress_mc.mouseEnabled = false;
			controller_mc.progress_mc.mouseChildren = false;
			controller_mc.progressMarker_mc.mouseEnabled = false;
			controller_mc.progressMarker_mc.mouseChildren = false;
			
			// Check for errors
			if (_youTubeId == null) {
				error_mc.visible = true;
				return;
			}
			
			// Load YouTube API
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, loaderInitHandler, false, 0, true);
			_loader.load(new URLRequest('http://www.youtube.com/apiplayer?version=3'));
			
			// Show spinner
			spinner_mc.visible = true;
			spinner_mc.play();
		}
		public function dispose():void {
			
			hideChildren();
			
			// Destroy player
			if (_player) {
				_player.stopVideo();
				_player.destroy();
				_player = null;
			}
			
			// Destroy loader
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.INIT, loaderInitHandler, false);
			}
			if (_loader && screen_mc.contains(_loader)) {
				_loader.content.removeEventListener('onReady', videoReadyHandler, false);
				_loader.content.removeEventListener('onError', videoErrorHandler, false);
				_loader.content.removeEventListener('onStateChange', videoStateChangeHandler, false);
				_loader.content.removeEventListener('onPlaybackQualityChange', videoPlaybackQualityChangeHandler, false);
			}
			_loader = null;
			
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
				controller_mc.removeEventListener(Event.ENTER_FRAME, timeEnterFrameHandler, false);
				controller_mc.stream_mc.removeEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false);
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
				var t = controller_mc.volume_mc.track_mc;
				var h = controller_mc.volume_mc.track_mc.hitArea_mc;
				var m = controller_mc.volume_mc.marker_mc;
				m.x = t.x + h.x + Math.round((_volume / 100) * h.width);
			}
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		// YouTube API
		
		private function loaderInitHandler (p_event:Event):void {
			screen_mc.addChild(_loader);
			_loader.content.addEventListener('onReady', videoReadyHandler, false, 0, true);
			_loader.content.addEventListener('onError', videoErrorHandler, false, 0, true);
			_loader.content.addEventListener('onStateChange', videoStateChangeHandler, false, 0, true);
			_loader.content.addEventListener('onPlaybackQualityChange', videoPlaybackQualityChangeHandler, false, 0, true);
		}
		private function videoReadyHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the player API ID
			// Console.log('READY:', Object(p_event).data);
			
			// Attach controller event handlers
			screen_mc.addEventListener(MouseEvent.CLICK, youTubeClickHandler, false, 0, true);
			start_mc.addEventListener(MouseEvent.CLICK, startClickHandler, false, 0, true);
			controller_mc.play_mc.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			//controller_mc.rewind_mc.addEventListener(MouseEvent.CLICK, rewindClickHandler, false, 0, true);
			//controller_mc.mute_mc.addEventListener(MouseEvent.CLICK, muteClickHandler, false, 0, true);
			controller_mc.volume_mc.toggle_mc.addEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false, 0, true);
			controller_mc.volume_mc.track_mc.addEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false, 0, true);
			controller_mc.fullScreen_mc.addEventListener(MouseEvent.CLICK, fullScreenClickHandler, false, 0, true);
			controller_mc.addEventListener(Event.ENTER_FRAME, timeEnterFrameHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false, 0, true);
			controller_mc.progress_mc.addEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false, 0, true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false, 0, true);
			
			// Attach event handler to show/hide the controller
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			showController();
			
			// Load YouTube video
			_player = _loader.content;
			_player.setSize(_screenWidth, _screenHeight);
			if (_autoPlay) {
				_player.loadVideoById(_youTubeId, 0, _suggestedQuality);
			} else {
				_player.cueVideoById(_youTubeId, 0, _suggestedQuality);
			}
			setVolume(_volume);
		}
		private function videoErrorHandler (p_event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace('ERROR:' + Object(p_event).data);
			dispose();
			error_mc.visible = true;
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
					start_mc.visible = false;
					spinner_mc.visible = false;
					spinner_mc.stop();
					controller_mc.play_mc.icon_mc.gotoAndStop(2);
					break;
				case VIDEO_PAUSED:
					// Console.log('Video Paused');
					if (_seeking) return;// Ignore event if seeking
					// Video paused
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
				if (_player.getPlayerState() == VIDEO_PLAYING) {
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
		private function timeEnterFrameHandler (p_event:Event):void {
			controller_mc.duration_txt.text = TimeUtil.format(_player.getDuration());
			controller_mc.time_txt.text = TimeUtil.format(_player.getCurrentTime());
		}
		private function startClickHandler (p_event:MouseEvent):void {
			if (_player.getPlayerState() != VIDEO_PLAYING) _player.playVideo();
		}
		private function playClickHandler (p_event:MouseEvent):void {
			if (_player.getPlayerState() == VIDEO_PLAYING) {
				_player.pauseVideo();
			} else {
				_player.playVideo();
			}
		}
		//private function rewindClickHandler (p_event:MouseEvent):void {
		//	_player.seekTo(0, false);
		//}
		//private function muteClickHandler (p_event:MouseEvent):void {
		//	if (_player.isMuted()) {
		//		_player.unMute();
		//		controller_mc.mute_mc.icon_mc.gotoAndStop(1);
		//	} else {
		//		_player.mute();
		//		controller_mc.mute_mc.icon_mc.gotoAndStop(2);
		//	}
		//}
		private function streamEnterFrameHandler (p_event:Event):void {
			var bLoaded = _player.getVideoBytesLoaded();
			var bTotal = _player.getVideoBytesTotal();
			if (bTotal > 0) {
				if (bLoaded == bTotal && controller_mc.stream_mc.scaleX < 1) {
					controller_mc.stream_mc.scaleX = 1;
					controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false);
				} else {
					controller_mc.stream_mc.scaleX = bLoaded / bTotal;
				}
			}
		}
		private function progressEnterFrameHandler (p_event:Event):void {
			if (_player.getDuration() > 0) {
				// Note: substract 2 pixels to allow the progress marker shadow to extend beyond the track
				var markerWidth = controller_mc.progressMarker_mc.width - 2;
				controller_mc.progressMarker_mc.x = controller_mc.track_mc.x + (_player.getCurrentTime() / _player.getDuration() * (controller_mc.track_mc.width - markerWidth));
				controller_mc.progress_mc.width = (controller_mc.progressMarker_mc.x - controller_mc.track_mc.x) + (markerWidth / 2);
				//controller_mc.progress_mc.scaleX = _player.getCurrentTime() / _player.getDuration();
			}
		}
		private function streamMouseDownHandler (p_event:MouseEvent):void {
			_seeking = true;
			_seekTo = NaN;
			_playingBeforeSeek = (_player.getPlayerState() == VIDEO_PLAYING);
			// Remove event handlers
			controller_mc.track_mc.addEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, streamMouseUpHandler, false, 0, true);
		}
		private function streamMouseUpHandler (p_event:MouseEvent):void {
			// Attach event handlers
			controller_mc.track_mc.removeEventListener(Event.ENTER_FRAME, trackEnterFrameHandler, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, streamMouseUpHandler, false);
			// Play video if needed
			if (_player.getPlayerState() != VIDEO_PLAYING && _playingBeforeSeek) {
				_player.playVideo();
			}
			_seekTo = NaN;
			_seeking = false;
		}
		private function trackEnterFrameHandler (p_event:Event):void {
			if (_player.getDuration()) {
				var r = controller_mc.track_mc.mouseX / controller_mc.track_mc.width;
				var t = _player.getDuration() * Math.min(Math.max(r, 0), 1);
				if (t != _seekTo) _player.seekTo(t, false);
				_seekTo = t;
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
			var h = controller_mc.volume_mc.track_mc.hitArea_mc;
			var v = (h.mouseX / h.width) * 100;
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
				_player.setPlaybackQuality('large');
				
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
				
				// Reset background
				bkgd_mc.visible = true;
				
				// Reset backdrop
				backdrop_mc.visible = false;
				backdrop_mc.scaleX = backdrop_mc.scaleY = 1;
				
				// Reset screen
				screen_mc.scaleX = screen_mc.scaleY = 1;
				screen_mc.x = 0;
				screen_mc.y = 0;
				
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
		
		// -------------------------------------------------------------------
	}
}