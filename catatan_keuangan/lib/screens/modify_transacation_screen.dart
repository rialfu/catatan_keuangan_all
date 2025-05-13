import 'dart:async';

import 'package:catatan_keuangan/components/dropdown_component.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
// import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/double_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/template/categoryscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ModifyTransactionScreen extends StatefulWidget {
  final TransactionDailyModel? data;
  const ModifyTransactionScreen({super.key, this.data});

  @override
  State<ModifyTransactionScreen> createState() =>
      _ModifyTransactionScreenState();
}

class _ModifyTransactionScreenState extends State<ModifyTransactionScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController harga = TextEditingController();
  // TextEditingController debcre = TextEditingController();
  String debCre = 'debit';
  DateTime tanggal = DateTime.now();
  int? category;
  final _formKey = GlobalKey<FormState>();
  late final TransactionBloc tranBloc;
  late final AuthBloc authBloc;
  late final CategoryBloc catBloc;
  late StreamSubscription tranStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.data?.name != null) {
      name.text = widget.data!.name;
    }
    if (widget.data?.detail != null) {
      detail.text = widget.data!.detail!;
    }
    if (widget.data?.harga != null) {
      harga.text = widget.data!.harga.toFormatMoneyForm();
    }
    if (widget.data?.debitCredit != null) {
      setState(() {
        debCre = widget.data!.debitCredit;
      });
    }
    if (widget.data?.categoryId != null) {
      setState(() {
        category = widget.data!.categoryId;
      });
    }

    if (widget.data?.tanggal != null) {
      setState(() {
        tanggal = DateTime.tryParse(widget.data!.tanggal) ?? DateTime.now();
      });
      // tanggal.text = widget.data!.tanggal;
    }
    catBloc = context.read<CategoryBloc>();
    authBloc = context.read<AuthBloc>();
    tranBloc = context.read<TransactionBloc>();
    tranStream = tranBloc.stream.listen((state) async {
      if (state is TransactionStateFinishLoad) {
        // print('finish');
        // return;
        return alertDialogCustom(
          callback: () {
            print('enter');
            Navigator.of(context).popUntil((r) => r.isFirst);
            tranBloc.add(TransactionCleanMessage());
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
            // Navigator

            Navigator.of(context).pop();
            tranBloc.add(TransactionCleanMessage());
          },
          message: message,
        );
      }
    });
    // tranBloc.state.categories.forEach((e) => print('${e.id} ${e.name}'));
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

  @override
  void dispose() {
    name.dispose();
    detail.dispose();
    harga.dispose();
    tranStream.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          widget.data == null ? 'Form Add' : 'Form Edit',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(builder: (context, state) {
        List<Map<String, String>> dropdownCategory = [];
        dropdownCategory = state.categories
            .map((e) => {'value': e.id.toString(), 'name': e.name})
            .toList();

        dropdownCategory.sort((a, b) => a['name']!.compareTo(b['name']!));
        // dropdownCategory.insert(0, {'value': '', 'name': 'Please Select'});
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GridView(gridDelegate: gridDelegate,c)
                Text('Nama', textAlign: TextAlign.left),
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
                Text('Detail', textAlign: TextAlign.left),
                TextFormField(
                  controller: detail,
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Type', textAlign: TextAlign.left),
                DropDownComponent(
                  position: AlignmentDirectional.centerStart,
                  callback: (String? val) {
                    setState(() {
                      debCre = val ?? debCre;
                    });
                  },
                  listData: [
                    {'value': 'debit', 'name': 'Income'},
                    {'value': 'credit', 'name': 'Expense'}
                  ],
                  setValue: debCre,
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Money', textAlign: TextAlign.left),
                TextFormField(
                  controller: harga,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]+'))
                    // FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Please input money';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String textValue) {
                    String value = textValue.fixStringMoney();

                    harga.value = TextEditingValue(
                      text: value,
                    );
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Category', textAlign: TextAlign.left),
                Row(
                  children: [
                    DropDownComponent(
                      position: AlignmentDirectional.centerStart,
                      callback: (String? val) {
                        setState(() {
                          category = int.tryParse(val ?? '');
                        });
                      },
                      listData: dropdownCategory,
                      setValue: category?.toString(),
                    ),
                    IconButton(
                      onPressed: () {
                        var bloc = context.read<CategoryBloc>();
                        if (bloc.state.loading) return;
                        bloc.add(CategoryRequested());
                      },
                      icon: Icon(
                        Icons.refresh,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                      ),
                    )
                  ],
                ),

                SizedBox(
                  height: 15,
                ),
                Text('Date', textAlign: TextAlign.left),
                TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tanggal, // Refer step 1
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          tanggal = picked;
                        });
                      }
                    },
                    child: Text(tanggal.ddMMyyyy())),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                    onPressed: () async {
                      String message = '';
                      // print(harga.text.moneyToDouble());

                      if (_formKey.currentState!.validate()) {
                        if (harga.text.moneyToDouble() == 0) {
                          message = 'The money must fill or not zero';
                        } else if (category == null) {
                          message = 'The category must choose';
                        }
                        if (message != '') {
                          return alertDialogCustom(
                            message: [message],
                            title: 'Error Message',
                            callback: () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                        // print(harga.text.moneyToDouble());
                        // return;
                        String? cat;
                        for (int i = 0;
                            i < catBloc.state.categories.length;
                            i++) {
                          if (catBloc.state.categories[i].id ==
                              (category ?? 0)) {
                            cat = catBloc.state.categories[i].name;
                            break;
                          }
                        }
                        var data = TransactionDailyModel(
                          id: widget.data?.id ?? 0,
                          name: name.text,
                          detail: detail.text,
                          categoryId: category ?? 0,
                          harga: harga.text.moneyToDouble(),
                          debitCredit: debCre,
                          category: cat,
                          tanggal: tanggal.yyyymmdd(),
                        );
                        if (widget.data == null) {
                          tranBloc.add(
                            TransactionSaveRequested(
                              data,
                            ),
                          );
                        } else {
                          tranBloc.add(
                            TransactionUpdateRequested(
                              data,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(widget.data == null ? 'Save' : 'Update'),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
