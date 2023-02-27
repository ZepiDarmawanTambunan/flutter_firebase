import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_v1/ui/auth/login_screen.dart';
import 'package:firebase_v1/ui/firestore/add_firestore_data.dart';
import 'package:firebase_v1/utils/utils.dart';
import 'package:flutter/material.dart';

class FireStoreScreen extends StatefulWidget {
  const FireStoreScreen({Key? key}) : super(key: key);

  @override
  State<FireStoreScreen> createState() => _FireStoreScreenState();
}

class _FireStoreScreenState extends State<FireStoreScreen> {
  final auth = FirebaseAuth.instance;
  final editController = TextEditingController();
  final fireStore = FirebaseFirestore.instance.collection('users').snapshots();
  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // cara melihat email user, boleh di meethod build atau initstate bebas
    // var user = auth.currentUser;
    // inspect(user!.email);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Firestore'),
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
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        StreamBuilder<QuerySnapshot>(
            stream: fireStore,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Text('Ada error!');
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(snapshot.data!.docs[index]['title'].toString()),
                      subtitle:
                          Text(snapshot.data!.docs[index]['id'].toString()),
                      trailing: PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                showMyDialog(
                                    snapshot.data!.docs[index]['title']
                                        .toString(),
                                    snapshot.data!.docs[index]['id']
                                        .toString());
                              },
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                ref
                                    .doc(snapshot.data!.docs[index]['id']
                                        .toString())
                                    .delete()
                                    .then((value) {
                                  Utils().toastMessage(
                                    message: 'Success',
                                    color: Colors.green,
                                  );
                                }).onError((error, stackTrace) {
                                  Utils().toastMessage(
                                    message: error.toString(),
                                    color: Colors.red,
                                  );
                                });
                              },
                              leading: Icon(Icons.delete_outline),
                              title: Text('Hapus'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFirestoreDataScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    editController.text = title;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update'),
            content: Container(
              child: TextField(
                controller: editController,
                decoration: InputDecoration(
                  hintText: 'Edit',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.doc(id).update(
                      {'title': editController.text.toString()}).then((value) {
                    Utils().toastMessage(
                      message: 'Success',
                      color: Colors.green,
                    );
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(
                      message: error.toString(),
                      color: Colors.red,
                    );
                  });
                },
                child: Text('Update'),
              ),
            ],
          );
        });
  }
}
