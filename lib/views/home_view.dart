import 'package:app_topografia/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa para usar el portapapeles
import '../controllers/auth_controller.dart';
import '../controllers/room_controller.dart';
import '../models/room_model.dart';
import 'room_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController _authController = AuthController();
  final RoomController _roomController = RoomController();
  String roomName = '';
  List<RoomModel> _rooms = [];
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAdminId() async {
    UserModel currentUser = await _authController.getCurrentUser();
    _adminId = currentUser.uid;
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (_adminId == null) return;

    _showLoadingDialog();
    QuerySnapshot roomSnapshot =
        await _roomController.getRoomsByAdmin(_adminId!);
    List<RoomModel> rooms = roomSnapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    _hideLoadingDialog();

    if (mounted) {
      setState(() {
        _rooms = rooms;
      });
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room code copied to clipboard!')),
      );
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Color(0xFFE7E8D8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        borderSide: BorderSide(color: Color(0xFF1A5319)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        borderSide: BorderSide(color: Color(0xFF1A5319)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        borderSide: BorderSide(color: Color(0xFF1A5319)),
      ),
      labelStyle: TextStyle(color: Color(0xFF508D4E)),
    );
  }

  TextField _buildTextField(String labelText, ValueChanged<String> onChanged,
      {bool obscureText = false}) {
    return TextField(
      onChanged: onChanged,
      decoration: _inputDecoration(labelText),
      style: TextStyle(color: Color(0xFF1A5319)),
      obscureText: obscureText,
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(color: Color(0xFF508D4E)),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7E8D8),
      appBar: AppBar(
        backgroundColor: Color(0xFFE7E8D8),
        title: Text('Panel de Administrador',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF508D4E),
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xFF1A5319),
            onPressed: () async {
              await _authController.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildTextField('Nombre de la sala', (value) {
                        setState(() {
                          roomName = value;
                        });
                      }),
                    ),
                    SizedBox(width: 0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_adminId != null) {
                          _showLoadingDialog();
                          try {
                            RoomModel room = await _roomController.createRoom(
                                roomName, _adminId!);
                            _loadRooms(); // Recargar la lista de salas
                          } catch (e) {
                            print(e);
                          } finally {
                            _hideLoadingDialog();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF508D4E),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                      ),
                      child: Text(
                        'Crear Sala',
                        style: TextStyle(
                            color: Color(0xFFE7E8D8),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: _rooms.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Color(0xFF508D4E), // Color del separador
                      thickness: 1,
                      height: 20, // Espacio alrededor del separador
                    ),
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return ListTile(
                        title: Text(
                          room.name,
                          style: TextStyle(
                              color: Color(0xFF1A5319)), // Color del texto
                        ),
                        subtitle: Text(
                          'Code: ${room.roomCode}',
                          style: TextStyle(
                              color: Color(0xFF1A5319)), // Color del texto
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(room.roomCode),
                              color: Color(0xFF1A5319), // Color del icono
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                if (_adminId != null) {
                                  _showLoadingDialog();
                                  try {
                                    await _roomController.deleteRoom(room.roomCode); // Usa el código de la sala
                                    _loadRooms(); // Recargar la lista de salas
                                  } catch (e) {
                                    print(e);
                                  } finally {
                                    _hideLoadingDialog();
                                  }
                                }
                              },
                              color: Color(0xFF1A5319), // Color del icono
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomView(
                                roomId: room.id,
                                roomName: room.name,
                                isAdmin: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
