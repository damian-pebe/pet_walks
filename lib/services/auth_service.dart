import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:petwalks_app/services/firebase_services.dart';
import 'dart:convert';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> logInGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      final userCredential = await _auth.signInWithCredential(cred);

      // hacer la peticion de http para la demas informacion
      final response = await http.get(
        Uri.parse(
            'https://people.googleapis.com/v1/people/me?personFields=names,phoneNumbers,addresses'),
        headers: await googleUser!.authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final name = data['names']?[0]?['displayName'];
        final phoneNumber = data['phoneNumbers']?[0]?['value'];
        final address = data['addresses']?[0]?['formattedValue'];

        await newUser(name, googleUser.email, phoneNumber, address);
      } else {
        print('Failed to fetch user data: ${response.body}');
      }

      return userCredential;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Algo salio mal');
    }
  }
}
