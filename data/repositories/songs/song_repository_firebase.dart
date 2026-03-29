import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';


class SongRepositoryFirebase extends SongRepository {
  final String baseUrl =
      'test-project-1716e-default-rtdb.asia-southeast1.firebasedatabase.app';

  List<Song>? _cachedSongs;

  @override
  Future<List<Song>> fetchSongs() async {
    
    if (_cachedSongs != null) return _cachedSongs!;

    final Uri songsUri = Uri.https(baseUrl, '/songs.json');
    final response = await http.get(songsUri);

    if (response.statusCode == 200) {
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }

      _cachedSongs = result; 
      return result;
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    final songs = await fetchSongs();

    try {
      return songs.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> increaseLike(String id) async {
    final song = await fetchSongById(id);
    if (song == null) throw Exception("Song not found");

    final int newLikes = song.likes + 1;

    final Uri songUri = Uri.https(baseUrl, '/songs/$id.json');

    final response = await http.patch(
      songUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'like': newLikes}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to increase like');
    }

  }
}
