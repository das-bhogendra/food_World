import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/theme/app_colors.dart';
import 'package:food_mandu/theme/theme_extensions.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ReportFoodItemPage extends ConsumerStatefulWidget {
  const ReportFoodItemPage({super.key});

  @override
  ConsumerState<ReportFoodItemPage> createState() => _ReportFoodItemPageState();
}

class _ReportFoodItemPageState extends ConsumerState<ReportFoodItemPage> {
  bool _isAvailable = true;
  FoodItemType _selectedType = FoodItemType.veg; // Default type
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Media
  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedMediaType; // 'photo' or 'video'

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.browse_gallery_rounded),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_call_rounded),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Please grant permissions from settings to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo =
        await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
        _selectedMediaType = 'photo';
      });
      await ref.read(foodItemNotifierProvider.notifier).uploadPhoto(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(image);
        _selectedMediaType = 'photo';
      });
      await ref.read(foodItemNotifierProvider.notifier).uploadPhoto(File(image.path));
    }
  }

  Future<void> _pickFromVideo() async {
    final hasCamera = await _requestPermission(Permission.camera);
    final hasMic = await _requestPermission(Permission.microphone);
    if (!hasCamera || !hasMic) return;

    final XFile? video =
        await _imagePicker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 1));

    if (video != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(video);
        _selectedMediaType = 'video';
      });
      await ref.read(foodItemNotifierProvider.notifier).uploadVideo(File(video.path));
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final userId = ref.read(userSessionServiceProvider).authId ?? 'unknown';
      final uploadedMedia = ref.read(foodItemNotifierProvider).uploadedMediaUrl;

      final foodItem = FoodItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        price: 0,
        isAvailable: _isAvailable,
        addedBy: userId,
        imageUrl: uploadedMedia,
        mediaType: _selectedMediaType,
      );

      await ref.read(foodItemNotifierProvider.notifier).createFoodItem(foodItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FoodItemsState>(foodItemNotifierProvider, (prev, next) {
      if (next.status == FoodItemStatus.created) {
        SnackbarUtils.showSuccess(
            context, _isAvailable ? 'Food item added!' : 'Food item marked sold out!');
        Navigator.pop(context);
      } else if (next.status == FoodItemStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: context.softShadow,
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Report Food Item',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Availability toggle
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Available'),
                              selected: _isAvailable,
                              onSelected: (_) => setState(() => _isAvailable = true),
                              selectedColor: AppColors.foundGradient.colors.first,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Sold Out'),
                              selected: !_isAvailable,
                              onSelected: (_) => setState(() => _isAvailable = false),
                              selectedColor: AppColors.lostGradient.colors.first,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Type selector
                      DropdownButtonFormField<FoodItemType>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Food Type',
                          prefixIcon: Icon(Icons.category, color: context.textSecondary),
                        ),
                        items: FoodItemType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (type) {
                          if (type != null) setState(() => _selectedType = type);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Food Name',
                          prefixIcon: Icon(Icons.fastfood_rounded, color: context.textSecondary),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter food name' : null,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_rounded, color: context.textSecondary),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Media picker
                      GestureDetector(
                        onTap: _pickMedia,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: context.softShadow,
                          ),
                          child: _selectedMedia.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_rounded, size: 36),
                                      SizedBox(height: 8),
                                      Text('Add Photo / Video'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedMedia.length,
                                  itemBuilder: (context, index) {
                                    final media = _selectedMedia[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          File(media.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      GestureDetector(
                        onTap: _handleSubmit,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: const Center(
                            child: Text(
                              'Submit Food Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 }
  