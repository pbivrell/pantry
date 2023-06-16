import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groceryui/constants.dart';
import 'package:http/http.dart' as http;

const AuthURL = "https://grocery-auth-dev-7osudstnga-uc.a.run.app";

class Login extends StatefulWidget {
  final Function setAuthed;

  const Login({Key? key, required this.setAuthed}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var email = "";
  var password = "";
  var loading = false;
  var errorText = "";

  void login(bool register) async {

    setState((){
      loading = true;
    });

    var endpoint = register ? "register" : "login";

    final response = await http.post(Uri.parse('${AuthURL}/${endpoint}'),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }));

    setState((){
      loading = false;
    });
    if (response.statusCode == 200) {
      response.headers["set-cookie"]?.split(";").forEach((value){
        var values = value.split("=");
        if(values[0] == "X-Session-Token"){
          widget.setAuthed(values[1]);
        }
      });
    } else {
      setState((){
        errorText = "Invalid username or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('assets/images/categories/all.png')),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'bob@example.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: ''),
              ),
            ),
            (!loading)
                ? Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () {
                              login(false);
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () {
                              login(true);
                            },
                            child: Text(
                              'Signup',
                              style: TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])
                : Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: CircularProgressIndicator(),
                ),
            Text(errorText),
            SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: () {
                //TODO FORGOT PASSWORD SCREEN GOES HERE
              },
              child: Text(
                'Forgot Password',
                style: TextStyle(color: secondary, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
