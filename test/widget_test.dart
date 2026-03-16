import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  Future<void> pumpTaskTile(
    WidgetTester tester, {
    required Task task,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskTile(task: task, onToggle: onToggle, onDelete: onDelete),
        ),
      ),
    );
  }

  Task createTask({
    String id = '00',
    String title = 'Test',
    bool completed = false,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title,
      isCompleted: completed,
      priority: priority,
      dueDate: dueDate ?? DateTime.now(),
    );
  }

  group('TaskTile — Rendering', () {
    testWidgets('Title displayed correctly', (tester) async {
      final task = createTask(title: 'Task Tile Test');

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      expect(find.text('Task Tile Test'), findsOneWidget);
    });

    testWidgets('Priority label shown', (tester) async {
      final task = createTask(priority: Priority.high);

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('Checkbox reflects isCompleted', (tester) async {
      final task = createTask(completed: true);

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Delete icon present', (tester) async {
      final task = createTask();

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  group('TaskTile — Checkbox Interaction', () {
    testWidgets('onToggle called on tap', (tester) async {
      bool called = false;
      final task = createTask();

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {
          called = true;
        },
        onDelete: () {},
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onToggle called exactly once', (tester) async {
      int count = 0;
      final task = createTask();

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {
          count++;
        },
        onDelete: () {},
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(count, equals(1));
    });
  });

  group('TaskTile — Delete Interaction', () {
    testWidgets('onDelete called on tap', (tester) async {
      bool called = false;
      final task = createTask();

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {
          called = true;
        },
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onDelete called exactly once', (tester) async {
      int count = 0;
      final task = createTask();

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {
          count++;
        },
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(count, equals(1));
    });
  });

  group('TaskTile — Completed State UI', () {
    testWidgets('LineThrough style when completed', (tester) async {
      final task = createTask(completed: true);

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      final textWidget = tester.widget<Text>(find.text(task.title));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('No decoration when active', (tester) async {
      final task = createTask(completed: false);

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      final textWidget = tester.widget<Text>(find.text(task.title));
      expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });

  group('TaskTile — Key Assertions', () {
    testWidgets('ValueKey matches task.id', (tester) async {
      final task = createTask(id: '123');

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      expect(find.byKey(ValueKey(task.id)), findsOneWidget);
    });

    testWidgets('Checkbox and delete keys are correct', (tester) async {
      final task = createTask(id: '123');

      await pumpTaskTile(
        tester,
        task: task,
        onToggle: () {},
        onDelete: () {},
      );

      expect(find.byKey(Key('checkbox_${task.id}')), findsOneWidget);
      expect(find.byKey(Key('delete_${task.id}')), findsOneWidget);
    });
  });
}