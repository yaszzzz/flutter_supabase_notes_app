// lib/screens/profile/profile_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = true;
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabaseService.getProfile();
      if (data != null) {
        setState(() {
          _profile = Profile.fromJson(data);
          _usernameController.text = _profile!.username;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _supabaseService.updateProfile(username: _usernameController.text);
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fileName =
          '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imageUrl;

      if (kIsWeb) {
        final imageBytes = await imageFile.readAsBytes();
        imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          'avatars',
          fileName,
        );
      } else {
        final file = File(imageFile.path);
        imageUrl = await _supabaseService.uploadImage(
          file,
          'avatars',
          fileName,
        );
      }

      await _supabaseService.updateProfile(
        username: _usernameController.text,
        avatarUrl: imageUrl,
      );
      _loadProfile();
      Get.snackbar(
        'Sukses',
        'Avatar berhasil diupload',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupload avatar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _profile == null
              ? const Center(child: Text('Gagal memuat profil.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _uploadAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            (_profile?.avatarUrl != null)
                                ? NetworkImage(_profile!.avatarUrl!)
                                : null,
                        child:
                            (_profile?.avatarUrl == null)
                                ? const Icon(Icons.person, size: 60)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _uploadAvatar,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ganti Avatar'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Perubahan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.notes),
                        icon: const Icon(Icons.note),
                        label: const Text('Lihat Catatan Saya'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.chat),
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('Chat Dengan AI'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
