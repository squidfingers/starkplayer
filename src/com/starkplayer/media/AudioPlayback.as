package com.starkplayer.media {
	
	import flash.events.EventDispatcher;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class AudioPlayback extends EventDispatcher {
		
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		private var _url:String;
		private var _playing:Boolean;
		private var _loaded:Boolean;
		private var _position:Number;
		private var _snd:Sound;
		private var _channel:SoundChannel;
		private var _soundTransform:SoundTransform;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function AudioPlayback (p_url:String):void {
			_url = p_url;
			_playing = false;
			_loaded = false;
			_position = 0;
			_snd = null;
			_channel = null;
			_soundTransform = new SoundTransform(1);
		}
		
		// ===================================================================
		// Public Properties
		// -------------------------------------------------------------------
		
		public function get playing():Boolean {
			return _playing;
		}
		
		// Sound Properties
		
		public function get bytesLoaded():Number {
			if (_snd) return (_snd.bytesTotal > 16) ? _snd.bytesLoaded : 0;
			else return 0;
		}
		public function get bytesTotal():Number {
			if (_snd) return (_snd.bytesTotal > 16) ? _snd.bytesTotal : 0;
			else return 0;
		}
		public function get currentLength():Number {// milliseconds
			return _snd ? _snd.length : 0;
		}
		public function get length():Number {// milliseconds
			if (_loaded) {
				return currentLength;
			} else {
				return (bytesTotal > 0) ? Math.ceil(currentLength / (bytesLoaded / bytesTotal)) : 0;
			}
		}
		public function get position():Number {// milliseconds
			return _playing ? _channel.position : _position;
		}
		
		// Volume

		public function get volume():Number {
			return _soundTransform.volume;
		}
		public function set volume (p_volume:Number):void {
			_soundTransform.volume = p_volume;
			if (_channel) _channel.soundTransform = _soundTransform;
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.VOLUME_CHANGE));
		}

		// ID3
		
		public function get id3():ID3Info {
			return _snd.id3;
		}
				
		// ===================================================================
		// Public Methods
		// -------------------------------------------------------------------
		
		public function dispose():void {
			_playing = false;
			_loaded = false;
			_position = 0;
			if (_channel) {
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false);
				_channel = null;
			}
			if (_snd) {
				if ( ! _loaded) {
					try {
						_snd.close();
					} catch (e:IOError) {
						//dispatchEvent(new AudioPlaybackErrorEvent(AudioPlaybackErrorEvent.ERROR, false, false, 'IO Error'));
						//trace('AudioPlayback IO Error: ' + e.message);
					}
				}
				_snd.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler, false);
				_snd.removeEventListener(Event.ID3, id3Handler, false);
				_snd.removeEventListener(Event.COMPLETE, completeHandler, false);
				_snd = null;
			}
		}
		public function play():void {
			if (_playing) {
				return;
			}
			_playing = true;
			if (_snd) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false);
				_channel = _snd.play(_position);
				_channel.soundTransform = _soundTransform;
				_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			} else {
				_snd = new Sound();
				_snd.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
				_snd.addEventListener(Event.ID3, id3Handler, false, 0, true);
				_snd.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
				try {
					_snd.load(new URLRequest(_url));
					_channel = _snd.play();
				} catch (e:Error) {
					dispatchEvent(new AudioPlaybackErrorEvent(AudioPlaybackErrorEvent.ERROR, false, false, e.message));
				}
				if (_channel) {
					_channel.soundTransform = _soundTransform;
					_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
				}
			}
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.PLAY));
		}
		public function pause():void {
			if ( ! _playing) {
				return;
			}
			_playing = false;
			_position = (_snd.bytesLoaded > 16) ? _channel.position : 0;
			_channel.stop();
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.PAUSE));
		}
		public function stop():void {
			if ( ! _playing) {
				return;
			}
			_playing = false;
			_position = 0;
			_channel.stop();
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.STOP));
		}
		public function seek (p_milliseconds:Number):void {
			if (length > 0) {
				if (p_milliseconds > 0 && p_milliseconds < length) {
					_position = p_milliseconds;
					if (_playing) {
						_channel.stop();
						_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false);
						_channel = _snd.play(_position);
						_channel.soundTransform = _soundTransform;
						_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
					}
					dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.SEEK));
				}
			}
		}
		
		// ===================================================================
		// Event handlers
		// -------------------------------------------------------------------
			
		private function errorHandler (p_event:IOErrorEvent):void {
			dispatchEvent(new AudioPlaybackErrorEvent(AudioPlaybackErrorEvent.ERROR, false, false, 'IO Error'));
			//trace('AudioPlayback IO Error: ' + p_event.text);
        }
		private function id3Handler (p_event:Event):void {
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.ID3));
		}
		private function completeHandler (p_event:Event):void {
			_loaded = true;
        }
        private function soundCompleteHandler (p_event:Event):void {
			stop();
			dispatchEvent(new AudioPlaybackEvent(AudioPlaybackEvent.COMPLETE));
        }
	
		// -------------------------------------------------------------------
		
	}
}