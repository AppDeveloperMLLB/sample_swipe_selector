import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_swipe_selector/item_grid_view.dart';

/// GirdViewに表示するアイテム
class Item extends ConsumerWidget {
  final int id;
  final VoidCallback? onTouch;

  const Item({
    super.key,
    required this.id,
    this.onTouch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 表示中のデータリストから選択状態を取得
    final isSelected = ref.watch(dataListProvider.select((value) {
      final index = value.indexWhere((element) => element.data.id == id);
      return value[index].isSelected;
    }));

    return TouchDetector(
      onTouch: () {
        onTouch?.call();
      },
      getIndex: () {
        return ref
            .read(dataListProvider)
            .indexWhere((element) => element.data.id == id);
      },
      isSelected: () {
        final data = ref
            .read(dataListProvider)
            .firstWhere((element) => element.data.id == id);
        return data.isSelected;
      },
      child: Stack(
        children: [
          Container(
            color: Colors.amber,
            child: Center(
                child: Text(
              "$id",
              style: Theme.of(context).textTheme.bodyLarge!,
            )),
          ),
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_box,
              ),
            ),
        ],
      ),
    );
  }
}

class TouchDetector extends SingleChildRenderObjectWidget {
  /// タッチされた際のコールバック
  final VoidCallback? onTouch;
  final int Function()? getIndex;
  final bool Function()? isSelected;

  const TouchDetector({
    Key? key,
    Widget? child,
    this.onTouch,
    this.getIndex,
    this.isSelected,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = TouchDetectorRenderBox();
    renderObject.onTouch = onTouch;
    renderObject.getIndex = getIndex;
    renderObject.isSelected = isSelected;
    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    TouchDetectorRenderBox renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject.onTouch = onTouch;
    renderObject.getIndex = getIndex;
    renderObject.isSelected = isSelected;
  }
}

// 描画処理用のRenderBox
// SingleChildRenderObjectWidgetを使うのに必要
// StatefullWidgetにStateのクラスが必要なのと同じ感じだと思う
class TouchDetectorRenderBox extends RenderProxyBox {
  // RenderBoxのhitTestメソッドを使い、
  // タッチされていればタッチした時の処理を行うために定義しておく
  VoidCallback? onTouch;
  int Function()? getIndex;
  bool Function()? isSelected;
}
