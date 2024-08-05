class RoomModel {
  final String id;
  final String name;
  final List<String> userIds;
  final String adminId;
  final String roomCode;  // Campo agregado

  RoomModel({required this.id, required this.name, required this.userIds, required this.adminId, required this.roomCode});

  factory RoomModel.fromMap(Map<String, dynamic> data) {
    return RoomModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      userIds: List<String>.from(data['userIds'] ?? []),
      adminId: data['adminId'] ?? '',
      roomCode: data['roomCode'] ?? '',  // Campo agregado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userIds': userIds,
      'adminId': adminId,
      'roomCode': roomCode,  // Campo agregado
    };
  }
}
