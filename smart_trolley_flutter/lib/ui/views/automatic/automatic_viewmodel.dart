import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_trolley/ui/setup_snackbar_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/models.dart';
import '../../../services/db_service.dart';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:connectivity/connectivity.dart';
import 'package:network_info_plus/network_info_plus.dart';

enum Direction {
  Straight,
  Left,
  Right,
  Stop,
}

class AutomaticViewModel extends ReactiveViewModel {
  final log = getLogger('AutomaticViewModel');

  final _snackBarService = locator<SnackbarService>();
  // final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();

  DeviceReading? get data => _dbService.node;

  @override
  List<DbService> get reactiveServices => [_dbService];

  late LatLng initialPosition;

  void onModelReady() async {
    setStop();
    getDeviceData();
    initialPosition = LatLng(data!.lat, data!.lng);
    initialCameraPosition = CameraPosition(
      target: initialPosition, // Set the initial target to a default location
      zoom: 30,
    );
    await loadCustomMarkerIcon();
    setMarkers();
    notifyListeners();
  }

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(0, 0), // Set the initial target to a default location
    zoom: 15,
  );

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void dropPin(LatLng location) {
    _selectedLocation = location;
    setMarkers();
  }

  BitmapDescriptor? customMarkerIcon;

  Future loadCustomMarkerIcon() async {
    final Uint8List markerIconBytes =
        await getBytesFromAsset('assets/tm.png', 120);
    customMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    final frame = await codec.getNextFrame();
    final imageBytes =
        (await frame.image.toByteData(format: ImageByteFormat.png))!
            .buffer
            .asUint8List();
    return imageBytes;
  }

  void setMarkers() {
    if (_selectedLocation != null)
      _markers = {
        Marker(
          markerId: MarkerId('trolley'),
          position: LatLng(data!.lat, data!.lng),
          icon: customMarkerIcon!,
        ),
        Marker(
          markerId: MarkerId('selected_location'),
          position: _selectedLocation!,
        ),
      };
    else {
      _markers = {
        Marker(
          markerId: MarkerId('trolley'),
          position: LatLng(data!.lat, data!.lng),
          icon: customMarkerIcon!,
        ),
      };
    }
    notifyListeners();
  }

  Timer? _timer;

  void startFunctionTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      // Call your function here
      autoMove();
    });
  }

  void stopFunctionTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void moveToInitialPoint() {
    _selectedLocation = initialPosition;
    setMarkers();
    startTrolley();
  }

  bool isMoving = false;
  Direction dir = Direction.Stop;
  double dist = 0;
  Future<void> startTrolley() async {
    if (isMoving) {
      stopFunctionTimer();
      isMoving = false;
      return setStop();
    }
    // Implement the logic to start the trolley movement
    // Access the selected location and other necessary data
    // Call the appropriate functions to control the trolley
    if (!data!.isGps) {
      return _snackBarService.showCustomSnackBar(
          message: "Trolley GPS not available", variant: SnackbarType.error);
    } else if (_selectedLocation == null) {
      return _snackBarService.showCustomSnackBar(
          message: "Pick a destination point", variant: SnackbarType.error);
    }

    isMoving = true;
    notifyListeners();
    startFunctionTimer();
  }

  void autoMove() {
    double bearing = getDirection();
    double distance = getDistance();
    double angle = calculateTurnAngle(data!.heading, bearing);
    Direction direction = determineTurnDirection(data!.heading, bearing);
    dir = direction;
    dist = distance;
    log.i("Bearing: $bearing");
    log.i("Distance: $distance");
    log.i("Angle: $angle");
    log.i(data!.heading);
    log.i(direction);
    move(distance, direction);
    setMarkers();
  }

  void move(double distance, Direction direction) {
    if (data!.d1 > 60 && data!.d2 > 60 && data!.d3 > 60) {
      if (distance > 2) {
        if (direction == Direction.Straight) {
          log.d("Moving straight");
          setForward();
        } else if (direction == Direction.Left) {
          log.d("Moving Left");
          setLeft();
        } else if (direction == Direction.Right) {
          log.d("Moving Right");
          setRight();
        }
      } else {
        setStop();
        log.e("Reached");
      }
    } else {
      setStop();
      log.e("Obstacle");
    }
  }

  double getDirection() {
    double bearing = Geolocator.bearingBetween(data!.lat, data!.lng,
        _selectedLocation!.latitude, _selectedLocation!.longitude);
    return bearing;
  }

  double getDistance() {
    double distance = Geolocator.distanceBetween(data!.lat, data!.lng,
        _selectedLocation!.latitude, _selectedLocation!.longitude);
    return distance;
  }

  double calculateTurnAngle(
    double currentHeadingAngle,
    double bearingToDestination,
  ) {
    double angleDifference = bearingToDestination - currentHeadingAngle;

    if (angleDifference > 180) {
      angleDifference -= 360;
    } else if (angleDifference < -180) {
      angleDifference += 360;
    }

    return angleDifference.abs();
  }

  Direction determineTurnDirection(
    double currentHeadingAngle,
    double bearingToDestination,
  ) {
    double angleDifference = bearingToDestination - currentHeadingAngle;

    if (angleDifference > 180) {
      angleDifference -= 360;
    } else if (angleDifference < -180) {
      angleDifference += 360;
    }

    log.e(angleDifference);

    if (angleDifference > 60) {
      return Direction.Right; // Angle is to the right
    } else if (angleDifference < -60) {
      return Direction.Left; // Angle is to the left
    } else {
      return Direction.Straight; // No turn required, straight ahead
    }
  }

  DeviceData _deviceData = DeviceData(
    m1Dir: false,
    m2Dir: false,
    m1Speed: 1,
    m2Speed: 1,
  );
  DeviceData get deviceData => _deviceData;

  void setStop() {
    _deviceData.m1Speed = 0;
    _deviceData.m2Speed = 0;
    _deviceData.m1Dir = false;
    _deviceData.m2Dir = false;
    setDeviceData();
    notifyListeners();
  }

  void setForward() {
    _deviceData.m1Speed = _speed;
    _deviceData.m2Speed = _speed;
    _deviceData.m1Dir = true;
    _deviceData.m2Dir = true;
    setDeviceData();
    notifyListeners();
  }

  void setLeft() {
    _deviceData.m1Speed = _speed;
    _deviceData.m2Speed = 0;
    _deviceData.m1Dir = true;
    _deviceData.m2Dir = false;
    setDeviceData();
    notifyListeners();
  }

  void setRight() {
    _deviceData.m1Speed = 0;
    _deviceData.m2Speed = _speed;
    _deviceData.m1Dir = false;
    _deviceData.m2Dir = true;
    setDeviceData();
    notifyListeners();
  }

  void setBack() {
    _deviceData.m1Speed = _speed;
    _deviceData.m2Speed = _speed;
    _deviceData.m1Dir = false;
    _deviceData.m2Dir = false;
    setDeviceData();
    notifyListeners();
  }

  int _speed = 0;

  double _sValue = 0;
  double get sValue => _sValue;

  void setSpeed(double value) {
    _sValue = value;
    if (value == 0)
      _speed = 0;
    else if (value == 1)
      _speed = 50;
    else if (value == 2)
      _speed = 70;
    else if (value == 3)
      _speed = 150;
    else if (value == 4)
      _speed = 200;
    else if (value == 5) _speed = 250;
    _deviceData.m1Speed = _speed;
    _deviceData.m2Speed = _speed;
    notifyListeners();
    setDeviceData();
  }

  void setDeviceData() {
    _dbService.setDeviceData(_deviceData);
  }

  void setSValue(double value) {
    if (value == 0)
      _sValue = 0;
    else if (value == 50)
      _sValue = 1;
    else if (value == 70)
      _sValue = 2;
    else if (value == 150)
      _sValue = 3;
    else if (value == 200)
      _sValue = 4;
    else if (value == 250) _sValue = 5;
    notifyListeners();
  }

  void getDeviceData() async {
    setBusy(true);
    DeviceData? deviceData = await _dbService.getDeviceData();
    if (deviceData != null) {
      setSValue(_deviceData.m1Speed.toDouble());
      _deviceData = DeviceData(
          m1Dir: deviceData.m1Dir,
          m2Dir: deviceData.m2Dir,
          m1Speed: deviceData.m1Speed,
          m2Speed: deviceData.m2Speed);
    }
    setBusy(false);
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) stopFunctionTimer();
    if (isFollowMe) stopCompassReading();
    super.dispose();
  }

  ///===========================================================
  Future<bool> requestSensorsPermission() async {
    PermissionStatus status = await Permission.sensors.request();
    PermissionStatus status2 = await Permission.location.request();
    return status2 == PermissionStatus.granted;
  }

  double? currentHeading;
  bool isFollowMe = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  void startCompassReading() {
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      if (event.heading != null) {
        currentHeading = event.heading!;

        // Correct for when signs are reversed.
        if (currentHeading! < 0) currentHeading = currentHeading! + 360;

        currentHeading = 360 - currentHeading!;

        ///
        // Check for wrap due to addition of declination.
        // if (currentHeading! > 2 * 3.14)
        // currentHeading = currentHeading! - 2 * 3.14;

        // Convert radians to degrees for readability.
        // currentHeading = currentHeading! * 180 / 3.14;

        log.i(currentHeading);
        Direction direction = followMe(currentHeading!, data!.heading);
        dir = direction;
        // getConnectedDeviceSignalStrength();
        notifyListeners();
        move(10, direction);
      }
    });
  }

  void stopCompassReading() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  void startReadingCompass() async {
    bool permissionGranted = await requestSensorsPermission();
    if (permissionGranted) {
      startCompassReading();
    } else {
      log.e("No permission");
    }
  }

  void setFollowMe() {
    if (isFollowMe) {
      isFollowMe = false;
      stopCompassReading();
      setStop();
      notifyListeners();
      return;
    } else {
      log.i("Follow me");
      isFollowMe = true;
      notifyListeners();
      startReadingCompass();
    }
  }

  Direction followMe(double initialHeading, double currentHeading) {
    const double tolerance =
        50.0; // Set a tolerance value to consider as straight
    const double rightThreshold =
        180.0; // Set the threshold to determine right turn
    const double leftThreshold =
        180.0; // Set the threshold to determine left turn

    double diff = currentHeading - initialHeading;
    log.e(diff);
    // if (diff.abs() <= (180 + tolerance) && diff.abs() <= (180 - tolerance)) {

    if (diff.abs() <= tolerance) {
      return Direction.Straight; // Within tolerance, consider as straight
    } else if (diff > 0) {
      if (diff <= rightThreshold) {
        return Direction.Right; // Within right turn threshold
      } else {
        return Direction.Left; // Beyond right turn threshold
      }
    } else {
      if (diff.abs() <= leftThreshold) {
        return Direction.Left; // Within left turn threshold
      } else {
        return Direction.Right; // Beyond left turn threshold
      }
    }
  }

  Future<int> getConnectedDeviceSignalStrength() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      var wifiDetails = await (NetworkInfo().getWifiBSSID());
      if (wifiDetails != null) {
        var signalStrength = int.parse(wifiDetails.split(",")[2].trim());
        log.e("Strength: $signalStrength");
        return signalStrength;
      }
    }
    return 0; // Return 0 if not connected to Wi-Fi
  }

// Future<int> getConnectedDeviceSignalStrength() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.wifi) {
  //     var wifiName = await NetworkInfo().getWifiName();
  //
  //     if (wifiName != null &&
  //         wifiName.isNotEmpty &&
  //         wifiName != '<unknown ssid>') {
  //       var connectedDevices = await NetworkInfo().get(wifiName);
  //       var connectedDevice = connectedDevices.firstWhere(
  //           (device) => device.ip != null && device.ip.isNotEmpty,
  //           orElse: () => null);
  //
  //       if (connectedDevice != null) {
  //         return connectedDevice.signalStrength;
  //       }
  //     }
  //   }
  //
  //   return 0; // Return 0 if no connected device or signal strength couldn't be retrieved
  // }
}
