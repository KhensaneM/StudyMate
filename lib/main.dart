import 'package:flutter/material.dart';

import 'models/study_task.dart';
import 'pages/add_task_page.dart';

void main() {
  runApp(const StudyMateApp());
}

enum TaskFilter { all, pending, completed, overdue }

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7856D8);

    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F7FC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E0EF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E0EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryPurple, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFECE8F3)),
          ),
        ),
      ),
      home: const StudyMateHome(),
    );
  }
}

class StudyMateHome extends StatefulWidget {
  const StudyMateHome({super.key});

  @override
  State<StudyMateHome> createState() => _StudyMateHomeState();
}

class _StudyMateHomeState extends State<StudyMateHome> {
  final List<StudyTask> _tasks = [];

  int _selectedIndex = 0;
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  int get _pendingCount => _tasks.where((task) => !task.isCompleted).length;

  double get _completionPercentage =>
      _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  bool _isOverdue(StudyTask task) {
    final today = DateUtils.dateOnly(DateTime.now());
    return !task.isCompleted && task.deadline.isBefore(today);
  }

  List<StudyTask> get _filteredTasks {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(query) ||
          task.subject.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
        TaskFilter.overdue => _isOverdue(task),
      };

      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
    return filtered;
  }

  Future<void> _openAddTask() async {
    final newTask = await Navigator.push<StudyTask>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskPage()),
    );

    if (!mounted || newTask == null) return;

    setState(() {
      _tasks.add(newTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment added successfully!')),
    );
  }

  Future<void> _editTask(StudyTask task) async {
    final updatedTask = await Navigator.push<StudyTask>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskPage(task: task)),
    );

    if (!mounted || updatedTask == null) return;

    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment updated successfully!')),
    );
  }

  void _toggleTask(StudyTask task, bool value) {
    setState(() {
      task.isCompleted = value;
    });
  }

  void _deleteTask(StudyTask task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assignment deleted.')));
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildDashboard(), _buildTasksPage(), _buildPlannerPage()];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFECE5FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF7856D8)),
            ),
            const SizedBox(width: 10),
            const Text(
              'StudyMate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFECE5FF),
              child: Icon(
                Icons.person_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Planner',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final upcomingTasks = _tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Hello, Student! 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF29213B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Small steps every day lead to big achievements.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _buildProgressCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Tasks',
                value: '${_tasks.length}',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF7856D8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Pending',
                value: '$_pendingCount',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFDE8A27),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Completed',
                value: '$_completedCount',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF26966D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Assignments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (upcomingTasks.isEmpty)
          _emptyState(
            icon: Icons.event_note_rounded,
            title: 'No upcoming assignments',
            message: 'Add a task to start planning your studies.',
          )
        else
          ...upcomingTasks
              .take(3)
              .map(
                (task) => AssignmentCard(
                  task: task,
                  isOverdue: _isOverdue(task),
                  onChanged: (value) => _toggleTask(task, value),
                  onDelete: () => _deleteTask(task),
                  onEdit: () => _editTask(task),
                ),
              ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final percentage = (_completionPercentage * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7856D8), Color(0xFF9A7BEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Study Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            '$_completedCount of ${_tasks.length} tasks completed',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _completionPercentage,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$percentage% complete — Keep going!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPage() {
    final tasks = _filteredTasks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'My Assignments',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your assignments and keep track of deadlines.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        TextField(
          key: const Key('task_search_field'),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search by title or subject...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', TaskFilter.all),
              const SizedBox(width: 8),
              _filterChip('Pending', TaskFilter.pending),
              const SizedBox(width: 8),
              _filterChip('Completed', TaskFilter.completed),
              const SizedBox(width: 8),
              _filterChip('Overdue', TaskFilter.overdue),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_tasks.isEmpty)
          _emptyState(
            icon: Icons.assignment_outlined,
            title: 'No assignments yet. Tap Add Task!',
            message: 'Your assignments will appear here.',
          )
        else if (tasks.isEmpty)
          _emptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching assignments',
            message: 'Try another search or filter.',
          )
        else
          ...tasks.map(
            (task) => AssignmentCard(
              task: task,
              isOverdue: _isOverdue(task),
              onChanged: (value) => _toggleTask(task, value),
              onDelete: () => _deleteTask(task),
              onEdit: () => _editTask(task),
            ),
          ),
      ],
    );
  }

  Widget _filterChip(String label, TaskFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) {
        setState(() {
          _filter = filter;
        });
      },
    );
  }

  Widget _buildPlannerPage() {
    final sortedTasks = [..._tasks]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Study Planner',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Plan ahead and stay ready for every deadline.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        if (sortedTasks.isEmpty)
          _emptyState(
            icon: Icons.calendar_month_outlined,
            title: 'No deadlines scheduled yet.',
            message: 'Add an assignment to see it in your planner.',
          )
        else
          ...sortedTasks.map(
            (task) => AssignmentCard(
              task: task,
              isOverdue: _isOverdue(task),
              onChanged: (value) => _toggleTask(task, value),
              onDelete: () => _deleteTask(task),
              onEdit: () => _editTask(task),
            ),
          ),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF9B8ABF)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final StudyTask task;
  final bool isOverdue;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const AssignmentCard({
    super.key,
    required this.task,
    this.isOverdue = false,
    required this.onChanged,
    required this.onDelete,
    this.onEdit,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:
        return const Color(0xFF26966D);
      case TaskPriority.medium:
        return const Color(0xFFDE8A27);
      case TaskPriority.high:
        return const Color(0xFFD84C4C);
    }
  }

  String get _formattedDate {
    final date = task.deadline;
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final overdue = isOverdue && !task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onChanged(value ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      task.subject,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _tag(
                          Icons.calendar_today_rounded,
                          overdue
                              ? 'Overdue: $_formattedDate'
                              : 'Due: $_formattedDate',
                          overdue ? Colors.red.shade700 : Colors.grey.shade700,
                          overdue
                              ? const Color(0xFFFFE8E8)
                              : const Color(0xFFF0EDF6),
                        ),
                        _tag(
                          Icons.flag_rounded,
                          task.priority.name.toUpperCase(),
                          _priorityColor,
                          _priorityColor.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Delete assignment',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Assignment options',
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit assignment'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete assignment'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
