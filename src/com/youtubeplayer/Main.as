package com.youtubeplayer {
	
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
		
		public var youTubePlayer_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function Main():void {
			
			var cm = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems.push(new ContextMenuItem('YouTube Starkplayer'));
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
			var youTubeId = root.loaderInfo.parameters.id;
			var autoPlay = root.loaderInfo.parameters.autoplay == 'true';
			var border = root.loaderInfo.parameters.border;
			var suggestedQuality = root.loaderInfo.parameters.quality;
			var logoURL = root.loaderInfo.parameters.logo;
			
			// Process parameters
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			suggestedQuality = (suggestedQuality) ? suggestedQuality.toLowerCase() : null;
			
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
			youTubePlayer_mc.load(youTubeId, stage.stageWidth, stage.stageHeight, autoPlay, borderColor, suggestedQuality, logoURL);
		}
		
		// -------------------------------------------------------------------
	}
}