import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:groceryui/models/tripItem.dart';
import 'package:groceryui/pages/ocr.dart';
import 'package:groceryui/pages/one-reciept.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:convert';

import '../constants.dart';



class RecieptPage extends StatefulWidget {
  const RecieptPage({Key? key}) : super(key: key);

  @override
  State<RecieptPage> createState() => _RecieptPageState();
}

class _RecieptPageState extends State<RecieptPage> {
  var loading = false;
  var fetching = false;
  var alert = false;
  String? token = "";
  final StreamController<List<ReciptItem>> productStream =
      StreamController<List<ReciptItem>>();

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fetching = true;
      token = prefs.getString('token');
    });
    loadProducts();
  }

  void loadProducts() async {
    final response = await http.get(Uri.parse('$ExposerURL/summary'),
        headers: {"cookie": "X-Session-Token=$token"});

    setState(() {
      fetching = false;
    });
    if (response.statusCode == 200) {
      var list = json.decode(response.body) as List;

      var x = list.map((i) => ReciptItem.fromJson(i)).toList();

      productStream.add(x);
    } else {
      print("status: $response.statusCode");
    }
  }

  void uploadImage(XFile image) async {
    if (token == null) {
      return;
    }

    setState(() {
      loading = true;
    });

    Map<String, String> headers = {"Cookie": "X-Session-Token=$token"};

    var request = http.MultipartRequest("POST", Uri.parse(OcrURL));
    request.headers.addAll(headers);

    var data = await image.readAsBytes();

    final img.Image? capturedImage = img.decodeImage(data);
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);

    request.files.add(http.MultipartFile.fromBytes(
        "photo", img.encodeJpg(orientedImage),
        filename: image!.path));
    var response = await request.send();

    setState(() {
      loading = false;
    });
    if (response.statusCode != 200) {
      setState(() {
        alert = true;
      });
      loadProducts();
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Stack(
            children: [
              Column(
                children: [
                  if (loading)
                    Container(
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(color: secondary))),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8.0, left: 8.0, right: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                          Text("Processing uploaded trip"),
                        ],
                      ),
                    ),
                  Expanded(
                    child: StreamBuilder<List<ReciptItem>>(
                      stream: productStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data?.length,
                            padding: EdgeInsets.only(bottom: 40),
                            itemBuilder: (context, item) {
                              final sum = snapshot.data![item];
                              return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          SingleReceipt(token: token!, id: sum.id)
                                          ));
                                },
                                leading: CircleAvatar(
                                  radius: 31,
                                  backgroundColor: secondary,
                                  child: CircleAvatar(
                                    radius: 29,
                                    foregroundImage: AssetImage(
                                      "assets/images/stores/kingsoopers.png",
                                    ),
                                  ),
                                ),
                                title: Text(
                                    "Boulder - ${DateFormat('MM/dd/yy').format(sum.visit)}"),
                                subtitle: Text("Items: ${sum.count}"),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: primary!),
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    "\$${sum.total/100}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: inPrimaryText),
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          setState(() {
                            alert = true;
                          });
                        }
                        return (fetching) ? Center(child: const CircularProgressIndicator()) : const Center(child: Text("Nothing to display. Upload a receipt"));
                      },
                    ),
                  ),
                ],
              ),
              if (alert)
                AlertDialog(
                  elevation: 5,
                  backgroundColor: Colors.white,
                  title: const Text('Failed to upload'),
                  content: const SingleChildScrollView(
                    child: ListBody(children: <Widget>[
                      Text('Please take another picture'),
                    ]),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        setState(() {
                          alert = false;
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        SizedBox(height: 50),
        Center(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 16, right: 8),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ]),
                  child: TextButton(
                    child: Icon(Icons.camera_alt_outlined),
                    onPressed: () async {
                      var cameras = await availableCameras()
                          .timeout(const Duration(seconds: 10), onTimeout: () {
                        print("giving up");
                        return [];
                      });
                      var output = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CameraApp(cameras: cameras)));
                      if (output != null) {
                        uploadImage(output);
                      }
                    },
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
