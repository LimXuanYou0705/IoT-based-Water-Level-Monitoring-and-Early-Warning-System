import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iot_water_monitor/widgets/change_photo_widget.dart';
import '../../../models/user.dart';
import '../../../services/firebase_service/auth_service.dart';
import '../../../services/firebase_service/firebase_service.dart';
import '../../../widgets/avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();

  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AppUser?>(
        stream: _firebaseService.streamUserProfile(),
        builder: (context, snapshot) {
          print(
            "[DEBUG] Profile snapshot: ${snapshot.connectionState}, user: ${snapshot.data}",
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Loading user..."));
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(child: Text("User not found"));
          }

          _nameController = TextEditingController(text: user.name);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ChangePhotoWidget(
                  imageUrl: user.profilePicture,
                  radius: 50,
                  onImageSelected: (file) async {
                    try {
                      final url = await _firebaseService.uploadProfilePicture(
                        file,
                      );
                      await _firebaseService.updateUserProfilePicture(url);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Upload Photo Successfully!")),
                      );
                    } catch (e) {
                      debugPrint("Upload failed: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to upload photo")),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 10),

                _isEditingName
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(60, 10, 30, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              maxLength: 20,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter your name',
                                counterText: '',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                            tooltip: "Save",
                            onPressed: () async {
                              final newName = _nameController.text.trim();

                              if (newName.length < 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Name must be more than 3 characters",
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (newName.isNotEmpty && newName != user.name) {
                                await _firebaseService.updateUserName(newName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Name updated")),
                                );
                              }
                              setState(() => _isEditingName = false);
                            },
                          ),
                        ],
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.amber,
                            ),
                            tooltip: "Edit",
                            onPressed: () {
                              setState(() => _isEditingName = true);
                            },
                          ),
                        ],
                      ),
                    ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () {
                    _authService.signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
