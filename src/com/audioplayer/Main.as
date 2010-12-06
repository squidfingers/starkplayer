package com.audioplayer {
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class Main extends MovieClip {
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		private var _github:ContextMenuItem;
		
		// ===================================================================
		// Children
		// -------------------------------------------------------------------
		
		public var audioPlayer_mc:MovieClip;
		
		// ===================================================================
		// Constructor
		// -------------------------------------------------------------------
		
		public function Main():void {
			
			_github = new ContextMenuItem('Github...');
	        _github.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, githubHandler);
	
			var cm = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems.push(new ContextMenuItem('Audio Starkplayer'));
			cm.customItems.push(new ContextMenuItem('Version: 0.9'));
			cm.customItems.push(_github);
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
			
			// Process parameters
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			
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
			audioPlayer_mc.load(audioURL, autoPlay, borderColor);
		}
		private function githubHandler (p_event:ContextMenuEvent):void {
			navigateToURL(new URLRequest('https://github.com/squidfingers/starkplayer'), '_blank');
		}
		
		// -------------------------------------------------------------------
	}
}