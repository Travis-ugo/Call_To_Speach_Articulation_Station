import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'authentication/database.dart';

class GoogleSign extends StatelessWidget {
  const GoogleSign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Testing Google signIn'),
            const Text('Try and erro block'),
            ElevatedButton.icon(
              onPressed: () {
                final provider =
                    Provider.of<FireBaseAuthService>(context, listen: false);
                provider.googleLogin();
              },
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.red,
              ),
              label: const Text('Google sign in'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 50),
                primary: Colors.grey[800],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // final provider =
                //     Provider.of<FireBaseAuthService>(context, listen: false);
                // provider.signInWithApple();
              },
              icon: const FaIcon(
                FontAwesomeIcons.apple,
                color: Colors.black54,
              ),
              label: const Text(
                'Apple sign in',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 50),
                primary: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FireBaseAuthService extends ChangeNotifier {
  // Trigger the authentication flow
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth!.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // check for existing Email and password
  Future<void> verifyEmail(
    void Function() displayDialogueBox,
    String email,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (!methods.contains('password')) {
        displayDialogueBox();
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  Future usersData(String name, String datatext) async {
    final brewCollection = FirebaseFirestore.instance.collection('users');
    final fuser = FirebaseAuth.instance;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss  EEE d MMM').format(now);
    return await brewCollection.doc(fuser.currentUser!.uid).set({
      'Name': name,
      'Datatext': datatext,
      'timestamp': formattedDate,
    });
  }

  Future studentsData(
    String name,
    String email,
    /*String birthDay, String notes*/
  ) async {
    final rewCollection = FirebaseFirestore.instance.collection('peter');
    final fuser = FirebaseAuth.instance;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss  EEE d MMM').format(now);
    return await rewCollection
        .doc(fuser.currentUser!.uid)
        .collection('students')
        .add(<String, dynamic>{
      'name': name,
      'timestamp': formattedDate,
      'email': email,
      // 'birthDay': birthDay,
      // 'note': notes,
      'userId': FirebaseAuth.instance.currentUser!.uid.toUpperCase(),
    });
  }

  // Register user Email and Password
  Future<void> registerAccount({
    required String email,
    required String displayName,
    required String password,
  }) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      var user = credential.user;
      await credential.user!.updateDisplayName(displayName);
      await DataBaseService(uid: user!.uid)
          .upDateData(displayName, 'photo Url');
      // await credential.user!.updatePhotoURL(photoURL);`
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // log user out
  Future logOut() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}

class LoggedIn extends StatelessWidget {
  const LoggedIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
        actions: [
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<FireBaseAuthService>(context, listen: false);
              provider.logOut();
            },
            child: const Text(
              'log Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            // TextButton(
            //   onPressed: () {},
            //   child: Text(user!.displayName ?? ''),
            // ),
            // CircleAvatar(
            //   backgroundImage: NetworkImage(user.photoURL ?? ''),
            // ),
            // const SizedBox(),
            // Text(user.phoneNumber.toString()),
            // Text(user.displayName ?? ''),
            // Text(user.email!),
          ],
        ),
      ),
    );
  }
}
