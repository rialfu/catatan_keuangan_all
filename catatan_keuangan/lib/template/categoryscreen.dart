import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/screens/modify_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Widget datable(List<CategoryModel> data) {
    if (data.isNotEmpty) {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            // color: Colors.green,
            child: Container(
              width: context.dynamicWidth(1),
              height: context.dynamicHeight(0.07),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.shade700,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data[index].name,
                    style: TextStyle(color: Colors.white),
                  ),
                  data[index].canDelete
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (bloc.state.loading) return;
                                  bloc.add(
                                      CategoryDeleteRequested(data[index].id));
                                },
                                child: Icon(Icons.delete))
                          ],
                        )
                      : SizedBox(),
                ],
              ),
              // child: Stack(
              //   children: [
              //     Positioned(
              //       left: 0,
              //       top: 0,
              //       child: Text(data[index].name),
              //     ),
              //     // Positioned(
              //     //   bottom: 0,
              //     //   right: 0,
              //     //   child: Text(data[index].name),
              //     // )
              //   ],
              // ),
            ),
          );
        },
      );
    }
    return Center(
      child: Text("Empty"),
    );
  }

  late final CategoryBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = context.read<CategoryBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(builder: (context, state) {
      return BlocListener<CategoryBloc, CategoryState>(
        listener: (context, stateB) async {
          if (stateB.message != null) {
            // print()
            List<Widget> message = [];
            if (stateB.message is List) {
              List<Widget> newWi = (state.message as List)
                  .map((e) => Text(e.toString()))
                  .toList();
              message.addAll(newWi);
            } else {
              message.add(Text(stateB.message.toString()));
            }

            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: message,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        bloc.add(CategoryCleanMessage());
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: context.dynamicWidth(0.6),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          if (bloc.state.loading) return;
                          bloc.add(CategoryRequested());
                        },
                        child: Text("Search"),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModifyCategoryScreen(),
                            ),
                          );
                        },
                        child: Text("Add"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: datable(state.categories),
            )
          ],
        ),
      );
    });
  }
}
