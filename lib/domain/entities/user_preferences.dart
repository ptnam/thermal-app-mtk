class UserPreferences {
  final String theme; // 'light' or 'dark'
  final String language; // 'en' or 'vi'
  final bool notificationsEnabled;

  UserPreferences({
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
  });

  // For Hive serialization
  Map<String, dynamic> toJson() => {
    'theme': theme,
    'language': language,
    'notificationsEnabled': notificationsEnabled,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        theme: json['theme'] as String? ?? 'light',
        language: json['language'] as String? ?? 'en',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );
}
