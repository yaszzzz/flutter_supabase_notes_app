import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/note.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note; // Catatan yang akan diedit (null jika menambah baru)

  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    if (_currentUserId == null) {
      Get.offAllNamed('/login'); // Pastikan user login
      return;
    }

    if (widget.note != null) {
      // Jika ada catatan yang diteruskan, isi form untuk edit
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  Future<void> _saveNote() async {
    if (_currentUserId == null) {
      Get.snackbar('Error', 'Anda harus login untuk menyimpan catatan.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Peringatan', 'Judul catatan tidak boleh kosong!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (widget.note == null) {
        // Tambah catatan baru
        await _supabase.from('notes').insert({
          'user_id': _currentUserId,
          'title': title,
          'content': content,
          // 'created_at' akan otomatis diisi oleh Supabase
        });
        Get.snackbar('Berhasil', 'Catatan baru berhasil ditambahkan!');
      } else {
        // Edit catatan yang sudah ada
        await _supabase
            .from('notes')
            .update({
              'title': title,
              'content': content,
              'updated_at': DateTime.now()
                  .toIso8601String(), // Perbarui timestamp
            })
            .eq('id', widget.note!.id);
        Get.snackbar('Berhasil', 'Catatan berhasil diperbarui!');
      }
      Get.back(); // Kembali ke halaman sebelumnya (HomeScreen)
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan catatan: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: Text(
          widget.note == null ? 'Tambah Catatan Baru' : 'Edit Catatan',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null, // Izinkan banyak baris
                keyboardType: TextInputType.multiline,
                expands:
                    true, // Memungkinkan TextField untuk mengisi ruang yang tersedia
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveNote,
                    child: Text(
                      widget.note == null
                          ? 'Simpan Catatan'
                          : 'Perbarui Catatan',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
