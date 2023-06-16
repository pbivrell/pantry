import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:groceryui/pages/ocr.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../constants.dart';

const OcrURL = "https://grocery-ocr-dev-7osudstnga-uc.a.run.app/api/ocr";

class RecieptPage extends StatefulWidget {
  const RecieptPage({Key? key}) : super(key: key);

  @override
  State<RecieptPage> createState() => _RecieptPageState();
}

class _RecieptPageState extends State<RecieptPage> {
  var loading = false;
  var alert = false;
  String? token = "";

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
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
    }
  }

  @override
  void initState() {
    getToken();
    super.initState();
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
                    child: ListView.builder(
                      itemCount: 13,
                      padding: EdgeInsets.only(bottom: 40),
                      itemBuilder: (context, item) {
                        return ListTile(
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
                              "Boulder - ${DateFormat('MM/dd/yy').format(DateTime.now())}"),
                          subtitle: Text("Items: 43"),
                          trailing: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary!),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "\$32",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: inPrimaryText),
                            ),
                          ),
                        );
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
                    child: ListBody(
                      children: <Widget>[
                        Text('Please take another picture'),
                      ],
                    ),
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
              padding: const EdgeInsets.all(8.0),
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
                    child: Text(
                      "Scan New Receipt",
                      style: TextStyle(color: secondary, fontSize: 15),
                    ),
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
