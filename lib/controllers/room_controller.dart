import 'dart:async';
import 'dart:math';
import 'package:app_topografia/models/user_location_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import 'package:app_topografia/services/location_service.dart';

class RoomController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  StreamSubscription<Map<String, dynamic>>? _userLocationsSubscription;
  final StreamController<List<UserModelLocation>> _userStreamController = StreamController.broadcast();
  Stream<List<UserModelLocation>> get userStream => _userStreamController.stream;
  String _generateRoomCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => characters[random.nextInt(characters.length)]).join();
  }

  Future<RoomModel> createRoom(String name, String adminId) async {
    String roomCode = _generateRoomCode();
    DocumentReference roomRef = await _firestore.collection('rooms').add({
      'name': name,
      'userIds': [],
      'adminId': adminId,
      'roomCode': roomCode,
    });

    await roomRef.update({
      'id': roomRef.id,
    });

    return RoomModel(id: roomRef.id, name: name, userIds: [], adminId: adminId, roomCode: roomCode);
  }

  Future<RoomModel?> getRoomByCode(String roomCode) async {
    QuerySnapshot roomSnapshot = await _firestore.collection('rooms')
        .where('roomCode', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      return RoomModel.fromMap(roomSnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUserOrder(String roomId, List<String> userIds) async {
    DocumentReference roomRef = _firestore.collection('rooms').doc(roomId);
    await roomRef.update({'userIds': userIds});
  }

  Future<QuerySnapshot> getRoomsByAdmin(String adminId) async {
    return await _firestore.collection('rooms')
        .where('adminId', isEqualTo: adminId)
        .get();
  }

  Future<void> deleteRoom(String roomCode) async {
    QuerySnapshot roomSnapshot = await _firestore.collection('rooms')
        .where('roomCode', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      DocumentReference roomRef = _firestore.collection('rooms').doc(roomSnapshot.docs.first.id);
      await roomRef.delete();
    } else {
      throw ArgumentError('Room with code $roomCode does not exist');
    }
  }


  Future<List<UserModelLocation>> getUsersInRoom(String roomId) async {
    DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
    List<String> userIds = List<String>.from(roomDoc['userIds']);

    List<UserModelLocation> users = [];
    for (String userId in userIds) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user_locations').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      users.add(UserModelLocation.fromMap(userData));
    }
    users.sort((a, b) => a.index.compareTo(b.index));
    return users;
  }

  Future<String> joinRoom(String roomId, String userName) async {
    DocumentReference roomRef = _firestore.collection('rooms').doc(roomId);
    DocumentSnapshot roomDoc = await roomRef.get();

    CollectionReference userLocationsRef = _firestore.collection('user_locations');
    DocumentReference userLocationRef = userLocationsRef.doc();


    final locationData = await _locationService.getLocation();
    if (locationData != null) {
      QuerySnapshot userLocationsSnapshot = await userLocationsRef.get();
      int maxIndex = 0;
      for (var doc in userLocationsSnapshot.docs) {
        int currentIndex = doc['index'];
        if (currentIndex > maxIndex) {
          maxIndex = currentIndex;
        }
      }
      int newIndex = maxIndex + 1;

      await userLocationRef.set({
        'name': userName,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'id': userLocationRef.id,
        'index': newIndex,
        'isActive': true,
      });

      String userId = userLocationRef.id;
      List<String> userIds = List<String>.from(roomDoc['userIds']);
      if (!userIds.contains(userId)) {
        userIds.add(userId);
        await roomRef.update({'userIds': userIds});
      }
      return userId;
    } else {
      throw Exception('Unable to obtain location data.');
    }
  }



  Stream<Map<String, dynamic>> getUserLocations(String roomId) async* {
    // Obtener el documento de la sala
    DocumentSnapshot roomDoc = await _firestore.collection('rooms').doc(roomId).get();
    List<String> userIds = List<String>.from(roomDoc['userIds']);
    if (userIds.isEmpty) {
        yield {};
        return;
    }
    // Usar snapshots para observar cambios en la colección user_locations
    yield* _firestore.collection('user_locations')
      .where(FieldPath.documentId, whereIn: userIds)
      .where('isActive', isEqualTo: true)
      .orderBy('index') // Filtrar solo los usuarios en la sala
      .snapshots()
      .map((snapshot) {
        return Map.fromIterable(
          snapshot.docs,
          key: (doc) => doc.id,
          value: (doc) => doc.data(),
        );
      });
  }

  Future<void> removeUserFromRoom(String roomId, String userId) async {
    DocumentReference roomRef = _firestore.collection('rooms').doc(roomId);
    DocumentSnapshot roomDoc = await roomRef.get();

    List<String> userIds = List<String>.from(roomDoc['userIds']);
    userIds.remove(userId);

    await roomRef.update({'userIds': userIds});
    await _firestore.collection('user_locations').doc(userId).delete();
    List<UserModelLocation> users = await getUsersInRoom(roomId);
    _userStreamController.add(users);
  }

  Future<void> toggleUserActivation(String userId) async {
    DocumentReference userRef = _firestore.collection('user_locations').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      bool isActive = userSnapshot['isActive'];
      bool newIsActive = !isActive;
      await userRef.update({'isActive': newIsActive});
    } else {
      print("El documento no existe.");
    }
  }

  Future<void> changeUserIndex(String userId, int newIndex) async {
    DocumentReference userRef = _firestore.collection('user_locations').doc(userId);
    await userRef.update({'index': newIndex});
  }

  void stopListeningToUserLocations() {
    _userLocationsSubscription?.cancel();
  }
}
