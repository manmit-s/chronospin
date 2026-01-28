import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileNotifier extends StateNotifier<File?> {
  ProfileNotifier() : super(null);

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage() async {
    try {
      print("Attempting to pick image...");
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final int sizeInBytes = await file.length();
        final double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 2.0) {
          print("Image too large: ${sizeInMb.toStringAsFixed(2)}MB");
          return "Image is too large (Max 2MB). Selected: ${sizeInMb.toStringAsFixed(1)}MB";
        }

        print("Image picked: ${image.path}");
        state = file;
        return null; // Success
      } else {
        print("Image picker cancelled or failed.");
        return null; // Cancelled (no error)
      }
    } catch (e) {
      print("Error picking image: $e");
      return "Error picking image: $e";
    }
  }
}

final profileImageProvider = StateNotifierProvider<ProfileNotifier, File?>((
  ref,
) {
  return ProfileNotifier();
});
