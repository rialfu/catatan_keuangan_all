import 'package:flutter/material.dart';

class FirstScreenNotifier extends ChangeNotifier {
  String _page = 'first';
  String get page => _page;
  void changePage(String page) {
    _page = page;
    notifyListeners();
  }
}
