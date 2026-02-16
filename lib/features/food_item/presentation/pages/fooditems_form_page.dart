import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/theme/app_colors.dart';
import 'food_gallery_pages.dart'; // Your FoodGalleryPage

class FoodItemFormPage extends ConsumerStatefulWidget {
  final FoodItemEntity? foodItem;
  const FoodItemFormPage({super.key, this.foodItem});

  @override
  ConsumerState<FoodItemFormPage> createState() => _FoodItemFormPageState();
}

class _FoodItemFormPageState extends ConsumerState<FoodItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  FoodItemType _type = FoodItemType.veg;
  bool _isAvailable = true;
  bool _isBestSeller = false;
  bool _isDiscounted = false;

  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem?.name ?? '');
    _descriptionController = TextEditingController(text: widget.foodItem?.description ?? '');
    _priceController = TextEditingController(
        text: widget.foodItem?.price != null ? widget.foodItem!.price.toString() : '');
    _type = widget.foodItem?.type ?? FoodItemType.veg;
    _isAvailable = widget.foodItem?.isAvailable ?? true;
    _isBestSeller = widget.foodItem?.isBestSeller ?? false;
    _isDiscounted = widget.foodItem?.isDiscounted ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Pick image from camera or gallery
  Future<void> _pickMedia(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    if (!await permission.request().isGranted) return;

    final XFile? file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    setState(() => _mediaFile = File(file.path));
  }

  /// Convert asset path to File
  Future<File> _getFileFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split("/").last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  /// Image preview
  Widget _buildImagePreview() {
    if (_mediaFile != null) return Image.file(_mediaFile!, height: 200, fit: BoxFit.cover);
    if (widget.foodItem?.imageUrl != null && widget.foodItem!.imageUrl!.isNotEmpty)
      return widget.foodItem!.imageUrl!.startsWith('http')
          ? Image.network(widget.foodItem!.imageUrl!, height: 200, fit: BoxFit.cover)
          : Image.file(File(widget.foodItem!.imageUrl!), height: 200, fit: BoxFit.cover);

    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 100, color: Colors.grey),
    );
  }

  /// Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final notifier = ref.read(foodItemNotifierProvider.notifier);

    final newFood = FoodItemEntity(
      id: widget.foodItem?.id ?? "",
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      type: _type,
      isAvailable: _isAvailable,
      isBestSeller: _isBestSeller,
      isDiscounted: _isDiscounted,
      addedBy: "Admin",
      imageUrl: widget.foodItem?.imageUrl,
    );

    try {
      if (widget.foodItem != null) {
        await notifier.updateFoodItem(newFood, imageFile: _mediaFile);
      } else {
        await notifier.createFoodItem(newFood, imageFile: _mediaFile);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading food: $e")),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem != null ? "Update Food Item" : "Create Food Item"),
        backgroundColor: AppColors.primary,
        actions: [
          // Open your FoodGalleryPage
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: "Select from gallery",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodGalleryPage(
                    onImageSelected: (path) async {
                      File file;
                      if (path.startsWith('assets/')) {
                        file = await _getFileFromAsset(path); // handle asset
                      } else {
                        file = File(path); // camera/gallery file
                      }
                      setState(() => _mediaFile = file);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Food Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter food name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? "Enter valid price" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodItemType>(
                value: _type,
                items: FoodItemType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: "Type"),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Available"),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              SwitchListTile(
                title: const Text("Best Seller"),
                value: _isBestSeller,
                onChanged: (v) => setState(() => _isBestSeller = v),
              ),
              SwitchListTile(
                title: const Text("Discounted"),
                value: _isDiscounted,
                onChanged: (v) => setState(() => _isDiscounted = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickMedia(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Take Photo"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickMedia(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text("Choose from Phone Gallery"),
                    ),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: 16), child: _buildImagePreview()),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.foodItem != null ? "Update" : "Create"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
