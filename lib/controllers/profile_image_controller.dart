import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageController extends GetxController {
  var imagePath = RxnString(); 

  @override
  void onInit() {
    super.onInit();
    loadImagePath();
  }

  Future<void> loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    imagePath.value = prefs.getString('profile_image');
  }

  Future<void> setImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
    imagePath.value = path;
  }

  Future<void> clearImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image');
    imagePath.value = null;
  }
}
