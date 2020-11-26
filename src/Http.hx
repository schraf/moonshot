
typedef HttpCallback = (success: Bool, data: String) -> Void;
typedef HttpParameters = Map<String, String>;

class Http {
	static var redirectHREF = ~/HREF="([^"]+)"/im;

	static public function get (url: String, params: HttpParameters, callback: HttpCallback) {
		#if hl
		sys.ssl.Socket.DEFAULT_VERIFY_CERT = false;
		#end

		var http = new haxe.Http(url);
		var redirect: Bool = false;
		var success: Bool = false;

		http.onStatus = function (code: Int) {
			if (code >= 300 && code < 400) {
				redirect = true;
			} else if (code == 200) {
				success = true;
			} else {
				callback(false, null);
			}
		};

		http.onData = function (data: String) {
			if (redirect) {
				if (redirectHREF.match(data)) {
					var href = redirectHREF.matched(1);
					var redirectURL = StringTools.htmlUnescape(href);
					redirectGet(redirectURL, callback);
				} else {
					callback(false, null);
				}
			} else if (success) {
				callback(true, data);
			}
		};

		for (key in params.keys()) {
			http.setParameter(key, params[key]);
		}

		http.request();
	}

	static function redirectGet (url: String, callback: HttpCallback) {
		var http = new haxe.Http(url);
		var success: Bool = false;

		http.onStatus = function (code: Int) {
			if (code == 200) {
				success = true;
			} else {
				callback(false, null);
			}
		};

		http.onData = function (data: String) {
			if (success) {
				callback(true, data);
			}
		};

		http.request(false);
	}
}

