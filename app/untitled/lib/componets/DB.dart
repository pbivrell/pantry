import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/product.dart';

class DB extends DBBase {

  static final DB _instance = DB._internal();

  DB._internal() {
    isar = Isar.openSync([ProductSchema]);
  }

  factory DB() {
    return _instance;
  }
}

abstract class DBBase {
  @protected
  late Isar isar;
}