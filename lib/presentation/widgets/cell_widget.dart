import 'package:flutter/material.dart';
import '../../domain/entities/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CellWidget({
    Key? key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key); // Dart sürümüne göre 'super.key' de kullanılabilir

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: cell.isRevealed
              ? (cell.isMine ? Colors.red : Colors.grey[300])
              : Colors.grey[600],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!cell.isRevealed) {
      if (cell.isFlagged) {
        return const Icon(Icons.flag, color: Colors.red, size: 18);
      }
      return const SizedBox.shrink();
    }

    if (cell.isMine) {
      return const Icon(Icons.bolt, color: Colors.black, size: 18); // Mayın simgesi
    }

    if (cell.mineCount > 0) {
      return Text(
        '${cell.mineCount}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getTextColor(cell.mineCount),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Komşu sayısına göre klasik Mayın Tarlası renkleri
  Color _getTextColor(int count) {
    switch (count) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      default: return Colors.black;
    }
  }
}