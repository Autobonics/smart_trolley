import 'package:smart_trolley/app/app.router.dart';
import 'package:smart_trolley/models/models.dart';
import 'package:smart_trolley/services/db_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
// import '../../setup_snackbar_ui.dart';

class HomeViewModel extends ReactiveViewModel {
  final log = getLogger('HomeViewModel');

  // final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();

  DeviceReading? get data => _dbService.node;

  @override
  List<DbService> get reactiveServices => [_dbService];

  void onModelReady() {
    getDeviceData();
  }

  void openAutomaticView() {
    _navigationService.navigateToAutomaticView();
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
    _deviceData.m2Speed = _speed;
    _deviceData.m1Dir = true;
    _deviceData.m2Dir = false;
    setDeviceData();
    notifyListeners();
  }

  void setRight() {
    _deviceData.m1Speed = _speed;
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
}
