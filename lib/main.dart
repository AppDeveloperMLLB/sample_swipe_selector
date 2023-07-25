import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_swipe_selector/item_grid_view.dart';
import 'package:sample_swipe_selector/state.dart';

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
  /// 選択状態かどうかを切り替えるトグルボタンが押されたときの処理
  void onSelectingToggleButtonPressed() {
    final isSelecting = ref.read(isSelectedProvider);
    ref.read(isSelectedProvider.notifier).state = !isSelecting;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // トグルボタン
          SizedBox(
            height: 64,
            width: 64,
            child: IconButton(
              onPressed: onSelectingToggleButtonPressed,
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
        // アイテム一覧の表示
        child: ItemGridView(),
      ),
    );
  }
}
