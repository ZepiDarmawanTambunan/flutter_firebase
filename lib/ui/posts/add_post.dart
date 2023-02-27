import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_v1/utils/utils.dart';
import 'package:firebase_v1/widgets/round_button.dart';
import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool loading = false;
  final db = FirebaseDatabase.instance.ref('Post');
  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TextFormField(
              maxLines: 4,
              controller: postController,
              decoration: InputDecoration(
                hintText: 'What is your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            RoundButton(
              title: 'Add',
              loading: loading,
              onTap: () {
                setState(() {
                  loading = true;
                });
                String id = DateTime.now().millisecondsSinceEpoch.toString();
                db.child(id).set({
                  'title': postController.text.toString(),
                  'id': id,
                }).then((value) {
                  setState(() {
                    loading = false;
                  });
                  Utils().toastMessage(
                    message: 'Success',
                    color: Colors.green,
                  );
                }).onError((error, stackTrace) {
                  Utils().toastMessage(
                    message: error.toString(),
                    color: Colors.red,
                  );
                  setState(() {
                    loading = false;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
