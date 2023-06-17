import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'online_status_viewmodel.dart';

class IsOnlineWidget extends StatelessWidget {
  const IsOnlineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) => model.setTimer(),
      builder: (context, model, child) {
        if (model.isOnline)
          return Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Online',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ));
        else
          return Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Offline',
              style: TextStyle(color: Colors.white70),
            ),
          ));
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<HomeViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Column(
      children: [],
    );
  }
}
