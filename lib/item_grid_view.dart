import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_swipe_selector/data_for_selector.dart';
import 'package:sample_swipe_selector/data_notifier.dart';
import 'package:sample_swipe_selector/item.dart';
import 'package:sample_swipe_selector/item_data.dart';
import 'package:sample_swipe_selector/state.dart';

// 表示するデータのリスト
final dataListProvider =
    StateNotifierProvider<DataNotifier, List<DataForSelector>>(
  (ref) => DataNotifier(
    [
      DataForSelector(data: ItemData(id: 0, name: "000")),
      DataForSelector(data: ItemData(id: 1, name: "001")),
      DataForSelector(data: ItemData(id: 2, name: "002")),
      DataForSelector(data: ItemData(id: 3, name: "003")),
      DataForSelector(data: ItemData(id: 4, name: "004")),
      DataForSelector(data: ItemData(id: 5, name: "005")),
      DataForSelector(data: ItemData(id: 6, name: "006")),
      DataForSelector(data: ItemData(id: 7, name: "007")),
      DataForSelector(data: ItemData(id: 8, name: "008")),
      DataForSelector(data: ItemData(id: 9, name: "009")),
      DataForSelector(data: ItemData(id: 10, name: "010")),
      DataForSelector(data: ItemData(id: 11, name: "011")),
      DataForSelector(data: ItemData(id: 12, name: "012")),
      DataForSelector(data: ItemData(id: 13, name: "013")),
      DataForSelector(data: ItemData(id: 14, name: "014")),
      DataForSelector(data: ItemData(id: 15, name: "015")),
    ],
  ),
);

/// アイテム一覧を表示するGirdView
class ItemGridView extends ConsumerWidget {
  const ItemGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idList = ref.watch(dataListProvider
        .select((value) => value.map((e) => e.data.id).toList()));
    return GestureDetector(
      onPanStart: (detail) {
        _judgeHit(ref, context, detail.globalPosition);
      },
      onPanUpdate: (detail) {
        _judgeHit(ref, context, detail.globalPosition);
      },
      onLongPressMoveUpdate: (detail) {
        _judgeHit(ref, context, detail.globalPosition);
      },
      onPanEnd: (detail) {
        ref.read(isChangingToSelected.notifier).state = null;
        tapStartIndex = null;
      },
      onTapUp: (detail) {
        _onTapUp(ref, context, detail.globalPosition);
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: 3,
        ),
        itemCount: idList.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final id = idList[index];
          return Item(
            id: id,
            onTouch: () {
              ref.read(dataListProvider.notifier).toggleIsSelected(index);
            },
          );
        },
        shrinkWrap: true,
      ),
    );
  }

  void _onTapUp(
    WidgetRef ref,
    BuildContext context,
    Offset globalPosition,
  ) {
    if (!ref.read(isSelectedProvider)) {
      return;
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final result = BoxHitTestResult();
    var local = box?.globalToLocal(globalPosition);

    if (box == null || local == null) {
      return;
    }

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is TouchDetectorRenderBox) {
          final index = target.getIndex?.call() ?? 0;
          ref.read(dataListProvider.notifier).toggleIsSelected(index);
        }
      }
    }
  }

  void _judgeHit(
    WidgetRef ref,
    BuildContext context,
    Offset globalPosition,
  ) {
    if (!ref.read(isSelectedProvider)) {
      return;
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final result = BoxHitTestResult();
    var local = box?.globalToLocal(globalPosition);

    if (box == null || local == null) {
      return;
    }

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is TouchDetectorRenderBox) {
          final index = target.getIndex?.call() ?? 0;
          final touchedData = ref.read(dataListProvider)[index];
          final newValue = !touchedData.isSelected;
          if (ref.read(isChangingToSelected) == null) {
            ref.read(isChangingToSelected.notifier).state = newValue;
          }

          tapStartIndex ??= index;

          if (tapStartIndex! <= index) {
            for (int i = tapStartIndex!; i <= index; i++) {
              final data = ref.read(dataListProvider)[i];
              if (data.isSelected != ref.read(isChangingToSelected)) {
                ref.read(dataListProvider.notifier).toggleIsSelected(i);
              }
            }
          } else {
            for (int i = tapStartIndex!; i >= index; i--) {
              final data = ref.read(dataListProvider)[i];
              if (data.isSelected != ref.read(isChangingToSelected)) {
                ref.read(dataListProvider.notifier).toggleIsSelected(i);
              }
            }
          }
        }
      }
    }
  }
}
