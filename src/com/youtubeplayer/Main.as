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
		// Private Methods
		// -------------------------------------------------------------------
		
		private function loadYouTubeVideo():void {
			
			// Get FlashVars
			var youTubeId = root.loaderInfo.parameters.id;
			var videoWidth = root.loaderInfo.parameters.width;
			var videoHeight = root.loaderInfo.parameters.height;
			var autoPlay = root.loaderInfo.parameters.autoplay == 'true';
			var border = root.loaderInfo.parameters.border;
			var suggestedQuality = root.loaderInfo.parameters.quality;
			var logoURL = root.loaderInfo.parameters.logo;
			
			// Process parameters
			videoWidth = (videoWidth) ? parseInt(videoWidth) : 0;
			videoHeight = (videoHeight) ? parseInt(videoHeight) : 0;
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			suggestedQuality = (suggestedQuality) ? suggestedQuality.toLowerCase() : null;
			
			// Determine width/height
			if ( ! videoWidth) videoWidth = stage.stageWidth;
			if ( ! videoHeight) videoHeight = stage.stageHeight;
			
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
			youTubePlayer_mc.load(youTubeId, videoWidth, videoHeight, autoPlay, borderColor, suggestedQuality, logoURL);
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		private function addedToStageHandler (p_event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false);
			
			// Set stage alignment
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Avoid IE bug where stageWidth and stageHeight are zero
			// http://jodieorourke.com/view.php?id=79&blog=news
			if (stage.stageWidth == 0 && stage.stageHeight == 0) {
				stage.addEventListener(Event.RESIZE, stageResizeHandler, false, 0, true);
			} else {
				loadYouTubeVideo();
			}
		}
		private function stageResizeHandler (p_event:Event):void {
			stage.removeEventListener(Event.RESIZE, stageResizeHandler, false);
			if ( ! youTubePlayer_mc.initialized && stage.stageWidth > 0 && stage.stageHeight > 0) {
				loadYouTubeVideo();
			}
		}
		
		// -------------------------------------------------------------------
	}
}