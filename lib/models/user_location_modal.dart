import 'package:cloud_firestore/cloud_firestore.dart';

class UserModelLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String name;
  final Timestamp? timestamp;
  final int index;
  final bool isActive;

  UserModelLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.timestamp,
    required this.index,
    required this.isActive,
  });

  factory UserModelLocation.fromMap(Map<String, dynamic> map) {
    return UserModelLocation(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      name: map['name'] as String,
      timestamp: map['timestamp'] as Timestamp?,
      index: map['index'] as int,
      isActive: map['isActive'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'timestamp': timestamp,
      'index': index,
      'isActive': isActive,
    };
  }
}