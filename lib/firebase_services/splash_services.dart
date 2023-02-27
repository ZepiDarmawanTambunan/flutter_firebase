import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_v1/ui/auth/login_screen.dart';
import 'package:firebase_v1/ui/firestore/firestore_list_screen.dart';
import 'package:firebase_v1/ui/posts/post_screen.dart';
import 'package:firebase_v1/ui/upload_image.dart';
import 'package:flutter/material.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if (user != null) {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => const UploadImageScreen()),
          // MaterialPageRoute(builder: (context) => const FireStoreScreen()),
          MaterialPageRoute(builder: (context) => const PostScreen()),
        ),
      );
    } else {
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen())));
    }
  }
}
