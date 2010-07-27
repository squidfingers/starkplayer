package com.videoplayer {
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class Main extends MovieClip {
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var videoPlayer_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function Main():void {
			
			var cm = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems.push(new ContextMenuItem('Video Starkplayer'));
			cm.customItems.push(new ContextMenuItem('Version: 0.9'));
			contextMenu = cm;
			
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
			var videoURL = root.loaderInfo.parameters.url;
			var posterURL = root.loaderInfo.parameters.poster;
			var autoPlay = root.loaderInfo.parameters.autoplay;
			var bufferTime = root.loaderInfo.parameters.buffertime;
			var border = root.loaderInfo.parameters.border;
			var logoURL = root.loaderInfo.parameters.logo;
			
			// Process parameters
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			bufferTime = (bufferTime) ? parseInt(bufferTime) : null;
			
			// Validate border
			var borderColor = NaN;
			if (border && border != 'false') {
				if (border.charAt(0) == '#') {
					border = border.substr(1, border.length);
				}
				if (border.length == 6) {
					borderColor = parseInt(border, 16);
				} else {
					borderColor = 0x000000;
				}
			}
			
			// Load video
			videoPlayer_mc.load(videoURL, stage.stageWidth, stage.stageHeight, posterURL, autoPlay, bufferTime, borderColor, logoURL);
		}
		
		// -------------------------------------------------------------------
	}
}