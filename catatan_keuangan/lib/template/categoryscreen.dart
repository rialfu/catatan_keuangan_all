import 'dart:async';

import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
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
  bool isLoad = false;

  late final CategoryBloc bloc;
  late final StreamSubscription stream;
  @override
  void initState() {
    super.initState();
    bloc = context.read<CategoryBloc>();
    stream = bloc.stream.listen((state) {
      if (state.status == AuthStatus.guest) {
        _showMyDialog();
      } else if (state.loading) {
        setState(() {
          isLoad = true;
        });
      } else {
        setState(() {
          isLoad = false;
        });
      }
    });
    if (bloc.state.loading) return;
    bloc.add(CategoryRequested());
  }

  @override
  void dispose() {
    stream.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Timeout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your session is gone.'),
                Text('You must login again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                var bloc = context.read<AuthBloc>();
                bloc.add(LogoutRequested());
              },
            ),
          ],
        );
      },
    );
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
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (bloc.state.loading) return;
                          bloc.add(CategoryRequested());
                        },
                        icon: Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModifyCategoryScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                )
              ],
            ),
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
          ),
          body: Stack(
            children: [
              ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: context.dynamicHeight(0.05),
                    width: context.dynamicWidth(1),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.categories[index].name),
                        // Text(state.categories[index].canDelete.toString()),
                        state.categories[index].canDelete
                            ? IconButton(
                                onPressed: () {
                                  if (bloc.state.loading) return;
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible:
                                        false, // user must tap button!
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmation'),
                                        content: const SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                'Are You Sure want delete?',
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Ok'),
                                            onPressed: () {
                                              if (bloc.state.loading) return;

                                              bloc.add(CategoryDeleteRequested(
                                                  state.categories[index].id));
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  );
                },
              ),
              if (isLoad)
                Container(
                  color: Colors.transparent,
                  height: context.dynamicHeight(1),
                  width: context.dynamicWidth(1),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
          // ),
        ),
        // child: Column(
        //   children: [
        //     Expanded(
        //       flex: 1,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(vertical: 10),
        //         width: context.dynamicWidth(0.6),
        //         child: Row(
        //           children: [
        //             Expanded(
        //               child: ElevatedButton(
        //                 style: ElevatedButton.styleFrom(
        //                   backgroundColor: Colors.red,
        //                   foregroundColor: Colors.white,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius:
        //                         BorderRadius.circular(12), // <-- Radius
        //                   ),
        //                 ),
        //                 onPressed: () {
        //                   if (bloc.state.loading) return;
        //                   bloc.add(CategoryRequested());
        //                 },
        //                 child: Text("Search"),
        //               ),
        //             ),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             Expanded(
        //               child: ElevatedButton(
        //                 style: ElevatedButton.styleFrom(
        //                   backgroundColor: Colors.red,
        //                   foregroundColor: Colors.white,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius:
        //                         BorderRadius.circular(12), // <-- Radius
        //                   ),
        //                 ),
        //                 onPressed: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => ModifyCategoryScreen(),
        //                     ),
        //                   );
        //                 },
        //                 child: Text("Add"),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       flex: 12,
        //       child: datable(state.categories),
        //     )
        //   ],
        // ),
      );
    });
  }
}
