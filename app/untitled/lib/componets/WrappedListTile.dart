import 'package:flutter/material.dart';

class WrappedListTile extends StatelessWidget {

  final ListTile listTile;

  const WrappedListTile({
    Key? key,
    required this.listTile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: listTile,
      )
    );
  }
}
