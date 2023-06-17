/// Institution model
class DeviceReading {
  double d1;
  double d2;
  double d3;
  double heading;
  double lat;
  double lng;
  bool isGps;
  bool isCompass;
  DateTime lastSeen;

  DeviceReading({
    required this.d1,
    required this.d2,
    required this.d3,
    required this.heading,
    required this.lat,
    required this.lng,
    required this.isGps,
    required this.isCompass,
    required this.lastSeen,
  });

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      d1: data['distance1'] != null
          ? (data['distance1'] % 1 == 0
              ? data['distance1'] + 0.1
              : data['distance1'])
          : 0.0,
      d2: data['distance2'] != null
          ? (data['distance2'] % 1 == 0
              ? data['distance2'] + 0.1
              : data['distance2'])
          : 0.0,
      d3: data['distance3'] != null
          ? (data['distance3'] % 1 == 0
              ? data['distance3'] + 0.1
              : data['distance3'])
          : 0.0,
      isGps: data['isGps'] ?? false,
      isCompass: data['isCompass'] ?? false,
      heading: data['heading'] != null
          ? (data['heading'] % 1 == 0 ? data['heading'] + 0.1 : data['heading'])
          : 0.0,
      lat: data['lat'] != null
          ? (data['lat'] % 1 == 0 ? data['lat'] + 0.1 : data['lat'])
          : 0.0,
      lng: data['lng'] != null
          ? (data['lng'] % 1 == 0 ? data['lng'] + 0.1 : data['lng'])
          : 0.0,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(data['ts']),
    );
  }
}

/// Device control model
class DeviceData {
  bool m1Dir;
  bool m2Dir;
  int m1Speed;
  int m2Speed;

  DeviceData({
    required this.m1Dir,
    required this.m2Dir,
    required this.m1Speed,
    required this.m2Speed,
  });

  factory DeviceData.fromMap(Map data) {
    return DeviceData(
      m1Dir: data['m1Dir'] ?? false,
      m2Dir: data['m2Dir'] ?? false,
      m1Speed: data['m1Speed'] ?? 1,
      m2Speed: data['m2Speed'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'm1Dir': m1Dir,
        'm2Dir': m2Dir,
        'm1Speed': m1Speed,
        'm2Speed': m2Speed,
      };
}
