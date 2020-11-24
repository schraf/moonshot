import haxe.Http;
import haxe.http.HttpStatus;

class Leaderboards {
	static var url = 'https://script.google.com/macros/s/AKfycbwqak9eqr9H_tszMvdRPtBOO8pYAQ6ahaIkFkSqNUVYpzaxtt-r/exec';

	public function new () {
	}

	public function request (gameMode: Data.GameMode, ?callback: (success:Bool) -> Void) {
		var http = new Http(url);
		var redirect: Bool = false;
		var success: Bool = false;

		http.onStatus = function (code: Int) {
			if (code >= 300 && code < 400) {
				redirect = true;
			} else if (code == HttpStatus.OK) {
				success = true;
			} else if (callback != null) {
				callback(false);
			}
		};

		http.onData = function (data: String) {
			if (redirect) {

			} else if (success) {
				Sys.print('DATA: ${data}');
			}
		};

		http.setParameter('action', 'get');
		http.setParameter('name', 'marc');
		http.setParameter('leaderboard', 'ClassA');
		http.request();
	}
}
