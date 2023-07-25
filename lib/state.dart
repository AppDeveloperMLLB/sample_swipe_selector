import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 選択状態を変更中に、未選択 → 選択に変えているかを保持
///
/// この値は、選択状態を変え始めたタイミングで確定する。
/// なぜこの値が必要かというと、未選択 → 選択に変え始めた場合、
/// 他のアイテムも未選択 → 選択への変更に固定しないと、
/// 選択状態の変更が繰り返されるため。
final isChangingToSelected = StateProvider<bool?>((ref) => null);

int? tapStartIndex;

final isSelectedProvider = StateProvider((ref) => false);
