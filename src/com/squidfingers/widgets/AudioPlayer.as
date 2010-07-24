package com.squidfingers.widgets {
	
	import com.squidfingers.media.AudioPlayback;
	import com.squidfingers.media.AudioPlaybackEvent;
	import com.squidfingers.media.AudioPlaybackErrorEvent;
	import com.squidfingers.utils.TimeUtil;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.motion.Color;
	
	public class AudioPlayer extends MovieClip {
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		protected var _initialized:Boolean;
		
		protected var _audioURL:String;
		protected var _autoPlay:Boolean;
		protected var _borderColor:Number;
		
		protected var _audio:AudioPlayback;
		protected var _volume:Number;
		protected var _volumeRestore:Number;
		
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var controller_mc:MovieClip;
		public var border_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function AudioPlayer():void {
			stop();
		}
		
		// ===================================================================
		// Public Methods
		// -------------------------------------------------------------------
		
		public function load (p_audioURL:String, p_autoPlay:Boolean = false, p_borderColor:Number = NaN):void {
			
			if (_initialized) dispose();
			
			// Save parameters
			_audioURL = p_audioURL;
			_autoPlay = p_autoPlay;
			_borderColor = p_borderColor;
			
			// Initialize volume properties
			_volume = 0.9;
			_volumeRestore = _volume;
			
			// Setup border
			if (isNaN(_borderColor)) {
				border_mc.visible = false;
			} else {
				border_mc.visible = true;
				var c = new Color();
				c.setTint(_borderColor, 1);
				border_mc.transform.colorTransform = c;
			}
			
			// Check for errors
			if (_audioURL == null) {
				gotoAndStop(2);
				return;
			} else {
				gotoAndStop(1);
			}
			
			// Setup controller
			controller_mc.stream_mc.scaleX = 0;
			controller_mc.progress_mc.scaleX = 0;
			controller_mc.progressMarker_mc.x = controller_mc.progress_mc.x;
			controller_mc.time_txt.text = '0:00';
			controller_mc.duration_txt.text = '0:00';
			
			// Setup play button
			controller_mc.play_mc.buttonMode = true;
			controller_mc.play_mc.mouseChildren = false;
			controller_mc.play_mc.hitArea = controller_mc.play_mc.hitArea_mc;
			controller_mc.play_mc.hitArea_mc.visible = false;
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
			
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
			controller_mc.volume_mc.track_mc.hitArea = controller_mc.volume_mc.track_mc.hitArea_mc;
			controller_mc.volume_mc.track_mc.hitArea_mc.visible = false;
			controller_mc.volume_mc.track_mc.buttonMode = true;
			controller_mc.volume_mc.track_mc.mouseChildren = false;
			controller_mc.volume_mc.marker_mc.mouseEnabled = false;
			controller_mc.volume_mc.marker_mc.mouseChildren = false;
			
			// Attach event handlers to controller buttons
			controller_mc.addEventListener(Event.ENTER_FRAME, timeEnterFrameHandler, false, 0, true);
			controller_mc.play_mc.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false, 0, true);
			controller_mc.stream_mc.addEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false, 0, true);
			controller_mc.progress_mc.addEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false, 0, true);
			controller_mc.volume_mc.toggle_mc.addEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false, 0, true);
			controller_mc.volume_mc.track_mc.addEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false, 0, true);
			
			// Load audio and attach event handlers
			_audio = new AudioPlayback(_audioURL);
			_audio.addEventListener(AudioPlaybackEvent.PLAY, audioPlayHandler, false);
			_audio.addEventListener(AudioPlaybackEvent.PAUSE, audioPauseHandler, false);
			_audio.addEventListener(AudioPlaybackEvent.COMPLETE, audioCompleteHandler, false);
			_audio.addEventListener(AudioPlaybackEvent.VOLUME_CHANGE, audioVolumeChangeHandler, false);
			_audio.addEventListener(AudioPlaybackErrorEvent.ERROR, audioErrorHandler, false);
			_audio.volume = _volume;
			
			// Play the audio
			if (_autoPlay) {
				_audio.play();
			}
			
			_initialized = true;
		}
		public function dispose():void {
			
			_initialized = false;
			
			// Remove event handlers on controller buttons
			if (controller_mc && controller_mc.hasEventListener(Event.ENTER_FRAME)) {
				controller_mc.removeEventListener(Event.ENTER_FRAME, timeEnterFrameHandler, false);
				controller_mc.play_mc.removeEventListener(MouseEvent.CLICK, playClickHandler, false);
				controller_mc.stream_mc.removeEventListener(MouseEvent.MOUSE_DOWN, streamMouseDownHandler, false);
				controller_mc.stream_mc.removeEventListener(Event.ENTER_FRAME, streamEnterFrameHandler, false);
				controller_mc.progress_mc.removeEventListener(Event.ENTER_FRAME, progressEnterFrameHandler, false);
				controller_mc.volume_mc.toggle_mc.removeEventListener(MouseEvent.CLICK, volumeToggleClickHandler, false);
				controller_mc.volume_mc.track_mc.removeEventListener(MouseEvent.MOUSE_DOWN, volumeTrackMouseDownHandler, false);
			}

			// Remove audio and event handlers
			if (_audio) {
				_audio.dispose();
				_audio.removeEventListener(AudioPlaybackEvent.PLAY, audioPlayHandler, false);
				_audio.removeEventListener(AudioPlaybackEvent.PAUSE, audioPauseHandler, false);
				_audio.removeEventListener(AudioPlaybackEvent.COMPLETE, audioCompleteHandler, false);
				_audio.removeEventListener(AudioPlaybackEvent.VOLUME_CHANGE, audioVolumeChangeHandler, false);
				_audio.removeEventListener(AudioPlaybackErrorEvent.ERROR, audioErrorHandler, false);
				_audio = null;
			}
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		// Controller
		
		private function timeEnterFrameHandler (p_event:Event):void {
			controller_mc.time_txt.text = TimeUtil.format(Math.round(_audio.position / 1000));
			controller_mc.duration_txt.text = TimeUtil.format(Math.round(_audio.length / 1000));
		}
		private function playClickHandler (p_event:MouseEvent):void {
			_audio[_audio.playing ? 'pause' : 'play']();
		}
		private function streamEnterFrameHandler (p_event:Event):void {
			var bLoaded = _audio.bytesLoaded;
			var bTotal = _audio.bytesTotal;
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
			if (_audio.length > 0) {
				// Note: substract 2 pixels to allow the progress marker shadow to extend beyond the track
				var markerWidth = controller_mc.progressMarker_mc.width - 2;
				controller_mc.progressMarker_mc.x = controller_mc.track_mc.x + (_audio.position / _audio.length * (controller_mc.track_mc.width - markerWidth));
				controller_mc.progress_mc.width = (controller_mc.progressMarker_mc.x - controller_mc.track_mc.x) + (markerWidth / 2);
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
			if (_audio.length) {
				var r = controller_mc.track_mc.mouseX / controller_mc.track_mc.width;
				var t = Math.min(Math.max(r, 0), 1) * _audio.length;
				_audio.seek(t);
			}
		}
		private function volumeToggleClickHandler (p_event:MouseEvent):void {
			if (_audio.volume > 0) {
				_volumeRestore = _audio.volume;
				_audio.volume = 0;
			} else {
				_audio.volume = _volumeRestore;
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
			_audio.volume = Math.min(Math.max((h.mouseX / h.width), 0), 1);
		}
		
		// Audio Playback
		
		private function audioPlayHandler (p_event:AudioPlaybackEvent):void {
			controller_mc.play_mc.icon_mc.gotoAndStop(2);
		}
		private function audioPauseHandler (p_event:AudioPlaybackEvent):void {
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
		}
		private function audioCompleteHandler (p_event:AudioPlaybackEvent):void {
			controller_mc.play_mc.icon_mc.gotoAndStop(1);
		}
		private function audioVolumeChangeHandler (p_event:AudioPlaybackEvent):void {
			var t = controller_mc.volume_mc.track_mc;
			var h = controller_mc.volume_mc.track_mc.hitArea_mc;
			var m = controller_mc.volume_mc.marker_mc;
			m.x = t.x + h.x + Math.round(_audio.volume * h.width);
			_volume = _audio.volume;
		}
		private function audioErrorHandler (p_event:AudioPlaybackErrorEvent):void {
			dispose();
			gotoAndStop(2);
			trace('ERROR: ' + p_event.text);
		}
		
		// -------------------------------------------------------------------
	}
}
