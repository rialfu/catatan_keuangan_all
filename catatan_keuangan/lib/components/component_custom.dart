import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/screens/saving_plan_screen.dart';
import 'package:catatan_keuangan/screens/setting_screen.dart';
import 'package:flutter/material.dart';

class ComponentCustom {
  static List<String> messageSessionOut = [
    'Your session is gone.',
    'You must login again',
  ];
  static void alert(BuildContext context, List message, String title,
      {VoidCallback? callback, String buttonClose = 'Close'}) {
    showDialog<void>(
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
              onPressed: callback ??
                  () {
                    Navigator.of(context).pop();
                    // tranBloc.add(TransactionCleanMessage());
                  },
              child: Text(buttonClose),
            ),
          ],
        );
      },
    );
  }

  static Drawer drawerCustom(BuildContext context, int index,
      {AuthBloc? bloc}) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text("Home / Catatan"),
            onTap: () {
              if (index == 0) {
                // Navigator.pop(context);
                return;
              }
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          ListTile(
            title: Text("Saving Plan"),
            onTap: () {
              if (index == 1) {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingPlanScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text("Setting"),
            onTap: () {
              if (index == 2) {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text("Log out"),
            onTap: () {
              bloc?.add(LogoutRequested());
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
