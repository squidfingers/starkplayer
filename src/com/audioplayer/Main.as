/**
 * Main
 * Version: 1.0
 * Last modified on July 20, 2010
 **/

package com.audioplayer {
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class Main extends MovieClip {
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var audioPlayer_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function Main():void {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		private function addedToStageHandler (p_event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false);
			
			// Set stage alignment
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Get FlashVars
			var audioURL = root.loaderInfo.parameters.url;
			var autoPlay = root.loaderInfo.parameters.autoplay == 'true';
			var bgColor = root.loaderInfo.parameters.bgcolor;
			
			// Validate bgColor
			if (bgColor) {
				if (bgColor.charAt(0) == '#') {
					bgColor = bgColor.substr(1, bgColor.length);
				}
				if (bgColor.length == 6) {
					bgColor = parseInt(bgColor, 16);
				} else {
					bgColor = NaN;
				}
			} else {
				bgColor = NaN;
			}
			
			// Load audio
			audioPlayer_mc.load(audioURL, autoPlay, bgColor);
		}
		
		// -------------------------------------------------------------------
	}
}