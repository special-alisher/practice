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
      title: 'Планировщик задач',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TaskScheduler scheduler = TaskScheduler();
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Планировщик задач'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TaskList(scheduler: scheduler, taskController: _taskController),
            SettingsScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Всплывающая подсказка при нажатии кнопки "Подсказка"
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Это подсказка!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Icon(Icons.help),
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final TaskScheduler scheduler;
  final TextEditingController taskController;

  TaskList({required this.scheduler, required this.taskController});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: widget.taskController,
            decoration: InputDecoration(labelText: 'Описание задачи'),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.brown, // Изменено на коричневый цвет
          ),
          onPressed: () {
            setState(() {
              widget.scheduler.addTask(widget.taskController.text);
              widget.taskController.clear();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8.0),
              Text(
                'Добавить задачу',
                style: TextStyle(color: Colors.white), // Изменено на белый цвет
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.scheduler.tasks.length,
            itemBuilder: (context, index) {
              var task = widget.scheduler.tasks[index];
              return Dismissible(
                key: Key(task.description),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  setState(() {
                    widget.scheduler.removeTask(index);
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
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            widget.scheduler.toggleTaskCompletion(index);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red, // Цвет значка удаления
                        onPressed: () {
                          setState(() {
                            widget.scheduler.removeTask(index);
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
    );
  }

  void _editTask(BuildContext context, int index) async {
    widget.taskController.text = widget.scheduler.tasks[index].description;

    String editedTaskDescription = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать задачу'),
          content: TextField(
            controller: widget.taskController,
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
                Navigator.of(context).pop(widget.taskController.text);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (editedTaskDescription != null) {
      setState(() {
        widget.scheduler.tasks[index].description = editedTaskDescription;
      });
    }
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Здесь находятся настройки'),
    );
  }
}
