import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Demo extends StatelessWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.blue,
                        width: 150,
                        height: 200,
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          color: Colors.red,
                          child: Column(
                            children: [
                              Text("Apple" ),
                              SizedBox(
                                height: 30,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                    Expanded(child: Text("King Soopers")),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.green,
                                      child: Text("A"),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.yellow,
                                      child: Text("B"),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.brown,
                                      child: Text("Ciasfhiuashfiuahsifuhaisfuhasiuhf"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
