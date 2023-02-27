import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_v1/ui/auth/login_screen.dart';
import 'package:firebase_v1/ui/posts/add_post.dart';
import 'package:firebase_v1/utils/utils.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref('Post');
  final searchFilter = TextEditingController();
  final editController = TextEditingController();

  // kalau pakai stream builder dia pakai initstate
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
    print(auth.currentUser?.email);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Post'),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextFormField(
            controller: searchFilter,
            decoration: InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),

        // ada 2 cara fetch data pakai stream builder
        // Expanded(
        //   child: StreamBuilder(
        //     stream: db.onValue,
        //     builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        //       Map<dynamic, dynamic> map =
        //           snapshot.data!.snapshot.value as dynamic;
        //       List<dynamic> list = [];
        //       list.clear();
        //       list = map.values.toList();
        //       if (!snapshot.hasData) {
        //         return CircularProgressIndicator(
        //           strokeWidth: 3,
        //           color: Colors.blueAccent,
        //         );
        //       } else {
        //         return ListView.builder(
        //           itemCount: snapshot.data!.snapshot.children.length,
        //           itemBuilder: (context, index) {
        //             return ListTile(
        //               title: Text(list[index]['title']),
        //               subtitle: Text(list[index]['title']),
        //             );
        //           },
        //         );
        //       }
        //     },
        //   ),
        // ),
        // ada 2 cara fetch data pakai firebase animated list
        Expanded(
          child: FirebaseAnimatedList(
            query: db,
            defaultChild: Text('Loading'),
            itemBuilder: (context, snapshot, animation, index) {
              final title = snapshot.child('title').value.toString();

              if (searchFilter.text.isEmpty) {
                return ListTile(
                  title: Text(title),
                  subtitle: Text(snapshot.child('id').value.toString()),
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
                                title, snapshot.child('id').value.toString());
                          },
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Hapus'),
                          onTap: () {
                            Navigator.pop(context);
                            db
                                .child(snapshot.child('id').value.toString())
                                .remove()
                                .then((value) {
                              Utils().toastMessage(
                                  message: 'success', color: Colors.green);
                            }).onError((error, stackTrace) {
                              Utils().toastMessage(message: error.toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (title
                  .toLowerCase()
                  .contains(searchFilter.text.toLowerCase().toString())) {
                return ListTile(
                  title: Text(title),
                  subtitle: Text(snapshot.child('id').value.toString()),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(),
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
                  db.child(id).update({
                    'title': editController.text.toLowerCase()
                  }).then((value) {
                    Utils()
                        .toastMessage(message: 'success', color: Colors.green);
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(message: error.toString());
                  });
                },
                child: Text('Update'),
              ),
            ],
          );
        });
  }
}
