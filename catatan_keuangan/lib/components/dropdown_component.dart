import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:flutter/material.dart';

class DropDownComponent extends StatelessWidget {
  final Function(String?) callback;
  final List<Map<String, dynamic>> listData;
  final String? setValue;
  final AlignmentDirectional position;
  const DropDownComponent({
    super.key,
    required this.callback,
    this.setValue,
    this.listData = const [],
    this.position = AlignmentDirectional.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        hint: Text("Choose"),
        value: setValue,
        menuMaxHeight: context.dynamicHeight(0.3),
        isExpanded: false,
        items: listData
            .map(
              (e) => DropdownMenuItem<String>(
                alignment: position,
                value: e['value'],
                child: Text(e['name']),
              ),
            )
            .toList(),
        // style: Theme.of(context).textTheme.displaySmall,
        // items: List.generate(
        //     100,
        //     (int index) => DropdownMenuItem<String>(
        //         alignment: AlignmentDirectional.center,
        //         value: (2000 + index).toString(),
        //         child: Text((2000 + index).toString())),
        //     growable: true),
        onChanged: (String? val) {
          callback(val);
        },
      ),
    );
  }
}
