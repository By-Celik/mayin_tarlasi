// Zorluk seçenekleri için bir enum tanımlıyoruz
enum GameDifficulty { easy, medium, hard }

class DifficultySettings {
  final int rows;
  final int cols;
  final int totalMines;

  const DifficultySettings({
    required this.rows,
    required this.cols,
    required this.totalMines,
  });

  // Seçilen zorluğa göre boyutları ve mayın sayısını döndüren yardımcı fonksiyon
  static DifficultySettings getSettings(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const DifficultySettings(rows: 9, cols: 9, totalMines: 10);
      case GameDifficulty.medium:
        return const DifficultySettings(rows: 16, cols: 16, totalMines: 40);
      case GameDifficulty.hard:
        return const DifficultySettings(rows: 16, cols: 30, totalMines: 99);
    }
  }
}