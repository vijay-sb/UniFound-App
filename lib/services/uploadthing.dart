import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadThingService {
  static const String uploadThingEndpoint =
      "https://uploadthing.com/api/uploadFiles";

  static const String UPLOADTHING_TOKEN =
      'eyJhcGlLZXkiOiJza19saXZlX2E4OWZkM2U1ZTk1MDQ4M2M4NmE1YzY5OWQ0NDRhNWEzZWYwOGUyNzc5MTU1OWViMWJlMDlhNGU2ZjM3ODc1MjciLCJhcHBJZCI6IjRnMGdrdGpxbmEiLCJyZWdpb25zIjpbInNlYTEiXX0';
  static Future<String> uploadImage(Uint8List bytes) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(uploadThingEndpoint),
    );

    request.headers["x-uploadthing-api-key"] = UPLOADTHING_TOKEN;

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: "found_item.jpg",
        contentType: MediaType("image", "jpeg"),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("UploadThing upload failed");
    }

    final decoded = json.decode(responseBody);

    // UploadThing returns an array
    return decoded[0]["url"]; // 👈 store this as image_key
  }
}
