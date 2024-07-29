// 캐릭터 타입
enum CharacterType { boy, girl }

// 감정 분류 (중립, 슬픔, 행복, 분노, 불안, 당황, 혐오)
enum Emotion { neutral, sad, happy, angry, anxious, confused, disgusted }

class CharacterModel {
  final CharacterType type;
  final Map<Emotion, String> emotionImages;

  CharacterModel({required this.type, required this.emotionImages});

  factory CharacterModel.boy() {
    return CharacterModel(
      type: CharacterType.boy,
      emotionImages: {
        Emotion.neutral: 'assets/neutral.png',
        Emotion.sad: 'assets/sad.png',
        Emotion.happy: 'assets/happy.png',
        Emotion.angry: 'assets/angry.png',
        Emotion.anxious: 'assets/anxious.png',
        Emotion.confused: 'assets/confused.png',
        Emotion.disgusted: 'assets/disgusted.png',
      },
    );
  }

  factory CharacterModel.girl() {
    return CharacterModel(
      type: CharacterType.girl,
      emotionImages: {
        Emotion.neutral: 'assets/neutral_girl.png',
        Emotion.sad: 'assets/sad_girl.png',
        Emotion.happy: 'assets/happy_girl.png',
        Emotion.angry: 'assets/angry_girl.png',
        Emotion.anxious: 'assets/anxious_girl.png',
        Emotion.confused: 'assets/confused_girl.png',
        Emotion.disgusted: 'assets/disgusted_girl.png',
      },
    );
  }

  String getEmotionImage(Emotion emotion) {
    return emotionImages[emotion] ?? '';
  }
}
