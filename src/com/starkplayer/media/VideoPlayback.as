package com.starkplayer.media {
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoPlayback extends EventDispatcher {
		
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		private var _url:String;
		private var _video:Video;
		private var _bufferTime:Number;
		private var _metaData:Object;
		private var _cuePoint:Object;
		private var _connected:Boolean;
		private var _playing:Boolean;
		private var _completed:Boolean;
		private var _buffering:Boolean;
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _soundTransform:SoundTransform;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function VideoPlayback (p_url:String, p_video:Video, p_bufferTime:Number = 10):void {
			_url = p_url;
			_video = p_video;
			_bufferTime = p_bufferTime;
			_metaData = new Object();
			_cuePoint = new Object();
			_connected = false;
			_playing = false;
			_completed = false;
			_buffering = false;
			_soundTransform = new SoundTransform(1);
		}
		
		// ===================================================================
		// Public Properties
		// -------------------------------------------------------------------
		
		public function get playing():Boolean {
			return _playing;
		}
		public function get buffering():Boolean {
			return _buffering;
		}
		
		// Video

		public function get smoothing():Boolean {
			return _video.smoothing;
		}
		public function set smoothing (p_smooth:Boolean):void {
			_video.smoothing = p_smooth;
		}
		public function get videoWidth():Number {
			return _video.videoWidth;
		}
		public function get videoHeight():Number {
			return _video.videoHeight;
		}
		
		// NetStream
		
		public function get bufferLength():Number {
			return _netStream ? _netStream.bufferLength : 0;
		}
		public function get bufferTime():Number {
			return _netStream ? _netStream.bufferTime : 0;
		}
		public function get bytesLoaded():Number {
			return _netStream ? _netStream.bytesLoaded : 0;
		}
		public function get bytesTotal():Number {
			return _netStream ? _netStream.bytesTotal : 0;
		}
		public function get currentFPS():Number {
			return _netStream ? _netStream.currentFPS : 0;
		}
		public function get time():Number {
			return _netStream ? _netStream.time : 0;
		}
		
		// MetaData
		
		public function get duration():Number {
			return _metaData.duration || 0;
		}
		public function get width():Number {
			return _metaData.width || 0;
		}
		public function get height():Number {
			return _metaData.height || 0;
		}
		public function get framerate():Number {
			return _metaData.framerate || 0;
		}
		
		// CuePoint
		
		public function get cuePoint():Object {
			return _cuePoint;
		}
		
		// Volume

		public function get volume():Number {
			return _soundTransform.volume;
		}
		public function set volume (p_volume:Number):void {
			_soundTransform.volume = p_volume;
			if (_netStream) _netStream.soundTransform = _soundTransform;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.VOLUME_CHANGE));
		}
		
		// ===================================================================
		// Public Methods
		// -------------------------------------------------------------------
		
		public function play():void {
			if (_playing) return;
			if (_connected) {
				_netStream.resume();
				if (_completed) {
					_completed = false;
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.START));
				}
				_playing = true;
				dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.PLAY));
			} else {
				openNetConnection();
			}
		}
		public function pause():void {
			if ( ! _playing) return;
			_netStream.pause();
			_playing = false;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.PAUSE));
		}
		public function stop():void {
			if ( ! _playing) return;
			_netStream.pause();
			_netStream.seek(0);
			_playing = false;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.STOP));
		}
		public function seek (p_seekTo:Number):void {
			if (duration > 0) {
				if (p_seekTo >= 0 && p_seekTo < duration) {
					_netStream.seek(p_seekTo);
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.SEEK));
				}
			}
		}
		public function close():void {
			_connected = false;
			_playing = false;
			if (_netConnection) {
				_netConnection.close();
				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false);
				_netConnection.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
			}
			if (_netStream) {
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false);
				_netStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
				_netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false);
			}
			if (_video) {
				_video.clear();
			}
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.CLOSE));
		}
		
		// ===================================================================
		// Private Methods
		// -------------------------------------------------------------------
		
		private function openNetConnection():void {
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			_netConnection.connect(null);
		}
		private function openNetStream():void {
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			_netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
			_netStream.client = this;
			_netStream.bufferTime = _bufferTime;
			_netStream.soundTransform = _soundTransform;
			_video.attachNetStream(_netStream);
			_netStream.play(_url);
			_connected = true;
			_playing = true;
			_buffering = true;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.PLAY));
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		private function netStatusHandler (p_event:NetStatusEvent):void {
			//trace('VideoPlayback.netStatusHandler(' + p_event.info.code + ')');
			switch (p_event.info.code) {
				case 'NetConnection.Connect.Success':
					openNetStream();
					break;
				case 'NetStream.Buffer.Empty':
					// Data is not being received quickly enough to fill the 
					// buffer. Data flow will be interrupted until the buffer 
					// refills, at which time a NetStream.Buffer.Full message 
					// will be sent and the stream will begin playing again.
					_buffering = true;
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.BUFFER_EMPTY));
					break;
				case 'NetStream.Buffer.Full':
					// The buffer is full and the stream will begin playing.
					_buffering = false;
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.BUFFER_FULL));
					break;
				case 'NetStream.Buffer.Flush':
					// Data has finished streaming, and the remaining buffer 
					// will be emptied.
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.BUFFER_FLUSH));
					break;
				case 'NetStream.Play.Start':
					// Playback has started.
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.START));
					break;
				case 'NetStream.Play.Stop':
				 	// Playback has stopped.
					stop();
					_completed = true;
					dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.COMPLETE));
					break;
				case 'NetStream.Play.Failed':
					// An error has occurred in playback for a reason such as 
					// the subscriber not having read access.
					dispatchEvent(new VideoPlaybackErrorEvent(VideoPlaybackErrorEvent.ERROR, false, false, 'Play Failed'));
					break;
				case 'NetStream.Play.StreamNotFound':
					// The FLV passed to the play() method can't be found.
					dispatchEvent(new VideoPlaybackErrorEvent(VideoPlaybackErrorEvent.ERROR, false, false, 'Stream Not Found'));
					break;
				case 'NetStream.Pause.Notify':
					// The stream is paused.
					break;
				case 'NetStream.Unpause.Notify':
					// The stream is resumed.
					break;
				case 'NetStream.Seek.Failed':
					// The seek fails, which happens if the 
					// stream is not seekable.
					break;
				case 'NetStream.Seek.InvalidTime':
					// For video downloaded with progressive download, the 
					// user has tried to seek or play past the end of the 
					// video data that has downloaded thus far, or past the 
					// end of the video once the entire file has downloaded. 
					// The message.details property contains a time code that 
					// indicates the last valid position to which the user 
					// can seek.
					break;
				case 'NetStream.Seek.Notify':
					// The seek operation is complete.
					break;
			}
		}
		private function ioErrorHandler (p_event:IOErrorEvent):void {
			dispatchEvent(new VideoPlaybackErrorEvent(VideoPlaybackErrorEvent.ERROR, false, false, 'IO Error'));
		}
		private function securityErrorHandler (p_event:SecurityErrorEvent):void {
			dispatchEvent(new VideoPlaybackErrorEvent(VideoPlaybackErrorEvent.ERROR, false, false, 'Security Violation'));
		}
		private function asyncErrorHandler (p_event:AsyncErrorEvent):void {
		}
		
		// ===================================================================
		// NetStream Client Methods
		// -------------------------------------------------------------------
		
		public function onPlayStatus (p_obj:Object):void {
			//trace('VideoPlayback.onPlayStatus');
			for (var prop in p_obj) {
				trace(prop + ': ' + p_obj[prop]);
			}
		}
		public function onMetaData (p_obj:Object):void {
			//trace('VideoPlayback.onMetaData');
			_metaData = p_obj;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.META_DATA));
		}
		public function onCuePoint (p_obj:Object):void {
			//trace('VideoPlayback.onCuePoint');
			_cuePoint = p_obj;
			dispatchEvent(new VideoPlaybackEvent(VideoPlaybackEvent.CUE_POINT));
		}
		
		// -------------------------------------------------------------------
	}
}