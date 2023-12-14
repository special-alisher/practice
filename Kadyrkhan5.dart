import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

class Task {
  String title;
  String additionalText;
  bool isCompleted;

  Task(this.title, this.additionalText, {this.isCompleted = false});
}

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    tasks[index].isCompleted = !tasks[index].isCompleted;
    notifyListeners();
  }

  void editTask(int index, Task editedTask) {
    tasks[index] = editedTask;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Задачник',
      theme: ThemeData.light(), // Белая тема
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Задачник'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                _showHint(context);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            TaskList(),
            SettingsScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskForm(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _showHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Это подсказка!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                var task = taskProvider.tasks[index];
                return Card(
                  elevation: 3.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.additionalText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                              task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                          onPressed: () {
                            taskProvider.toggleTaskCompletion(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTask(context, taskProvider, index, task);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            taskProvider.removeTask(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _editTask(BuildContext context, TaskProvider taskProvider, int index, Task task) {
    final TextEditingController _editedTitleController = TextEditingController(text: task.title);
    final TextEditingController _editedAdditionalTextController =
    TextEditingController(text: task.additionalText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать задание'),
          content: Column(
            children: [
              TextField(
                controller: _editedTitleController,
                decoration: InputDecoration(labelText: 'Название задание'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _editedAdditionalTextController,
                decoration: InputDecoration(labelText: 'Дополнительный текст'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Task editedTask = Task(
                  _editedTitleController.text,
                  _editedAdditionalTextController.text,
                  isCompleted: task.isCompleted,
                );
                taskProvider.editTask(index, editedTask);
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Здесь находятся настройки'),
      ),
      body: Center(
        child: Text('Здесь будут настройки'),
      ),
    );
  }
}

class AddTaskForm extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _additionalTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить задание'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Название задания'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _additionalTextController,
                  decoration: InputDecoration(labelText: 'Дополнительный текст'),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _addTask(context, taskProvider);
                      },
                      child: Text('Добавить'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addTask(BuildContext context, TaskProvider taskProvider) {
    String title = _titleController.text;
    String additionalText = _additionalTextController.text;

    if (title.isNotEmpty) {
      taskProvider.addTask(Task(title, additionalText));
      Navigator.pop(context);
    } else {
      // Обработка случая, когда название задачи пустое
    }
  }
}
