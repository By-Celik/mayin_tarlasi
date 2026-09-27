import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/game_difficulty.dart';
import '../../domain/services/game_service.dart';
import '../widgets/cell_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameService _gameService;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _gameService = GameService(difficulty: GameDifficulty.easy);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Kronometreyi başlatma
  void _startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  // Kronometreyi durdurma ve sıfırlama
  void _stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
  }

  void _resetGame() {
    _stopTimer();
    setState(() {
      _secondsElapsed = 0;
      _gameService.initializeBoard();
    });
  }

  void _changeDifficulty(GameDifficulty difficulty) {
    _stopTimer();
    setState(() {
      _secondsElapsed = 0;
      _gameService.setDifficulty(difficulty);
    });
  }

  // Oyun bittiğinde veya kazanıldığında kontrol
  void _checkGameStatus() {
    if (_gameService.isGameOver || _gameService.isWon) {
      _stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kalan potansiyel mayın hesaplaması (Toplam mayın - Konulan bayrak)
    int remainingMines = _gameService.totalMines - _gameService.flaggedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Mayın Tarlası'),
        centerTitle: true,
        actions: [
          PopupMenuButton<GameDifficulty>(
            icon: const Icon(Icons.settings),
            tooltip: 'Zorluk Seç',
            onSelected: _changeDifficulty,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GameDifficulty.easy,
                child: Text('Kolay (9x9)'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.medium,
                child: Text('Orta (16x16)'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.hard,
                child: Text('Zor (16x30)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Yeniden Başlat',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Üst Bilgi Paneli (Sayaçlar ve Durum)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Kalan Mayın Sayacı
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$remainingMines',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Oyun Durumu Metni
                Text(
                  _gameService.isGameOver
                      ? 'OYUN BİTTİ! 💥'
                      : _gameService.isWon
                      ? 'KAZANDIN! 🎉'
                      : 'Oynanıyor...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _gameService.isGameOver
                        ? Colors.red
                        : _gameService.isWon
                        ? Colors.green
                        : Colors.black,
                  ),
                ),
                // Kronometre
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '$_secondsElapsed sn',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Oyun Tahtası (GridView)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: _gameService.cols / _gameService.rows,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gameService.cols,
                    ),
                    itemCount: _gameService.rows * _gameService.cols,
                    itemBuilder: (context, index) {
                      int r = index ~/ _gameService.cols;
                      int c = index % _gameService.cols;
                      var cell = _gameService.board[r][c];

                      return CellWidget(
                        cell: cell,
                        onTap: () {
                          // İlk tıklamada kronometreyi başlat
                          if (!_isTimerRunning && !_gameService.isGameOver && !_gameService.isWon) {
                            _startTimer();
                          }
                          setState(() {
                            _gameService.revealCell(r, c);
                            _checkGameStatus();
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            if (!cell.isRevealed && !_gameService.isGameOver && !_gameService.isWon) {
                              _gameService.toggleFlag(r, c);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}