import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_trolley/ui/smart_widgets/online_status.dart';
import 'package:stacked/stacked.dart';

import 'package:lottie/lottie.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onViewModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        // print(model.node?.lastSeen);
        return Scaffold(
            appBar: AppBar(
              title: const Text('Smart trolley'),
              centerTitle: true,
              actions: [IsOnlineWidget()],
            ),
            body: model.data != null
                ? const _HomeBody()
                : Center(child: Text("No data")));
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<HomeViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CsButton(
                    onTap: model.openAutomaticView,
                    text: "Open automatic movement"),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("D1: ${model.data!.d1}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("D2: ${model.data!.d2}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("D3: ${model.data!.d3}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                        "Compass ${model.data!.isCompass ? "connected" : "not connected"}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Heading: ${model.data!.heading}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                        "GPS ${model.data!.isGps ? "connected" : "not connected"}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Latitude: ${model.data!.lat}"),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Longitude: ${model.data!.lng}"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CsButton(onTap: model.setForward, text: "Forward"),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CsButton(onTap: model.setLeft, text: "Left"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  CsButton(onTap: model.setStop, text: "Stop"),
                                ],
                              ),
                            ),
                            CsButton(onTap: model.setRight, text: "Right"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      CsButton(onTap: model.setBack, text: "Backward"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Slider(
                    value: model.sValue,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: model.sValue.toString(),
                    onChanged: model.setSpeed,
                    onChangeEnd: (value) {
                      model.setDeviceData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // if (model.data!.d1)
        //   Positioned.fill(
        //       child: Warning(
        //     message: "Accident detected",
        //   )),
        // if (model.data2!.isSleeping)
        //   Positioned.fill(
        //       child: Warning(
        //     message: "Driver is sleeping",
        //   )),
      ],
    );
  }
}

class CsButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const CsButton({Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class Warning extends StatelessWidget {
  final String message;
  const Warning({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Center(
        child: Card(
          // elevation: 10,
          color: Colors.black.withOpacity(0.5),
          child: Container(
            height: 400,
            width: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.network(
                      'https://assets2.lottiefiles.com/packages/lf20_Tkwjw8.json'),
                  SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
