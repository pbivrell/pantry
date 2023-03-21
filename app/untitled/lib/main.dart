import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:untitled/pages/driver.dart';

import 'componets/DB.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      onPanDown: (DragDownDetails) {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: const MaterialApp(
          home: const DriverPage(),
      ),
    );
  }
}