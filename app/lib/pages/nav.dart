import 'package:flutter/material.dart';
import 'package:groceryui/pages/cart.dart';
import 'package:groceryui/pages/search.dart';
import 'package:groceryui/pages/login.dart';
import 'package:groceryui/pages/home.dart';
import 'package:groceryui/pages/reciept.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  int _index = 0;

  void _onAuthed(String token) async {
    setState(() {
        _authenticated = true;
        _token = token;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Scaffold(),
    CartPage(),
    RecieptPage(),
    CartPage(),
  ];

  bool _authenticated = true;
  String _token = "-NWd0wmQY2r6rgy9lM3q";

  @override
  Widget build(BuildContext context) {

    return _authenticated ? Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        currentIndex: _index,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.cookie_outlined), label: "food"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "meals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart_sharp), label: "cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "trips"),
        ],
      ),
      body: _pages[_index],
    ) :
        Login(setAuthed: _onAuthed);
  }
}
