// services/supabase_upload_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const String SUPABASE_URL = 'https://vxjbrldfgvndzoraqmhf.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4amJybGRmZ3ZuZHpvcmFxbWhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDE0NzksImV4cCI6MjA4NjIxNzQ3OX0.tPzSxlMTfGiF1kpMfWPScJgWXKkY3dhRjUJikPE-w88';

class SupabaseUploadService {
  static Future<String> uploadImage(Uint8List bytes) async {
    final fileName = '${const Uuid().v4()}.jpg';

    final uri = Uri.parse(
      '$SUPABASE_URL/storage/v1/object/found-items/$fileName',
    );

    final res = await http.put(
      uri,
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': 'Bearer $SUPABASE_ANON_KEY',
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

    return '$SUPABASE_URL/storage/v1/object/public/found-items/$fileName';
  }
}
