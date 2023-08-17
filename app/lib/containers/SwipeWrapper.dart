
import 'package:flutter/material.dart';

import '../constants.dart';

class SwipeWrapper extends StatefulWidget {

  final List<Widget> widgets;
  final List funcs;

  const SwipeWrapper({Key? key, required this.widgets, required this.funcs}) : super(key: key);

  @override
  State<SwipeWrapper> createState() => _SwipeWrapperState();
}

class _SwipeWrapperState extends State<SwipeWrapper>
    with SingleTickerProviderStateMixin {

  int _selected = 0;
  late final TabController _controller = TabController(length: widget.widgets.length, vsync: this);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _selected = _controller.index;
      });
      widget.funcs[_selected]();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 270,
            child: TabBarView(
              controller: _controller,
              children: widget.widgets,
            ),
          ),
          SizedBox(
            height: 12,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: <Widget>[
                  for(int i = 0; i < widget.widgets.length; i++ ) CircleAvatar(
                    backgroundColor: _selected == i ? secondary : alternate,
                    radius: _selected == i ? 8 : 4,
                  )
                ],
                controller: _controller,
              ),
            ),
          ),
        ],
      );
  }
}