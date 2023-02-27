import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_v1/ui/auth/login_screen.dart';
import 'package:firebase_v1/utils/utils.dart';
import 'package:firebase_v1/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final auth = FirebaseAuth.instance;
  bool loading = false;
  File? _image;
  final picker = ImagePicker();

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  DatabaseReference db = FirebaseDatabase.instance.ref('Post');

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image picked');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Upload image'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }).onError((error, stackTrace) {
                Utils().toastMessage(
                  message: error.toString(),
                  color: Colors.red,
                );
              });
            },
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  getImageGallery();
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: _image != null
                      ? Image.file(_image!.absolute)
                      : Center(
                          child: Icon(Icons.image),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            RoundButton(
                title: 'Upload',
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  firebase_storage.Reference ref =
                      firebase_storage.FirebaseStorage.instance.ref('/images/' +
                          DateTime.now().millisecondsSinceEpoch.toString());
                  firebase_storage.UploadTask uploadTask =
                      ref.putFile(_image!.absolute);

                  Future.value(uploadTask).then((value) async {
                    var newURL = await ref.getDownloadURL();

                    db.child('1').set({
                      'id': '12324',
                      'title': newURL.toString(),
                    }).then((value) {
                      setState(() {
                        loading = false;
                      });

                      Utils().toastMessage(
                        message: 'Success',
                        color: Colors.green,
                      );
                    }).onError((error, stackTrace) {
                      setState(() {
                        loading = false;
                      });

                      Utils().toastMessage(
                        message: error.toString(),
                        color: Colors.red,
                      );
                    });
                  }).onError((error, stackTrace) {
                    setState(() {
                      loading = false;
                    });

                    Utils().toastMessage(
                      message: error.toString(),
                      color: Colors.red,
                    );
                  });
                },
                loading: loading),
          ],
        ),
      ),
    );
  }
}
