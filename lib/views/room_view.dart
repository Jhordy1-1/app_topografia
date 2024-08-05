import 'dart:async';
import 'package:app_topografia/models/user_location_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import '../controllers/room_controller.dart';
import '../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geodesy/geodesy.dart' as geodesy;
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

class RoomView extends StatefulWidget {
  final String roomId;
  final bool isAdmin;
  final String userId;
  final String roomName;

  RoomView(
      {required this.roomId,
      required this.roomName,
      this.isAdmin = false,
      this.userId = ''});

  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final RoomController _roomController = RoomController();
  final LocationService _locationService = LocationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleMapController? _mapController;
  Map<String, Marker> _userMarkers = {};
  List<UserModelLocation> _users = [];
  StreamSubscription<LocationData>? _locationStreamSubscription;
  List<geodesy.LatLng> _polygonVertices = [];
  Polygon? _polygon;

  final geodesy.Geodesy geodesyInstance =
      geodesy.Geodesy(); // Instancia de Geodesy
  final geodesy.Distance distance = new geodesy.Distance();

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código de sala copiado!')),
      );
    }
  }

  void _updateUserMarkers(Map<String, dynamic> userLocations) {
    final newMarkers = <String, Marker>{};
    _polygonVertices.clear(); // Limpiar vértices del polígono

    int index = 1;
    userLocations.forEach((userId, locationData) {
      final position =
          geodesy.LatLng(locationData['latitude'], locationData['longitude']);
      newMarkers[userId] = Marker(
        markerId: MarkerId(userId),
        position: LatLng(locationData['latitude'], locationData['longitude']),
        infoWindow: InfoWindow(
          title: locationData['name'],
          snippet: 'Topólogo $index',
        ),
      );

      _polygonVertices.add(position); // Agregar posición al polígono
      index++;
    });

    if (_polygonVertices.length > 2) {
      _polygon = Polygon(
        polygonId: PolygonId('userPolygon'),
        points: _polygonVertices
            .map((v) => LatLng(v.latitude, v.longitude))
            .toList(),
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
      );
    } else {
      _polygon = null;
    }

    if (mounted) {
      setState(() {
        _userMarkers = newMarkers;
      });
    }
  }

  void _centerMapOnUser(LocationData locationData) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isAdmin) {
      _locationService.updateUserLocation(widget.userId).then((_) {
        _locationService.getLocation().then((locationData) {
          if (locationData != null) {
            _centerMapOnUser(locationData);
          }
        });
      });

      _locationStreamSubscription =
          _locationService.getLocationStream().listen((locationData) {
        _locationService.updateUserLocation(widget.userId).catchError((error) {
          print('Error updating user location: $error');
        });
      });
    }

    _roomController.getUsersInRoom(widget.roomId).then((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    });

    _roomController.getUserLocations(widget.roomId).listen((userLocations) {
      _updateUserMarkers(userLocations);
    });

    _roomController.userStream.listen((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    });
  }

  @override
  void dispose() {
    if (!widget.isAdmin) {
      _locationStreamSubscription?.cancel();
    }
    _roomController.stopListeningToUserLocations();
    super.dispose();
  }

  void _leaveRoom() async {
    if (!widget.isAdmin) {
      await _roomController.removeUserFromRoom(widget.roomId, widget.userId);
    } else {
      await _auth.signOut();
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
  }

  void _toggleUserActivation(String userId) async {
    await _roomController.toggleUserActivation(userId);
  }

  void _removeUser(String roomId, String userId) async {
    await _roomController.removeUserFromRoom(roomId, userId);
  }

  List<DropdownMenuItem<int>> _buildDropdownMenuItems(int currentIndex) {
    return List<DropdownMenuItem<int>>.generate(_users.length, (index) {
      final user = _users[index];
      return DropdownMenuItem(
        value: index,
        child: Text(user.name),
      );
    });
  }

  void _changeUserIndex(String userId, int newIndex) async {
    final oldIndex = _users.indexWhere((user) => user.id == userId);
    if (oldIndex != -1) {
      final movedUser = _users.removeAt(oldIndex);
      _users.insert(newIndex, movedUser);

      for (int i = 0; i < _users.length; i++) {
        await _roomController.changeUserIndex(_users[i].id, i);
      }

      setState(() {});
    }
  }

  maps_toolkit.LatLng convertToMapsToolkitLatLng(geodesy.LatLng latLng) {
    return maps_toolkit.LatLng(latLng.latitude, latLng.longitude);
  }

  String _calculatePolygonArea(List<geodesy.LatLng> vertices) {
    if (vertices.length < 3) return "0.0 m²";

    // Convertir a LatLng de maps_toolkit
    final toolkitVertices =
        vertices.map((v) => maps_toolkit.LatLng(v.latitude, v.longitude)).toList();
    
    num areaMeters = maps_toolkit.SphericalUtil.computeArea(toolkitVertices);
    if (areaMeters > 10000) {
      double areaKm = areaMeters / 1000000;
      return "${areaKm.toStringAsFixed(2)} km²";
    } else {
      return "${areaMeters.toStringAsFixed(2)} m²";
    }
  }

  String _calculatePolygonPerimeter(List<geodesy.LatLng> vertices) {
    double perimeterMeters = 0.0;
    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];
      perimeterMeters += distance(p1, p2);
    }

    if (perimeterMeters > 10000) {
      double perimeterKm = perimeterMeters / 1000;
      return "${perimeterKm.toStringAsFixed(2)} km";
    } else {
      return "${perimeterMeters.toStringAsFixed(2)} m";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7E8D8),
      appBar: AppBar(
        backgroundColor: Color(0xFFE7E8D8),
        title: Text('Sala ${widget.roomName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF508D4E),
            )),
        leading: widget.isAdmin ? null : Container(),
        actions: widget.isAdmin
            ? []
            : [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  color: Color(0xFF1A5319),
                  onPressed: _leaveRoom,
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: widget.isAdmin ? 1 : 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-0.2104, -78.4898),
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _userMarkers.values.toSet(),
              polygons: _polygon != null ? Set.from([_polygon!]) : Set(),
            ),
          ),
          if (widget.isAdmin)
          SizedBox(height: 5),
          if (widget.isAdmin)
            Expanded(
              flex: 1,
              child: ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (context, index) => Divider(
                  color: Color(0xFFB5CFB7),
                  thickness: 1,
                  height: 5,
                ),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    key: ValueKey(user.id),
                    color: Color(0xFFE7E8D8),
                    elevation:0,
                    child: ListTile(
                      title: Text(user.name,
                          style: TextStyle(color: Color(0xFF1A5319))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: index,
                            items: _buildDropdownMenuItems(index),
                            onChanged: (newIndex) {
                              if (newIndex != null && newIndex != index) {
                                _changeUserIndex(user.id, newIndex);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.toggle_on),
                            color: Color(0xFF1A5319),
                            onPressed: () {
                              _toggleUserActivation(user.id);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Color(0xFF1A5319),
                            onPressed: () {
                              _removeUser(widget.roomId, user.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF606676),
        onPressed: () {
          if (_polygonVertices.length > 2) {
            final area = _calculatePolygonArea(_polygonVertices);
            final perimeter = _calculatePolygonPerimeter(_polygonVertices);

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Color(0xFFE7E8D8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Borde redondeado
                ),
                title: Text(
                  'Métricas',
                  style: TextStyle(
                    color: Color(0xFF508D4E), // Color de texto del título
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Área: ${area} \nPerímetro: ${perimeter}',
                  style: TextStyle(
                    color: Color(0xFF1A5319), // Color de texto del contenido
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK',
                        style: TextStyle(
                          color: Color(0xFF508D4E), // Color del texto del botón
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            );
          }
        },
        child: Icon(Icons.calculate, color: Color(0xFFFEF3E2)),
        tooltip: 'Calcular área y perímetro',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
