// lib/services/supabase_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses `supabase` client

class SupabaseService {
  // Upload Gambar (Bekerja untuk Web dan Mobile)
  Future<String> uploadImage(
    File file,
    String bucketName,
    String fileName,
  ) async {
    final bytes = await file.readAsBytes();
    await supabase.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    // Mendapatkan URL publik dari gambar yang diupload
    final String publicUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);
    return publicUrl;
  }

  // Versi lain untuk web menggunakan XFile
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String bucketName,
    String fileName,
  ) async {
    await supabase.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final String publicUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);
    return publicUrl;
  }

  // --- CRUD Catatan ---

  Future<List<Map<String, dynamic>>> getNotes() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  Future<void> addNote({
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('notes').insert({
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    final updates = {'title': title, 'content': content, 'image_url': imageUrl};
    await supabase.from('notes').update(updates).eq('id', id);
  }

  Future<void> deleteNote(int id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  // --- Profil Pengguna ---

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return data;
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('profiles').upsert(updates);
  }
}
