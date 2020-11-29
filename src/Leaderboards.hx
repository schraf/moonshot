
class LeaderboardRanking {
	public var name: String;
	public var rank: Int;
	public var score: Int;

	public function new (name: String, rank: Int, score: Int) {
		this.name = name;
		this.rank = rank;
		this.score = score;
	}
}

class Leaderboard {
	public var gameMode: Data.GameModeKind;
	public var rank: Int;
	public var rankings: Array<LeaderboardRanking>;
	public var isLoading: Bool;

	public function new (gameMode: Data.GameModeKind) {
		this.gameMode = gameMode;
		this.rank = -1;
		this.rankings = new Array<LeaderboardRanking>();
		this.isLoading = false;
	}
}

class Leaderboards {
	static var url = 'https://script.google.com/a/schraffenberger.com/macros/s/AKfycbzWIp97IjYUDRvPAzFYS25m-yf08VkP-GBV3oBXhA/exec';

	var name: String;
	var leaderboards: Array<Leaderboard>;
	var currentScore: Int;
	var enteringName: Bool;

	public function new () {
		this.leaderboards = new Array<Leaderboard>();
		resetScore();
	}

	public function getName (): String {
		return this.name;
	}

	public function setName (name: String) {
		this.name = name;
	}

	public function getCurrentScore() {
		return this.currentScore;
	}

	public function resetScore () {
		this.currentScore = 0;
	}

	public function addToScore (points: Int) {
		this.currentScore += points;
	}

	public function removeFromScore (points: Int) {
		this.currentScore = Math.floor(Math.max(0, this.currentScore - points));
	}

	public function getLeaderboard (gameMode: Data.GameModeKind): Leaderboard {
		for (leaderboard in this.leaderboards) {
			if (leaderboard.gameMode == gameMode) {
				return leaderboard;
			}
		}

		return null;
	}

	public function finalizeScore (gameMode: Data.GameModeKind) {
		var leaderboard = getLeaderboard(gameMode);

		if (leaderboard == null) {
			leaderboard = new Leaderboard(gameMode);
			this.leaderboards.push(leaderboard);
		}

		var params = new Http.HttpParameters();
		params['action'] = 'set';
		params['name'] = this.name;
		params['leaderboard'] = Data.gameMode.get(gameMode).leaderboard;
		params['score'] = Std.string(Std.int(this.currentScore));

		leaderboard.isLoading = true;

		Http.get(url, params, function (success: Bool, data: String): Void {
			if (success) {
				var result = haxe.Json.parse(data);

				if (result.status == 'OK') {
					leaderboard.rank = result.rank;
					loadLeaderboard(gameMode);
				} else {
					trace('error from leaderboard service for ${gameMode} for ${this.name}');
				}
			} else {
				trace('failed to set leaderboard ${gameMode} for ${this.name}');
			}
		});
	}

	public function loadLeaderboard (gameMode: Data.GameModeKind) {
		var leaderboard = getLeaderboard(gameMode);

		if (leaderboard == null) {
			leaderboard = new Leaderboard(gameMode);
			this.leaderboards.push(leaderboard);
		}

		var params = new Http.HttpParameters();
		params['action'] = 'get';
		params['name'] = this.name;
		params['leaderboard'] = Data.gameMode.get(gameMode).leaderboard;

		leaderboard.isLoading = true;

		Http.get(url, params, function (success: Bool, data: String): Void {
			if (success) {
				var result = haxe.Json.parse(data);
				leaderboard.rank = result.rank;
				leaderboard.rankings = [];

				var rankings: Array<Dynamic> = result.rankings;

				for (ranking in rankings) {
					var rank: Int = ranking[0];
					var name: String = ranking[1];
					var score: Int = ranking[2];

					leaderboard.rankings.push(new LeaderboardRanking(name, rank, score));
				}

				leaderboard.isLoading = false;
			} else {
				trace('failed to load leaderboard ${gameMode} for ${this.name}');
			}
		});
	}
}
