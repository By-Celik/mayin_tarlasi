import 'dart:math';
import '../../core/constants/game_difficulty.dart';
import '../entities/cell.dart';

class GameService {
  late int rows;
  late int cols;
  late int totalMines;
  late GameDifficulty currentDifficulty;

  late List<List<Cell>> board;
  bool isGameOver = false;
  bool isWon = false;
  bool _isFirstClick = true;
  int flaggedCount = 0; // Bayrak sayacı

  GameService({GameDifficulty difficulty = GameDifficulty.easy}) {
    setDifficulty(difficulty);
  }

  // Zorluk seviyesini ayarlayıp tahtayı kuran metot
  void setDifficulty(GameDifficulty difficulty) {
    currentDifficulty = difficulty;
    var settings = DifficultySettings.getSettings(difficulty);
    rows = settings.rows;
    cols = settings.cols;
    totalMines = settings.totalMines;
    initializeBoard();
  }

  // Tahtayı boş hücrelerle doldurma
  void initializeBoard() {
    board = List.generate(rows, (r) {
      return List.generate(cols, (c) {
        return Cell(row: r, col: c);
      });
    });
    isGameOver = false;
    isWon = false;
    _isFirstClick = true;
    flaggedCount = 0;
  }

  // Mayınları rastgele yerleştirme (İlk tıklanan hücre hariç)
  void placeMines(int firstRow, int firstCol) {
    int minesPlaced = 0;
    Random random = Random();

    while (minesPlaced < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);

      if (board[r][c].isMine) continue;
      if (r == firstRow && c == firstCol) continue;

      board[r][c].isMine = true;
      minesPlaced++;
    }

    calculateMineCounts();
  }

  // Etraftaki mayın sayılarını hesaplama
  void calculateMineCounts() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isMine) continue;

        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr;
            int nc = c + dc;

            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
              if (board[nr][nc].isMine) {
                count++;
              }
            }
          }
        }
        board[r][c].mineCount = count;
      }
    }
  }

  // Bayrak koyma / kaldırma fonksiyonu
  void toggleFlag(int r, int c) {
    if (isGameOver || isWon) return;
    Cell cell = board[r][c];

    if (cell.isRevealed) return;

    cell.isFlagged = !cell.isFlagged;
    if (cell.isFlagged) {
      flaggedCount++;
    } else {
      flaggedCount--;
    }
  }

  // Hücreye tıklandığında çalışacak ana fonksiyon
  void revealCell(int r, int c) {
    if (isGameOver || isWon) return;
    Cell cell = board[r][c];

    if (cell.isRevealed || cell.isFlagged) return;

    if (_isFirstClick) {
      _isFirstClick = false;
      placeMines(r, c);
    }

    if (cell.isMine) {
      cell.isRevealed = true;
      isGameOver = true;
      revealAllMines();
      return;
    }

    _revealRecursive(r, c);
    checkWinCondition();
  }

  // Zincirleme açılma algoritması (Flood Fill)
  void _revealRecursive(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols) return;
    Cell cell = board[r][c];

    if (cell.isRevealed || cell.isFlagged) return;

    cell.isRevealed = true;

    if (cell.mineCount == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _revealRecursive(r + dr, c + dc);
        }
      }
    }
  }

  // Oyuncu kaybettiğinde tüm mayınları görünür yap
  void revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isMine) {
          board[r][c].isRevealed = true;
        }
      }
    }
  }

  // Kazanma koşulu: Mayın olmayan tüm hücreler açıldı mı?
  void checkWinCondition() {
    bool allSafeRevealed = true;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        Cell cell = board[r][c];
        if (!cell.isMine && !cell.isRevealed) {
          allSafeRevealed = false;
          break;
        }
      }
    }
    if (allSafeRevealed) {
      isWon = true;
    }
  }
}