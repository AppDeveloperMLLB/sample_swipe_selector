import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_swipe_selector/data_for_selector.dart';

class DataNotifier extends StateNotifier<List<DataForSelector>> {
  DataNotifier(List<DataForSelector> initialData) : super(initialData);
  void toggleIsSelected(int index) {
    final previousData = state[index];
    final newData = DataForSelector(data: previousData.data);
    newData.setIsSelected(!previousData.isSelected);
    state = [...state]..[index] = newData;
  }
}
