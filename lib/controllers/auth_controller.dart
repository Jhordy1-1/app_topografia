import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> registerAdmin(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = userCredential.user;

    await _firestore.collection('users').doc(user?.uid).set({
      'uid': user?.uid,
      'email': email,
      'role': 'admin',
    });

    return UserModel(uid: user?.uid as String, email: email, role: 'admin');
  }

  Future<UserModel> login(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = userCredential.user;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user?.uid).get();
    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    }
    throw Exception('No user is signed in.');
  }

}
