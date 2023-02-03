import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSelecting = false;

  void onSelectingToggleButton() {
    setState(() {
      _isSelecting = !_isSelecting;
    });
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
              icon: Text(
                _isSelecting ? "Cancel" : "Select",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onPanStart: (detail) {
            _judgeHit(context, detail.globalPosition);
          },
          onPanUpdate: (detail) {
            _judgeHit(context, detail.globalPosition);
          },
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 3,
            ),
            itemCount: 30,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Item(
                index: index,
              );
            },
            shrinkWrap: true,
          ),
        ),
      ),
    );
  }

  void _judgeHit(BuildContext context, Offset globalPosition) {
    if (!_isSelecting) {
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
          target.onTouch?.call();
        }
      }
    }
  }
}

class Item extends StatefulWidget {
  final int index;
  const Item({super.key, required this.index});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return TouchDetector(
      child: Stack(
        children: [
          Container(
            color: Colors.amber,
            child: Center(
                child: Text(
              "$widget.index",
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

  const TouchDetector({
    Key? key,
    Widget? child,
    this.onTouch,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TouchDetectorRenderBox();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    TouchDetectorRenderBox renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject.onTouch = onTouch;
  }
}

// 描画処理用のRenderBox
// SingleChildRenderObjectWidgetを使うのに必要
// StatefullWidgetにStateのクラスが必要なのと同じ感じだと思う
class TouchDetectorRenderBox extends RenderBox {
  // RenderBoxのhitTestメソッドを使い、
  // タッチされていればタッチした時の処理を行うために定義しておく
  VoidCallback? onTouch;
}
