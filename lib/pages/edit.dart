import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'home_page.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;
  bool _completed = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _imageUrlController = TextEditingController(text: widget.task.imageUrl);
    _completed = widget.task.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
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
                  labelText: 'Enter a Task Name',
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
                    child: const Text('Take New Image'),
                  ),
                  if (_imageFile != null || widget.task.imageUrl.isNotEmpty)
                    const SizedBox(width: 16.0),
                  if (_imageFile != null || widget.task.imageUrl.isNotEmpty)
                    ElevatedButton(
                      child: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _removeImage();
                          _imageFile = null;
                          _imageUrlController.text = '';
                        });
                      },
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
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        final firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;
        final String fileName = 'task$taskId.jpg';
        final firebase_storage.Reference storageRef = storage
            .refFromURL('gs://learnfirebase-f68f0.appspot.com/')
            .child(fileName);
        final firebase_storage.UploadTask uploadTask =
            storageRef.putFile(_imageFile!);
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

  void _removeImage() async {
    try {
      final firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      final String fileName = 'task${widget.task.id}.jpg';
      final firebase_storage.Reference storageRef = storage
          .refFromURL('gs://learnfirebase-f68f0.appspot.com/')
          .child(fileName);

      // Delete the image file from Firebase Storage
      await storageRef.delete();

      // Update the task's imageUrl field to an empty string
      final taskDocSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task.id)
          .get();
      await taskDocSnapshot.reference.update({'imageUrl': ''});

      setState(() {
        widget.task.imageUrl = '';
        _imageFile = null;
      });

      if (kDebugMode) {
        print('Image removed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing image: $e');
      }
    }
  }

  void _saveChanges() async {
    showDialog(
      context: context,
      builder: (contex) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      final firestore = FirebaseFirestore.instance;
      final documentReference = firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(widget.task.id);

      final title = _titleController.text;
      final completed = _completed;

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(widget.task.id);
      } else if (_imageUrlController.text.isNotEmpty) {
        imageUrl = _imageUrlController.text;
      }

      final updatedTask = Task(
        id: widget.task.id,
        title: title,
        imageUrl: imageUrl ?? '',
        completed: completed,
      );

      await documentReference.set(updatedTask.toMap());
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task edited successfully!'),
      ));
      // ignore: use_build_context_synchronously
      Navigator.pop(context, updatedTask);
      // ignore: use_build_context_synchronously
      Navigator.pop(context); //to end circular loading indicator
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error editing task'),
      ));
      Navigator.pop(context); // navigate back to main screen
    }
  }
}
