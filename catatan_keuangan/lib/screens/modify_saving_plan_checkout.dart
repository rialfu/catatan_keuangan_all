import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_bloc.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_event.dart';
import 'package:catatan_keuangan/core/model/saving_plan_checkout_model.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ModifySavingPlanCheckout extends StatefulWidget {
  final String idSavingPlan;
  const ModifySavingPlanCheckout({super.key, required this.idSavingPlan});

  @override
  State<ModifySavingPlanCheckout> createState() =>
      _ModifySavingPlanCheckoutState();
}

class _ModifySavingPlanCheckoutState extends State<ModifySavingPlanCheckout> {
  final _formKey = GlobalKey<FormState>();
  DateTime tanggal = DateTime.now();
  TextEditingController money = TextEditingController();

  @override
  void initState() {
    money.text == '0';
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    money.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red,
        title: Text(
          'Form Store Saving',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', textAlign: TextAlign.left),
              TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: tanggal, // Refer step 1
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
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
              Text('Target Money', textAlign: TextAlign.left),
              TextFormField(
                controller: money,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if ((value?.moneyToDouble() ?? 0) < 0) {
                    return 'Please fill not zero';
                  }
                  return null;
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
              SizedBox(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 200,
                    ),
                    width: context.dynamicWidth(0.6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var bloc = context.read<SavingPlanBloc>();
                          var data = SavingPlanCheckoutModel(
                              id: 0,
                              money: money.text.moneyToDouble(),
                              dateCheckout: tanggal.yyyymmdd());
                          bloc.add(SavingPlanCheckoutSavingRequested(
                            data,
                            widget.idSavingPlan,
                          ));
                        }
                      },
                      child: Text('Save'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
