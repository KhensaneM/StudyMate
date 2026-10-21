import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // HELPER: Create an assignment.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  Future<void> pumpStudyMate(WidgetTester tester) async {
    await tester.pumpWidget(const StudyMateApp());
    await tester.pumpAndSettle();
  }

  Future<void> addTestTask(WidgetTester tester) async {
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Add Assignment'), findsOneWidget);

    // Enter assignment details.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Assignment Title'),
      'Flutter Project',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subject'),
      'Mobile Development',
    );

    // Select a deadline.
    await tester.tap(find.text('Select Deadline'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);

    // Save the assignment.
    await tester.ensureVisible(find.text('Save Task'));
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    // Confirm the form closed.
    expect(find.text('Add Assignment'), findsNothing);

    // Confirm the dashboard received the assignment.
    expect(find.text('0 of 1 tasks completed'), findsOneWidget);
  }

  // TEST 1: Dashboard displays correctly.
  testWidgets('Dashboard displays correctly', (tester) async {
    await pumpStudyMate(tester);

    expect(find.text('StudyMate'), findsOneWidget);
    expect(find.text('Hello, Student! 👋'), findsOneWidget);
    expect(find.text('Your Study Progress'), findsOneWidget);
    expect(find.text('0 of 0 tasks completed'), findsOneWidget);
    expect(find.text('0% complete — Keep going!'), findsOneWidget);

    // Scroll down so the ListView builds the upcoming assignments heading.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Assignments'), findsOneWidget);
  });

  // TEST 2: Add Task button opens the form.
  testWidgets('Add Task button opens assignment form', (tester) async {
    await pumpStudyMate(tester);

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Add Assignment'), findsOneWidget);
    expect(find.text('Create a New Assignment'), findsOneWidget);
    expect(find.text('Save Task'), findsOneWidget);
  });

  // TEST 3: Tasks tab displays empty state.
  testWidgets('Tasks navigation displays empty state', (tester) async {
    await pumpStudyMate(tester);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('My Assignments'), findsOneWidget);

    expect(find.text('No assignments yet. Tap Add Task!'), findsOneWidget);
  });

  // TEST 4: Planner displays empty state.
  testWidgets('Planner navigation displays empty state', (tester) async {
    await pumpStudyMate(tester);

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();

    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text('No deadlines scheduled yet.'), findsOneWidget);
  });

  // TEST 5: User can create an assignment.
  testWidgets('User can create an assignment', (tester) async {
    await pumpStudyMate(tester);

    await addTestTask(tester);

    expect(find.text('0 of 1 tasks completed'), findsOneWidget);

    // Open Tasks to verify the assignment exists.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Project'), findsOneWidget);
    expect(find.text('Mobile Development'), findsOneWidget);
  });

  // TEST 6: Completing an assignment updates progress.
  testWidgets('Dashboard updates after completing an assignment', (
    tester,
  ) async {
    await pumpStudyMate(tester);

    await addTestTask(tester);

    expect(find.text('0 of 1 tasks completed'), findsOneWidget);

    // Open the Tasks tab.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Project'), findsOneWidget);

    // Find the assignment checkbox.
    final checkboxFinder = find.descendant(
      of: find.byType(AssignmentCard),
      matching: find.byType(Checkbox),
    );

    expect(checkboxFinder, findsOneWidget);

    // Complete the assignment.
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Confirm the checkbox is checked.
    expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

    // Return to the dashboard.
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // Confirm progress updates.
    expect(find.text('1 of 1 tasks completed'), findsOneWidget);

    expect(find.text('100% complete — Keep going!'), findsOneWidget);
  });

  // TEST 7: User can delete an assignment.
  testWidgets('User can delete an assignment', (tester) async {
    await pumpStudyMate(tester);

    await addTestTask(tester);

    // Open the Tasks tab.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('My Assignments'), findsOneWidget);
    expect(find.text('Flutter Project'), findsOneWidget);

    // Delete the assignment.
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Flutter Project'), findsNothing);

    expect(find.text('No assignments yet. Tap Add Task!'), findsOneWidget);
  });

  // TEST 8: Planner displays assignments.
  testWidgets('Task remains visible in the Planner', (tester) async {
    await pumpStudyMate(tester);

    await addTestTask(tester);

    // Open the Planner tab.
    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();

    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text('Flutter Project'), findsOneWidget);
    expect(find.text('Mobile Development'), findsOneWidget);
  });
}
