/**
 * VideoPlaybackErrorEvent
 * Version: 1.0
 * Last modified on July 18, 2010
 **/

package com.squidfingers.media {
	
	import flash.events.Event;
	
	public class VideoPlaybackErrorEvent extends Event {
		
		// ===================================================================
		// Constants
		// -------------------------------------------------------------------
		
		public static const ERROR:String = 'error';
		
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		public var text:String;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function VideoPlaybackErrorEvent (p_type:String, p_bubbles:Boolean=false, p_cancelable:Boolean=false, p_text:String=''):void {
			super(p_type, p_bubbles, p_cancelable);
			text = p_text;
		}
		
		// -------------------------------------------------------------------
	}
}