import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget templateHeader1(String value1, String value2) {
  if (value1.toLowerCase() == 'expense') {}
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            value1,
            style: TextStyle(fontSize: 18),
          ),
          AutoSizeText(
            value2,
            maxLines: 1,
            style: TextStyle(
              color: value1.toLowerCase() == 'expense'
                  ? Colors.red
                  : value1.toLowerCase() == 'income'
                      ? Colors.green
                      : Colors.black,
            ),
          )
        ],
      ),
    ),
  );
}
