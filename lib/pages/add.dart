// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddTaskScreen(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final bool completed;
  final String imageUrl;
  Task({
    String? id,
    required this.title,
    required this.completed,
    required this.imageUrl,
  }) : id = id ?? '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'imageUrl': imageUrl,
    };
  }
}

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  File? _imageFile;

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<String?> _uploadImage(String taskId) async {
    try {
      if (_imageFile != null) {
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String fileName = 'task$taskId.jpg';
        final Reference storageRef = storage
            .refFromURL('gs://learnfirebase-f68f0.appspot.com/')
            .child(fileName);
        final UploadTask uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask;
        final String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          _imageFile = null;
        });
        return downloadUrl;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _addTask() async {
    showDialog(
      context: context,
      builder: (contex) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      final FormState? form = _formKey.currentState;
      if (form != null && form.validate()) {
        form.save();
        final String title = _titleController.text.trim();
        final String taskId = DateTime.now().millisecondsSinceEpoch.toString();
        final String? imageUrl = await _uploadImage(taskId);

        // get the user ID
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid;

        final Task task = Task(
          id: taskId,
          title: title,
          completed: false,
          imageUrl: imageUrl ?? '',
        );
        final CollectionReference userTasks = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('tasks');
        await userTasks.doc(taskId).set(task.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            duration: Duration(seconds: 1),
          ),
        );
        _formKey.currentState?.reset();
        _titleController.clear();
        setState(() {
          _imageFile = null;
        });
        Navigator.pop(context); // navigate back to main screen
      }
      Navigator.pop(context); //to end circular loading indicator
    } catch (e) {
      if (kDebugMode) {
        print('Error adding task: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error adding task'),
        duration: Duration(seconds: 1),
      ));
      Navigator.pop(context); // navigate back to main screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Enter task here...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _getImage,
                    child: const Text('Add photo'),
                  ),
                  if (_imageFile != null) const SizedBox(width: 16.0),
                  if (_imageFile != null)
                    ElevatedButton(
                      onPressed: _removeImage,
                      child: const Icon(Icons.delete),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              _imageFile != null
                  ? Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
