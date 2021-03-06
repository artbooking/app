class UserChallengesStats {
  /// Total challenges this user has created.
  int created;

  /// Total challenges this user has deleted.
  int deleted;

  /// Total challenges this user has entered.
  int entered;

  /// Number of existing challenges this user own.
  int owned;

  /// Number of existing challenges this user is doing.
  int participating;

  /// Total challenges this user has won.
  int won;

  UserChallengesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
  });

  factory UserChallengesStats.empty() {
    return UserChallengesStats(
      created: 0,
      deleted: 0,
      entered: 0,
      owned: 0,
      participating: 0,
      won: 0,
    );
  }

  factory UserChallengesStats.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserChallengesStats.empty();
    }

    return UserChallengesStats(
      created: data['created'] ?? 0,
      deleted: data['deleted'] ?? 0,
      entered: data['entered'] ?? 0,
      owned: data['owned'] ?? 0,
      participating: data['participating'] ?? 0,
      won: data['won'] ?? 0,
    );
  }
}
