// Stub for web platform where path_provider is not available


class Directory {
  final String path;
  Directory(this.path);
}

Future<Directory> getApplicationDocumentsDirectory() async {
  // For web, return a dummy directory since local storage is handled differently
  return Directory('web_storage');
}
