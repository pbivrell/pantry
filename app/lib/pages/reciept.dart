import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:groceryui/models/reciptItem.dart';
import 'package:groceryui/models/trip.dart';
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
  final StreamController<List<RecieptItem>> productStream =
      StreamController<List<RecieptItem>>();

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var t = prefs.getString("token") ?? "";
    setState(() {
      fetching = true;
      token = t;
    });
    loadProducts(DisableHTTP, t!);
  }

  void loadProducts(bool disabled, String token) async {
    List<RecieptItem> recipts;
    if (disabled) {
      recipts = await RecieptItem.readJson();
    }else {
      recipts = await RecieptItem.getSummary(token);
    }
    productStream.add(recipts);
    return;
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
      loadProducts(true, token!);
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
          padding: const EdgeInsets.only(top: 10.0),
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
                    child: StreamBuilder<List<RecieptItem>>(
                      stream: productStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, item) {
                              final sum = snapshot.data![item];
                              return ListTile(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    if (mounted) {
                                      return SingleReceipt(
                                          token: token!, id: sum.id);
                                    }
                                    return Container();
                                  }));
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
                                    "\$${sum.total / 100}",
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
                        return (fetching)
                            ? Center(child: const CircularProgressIndicator())
                            : const Center(
                                child: Text(
                                    "Nothing to display. Upload a receipt"));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary!),
                        ),
                        child: TextButton(
                          child: Icon(Icons.camera_alt_outlined),
                          onPressed: () async {
                            var cameras = await availableCameras().timeout(
                                const Duration(seconds: 10), onTimeout: () {
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
                        )
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
      ],
    );
  }
}
