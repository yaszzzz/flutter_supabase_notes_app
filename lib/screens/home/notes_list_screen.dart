// lib/screens/home/notes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabaseService.getNotes();
      setState(() {
        _notes = data.map((item) => Note.fromJson(item)).toList();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat catatan: $e',
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

  Future<void> _deleteNote(int id) async {
    try {
      await _supabaseService.deleteNote(id);
      Get.snackbar(
        'Sukses',
        'Catatan berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchNotes(); // Muat ulang daftar catatan
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus catatan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Saya')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('Anda belum memiliki catatan. Buat satu!'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: note.imageUrl != null
                        ? Image.network(
                            note.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.note, size: 40),
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            // Tunggu hasil dari halaman edit, jika true, muat ulang
                            final result = await Get.toNamed(
                              AppRoutes.noteForm,
                              arguments: note,
                            );
                            if (result == true) {
                              _fetchNotes();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(note.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.noteForm);
          if (result == true) {
            _fetchNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    Get.defaultDialog(
      title: "Hapus Catatan",
      middleText: "Apakah Anda yakin ingin menghapus catatan ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Tutup dialog
        _deleteNote(id);
      },
    );
  }
}
