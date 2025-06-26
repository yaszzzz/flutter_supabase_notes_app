Tutorial lengkap untuk membuat aplikasi catatan di Flutter menggunakan VS Code. Kita akan menerapkan fitur pencarian "pintar" dengan `fuzzywuzzy`, mengikuti konsep *clean code* dengan struktur folder dan *service*, serta hanya menggunakan `setState` untuk mengelola *state*.

### 🎯 **Hasil Akhir Aplikasi**

Aplikasi kita akan memiliki dua layar:

1. **Layar Daftar Catatan**: Menampilkan semua catatan dan sebuah *search bar*.
2. **Layar Tambah Catatan**: Sebuah form untuk membuat catatan baru.

------

### 🛠️ **Langkah 1: Setup Proyek di VS Code**

1. Buka VS Code dan buka *Command Palette* (**Ctrl+Shift+P** atau **Cmd+Shift+P** di macOS).

2. Ketik `Flutter: New Project` dan pilih `Application`.

3. Pilih folder untuk menyimpan proyek Anda dan beri nama (misalnya: `simple_notes_app`).

4. Setelah proyek dibuat, buka file `pubspec.yaml` dan tambahkan `fuzzywuzzy` di bawah `dependencies`:

   YAML

   ```
   dependencies:
     flutter:
       sdk: flutter
     cupertino_icons: ^1.0.2
     fuzzywuzzy: ^1.0.2 # Tambahkan baris ini
   ```

5. Simpan file tersebut. VS Code akan otomatis menjalankan `flutter pub get`. Jika tidak, buka terminal di VS Code **View > Terminal** dan jalankan perintah `flutter pub get`.

------

### 📁 **Langkah 2: Struktur Folder**

Untuk menjaga kode tetap rapi (*clean code*), buatlah struktur folder berikut di dalam direktori `lib` Anda. Anda bisa melakukannya langsung dari *File Explorer* di VS Code.

```
lib/
├── main.dart
├── models/
│   └── note_model.dart
├── screens/
│   ├── note_detail_screen.dart
│   └── note_list_screen.dart
└── services/
    └── note_service.dart
```

- **models**: Berisi kelas model data (struktur sebuah `Note`).
- **screens**: Berisi file-file untuk setiap layar UI.
- **services**: Berisi logika bisnis aplikasi, seperti mengelola dan mencari data.

------

### 💻 **Langkah 3: Menulis Kode**

Sekarang, kita akan mengisi setiap file dengan kode yang diperlukan.

#### **1. Model Catatan (`lib/models/note_model.dart`)**

File ini mendefinisikan objek `Note`.

Dart

```
// lib/models/note_model.dart

class Note {
  final int id;
  final String title;
  final String content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });
}
```

#### **2. Service Catatan (`lib/services/note_service.dart`)**

Ini adalah "otak" dari aplikasi kita. *Service* ini mengelola data catatan (menambah, mengambil, dan mencari) secara terpusat. Untuk kesederhanaan, kita gunakan data *dummy*.

Dart

```
// lib/services/note_service.dart

import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import '../models/note_model.dart';

class NoteService {
  // Daftar catatan sebagai database sementara (dummy data)
  final List<Note> _notes = [
    Note(id: 1, title: "Resep Nasi Goreng", content: "Bawang merah, bawang putih, nasi, kecap."),
    Note(id: 2, title: "Rencana Belajar Flutter", content: "State Management, Widget, Layouting."),
    Note(id: 3, title: "Daftar Belanja Bulanan", content: "Sabun, sikat gigi, beras, minyak goreng."),
    Note(id: 4, title: "Ide Proyek Flutter", content: "Aplikasi resep masakan atau todo list."),
  ];

  /// Mengambil semua catatan.
  List<Note> getNotes() {
    return _notes;
  }

  /// Menambah catatan baru.
  void addNote(Note note) {
    _notes.add(note);
  }

  /// Mencari catatan menggunakan fuzzywuzzy.
  List<Note> searchNotes(String query) {
    if (query.isEmpty) {
      return _notes;
    }

    // Menggabungkan title dan content untuk pencarian yang lebih efektif.
    List<String> choices = _notes.map((note) => "${note.title} ${note.content}").toList();
    
    // Mengekstrak hasil terbaik dengan skor kemiripan di atas 50.
    List<dynamic> results = fuzzy.extractTop(
      query: query,
      choices: choices,
      limit: 5,
      cutoff: 50, // Skor minimum kecocokan (0-100).
    );

    // Mengembalikan objek Note asli berdasarkan hasil pencarian.
    return results.map((result) {
      return _notes[result.index];
    }).toList();
  }
}
```

**Penjelasan `searchNotes`**:

- **`fuzzy.extractTop`**: Fungsi inti dari `fuzzywuzzy` untuk mencari string yang paling mirip.
- **`query`**: Teks yang diketik pengguna di *search bar*.
- **`choices`**: Daftar teks sumber (kita gabungkan judul dan isi catatan).
- **`cutoff: 50`**: Ambang batas skor kemiripan. Hasil dengan skor di bawah 50 akan diabaikan, sehingga lebih relevan.

------

#### **3. Layar Daftar Catatan (`lib/screens/note_list_screen.dart`)**

Layar utama yang menampilkan daftar catatan dan memiliki *search bar*.

Dart

```
// lib/screens/note_list_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteService _noteService = NoteService();
  late List<Note> _displayedNotes;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi: tampilkan semua catatan saat layar pertama kali dimuat.
    _displayedNotes = _noteService.getNotes();

    // Listener untuk memicu pencarian setiap kali teks di search bar berubah.
    _searchController.addListener(_filterNotes);
  }

  /// Memfilter catatan berdasarkan input dari search bar.
  void _filterNotes() {
    final query = _searchController.text;
    setState(() {
      _displayedNotes = _noteService.searchNotes(query);
    });
  }
  
  /// Navigasi ke halaman tambah catatan dan menangani data yang dikembalikan.
  void _navigateAndAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
    );

    // Jika ada catatan baru yang ditambahkan, refresh list.
    if (result != null && result is Note) {
      _noteService.addNote(result);
      setState(() {
        _filterNotes(); // Update UI sesuai query yang mungkin masih aktif.
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Apps'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Daftar Catatan
            Expanded(
              child: _displayedNotes.isEmpty
                  ? const Center(child: Text("Tidak ada catatan ditemukan."))
                  : ListView.builder(
                      itemCount: _displayedNotes.length,
                      itemBuilder: (context, index) {
                        final note = _displayedNotes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(note.title),
                            subtitle: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddNote,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Poin Penting**:

- **`_displayedNotes`**: Variabel *state* yang menyimpan daftar catatan untuk ditampilkan di UI.
- **`initState()`**: Menginisialisasi data awal dan memasang *listener* pada `_searchController`.
- **`_filterNotes()`**: Memanggil *service* untuk mencari, lalu memanggil `setState()` untuk memberitahu Flutter agar membangun ulang UI dengan data yang baru.
- **`_navigateAndAddNote()`**: Menggunakan `await Navigator.push` untuk menunggu data yang dikirim kembali dari `NoteDetailScreen`. Saat data diterima, UI diperbarui.

------

#### **4. Layar Tambah Catatan (`lib/screens/note_detail_screen.dart`)**

Layar ini berisi form untuk membuat catatan baru.

Dart

```
// lib/screens/note_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveNote() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final newNote = Note(
        // Gunakan timestamp untuk ID unik sederhana.
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        content: _contentController.text,
      );
      // Kirim objek catatan baru kembali ke layar sebelumnya.
      Navigator.pop(context, newNote);
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
        title: const Text('Tambah Catatan Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Poin Penting**:

- `_saveNote()`: Fungsi ini membuat objek `Note` baru, lalu `Navigator.pop(context, newNote)` akan menutup layar ini dan mengirimkan `newNote` sebagai `result` ke `await` di `NoteListScreen`.

------

#### **5. File Utama (`lib/main.dart`)**

Terakhir, atur `main.dart` untuk menjalankan `NoteListScreen` sebagai layar utama.

Dart

```
// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/note_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Apps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const NoteListScreen(),
    );
  }
}
```

------

### 🎉 **Selesai! Jalankan Aplikasi Anda**

1. Pastikan Anda memiliki perangkat (emulator atau fisik) yang berjalan. Anda bisa melihatnya di pojok kanan bawah VS Code.
2. Tekan **F5** atau buka *Run and Debug* di VS Code dan klik tombol *play* untuk menjalankan aplikasi.

Anda sekarang memiliki aplikasi catatan sederhana yang fungsional dengan pencarian *fuzzy*, dibangun dengan struktur kode yang bersih, dan murni menggunakan `setState`. Selamat mencoba!