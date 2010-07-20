/**
 * VideoPlaybackEvent
 * Version: 1.0
 * Last modified on July 18, 2010
 **/

package com.squidfingers.media {
	
	import flash.events.Event;
	
	public class VideoPlaybackEvent extends Event {
		
		// ===================================================================
		// Constants
		// -------------------------------------------------------------------
		
		public static const VOLUME_CHANGE:String = 'volumeChange';
		public static const META_DATA:String = 'metaData';
		public static const CUE_POINT:String = 'cuePoint';
		
		public static const BUFFER_EMPTY:String = 'bufferEmpty';
		public static const BUFFER_FULL:String = 'bufferFull';
		public static const BUFFER_FLUSH:String = 'bufferFlush';
		
		public static const PLAY:String = 'play';
		public static const START:String = 'start';
		public static const STOP:String = 'stop';
		public static const PAUSE:String = 'pause';
		public static const SEEK:String = 'seek';
		public static const COMPLETE:String = 'complete';
		
		public static const CLOSE:String = 'close';
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function VideoPlaybackEvent (p_type:String, p_bubbles:Boolean=false, p_cancelable:Boolean=false):void {
			super(p_type, p_bubbles, p_cancelable);
		}
		
		// -------------------------------------------------------------------
	}
}