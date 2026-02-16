import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/category_view_model.dart';
import '../../domain/entities/category_entity.dart';

class ReportCategoryPage extends ConsumerStatefulWidget {
  final CategoryEntity? category; // null = create, non-null = update
  final String userRole;

  const ReportCategoryPage({super.key, this.category, required this.userRole});

  @override
  ConsumerState<ReportCategoryPage> createState() => _ReportCategoryPageState();
}

class _ReportCategoryPageState extends ConsumerState<ReportCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.userRole.toLowerCase() != 'admin') return;

    final name = _nameController.text.trim();
    final description =
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    final categoryNotifier = ref.read(categoryViewModelProvider.notifier);

    setState(() => _isLoading = true);

    try {
      if (widget.category == null) {
        // CREATE
        await categoryNotifier.createCategory(
          name: name,
          description: description,
          createdBy: 'admin', // replace with actual user if needed
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      } else {
        // UPDATE
        final updatedCategory = widget.category!.copyWith(
          name: name,
          description: description,
          updatedAt: DateTime.now(),
        );
        await categoryNotifier.updateCategory(updatedCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }

      Navigator.pop(context, true); // return true for refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (widget.category == null) return;
    if (widget.userRole.toLowerCase() != 'admin') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final categoryNotifier = ref.read(categoryViewModelProvider.notifier);
        await categoryNotifier.deleteCategory(widget.category!.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Category' : 'Add Category'),
        backgroundColor: Colors.orange,
        actions: [
          if (isEditing && widget.userRole.toLowerCase() == 'admin')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Category Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter category name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: Text(isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
