import 'package:task_manager/services/task_service.dart';
import 'package:test/test.dart';
import 'package:task_manager/models/task.dart';
void main() {
  group('Task Model — Constructor & Properties', () {
    late Task task;
    setUp(() {
      task = Task(
        id: '1',
        title: 'This is a task',
        description: 'This is a task description',
        priority: Priority.low,
        dueDate: DateTime(2026, 3, 20),
        isCompleted: true,
      );
    });

    test('returns the default values', () {
        expect([
          task.description,
          task.isCompleted
        ],
        [
          'This is a task description',
          true,
        ]);
      });

      test('returns required fields', () {
        expect([
          task.id,
          task.title,
        ], [
          '1',
          'This is a task'
        ]);
      });

      test('returns priority assignment', () {
        expect(task.priority, Priority.low);
      });

      test('returns due date', () {
        expect(task.dueDate, DateTime(2026, 3, 20));
      });
  });

  group('Task Model — copyWith()', () {
    late Task task;
    setUp(() {
      task = Task(
        id: '1',
        title: 'This is a task',
        description: 'This is a task description',
        priority: Priority.low,
        dueDate: DateTime(2026, 3, 20),
        isCompleted: true,
      );
    });

    test('returns partially updated values', () {
      final updated = task.copyWith(
        title: 'This task title is updated',
        description: 'This description is updated',
      );

      expect([
        updated.title,
        updated.description
      ], 
      [
        'This task title is updated',
        'This description is updated',
      ]);
    });

    test('returns fully updated values', () {
      final updated = task.copyWith(
        id: '2',
        title: 'This task is updated',
        description: 'This description is updated',
        priority: Priority.medium,
        dueDate: DateTime(2025, 5, 9),
        isCompleted: false,
      );

      expect([
        updated.id,
        updated.title,
        updated.description,
        updated.priority,
        updated.dueDate,
        updated.isCompleted,
      ],
      [
        '2',
        'This task is updated',
        'This description is updated',
        Priority.medium,
        DateTime(2025, 5, 9),
        false,
      ]);
    });

    test('returns original and updated values', () {
      final updated = task.copyWith(
        id: '2',
        title: 'This task is updated',
        description: 'This description is updated',
        priority: Priority.medium,
        dueDate: DateTime(2025, 5, 9),
        isCompleted: false,
      );

      expect([
        task.id,
        task.title,
        task.description,
        task.priority,
        task.dueDate,
        task.isCompleted,
      ],
      [
        '1',
        'This is a task',
        'This is a task description',
        Priority.low,
        DateTime(2026, 3, 20),
        true,
      ]);

      expect([
        updated.id,
        updated.title,
        updated.description,
        updated.priority,
        updated.dueDate,
        updated.isCompleted,
      ],
      [
        '2',
        'This task is updated',
        'This description is updated',
        Priority.medium,
        DateTime(2025, 5, 9),
        false,
      ]);
    });
  });

  group('Task Model — isOverdue getter', () {
    late Task task;
    setUp(() {
      task = Task(
        id: '1',
        title: 'This is a task',
        description: 'This is a task description',
        priority: Priority.low,
        dueDate: DateTime.now(),
        isCompleted: false,
      );
    });

    test('returns true when task is incomplete and due date is past', () {
      task = task.copyWith(
        dueDate: DateTime.now().subtract(Duration(days: 1)),
      );

      expect(task.isOverdue, true);
    });

    test('returns false when task is when task is incomplete but not past due date', () {
      task = task.copyWith(
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      expect(task.isOverdue, false);
    });

    test('returns false when task is completed and due date is not and is not past due date', () {
      task = task.copyWith(
        dueDate: DateTime.now().subtract(Duration(days: 1)),
        isCompleted: true,
      );

      expect(task.isOverdue, false);
    });
  });

  group('Task Model — toJson() / fromJson()', () {
    late Task task;
    setUp(() {
      task = Task(
        id: '1',
        title: 'This is a task',
        description: 'This is a task description',
        priority: Priority.low,
        dueDate: DateTime(2026, 3, 20),
        isCompleted: true,
      );
    });

    test('Serialization round trip', () {
      final json = task.toJson();
      final result = Task.fromJson(json);
      expect([
        result.id,
        result.title,
        result.description,
        result.priority,
        result.dueDate,
        result.isCompleted
      ], 
      [
        task.id,
        task.title,
        task.description,
        task.priority,
        task.dueDate,
        task.isCompleted
      ]);
    });

    test('JSON field types are correct', () {
      final json = task.toJson();
      expect([
        json['id'],
        json['title'],
        json['description'],
        json['priority'],
        json['dueDate'],
        json['isCompleted'],
      ], 
      [
        isA<String>(),
        isA<String>(),
        isA<String>(),
        isA<int>(),
        isA<String>(),
        isA<bool>(),
      ]);
    });

    test('Priority index mapping works correctly', () {
      final json = task.toJson();
      final result = Task.fromJson(json);

      expect(json['priority'], Priority.low.index);
      expect(result.priority, Priority.low);
    });
  });

  group('TaskService — addTask()', () {
    late Task task, task2;
    late TaskService service;
    setUp(() {
      service = TaskService();
      task = Task(
        id: '1',
        title: 'This is a task',
        dueDate: DateTime(2026, 3, 20),
      );
      task2 = Task(
        id: '1',
        title: 'This is task2',
        dueDate: DateTime(2026, 4, 20),
      );
    });

    test('Adds task successfully', () {
      service.addTask(task);
      expect(service.allTasks.length, 1);
    });

    test('Throws an error when task title is empty', () {
      task = task.copyWith(
        title: '',
      );
      expect(() => {service.addTask(task)}, throwsArgumentError);
    });

    test('The service allow double id', () {
      service.addTask(task);
      service.addTask(task2); 
      expect(service.allTasks.length, 2);
    });
  });

  group('TaskService — deleteTask()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();

      service.addTask(Task(
        id: '1',
        title: 'this is a task',
        dueDate: DateTime.now(),
      ));
    });

    test('removes task if task id found', () {
      service.deleteTask('1');
      expect(service.allTasks.isEmpty, true);
    });

    test('Does nothing when task id is not found', () {
      service.deleteTask('999');
      expect(service.allTasks.isEmpty, false);
    });

  });

  group('TaskService — toggleComplete()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();

      service.addTask(Task(
        id: '1',
        title: 'This is a task',
        dueDate: DateTime(2026, 3, 12),
        isCompleted: false,
      ));
    });

    test('Changes task completion from false->true', () {
      service.toggleComplete('1');

      expect(service.allTasks.first.isCompleted, true);
    });

    test('Changes task completion from true->false', () {
      service.toggleComplete('1');
      service.toggleComplete('1');

      expect(service.allTasks.first.isCompleted, false);
    });

    test('Throws an error when no task matches the Id', () {
        expect(() => {service.toggleComplete('999')}, throwsStateError);
    });
  });

  group('TaskService — getByStatus()', () {
    late TaskService service;
    late Task task;

    setUp(() {
      service = TaskService();

      task = Task(
        id: '1',
        title: 'This is a task',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      service.addTask(task);
    });

      test("returns false when task status is incomplete", () {
      expect(service.allTasks.first.isCompleted, false);
    });

    test('returns true when task status is complete', () {
      service.toggleComplete('1');

      expect(service.allTasks.first.isCompleted, true);
    });
  });

  group('TaskService — sortByPriority()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();

      service.addTask(Task(
        id: '1', 
        title: 'This is a task', 
        dueDate: DateTime.now(),
        priority: Priority.high,
      ));

      service.addTask(Task(
        id: '2', 
        title: 'This is another task', 
        dueDate: DateTime.now(),
        priority: Priority.low,
      ));
    });

    test('', () {
      
    });
  });
}