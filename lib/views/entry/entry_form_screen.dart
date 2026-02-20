import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../models/timetable_entry.dart';
import '../../providers/timetable_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/haptic_service.dart';

class EntryFormScreen extends ConsumerStatefulWidget {
  final TimetableEntry? entry;

  const EntryFormScreen({super.key, this.entry});

  @override
  ConsumerState<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends ConsumerState<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late ActivityCategory _category;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _descriptionController = TextEditingController(
      text: entry?.description ?? '',
    );
    _selectedDate = entry?.startTime ?? DateTime.now();
    _startTime = TimeOfDay.fromDateTime(entry?.startTime ?? DateTime.now());
    _endTime = TimeOfDay.fromDateTime(
      entry?.endTime ?? DateTime.now().add(const Duration(hours: 1)),
    );
    _category = entry?.category ?? ActivityCategory.work;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _deleteEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticService.success(ref);
              ref
                  .read(timetableProvider.notifier)
                  .deleteEntry(widget.entry!.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop screen
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Activity deleted')));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final entry = TimetableEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        category: _category,
        reminderMinutes: 5,
        repeat: RepeatCycle.none,
        isCompleted: widget.entry?.isCompleted ?? false,
      );

      if (widget.entry == null) {
        ref.read(timetableProvider.notifier).addEntry(entry);
      } else {
        ref.read(timetableProvider.notifier).updateEntry(entry);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Activity' : 'Edit Activity'),
        actions: [
          if (widget.entry != null)
            IconButton(
              onPressed: _deleteEntry,
              icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            ),
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(LucideIcons.check, color: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'What are you doing?',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Add some details (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Date & Time'),
              const SizedBox(height: 12),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Category'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPickerRow(
            icon: LucideIcons.calendar,
            label: 'Date',
            value: DateFormat('MMM d, yyyy').format(_selectedDate),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          const Divider(height: 24),
          _buildPickerRow(
            icon: LucideIcons.clock,
            label: 'Start Time',
            value: _startTime.format(context),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (picked != null) setState(() => _startTime = picked);
            },
          ),
          const Divider(height: 24),
          _buildPickerRow(
            icon: LucideIcons.timer,
            label: 'End Time',
            value: _endTime.format(context),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (picked != null) setState(() => _endTime = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPickerRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ActivityCategory.values.map((cat) {
        final isSelected = _category == cat;
        final color = AppColors.getCategoryColor(cat.name);
        return ChoiceChip(
          label: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _category = cat);
          },
          selectedColor: color.withValues(alpha: 0.3),
          labelStyle: TextStyle(
            color: isSelected
                ? color
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
