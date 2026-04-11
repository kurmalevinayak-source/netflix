class UserProfile {
  final String uid;
  final String email;
  final String name;
  final List<String> watchlist;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.watchlist = const [],
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      watchlist: List<String>.from(map['watchlist'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'watchlist': watchlist,
    };
  }
}
