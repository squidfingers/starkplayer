package com.audioplayer {
	
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
		
		public var audioPlayers_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function Main():void {
			
			var cm = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems.push(new ContextMenuItem('Squidfingers Video Player'));
			cm.customItems.push(new ContextMenuItem('Version: 1.3'));
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
			var audioURL = root.loaderInfo.parameters.url;
			var autoPlay = root.loaderInfo.parameters.autoplay;
			var border = root.loaderInfo.parameters.border;
			var skin = root.loaderInfo.parameters.skin;
			
			// Process parameters
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			skin = (skin) ? skin.toLowerCase() : null;
			
			// Set skin
			var player = audioPlayers_mc.audioPlayerDefault_mc;
			if (audioPlayers_mc.totalFrames > 1) {
				if (skin == 'compact') {
					audioPlayers_mc.gotoAndStop(2);
					player = audioPlayers_mc.audioPlayerCompact_mc;
				}
			}
			
			// Validate border
			var borderColor = NaN;
			if (border && border != 'false') {
				if (border.charAt(0) == '#') {
					border = border.substr(1, border.length);
				}
				if (border.length == 6) {
					borderColor = parseInt(border, 16);
				} else {
					borderColor = 0x666666;
				}
			}
			
			// Load audio
			player.load(audioURL, autoPlay, borderColor);
		}
		
		// -------------------------------------------------------------------
	}
}