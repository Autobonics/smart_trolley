import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

import 'automatic_viewmodel.dart';

class AutomaticView extends StackedView<AutomaticViewModel> {
  const AutomaticView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AutomaticViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text("Map")),
      body: Stack(
        children: [
          if (viewModel.data != null)
            GoogleMap(
              onMapCreated: viewModel.onMapCreated,
              initialCameraPosition: viewModel.initialCameraPosition,
              markers: viewModel.markers.toSet(),
              onTap: viewModel.dropPin,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.hybrid,
            )
          else
            Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "D1: ${viewModel.data!.d1}  D2: ${viewModel.data!.d2}  D3: ${viewModel.data!.d3}, "),
                      Text(viewModel.selectedLocation == null &&
                              viewModel.dir == Direction.Stop
                          ? "Location not selected"
                          // : 'Selected Location: ${viewModel.selectedLocation ?? ''}'),
                          : 'Moving : ${viewModel.dir}, Distance: ${viewModel.dist.toStringAsFixed(2)}m'),
                      Row(
                        children: [
                          if (!viewModel.isFollowMe)
                            ElevatedButton(
                              onPressed: viewModel.startTrolley,
                              child: Text(viewModel.isMoving
                                  ? "Stop Trolley"
                                  : 'Start Trolley'),
                            ),
                          SizedBox(width: 20),
                          if (!viewModel.isMoving)
                            ElevatedButton(
                              onPressed: viewModel.setFollowMe,
                              child: Text(!viewModel.isFollowMe
                                  ? "Follow me Trolley"
                                  : 'Stop Trolley'),
                            ),
                        ],
                      ),
                      if (!viewModel.isFollowMe && !viewModel.isMoving)
                        ElevatedButton(
                          onPressed: viewModel.moveToInitialPoint,
                          child: Text(viewModel.isMoving
                              ? "Stop Trolley"
                              : 'Move to initial position'),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slider(
                          value: viewModel.sValue,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: viewModel.sValue.toString(),
                          onChanged: viewModel.setSpeed,
                          onChangeEnd: (value) {
                            viewModel.setDeviceData();
                          },
                        ),
                      ),
                      Text("Compass: ${viewModel.data!.heading}"),
                      if (viewModel.currentHeading != null)
                        Text("Phone Compass: ${viewModel.currentHeading!}"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  AutomaticViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AutomaticViewModel();

  @override
  void onViewModelReady(AutomaticViewModel viewModel) {
    viewModel.onModelReady();
    super.onViewModelReady(viewModel);
  }
}
