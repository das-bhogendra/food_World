import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/category_view_model.dart';
import '../state/category_state.dart';
import 'category_detail_page.dart';
import 'report_category_page.dart';

class CategoryPage extends ConsumerWidget {
  final String userRole;

  const CategoryPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryViewModelProvider);
    final categoryNotifier = ref.read(categoryViewModelProvider.notifier);

    // Load categories only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryState.status == CategoryStatus.initial) {
        categoryNotifier.loadCategories();
      }
    });

    final isAdmin = userRole.toLowerCase() == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportCategoryPage(userRole: userRole),
                  ),
                );
                // Refresh after creating a category
                categoryNotifier.loadCategories();
              },
            )
          : null,
      body: Builder(builder: (context) {
        switch (categoryState.status) {
          case CategoryStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case CategoryStatus.error:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load categories',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(categoryState.errorMessage ?? ''),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => categoryNotifier.loadCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );

          case CategoryStatus.loaded:
          case CategoryStatus.initial:
          default:
            if (categoryState.categories.isEmpty) {
              return const Center(child: Text('No categories available'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: categoryState.categories.length,
              itemBuilder: (context, index) {
                final category = categoryState.categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailPage(
                          categoryId: category.id,
                          categoryName: category.name,
                          userRole: userRole,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (isAdmin)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReportCategoryPage(
                                          category: category,
                                          userRole: userRole,
                                        ),
                                      ),
                                    );
                                    categoryNotifier.loadCategories();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Delete Category"),
                                        content: Text(
                                            "Are you sure you want to delete '${category.name}'?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancel")),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text("Delete")),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await categoryNotifier
                                          .deleteCategory(category.id);
                                      categoryNotifier.loadCategories();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
        }
      }),
    );
  }
}
