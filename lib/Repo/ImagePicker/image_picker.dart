import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? file;
  UploadTask? task;
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? file!.path : 'No file selected';
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: const Text('Firebase project'),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 250),
            button(onTap: () => selectFile(), text: 'Select File'),
            const SizedBox(height: 20),
            Text(
              fileName,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 35),
            button(onTap: () => uploadFile(), text: 'Uplooad File'),
            const SizedBox(height: 20),
            task != null
                ? buildUploadStatus(task!)
                : const Text(
                    'No File to upload',
                    style: TextStyle(color: Colors.white),
                  ),

                 const SizedBox(height: 300),
          ],
        )),
      ),
    );
  }

  Widget button({required String text, required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.purpleAccent,
            borderRadius: BorderRadius.circular(20)),
        height: 50,
        width: 350,
        child: Center(
            child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        )),
      ),
    );
  }

  Future selectFile() async {
    final results = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (results == null) return;
    final path = results.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = file!.path;
    final destination = "Files/$fileName";

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;
    final snapShot = await task!.whenComplete(() => null);
    final urlDownload = await snapShot.ref.getDownloadURL();
    print('url of this file is: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) =>
      StreamBuilder<TaskSnapshot>(builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data!;
          final progress = snap.bytesTransferred / snap.totalBytes;
          final percentage = (progress * 100).toStringAsFixed(2);

          return Text(
            percentage.toString(),
            style: const TextStyle(color: Colors.white),
          );
        } else {
          return const Text(
            'No File to upload',
            style: TextStyle(color: Colors.white),
          );
        }
      });
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
