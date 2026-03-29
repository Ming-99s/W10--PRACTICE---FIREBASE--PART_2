import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  @override
  Future<List<Song>> fetchSongs() async {
    final Uri songsUri = Uri.https(
      'test-project-1716e-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs.json',
    );
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<void> increaseLike(String id) async {
    final Uri songUri = Uri.https(
      'test-project-1716e-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs/$id.json',
    );
    final http.Response response = await http.put(
      songUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        '.sv': {'increment': 1},
      }),
    );

    if (response.statusCode != 200) { 
      throw Exception('Failed to increase like for song $id');
    }
  }
}
