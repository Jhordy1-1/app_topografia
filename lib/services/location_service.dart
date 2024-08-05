import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<LocationData?> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await _location.getLocation();
  }

  Future<void> updateUserLocation(String userId) async {
    final locationData = await getLocation();
    if (locationData != null) {
      await _firestore.collection('user_locations').doc(userId).update({
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Unable to obtain location data.');
    }
  }

  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }
}
