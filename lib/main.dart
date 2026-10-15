import 'package:flutter/material.dart';

import 'models/study_task.dart';
import 'pages/add_task_page.dart';

void main() {
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7856D8)),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<StudyTask> _tasks = [];

  int _selectedIndex = 0;

  int get _completedCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get _pendingCount {
    return _tasks.length - _completedCount;
  }

  double get _progress {
    if (_tasks.isEmpty) return 0;
    return _completedCount / _tasks.length;
  }

  // ADD NEW ASSIGNMENT
  Future<void> _openAddTask() async {
    final StudyTask? newTask = await Navigator.of(context).push<StudyTask>(
      MaterialPageRoute<StudyTask>(builder: (context) => const AddTaskPage()),
    );

    if (!mounted) return;

    if (newTask != null) {
      setState(() {
        _tasks.add(newTask);
        _selectedIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newTask.title} created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // COMPLETE OR REOPEN ASSIGNMENT
  void _toggleTask(StudyTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  // DELETE ASSIGNMENT
  void _deleteTask(StudyTask task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyMate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE9DFFF),
              child: Icon(Icons.school, color: Color(0xFF7856D8)),
            ),
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildDashboard(), _buildTasksPage(), _buildPlannerPage()],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
        ],
      ),
    );
  }

  // DASHBOARD PAGE
  Widget _buildDashboard() {
    const purple = Color(0xFF7856D8);

    final upcomingTasks = _tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Hello, Student! 👋',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ready to make progress today?',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        const SizedBox(height: 24),

        // STUDY PROGRESS
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Study Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_completedCount of ${_tasks.length} tasks completed',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 9,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                '${(_progress * 100).round()}% complete — Keep going!',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // STATISTICS
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Tasks',
                count: '${_tasks.length}',
                icon: Icons.assignment_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryCard(
                title: 'Pending',
                count: '$_pendingCount',
                icon: Icons.schedule,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryCard(
                title: 'Done',
                count: '$_completedCount',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        const Text(
          'Upcoming Assignments',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        if (upcomingTasks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No pending assignments. Add a task to get started!'),
            ),
          )
        else
          ...upcomingTasks.map(
            (task) => AssignmentCard(
              key: ValueKey(task.id),
              task: task,
              onChanged: () => _toggleTask(task),
              onDelete: () => _deleteTask(task),
            ),
          ),
      ],
    );
  }

  // TASKS PAGE
  Widget _buildTasksPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Assignments',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (_tasks.isEmpty)
          const Text('No assignments yet. Tap Add Task!')
        else
          ..._tasks.map(
            (task) => AssignmentCard(
              key: ValueKey(task.id),
              task: task,
              onChanged: () => _toggleTask(task),
              onDelete: () => _deleteTask(task),
            ),
          ),
      ],
    );
  }

  // PLANNER PAGE
  Widget _buildPlannerPage() {
    final sortedTasks = List<StudyTask>.from(_tasks)
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Study Planner',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (sortedTasks.isEmpty)
          const Text('No deadlines scheduled yet.')
        else
          ...sortedTasks.map(
            (task) => AssignmentCard(
              key: ValueKey(task.id),
              task: task,
              onChanged: () => _toggleTask(task),
              onDelete: () => _deleteTask(task),
            ),
          ),
      ],
    );
  }
}

// SUMMARY CARD
class SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ASSIGNMENT CARD
class AssignmentCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const AssignmentCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(value: task.isCompleted, onChanged: (_) => onChanged()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subject,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Due: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.priority.name.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete ${task.title}',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
