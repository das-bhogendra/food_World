import 'package:flutter/material.dart';

class FoodGalleryPage extends StatefulWidget {
  final Function(String) onImageSelected;

  const FoodGalleryPage({super.key, required this.onImageSelected});

  @override
  _FoodGalleryPageState createState() => _FoodGalleryPageState();
}

class _FoodGalleryPageState extends State<FoodGalleryPage> {
  // List of food images from assets
  final List<String> _assetImages = [
    'assets/images/biryani.jpg',
    'assets/images/burger.jpg',
    'assets/images/butterfly_pasta.jpg',
    'assets/images/chicken.jpg',
    'assets/images/fried_chicken.jpg',
    'assets/images/fried_rice.jpg',
    'assets/images/hotdog.jpg',
    'assets/images/jollof_rice.jpg',
    'assets/images/noodles.jpg',
    'assets/images/pasta.jpg',
    'assets/images/pizza.jpg',
    'assets/images/sandwich.jpg',
    'assets/images/white_rice.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Gallery")),
      body: _assetImages.isEmpty
          ? const Center(child: Text("No images found"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _assetImages.length,
              itemBuilder: (context, index) {
                final assetPath = _assetImages[index];
                final imageName = assetPath.split('/').last;

                return GestureDetector(
                  onTap: () {
                    // Return the asset path to the caller
                    widget.onImageSelected(assetPath);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, color: Colors.grey),
                                const SizedBox(height: 4),
                                Text(
                                  imageName,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
