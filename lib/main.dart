import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProviderScope(
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
      //home: const MyWidget(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  void onSelectingToggleButton() {
    final isSelecting = ref.read(isSelectedProvider);
    ref.read(isSelectedProvider.notifier).state = !isSelecting;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          SizedBox(
            height: 64,
            width: 64,
            child: IconButton(
              onPressed: onSelectingToggleButton,
              icon: Consumer(builder: (context, ref, child) {
                final isSelected = ref.watch(isSelectedProvider);
                return Text(
                  isSelected ? "Cancel" : "Select",
                  style: const TextStyle(color: Colors.white),
                );
              }),
            ),
          ),
        ],
      ),
      body: const Center(
        child: ItemGridView(),
      ),
    );
  }
}

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
      onPanEnd: (detail) {
        ref.read(isChangingToSelected.notifier).state = null;
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

          if (newValue == ref.read(isChangingToSelected)) {
            target.onTouch?.call();
          }
        }
      }
    }
  }
}

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

class DataForSelector {
  final ItemData data;
  bool _isSelected = false;
  bool get isSelected => _isSelected;

  DataForSelector({required this.data});

  void setIsSelected(bool value) {
    _isSelected = value;
  }
}

class DataNotifier extends StateNotifier<List<DataForSelector>> {
  DataNotifier(List<DataForSelector> initialData) : super(initialData);
  void toggleIsSelected(int index) {
    print("toggle");
    final previousData = state[index];
    print("Previous isSelected : ${previousData.isSelected}");
    final newData = DataForSelector(data: previousData.data);
    newData.setIsSelected(!previousData.isSelected);
    print("new isSelected : ${newData.isSelected}");
    state = [...state]..[index] = newData;
  }
}

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

final isSelectedProvider = StateProvider((ref) => false);

/// 選択状態を変更中に、未選択 → 選択に変えているかを保持
///
/// この値は、選択状態を変え始めたタイミングで確定する。
/// なぜこの値が必要かというと、未選択 → 選択に変え始めた場合、
/// 他のアイテムも未選択 → 選択への変更に固定しないと、
/// 選択状態の変更が繰り返されるため。
final isChangingToSelected = StateProvider<bool?>((ref) => null);
