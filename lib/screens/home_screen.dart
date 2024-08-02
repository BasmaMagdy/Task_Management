import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _taskController;
  List<Task> _tasks = []; // Initialize to an empty list
  List<bool> _tasksDone = []; // Initialize to an empty list

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();

    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose(); // Call dispose with parentheses
    super.dispose();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String? tasks = prefs.getString('task');
    List<dynamic> list = (tasks == null) ? [] : json.decode(tasks);
    list.add(json.encode(t.getMap()));
    await prefs.setString('task', json.encode(list));
    setState(() {
      _taskController.text = '';
    });
    Navigator.of(context).pop();

    _getTasks();
  }

  Future<void> updatePendingTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++) {
      if (!_tasksDone[i]) {
        pendingList.add(_tasks[i]);
      }
    }

    List<String> pendingListEncoded =
        pendingList.map((task) => json.encode(task.getMap())).toList();

    await prefs.setString('task', json.encode(pendingListEncoded));

    _getTasks(); // Refresh the task list
  }

  Future<void> _getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('task');
    List<dynamic> list = (tasks == null) ? [] : json.decode(tasks);
    List<Task> loadedTasks = [];
    List<bool> doneTasks = [];
    for (dynamic d in list) {
      loadedTasks.add(Task.fromMap(json.decode(d)));
      doneTasks.add(false); // Initialize done status for each task
    }

    setState(() {
      _tasks = loadedTasks;
      _tasksDone = doneTasks; // Set done status list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updatePendingTasksList, // Fix this line
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('task', json.encode([]));

                _getTasks();
              })
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks added yet'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, index) => Container(
                height: 70.0,
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                padding: const EdgeInsets.only(left: 10.0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tasks[index].task,
                      style: GoogleFonts.montserrat(),
                    ),
                    Checkbox(
                      value: _tasksDone[index],
                      onChanged: (val) {
                        setState(() {
                          _tasksDone[index] = val ?? false;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: 250.0,
            color: Colors.blue[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Task',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    )
                  ],
                ),
                const Divider(thickness: 1.2),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter Task',
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.symmetric(horizontal: 50.0),
                        width: (MediaQuery.of(context).size.width / 5) - 43,
                        child: ElevatedButton(
                          child: Text(
                            'RESET',
                            style: GoogleFonts.montserrat(),
                          ),
                          onPressed: () => _taskController.clear(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        width: (MediaQuery.of(context).size.width / 5) - 43,
                        child: ElevatedButton(
                          child: Text(
                            'ADD',
                            style: GoogleFonts.montserrat(),
                          ),
                          onPressed: () => saveData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
