import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/room_controller.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../views/room_view.dart';

class AuthView extends StatefulWidget {
  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final AuthController _authController = AuthController();
  final RoomController _roomController = RoomController();
  String email = '';
  String password = '';
  String role = 'Topólogo';
  String name = '';
  String roomCode = '';

  void _clearInputs() {
    setState(() {
      email = '';
      password = '';
      name = '';
      roomCode = '';
    });
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Color(0xFFE7E8D8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF1A5319)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF1A5319)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
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
          child: CircularProgressIndicator(color:Color(0xFF508D4E)),
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF508D4E),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: role,
                    onChanged: (String? newValue) {
                      setState(() {
                        role = newValue!;
                        _clearInputs();
                      });
                    },
                    items: <String>['Administrador', 'Topólogo']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Color(0xFF1A5319)),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                    decoration: _inputDecoration('Rol'),
                    style: TextStyle(color: Color(0xFF1A5319)),
                  ),
                  SizedBox(height: 20),
                  if (role == 'Administrador') ...[
                    _buildTextField('Email', (value) {
                      setState(() {
                        email = value;
                      });
                    }),
                    SizedBox(height: 20),
                    _buildTextField('Contraseña', (value) {
                      setState(() {
                        password = value;
                      });
                    }, obscureText: true),
                  ] else ...[
                    _buildTextField('Nombre', (value) {
                      setState(() {
                        name = value;
                      });
                    }),
                    SizedBox(height: 20),
                    _buildTextField('Código de sala', (value) {
                      setState(() {
                        roomCode = value;
                      });
                    }),
                  ],
                  SizedBox(height: 20),
                  if (role == 'Administrador')
                    TextButton(
                      onPressed: () async {
                        _showLoadingDialog();
                        try {
                          UserModel user =
                              await _authController.login(email, password);
                          _hideLoadingDialog();
                          Navigator.pushReplacementNamed(context, '/home');
                        } catch (e) {
                          _hideLoadingDialog();
                          print(e);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFF508D4E)),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      child: Text(
                        'Ingresar',
                        style: TextStyle(
                            color: Color(0xFFE7E8D8),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      _showLoadingDialog();
                      try {
                        if (role == 'Administrador') {
                          UserModel user = await _authController.registerAdmin(
                              email, password);
                          _hideLoadingDialog();
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          RoomModel? room =
                              await _roomController.getRoomByCode(roomCode);
                          if (room != null) {
                            String userId =
                                await _roomController.joinRoom(room.id, name);
                            _hideLoadingDialog();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomView(
                                  roomId: room.id,
                                  roomName: room.name,
                                  userId: userId,
                                ),
                              ),
                            );
                          } else {
                            _hideLoadingDialog();
                            print('Room not found');
                          }
                        }
                      } catch (e) {
                        _hideLoadingDialog();
                        print(e);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:role == 'Administrador' ? Color(0xFFE7E8D8):Color(0xFF508D4E),
                      elevation: role == 'Administrador' ? 0 : 2,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      role == 'Administrador'
                          ? 'Registrate'
                          : 'Ingresar a la sala',
                      style: TextStyle(
                          color: role == 'Administrador' ? Color(0xFF508D4E):Color(0xFFE7E8D8),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
