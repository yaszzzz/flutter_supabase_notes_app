// lib/screens/home/note_form_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;
  Note? _existingNote;
  XFile? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    // Cek apakah kita sedang mengedit note yang sudah ada
    if (Get.arguments is Note) {
      _existingNote = Get.arguments as Note;
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
      _existingImageUrl = _existingNote!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl = _existingImageUrl;

        // Jika ada gambar baru yang dipilih, upload
        if (_imageFile != null) {
          final fileName =
              '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          if (kIsWeb) {
            final imageBytes = await _imageFile!.readAsBytes();
            imageUrl = await _supabaseService.uploadImageBytes(
              imageBytes,
              'notes_images',
              fileName,
            );
          } else {
            final file = File(_imageFile!.path);
            imageUrl = await _supabaseService.uploadImage(
              file,
              'notes_images',
              fileName,
            );
          }
        }

        if (_existingNote != null) {
          // Update note
          await _supabaseService.updateNote(
            id: _existingNote!.id,
            title: _titleController.text,
            content: _contentController.text,
            imageUrl: imageUrl,
          );
        } else {
          // Tambah note baru
          await _supabaseService.addNote(
            title: _titleController.text,
            content: _contentController.text,
            imageUrl: imageUrl,
          );
        }
        // Kembalikan `true` untuk menandakan sukses
        Get.back(result: true);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menyimpan catatan: $e',
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingNote == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pratinjau Gambar
              _imageFile != null
                  ? (kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_imageFile!.path),
                            height: 150,
                            fit: BoxFit.cover,
                          ))
                  : (_existingImageUrl != null
                        ? Image.network(
                            _existingImageUrl!,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _titleController,
                labelText: 'Judul',
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _contentController,
                labelText: 'Isi Catatan',
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Isi catatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Catatan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
