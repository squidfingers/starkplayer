package com.videoplayer {
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class Main extends MovieClip {
		// ===================================================================
		// Properties
		// -------------------------------------------------------------------
		
		private var _frameCount:Number;
		
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
		// Private Methods
		// -------------------------------------------------------------------
		
		private function loadVideo():void {
			
			// Get FlashVars
			var videoURL = root.loaderInfo.parameters.url;
			var videoWidth = root.loaderInfo.parameters.width;
			var videoHeight = root.loaderInfo.parameters.height;
			var posterURL = root.loaderInfo.parameters.poster;
			var autoPlay = root.loaderInfo.parameters.autoplay;
			var bufferTime = root.loaderInfo.parameters.buffertime;
			var border = root.loaderInfo.parameters.border;
			var logoURL = root.loaderInfo.parameters.logo;
			
			// Process parameters
			videoWidth = (videoWidth) ? parseInt(videoWidth) : 0;
			videoHeight = (videoHeight) ? parseInt(videoHeight) : 0;
			autoPlay = (autoPlay) ? autoPlay.toLowerCase() == 'true' : false;
			border = (border) ? border.toLowerCase() : null;
			bufferTime = (bufferTime) ? parseInt(bufferTime) : null;
			
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
			videoPlayer_mc.visible = true;
			videoPlayer_mc.load(videoURL, videoWidth, videoHeight, posterURL, autoPlay, bufferTime, borderColor, logoURL);
		}
		
		// ===================================================================
		// Event Handlers
		// -------------------------------------------------------------------
		
		private function addedToStageHandler (p_event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false);
			
			// Hide video until initialized
			videoPlayer_mc.visible = false;
			
			// Set stage alignment
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Avoid IE bug where stageWidth and stageHeight are zero
			if (stage.stageWidth == 0 || stage.stageHeight == 0) {
				_frameCount = 0;
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			} else {
				loadVideo();
			}
		}
		private function enterFrameHandler (p_event:Event):void {
			if (++_frameCount > 500 || (stage.stageWidth > 0 && stage.stageHeight > 0)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
				if ( ! videoPlayer_mc.visible) {
					loadVideo();
				}
			}
		}
		
		// -------------------------------------------------------------------
	}
}