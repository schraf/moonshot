
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
	static var url = 'https://script.google.com/macros/s/AKfycbwqak9eqr9H_tszMvdRPtBOO8pYAQ6ahaIkFkSqNUVYpzaxtt-r/exec';

	var name: String;
	var leaderboards: Array<Leaderboard>;

	public function new () {
		this.leaderboards = new Array<Leaderboard>();
	}

	public function setName (name: String) {
		this.name = name;
	}

	public function getLeaderboard (gameMode: Data.GameModeKind): Leaderboard {
		for (leaderboard in this.leaderboards) {
			if (leaderboard.gameMode == gameMode) {
				return leaderboard;
			}
		}

		return null;
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
				leaderboard.isLoading = false;
			} else {
				trace('failed to load leaderboard ${gameMode} for ${this.name}');
			}
		});
	}
}

