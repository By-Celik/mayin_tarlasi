class Cell
{
  final int row; // Hücrenin satır koordinatı
  final int col; // Hücrenin sütun koordinatı
  bool isMine; // Mayın içerip içermediği
  bool isRevealed; // Açılıp açılmadığı
  bool isFlagged; // Bayrak eklenip eklenmediği
  int mineCount; // Etrafındaki komşu mayın sayısı
 Cell({
    required this.row,
   required this.col,
   this.isMine = false,
   this.isRevealed = false,
   this.isFlagged = false,
   this.mineCount = 0,
 });
}