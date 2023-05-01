import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; //used to get current date
import 'add.dart';
import 'edit.dart';

class Task {
  final String id;
  final String title;
  bool completed;
  String imageUrl;

  Task({
    String? id,
    required this.title,
    required this.completed,
    required this.imageUrl,
  }) : id = id ?? ''; // Assigns an empty string as the default ID value if null

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    // A factory constructor that takes a map of task properties and an ID as arguments
    return Task(
      id: id,
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    // A method that returns a map of task properties
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'imageUrl': imageUrl,
    };
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userId = user.uid;
    final currentDate = DateTime.now();
    final formatter = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = formatter.format(currentDate);

    final CollectionReference tasks =
        FirebaseFirestore.instance.collection('users/$userId/tasks');

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasks.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Extract the documents from the QuerySnapshot and convert them to Task objects
          final List<Task> taskList = snapshot.data!.docs
              .map((QueryDocumentSnapshot doc) =>
                  Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          // Show the list of tasks in a ListView widget
          return ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (BuildContext context, int index) {
              final Task task = taskList[index];

              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                onDismissed: (_) async {
                  await tasks.doc(task.id).delete();
                },
                child: ListTile(
                  trailing: Checkbox(
                    value: task.completed,
                    onChanged: (bool? value) async {
                      if (value != null) {
                        await tasks.doc(task.id).update({'completed': value});
                      }
                    },
                  ),
                  title: Opacity(
                    opacity: task.completed ? 0.5 : 1.0,
                    child: Text(task.title),
                  ),
                  subtitle: Opacity(
                    opacity: task.completed ? 0.5 : 1.0,
                    child: Text(task.completed ? 'Completed' : 'Incomplete'),
                  ),
                  leading: task.imageUrl.isNotEmpty
                      ? Opacity(
                          opacity: task.completed ? 0.5 : 1.0,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Stack(
                                      children: <Widget>[
                                        SizedBox(
                                          width: double.infinity,
                                          height: 300,
                                          child: Image.network(task.imageUrl),
                                        ),
                                        const Positioned(
                                          top: 0,
                                          right: 0,
                                          child: CloseButton(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(task.imageUrl),
                            ),
                          ),
                        )
                      : const Icon(Icons.image),
                  onTap: () async {
                    final bool completed = !task.completed;
                    await tasks.doc(task.id).update({'completed': completed});
                  },
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          (const EditPage(title: 'Edit Page')),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
