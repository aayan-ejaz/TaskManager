import 'dart:convert';
import 'dart:io';

class Task {
  String title;
  String description;
  bool isCompleted;

  Task(this.title, this.description, {this.isCompleted = false});

  @override
  String toString() {
    return 'Title: $title, Description: $description, Completed: $isCompleted';
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
      };

  Task.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        isCompleted = json['isCompleted'];
}

class TaskManager {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.insert(0, task); 
    print('Task added successfully.');
  }

  void updateTask(int index, Task task) {
    if (index.isNegative || index >= tasks.length) {
      print('Invalid task index.');
      return;
    }
    final existingTask = tasks[index];
    tasks[index] = Task(task.title, task.description,
        isCompleted: existingTask.isCompleted); 
    print('Task updated successfully.');
  }

  void deleteTask(int index) {
    if (index.isNegative || index >= tasks.length) {
      print('Invalid task index.');
      return;
    }
    Task removedTask = tasks.removeAt(index);
    print('Task "${removedTask.title}" deleted successfully.');
  }

  void listTasks() {
    if (tasks.isEmpty) {
      print('No tasks available.');
      return;
    }
    print('\nTasks List:');
    print('-----------------------------------------');
    print('| Index | Title             | Completed |');
    print('-----------------------------------------');
    tasks.asMap().forEach((index, task) {
      print('| ${index.toString().padRight(5)} | ${task.title.padRight(17)} | ${task.isCompleted ? 'Yes' : 'No'.padRight(9)} |');
    });
    print('-----------------------------------------');
  }

  void listCompletedTasks() {
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    if (completedTasks.isEmpty) {
      print('No completed tasks.');
      return;
    }
    print('\nCompleted Tasks:');
    print('-----------------------------------------');
    print('| Index | Title             | Completed |');
    print('-----------------------------------------');
    completedTasks.asMap().forEach((index, task) {
      print('| ${index.toString().padRight(5)} | ${task.title.padRight(17)} | Yes      |');
    });
    print('-----------------------------------------');
  }

  void listIncompleteTasks() {
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    if (incompleteTasks.isEmpty) {
      print('No incomplete tasks.');
      return;
    }
    print('\nIncomplete Tasks:');
    print('-----------------------------------------');
    print('| Index | Title             | Completed |');
    print('-----------------------------------------');
    incompleteTasks.asMap().forEach((index, task) {
      print('| ${index.toString().padRight(5)} | ${task.title.padRight(17)} | No       |');
    });
    print('-----------------------------------------');
  }

  void toggleTaskCompletion(int index) {
    if (index.isNegative || index >= tasks.length) {
      print('Invalid task index.');
      return;
    }
    tasks[index].isCompleted = !tasks[index].isCompleted; 
    print('Task completion status toggled.');
  }


  Future<void> saveTasks() async {
    final file = File('tasks.json');
    final jsonData = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await file.writeAsString(jsonData);
    print('Tasks saved to tasks.json');
  }


  Future<void> loadTasks() async {
    final file = File('tasks.json');
    if (await file.exists()) {
      final jsonData = await file.readAsString();
      final List<dynamic> taskList = jsonDecode(jsonData);
      tasks = taskList.map((json) => Task.fromJson(json)).toList();
      print('Tasks loaded from tasks.json');
    } else {
      print('No saved tasks found.');
    }
  }
}

void displayMenu() {
  print('\nTask Manager Menu:');
  print('-----------------------------------------');
  print('| Option | Action                     |');
  print('-----------------------------------------');
  print('| 1      | Add a new task             |');
  print('| 2      | Update a task              |');
  print('| 3      | Delete a task              |');
  print('| 4      | List all tasks             |');
  print('| 5      | List completed tasks       |');
  print('| 6      | List incomplete tasks      |');
  print('| 7      | Toggle task completion      |');
  print('| 8      | Save tasks to file         |');
  print('| 0      | Exit                       |');
  print('-----------------------------------------');
}

void main() async {
  TaskManager taskManager = TaskManager();

  await taskManager.loadTasks();

  while (true) {
    displayMenu();
    stdout.write('Choose an option: ');
    String? choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        stdout.write('Enter task title: ');
        String title = stdin.readLineSync() ?? '';
        stdout.write('Enter task description: ');
        String description = stdin.readLineSync() ?? '';
        taskManager.addTask(Task(title, description));
        break;

      case '2':
        stdout.write('Enter task index to update: ');
        int index = int.parse(stdin.readLineSync() ?? '-1');
        if (index.isNegative || index >= taskManager.tasks.length) {
          print('Invalid index');
          continue;
        }
        stdout.write('Enter new task title: ');
        String newTitle = stdin.readLineSync() ?? '';
        stdout.write('Enter new task description: ');
        String newDescription = stdin.readLineSync() ?? '';
        taskManager.updateTask(index, Task(newTitle, newDescription));
        break;

      case '3':
        stdout.write('Enter task index to delete: ');
        int index = int.parse(stdin.readLineSync() ?? '-1');
        taskManager.deleteTask(index);
        break;

      case '4':
        taskManager.listTasks();
        break;

      case '5':
        taskManager.listCompletedTasks();
        break;

      case '6':
        taskManager.listIncompleteTasks();
        break;

      case '7':
        stdout.write('Enter task index to toggle completion: ');
        int index = int.parse(stdin.readLineSync() ?? '-1');
        taskManager.toggleTaskCompletion(index);
        break;

      case '8':
        await taskManager.saveTasks();
        break;

      case '0':
        print('Exiting!!!');
        return;

      default:
        print('Invalid option, please try again.');
        break;
    }
  }
}

