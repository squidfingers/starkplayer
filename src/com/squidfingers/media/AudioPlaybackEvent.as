/**
 * AudioPlaybackEvent
 * Version: 1.0
 * Last modified on July 19, 2010
 **/

package com.squidfingers.media {
	
	import flash.events.Event;
	
	public class AudioPlaybackEvent extends Event {
		
		// ===================================================================
		// Constants
		// -------------------------------------------------------------------
		
		public static const PLAY:String = 'play';
		public static const PAUSE:String = 'pause';
		public static const STOP:String = 'stop';
		public static const SEEK:String = 'seek';
		public static const COMPLETE:String = 'complete';
		public static const ID3:String = 'id3';
		public static const VOLUME_CHANGE:String = 'volumeChange';
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function AudioPlaybackEvent (p_type:String, p_bubbles:Boolean=false, p_cancelable:Boolean=false):void {
			super(p_type, p_bubbles, p_cancelable);
		}
		
		// -------------------------------------------------------------------
	}
}