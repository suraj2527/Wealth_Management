import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/profile_image_controller.dart';
import 'package:wealth_app/controllers/theme_controller.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ProfileImageController profileImageController =
      Get.find<ProfileImageController>();

  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = authController.fullName.value;
    profileImageController.loadImagePath();
  }

  Future<void> _pickImageDialog(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final pickedFile = File(picked.path);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(pickedFile, height: 150),
                const SizedBox(height: 12),
                const Text("Set this as your profile picture?"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: context.buttonColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final dir = await getApplicationDocumentsDirectory();
                  final saved = await pickedFile.copy(
                    '${dir.path}/profile_image.png',
                  );

                  imageCache.clear();
                  imageCache.clearLiveImages();
                  await profileImageController.setImagePath(saved.path);
                },
                child: Text("OK", style: TextStyle(color: context.buttonColor)),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: context.fieldColor,
            title: Text(
              "Logout",
              style: TextStyle(fontWeight: AppTextStyle.mediumWeight),
            ),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: context.mainFontColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 300));
                      await authController.logout();
                      Get.offAllNamed('/login');
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(color: context.buttonColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UniversalScaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: RefreshIndicator(
          onRefresh: () async {
            imageCache.clear();
            imageCache.clearLiveImages();
            await profileImageController.loadImagePath();
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Theme Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.mainFontColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: context.buttonColor,
                      ),
                      onPressed:
                          () => Get.find<ThemeController>().toggleTheme(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "These details are from Azure",
                  style: TextStyle(
                    fontSize: 14,
                    color: context.placeholderColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImageDialog(context),
                    child: Stack(
                      children: [
                        Obx(() {
                          final path = profileImageController.imagePath.value;
                          return CircleAvatar(
                            key: ValueKey(path),
                            radius: 50,
                            backgroundColor: context.fieldColor,
                            backgroundImage:
                                path != null ? FileImage(File(path)) : null,
                            child:
                                path == null
                                    ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: context.placeholderColor,
                                    )
                                    : null,
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.buttonColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Name Field
                Text(
                  "Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.mainFontColor,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _isEditing
                          ? Form(
                            key: _formKey,
                            child: Container(
                              key: const ValueKey("editing"),
                              padding: const EdgeInsets.all(12),
                              decoration: _fieldDecoration(context),
                              child: TextFormField(
                                controller: _nameController,
                                autofocus: true,
                                validator:
                                    (value) =>
                                        value == null || value.trim().isEmpty
                                            ? "Name cannot be empty"
                                            : null,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "Enter your name",
                                ),
                              ),
                            ),
                          )
                          : GestureDetector(
                            key: const ValueKey("displaying"),
                            onTap: () => setState(() => _isEditing = true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: _fieldDecoration(context),
                              child: Obx(() {
                                final name = authController.fullName.value;
                                return Text(
                                  name.isEmpty ? "Enter your name" : name,
                                  style: TextStyle(
                                    color:
                                        name.isEmpty
                                            ? context.placeholderColor
                                            : context.mainFontColor,
                                  ),
                                );
                              }),
                            ),
                          ),
                ),

                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            authController.updateName(
                              _nameController.text.trim(),
                            );
                            setState(() => _isEditing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Name updated successfully"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.buttonColor,
                          foregroundColor: context.buttonTextColor,
                        ),
                        child: const Text("Update"),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                _labeledStaticField(
                  context,
                  "Email",
                  authController.email.value,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.buttonColor,
                      foregroundColor: context.buttonTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.fieldColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: context.borderColor.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5),
      ],
    );
  }

  Widget _labeledStaticField(
    BuildContext context,
    String label,
    String? value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: context.mainFontColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: _fieldDecoration(context),
          child: Text(
            value ?? 'Not Available',
            style: TextStyle(color: context.mainFontColor),
          ),
        ),
      ],
    );
  }
}
