import 'package:sample_swipe_selector/item_data.dart';

/// 表示するアイテムのデータと選択状態を保持するクラス
class DataForSelector {
  final ItemData data;
  bool _isSelected = false;
  bool get isSelected => _isSelected;

  DataForSelector({required this.data});

  void setIsSelected(bool value) {
    _isSelected = value;
  }
}
