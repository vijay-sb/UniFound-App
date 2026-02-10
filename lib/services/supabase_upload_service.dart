// services/supabase_upload_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const String supabaseUrl = 'https://vxjbrldfgvndzoraqmhf.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4amJybGRmZ3ZuZHpvcmFxbWhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDE0NzksImV4cCI6MjA4NjIxNzQ3OX0.tPzSxlMTfGiF1kpMfWPScJgWXKkY3dhRjUJikPE-w88';

class SupabaseUploadService {
  static Future<String> uploadImage(Uint8List bytes) async {
    final fileName = '${const Uuid().v4()}.jpg';

    final uri = Uri.parse(
      '$supabaseUrl/storage/v1/object/found-items/$fileName',
    );

    final res = await http.put(
      uri,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'image/jpeg',
        'x-upsert': 'true',
      },
      body: bytes, // ✅ RAW BYTES — NOT MULTIPART
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Upload failed ${res.statusCode}: ${res.body}',
      );
    }

    return '$supabaseUrl/storage/v1/object/public/found-items/$fileName';
  }
}
