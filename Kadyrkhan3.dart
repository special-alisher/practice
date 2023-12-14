import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String description;
  bool isCompleted;

  Task(this.description, this.isCompleted);
}

class TaskScheduler {
  List<Task> tasks = [];

  void addTask(String description) {
    tasks.add(Task(description, false));
  }

  void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
    }
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Задачник',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskList(),
    );
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TaskScheduler scheduler = TaskScheduler();
  TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Задачник'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Описание задания'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.brown, // Изменено на коричневый цвет
            ),
            onPressed: () {
              setState(() {
                scheduler.addTask(_taskController.text);
                _taskController.clear();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8.0),
                Text(
                  'Добавить задание',
                  style: TextStyle(color: Colors.white), // Изменено на белый цвет
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scheduler.tasks.length,
              itemBuilder: (context, index) {
                var task = scheduler.tasks[index];
                return Dismissible(
                  key: Key(task.description),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    setState(() {
                      scheduler.removeTask(index);
                    });
                  },
                  child: ListTile(
                    title: Text(task.description),
                    subtitle: Text(task.isCompleted ? 'Выполнено' : 'Не выполнено'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTask(context, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red, // Цвет значка удаления
                          onPressed: () {
                            setState(() {
                              scheduler.removeTask(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, int index) async {
    _taskController.text = scheduler.tasks[index].description;

    String editedTaskDescription = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать задание'),
          content: TextField(
            controller: _taskController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_taskController.text);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (editedTaskDescription != null) {
      setState(() {
        scheduler.tasks[index].description = editedTaskDescription;
      });
    }
  }
}
