import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart'; // Halaman tambah/edit catatan

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    if (_currentUserId == null) {
      // Jika user ID tidak ditemukan, mungkin sesi habis, arahkan ke login
      Get.offAllNamed('/login');
    }
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: ${e.toString()}');
    }
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await _supabase.from('notes').delete().eq('id', noteId);
      Get.snackbar('Berhasil', 'Catatan berhasil dihapus!');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus catatan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Anda'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Menggunakan stream() untuk mendapatkan pembaruan real-time
        stream: _supabase
            .from('notes')
            .stream(primaryKey: ['id']) // Menggunakan primaryKey untuk stream
            .eq(
              'user_id',
              _currentUserId!,
            ) // Filter catatan berdasarkan user ID
            .order(
              'created_at',
              ascending: false,
            ), // Urutkan berdasarkan waktu pembuatan
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan. Buat yang baru!'),
            );
          }

          final notes = snapshot.data!.map((map) => Note.fromMap(map)).toList();

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigasi ke halaman edit catatan
                    Get.to(() => AddEditNoteScreen(note: note));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteNote(note.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah catatan baru
          Get.to(() => const AddEditNoteScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
