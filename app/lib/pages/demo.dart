import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Demo extends StatelessWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Future<List<int>> _value;

    Future<List<int>> a() {
        return Future.delayed(Duration(milliseconds: 100), (){
          return [1,2,3];
        });
    }
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Container(
              color: Colors.red,
              height: 300,
            ),
            FutureBuilder(
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Column(
                  children: [
                    Container(
                      color: Colors.green,
                      height: 100,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 100,
                    ),
                    Container(
                      color: Colors.yellow,
                      height: 100,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
