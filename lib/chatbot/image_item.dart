class ImageItem {
  final String name;
  final String imagePath;
  final int? characterId;
  final int? memberId;
  final String? characterName;
  final String? voiceId;
  final Map<String, String> emotionImages;

  ImageItem({
    required this.name,
    required this.imagePath,
    this.characterId,
    this.memberId,
    this.characterName,
    this.voiceId,
    required this.emotionImages,
  });

  ImageItem copyWith({
    String? name,
    String? imagePath,
    int? characterId,
    int? memberId,
    String? characterName,
    String? voiceId,
    Map<String, String>? emotionImages,
  }) {
    return ImageItem(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      characterId: characterId ?? this.characterId,
      memberId: memberId ?? this.memberId,
      characterName: characterName ?? this.characterName,
      voiceId: voiceId ?? this.voiceId,
      emotionImages: emotionImages ?? this.emotionImages,
    );
  }
}
