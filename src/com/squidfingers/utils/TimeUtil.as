package com.squidfingers.utils {
	
	public class TimeUtil {
	
		// ===================================================================
		// Public Static Methods
		// -------------------------------------------------------------------
	
		public static function format (p_seconds:Number):String {
			var seconds = Math.round(p_seconds);
			if (seconds < 0) seconds = 0;
			// Find hours
			var hours = Math.floor(seconds / 60 / 60);
			if (hours) {
				seconds -= hours * 60 * 60;
			}
			// Find minutes
			var minutes = Math.floor(seconds / 60);
			if (minutes) {
				seconds -= minutes * 60;
			}
			// Format hours & minutes
			var h = '';
			if (hours) {
				h = hours + ':';
				if (minutes < 10) {
					minutes = '0' + minutes;
				}
			}
			// Format seconds
			if (seconds < 10) {
				seconds = '0' + seconds;
			}
			// Return formatted time
			return h + minutes + ':' + seconds;
		}
		
		// -------------------------------------------------------------------
	}
}
