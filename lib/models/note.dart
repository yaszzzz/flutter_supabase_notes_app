class Note {
  final String id;
  final String userId; // Untuk mengaitkan catatan dengan pengguna
  String title;
  String content;
  final DateTime createdAt;
  DateTime? updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Note dari Map (dari Supabase)
  factory Note.fromMap(Map<String, dynamic> data) {
    return Note(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }

  // Method untuk mengubah objek Note menjadi Map untuk disimpan di Supabase
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
