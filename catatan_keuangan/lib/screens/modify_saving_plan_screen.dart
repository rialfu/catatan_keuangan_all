import 'dart:async';

import 'package:catatan_keuangan/components/dropdown_component.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_bloc.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ModifySavingPlanScreen extends StatefulWidget {
  final SavingPlanModel? data;
  const ModifySavingPlanScreen({this.data, super.key});

  @override
  State<ModifySavingPlanScreen> createState() => _ModifySavingPlanScreenState();
}

class _ModifySavingPlanScreenState extends State<ModifySavingPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController money = TextEditingController();
  String typeReminder = 'daily';
  String dateReminderWeekly = 'monday';
  String dateReminderMonthly = '1';
  DateTime dataDate = DateTime.now();
  bool isLoad = false;
  List<Map<String, String>> dataWeekly = [
    {'value': 'monday', 'name': 'Monday'},
    {'value': 'tuesday', 'name': 'Tuesday'},
    {'value': 'wednesday', 'name': 'Wednesday'},
    {'value': 'thursday', 'name': 'Thursday'},
    {'value': 'friday', 'name': 'Friday'},
    {'value': 'saturday', 'name': 'Saturday'},
    {'value': 'sunday', 'name': 'Sunday'},
  ];
  late StreamSubscription spStream;
  late SavingPlanBloc bloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = context.read<SavingPlanBloc>();
    spStream = bloc.stream.listen((state) async {
      if (state is SavingPlanStateFinishLoad) {
        // print('finish');
        // return;
        return alertDialogCustom(
          callback: () {
            // print('enter');

            bloc.add(SavingPlanCleanMessage());
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          message: ['Success ${widget.data == null ? "Add" : "Update"}'],
          title: 'Success',
        );
      } else if (state.status == AuthStatus.guest) {
      } else if (state.message != null) {
        List message = [];
        if (state.message is List) {
          message.addAll(state.message as List);
        } else {
          message.add(state.message);
        }
        return alertDialogCustom(
          callback: () {
            bloc.add(SavingPlanCleanMessage());
            Navigator.of(context).pop();
          },
          message: message,
        );
      }
    });
    if (widget.data != null) {
      name.text = widget.data?.name ?? '';
      money.text = (widget.data?.targetMoney.toString() ?? '0').formatMoney();
      String tr = widget.data?.typeReminder ?? 'daily';
      String drw = 'monday';
      String drm = '1';
      if (tr == 'weekly') {
        drw = widget.data?.dateReminder ?? 'monday';
      } else if (tr == 'monthly') {
        drm = widget.data?.dateReminder ?? '1';
      }
      DateTime dd = DateTime.now();
      // try {
      dd = DateTime.tryParse(widget.data?.targetDate ?? '2024-01-03') ??
          DateTime.now();
      setState(() {
        typeReminder = tr;
        dateReminderMonthly = drm;
        dateReminderWeekly = drw;
        dataDate = dd;
      });
    }
  }

  @override
  void dispose() {
    name.dispose();
    spStream.cancel();
    money.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future alertDialogCustom(
      {String title = 'Error',
      required VoidCallback callback,
      List message = const [],
      String textClose = 'Close'}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: message.map((e) => Text(e.toString())).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(textClose),
              onPressed: callback,
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildDateReminder() {
    List<Widget> widgets = [];
    if (typeReminder != 'monthly' && typeReminder != 'weekly') {
      return [];
    }
    widgets.add(Text('DateReminder', textAlign: TextAlign.left));
    if (typeReminder == 'monthly') {
      widgets.add(DropDownComponent(
        position: AlignmentDirectional.centerStart,
        callback: (String? val) {
          setState(() {
            dateReminderMonthly = val ?? '1';
          });
        },
        listData: List.generate(
          31,
          (int index) =>
              {'value': (index + 1).toString(), 'name': (index + 1).toString()},
        ),
        setValue: dateReminderMonthly,
      ));
    } else if (typeReminder == 'weekly') {
      widgets.add(DropDownComponent(
        position: AlignmentDirectional.centerStart,
        callback: (String? val) {
          setState(() {
            dateReminderWeekly = val ?? 'monday';
          });
        },
        listData: dataWeekly,
        setValue: dateReminderWeekly,
      ));
    }
    widgets.add(SizedBox(
      height: 15,
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // widget.data.
    return Scaffold(
      appBar: AppBar(
        title: Text("Modify Data Saving Plan"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', textAlign: TextAlign.left),
                TextFormField(
                  controller: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Type Reminder', textAlign: TextAlign.left),
                DropDownComponent(
                  position: AlignmentDirectional.centerStart,
                  callback: (String? val) {
                    setState(() {
                      typeReminder = val ?? '';
                    });
                  },
                  listData: [
                    {'value': 'daily', 'name': 'Daily'},
                    {'value': 'weekly', 'name': 'Weekly'},
                    {'value': 'monthly', 'name': 'Monthly'}
                  ],
                  setValue: typeReminder,
                ),
                SizedBox(
                  height: 15,
                ),
                ...buildDateReminder(),
                Text('Target Date', textAlign: TextAlign.left),
                TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dataDate, // Refer step 1
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          dataDate = picked;
                        });
                      }
                    },
                    child: Text(dataDate.ddMMyyyy())),
                SizedBox(
                  height: 15,
                ),
                Text('Target Money', textAlign: TextAlign.left),
                TextFormField(
                  controller: money,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((value?.moneyToDouble() ?? 0) < 0) {
                      return 'Please target not zero';
                    }
                  },
                  onChanged: (String textValue) {
                    var valueNumber =
                        double.parse(textValue.replaceAll(RegExp(r"\D"), "")) /
                            100;
                    var fomattedValue =
                        NumberFormat("#,##0.00", "en_US").format(valueNumber);
                    money.value = TextEditingValue(
                      text: fomattedValue,
                      selection: TextSelection.collapsed(
                        offset: fomattedValue.length,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        var bloc = context.read<SavingPlanBloc>();
                        var data = SavingPlanModel(
                          id: widget.data == null ? '' : widget.data?.id ?? '',
                          name: name.text,
                          typeReminder: typeReminder,
                          dateReminder: typeReminder == 'monthly'
                              ? dateReminderMonthly
                              : dateReminderWeekly,
                          targetDate: dataDate.yyyymmdd(),
                          targetMoney: money.text.moneyToDouble(),
                          notification: widget.data == null
                              ? false
                              : widget.data?.notification ?? false,
                        );
                        // print(data.toJsonSave());
                        if (widget.data == null) {
                          bloc.add(SavingPlanSaveRequested(data));
                        } else {
                          bloc.add(SavingPlanUpdateRequested(
                            data.toJsonUpdate(),
                            data,
                          ));
                        }
                      }
                    },
                    child: Text(widget.data == null ? 'Save' : 'Update'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
