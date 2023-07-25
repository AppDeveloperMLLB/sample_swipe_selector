/// 一覧に表示するアイテムのデータクラス
class ItemData {
  final int id;
  final String name;

  ItemData({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode;
}
