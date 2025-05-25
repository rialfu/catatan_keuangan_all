import 'dart:async';

// import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
// import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModifyCategoryScreen extends StatefulWidget {
  final CategoryModel? data;
  const ModifyCategoryScreen({super.key, this.data});

  @override
  State<ModifyCategoryScreen> createState() => _ModifyCategoryScreenState();
}

class _ModifyCategoryScreenState extends State<ModifyCategoryScreen> {
  late CategoryBloc categoryBloc;
  final _formKey = GlobalKey<FormState>();
  TextEditingController field = TextEditingController();
  late StreamSubscription catStream;
  bool isLoad = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryBloc = context.read<CategoryBloc>();
    catStream = categoryBloc.stream.listen((state) async {
      setState(() {
        isLoad = state.loading;
      });
      if (state is CategoryStateFinishLoad) {
        return _showMyDialog(
          customMethod: () {
            Navigator.of(context).pop();
            categoryBloc.add(CategoryCleanMessage());
            Navigator.of(context).pop();
          },
          message: [
            'Success ${widget.data == null ? "Add" : "Update"}',
          ],
          title: 'Success',
          textClose: 'Close',
        );
      } else if (state.status == AuthStatus.guest) {
        return _showMyDialog(customMethod: () {
          var authBloc = context.read<AuthBloc>();
          authBloc.add(LogoutRequested());
        });
      } else if (state.message != null) {
        List message = [];
        if (state.message is List) {
          message.addAll(state.message as List);
        } else {
          message.add(message);
        }
        _showMyDialog(
          customMethod: () {
            Navigator.of(context).pop();
            // Navigator.of(context).pop();
            categoryBloc.add(CategoryCleanMessage());
          },
          title: 'error',
          message: message,
          textClose: 'close',
        );
      }
    });
  }

  Future<void> _showMyDialog({
    String title = 'Session Timeout',
    String textClose = 'Logout',
    List message = const ['Your session is gone.', 'You must login again'],
    required VoidCallback customMethod,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: message.map((e) => Text(e.toString())).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: customMethod,
                child: Text(textClose),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    field.dispose();
    catStream.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Form Add",
          style: TextStyle(fontSize: 18),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama Category"),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: field,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Nama Category must fill';
                    } else if (value.length > 20) {
                      return 'Please max 20 character';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 100,
                ),
                width: context.dynamicWidth(0.4),
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (isLoad || categoryBloc.state.loading) return;
                    if (_formKey.currentState!.validate()) {
                      categoryBloc.add(
                          CategorySaveRequested(CategoryModel(0, field.text)));
                    }
                  },
                  child: isLoad || categoryBloc.state.loading
                      ? Transform.scale(
                          scale: 0.5,
                          child: CircularProgressIndicator(),
                        )
                      : Text("Process"),
                ),
              ),
              Expanded(
                flex: 8,
                child: SizedBox(),
                // child: TextFormField(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
