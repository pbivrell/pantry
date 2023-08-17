import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../constants.dart';

abstract class Jsonable<T> {
  T fromJson(Map<String, dynamic> json);
  Widget build(dynamic items);
  String get route;
  String get jsonPath;
}

abstract class Loader {
  Future<dynamic> readJson();
  Future<dynamic> getHome(String token);
}

class ListLoader<T extends Jsonable<T>> implements Loader {

  final T inst;

  ListLoader({
    required this.inst
  });

  Future<List<T>> readJson() {
    print("Called");
    return rootBundle.loadString(inst.jsonPath).then(
            (String response) {
          final data = json.decode(response) as List;
          final items = data.map((i) => inst.fromJson(i)).toList();
          return items;
        }
    );
  }

  Future<List<T>> getHome(String token) {
    return http.get(
        Uri.parse('$ExposerURL/${inst.route}'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
            (http.Response response) {
          if (response.statusCode == 200) {
            var data= json.decode(response.body) as List;
            var x = data.map((i) => inst.fromJson(i)).toList();
            return x;
          }
          return Future.error("unable to load");
        }
    );
  }
}

class SingleLoader<T extends Jsonable<T>> implements Loader {

  final T inst;

  SingleLoader({
    required this.inst
  });

  Future<T> readJson() {
    print("Called");
    return rootBundle.loadString(inst.jsonPath).then(
            (String response) {
          final data = json.decode(response);
          return inst.fromJson(data);
        }
    );
  }

  Future<T> getHome(String token) {
    return http.get(
        Uri.parse('$ExposerURL/${inst.route}'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
            (http.Response response) {
          if (response.statusCode == 200) {
            var data= json.decode(response.body);
            return inst.fromJson(data);
          }
          return Future.error("unable to load");
        }
    );
  }
}