import 'package:flutter/material.dart';

import '../models/study_task.dart';

class AddTaskPage extends StatefulWidget {
  final StudyTask? task;

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.medium;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _subjectController.text = task.subject;
      _deadline = task.deadline;
      _priority = task.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 5, now.month, now.day),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _deadline = selectedDate;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline.')),
      );
      return;
    }

    final existingTask = widget.task;

    final task = StudyTask(
      id: existingTask?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      deadline: _deadline!,
      priority: _priority,
      isCompleted: existingTask?.isCompleted ?? false,
    );

    Navigator.pop(context, task);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.edit_note_rounded
                              : Icons.assignment_add,
                          size: 36,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isEditing
                              ? 'Update Your Assignment'
                              : 'Create a New Assignment',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keep track of your studies and stay on top '
                          'of your deadlines.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Assignment title',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('assignment_title_field'),
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title',
                      hintText: 'e.g. Flutter Project',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an assignment title.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Subject',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('assignment_subject_field'),
                    controller: _subjectController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g. Mobile Development',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subject.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Deadline',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('deadline_picker_button'),
                    onPressed: _selectDeadline,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _deadline == null
                          ? 'Select Deadline'
                          : _formatDate(_deadline!),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Priority',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskPriority>(
                    key: const Key('assignment_priority_dropdown'),
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.flag_outlined),
                      labelText: 'Task Priority',
                    ),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Text(_priorityLabel(priority)),
                      );
                    }).toList(),
                    onChanged: (priority) {
                      if (priority != null) {
                        setState(() {
                          _priority = priority;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: _saveTask,
                    icon: Icon(
                      _isEditing ? Icons.save_outlined : Icons.add_rounded,
                    ),
                    label: const Text('Save Task'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
