import 'package:flutter/material.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

class RecentPage extends StatelessWidget {
  final SoundcloudClient client = SoundcloudClient();
  final AudioPlayer player = AudioPlayer();
  final List<String> songs = [
    'https://soundcloud.com/no-no-376380923/persona-3-reload-dont-by-azumi',
    'https://soundcloud.com/tribaltrapmusic/tucadonka',
    'https://soundcloud.com/ersona4ancingllight/dance',
    'https://soundcloud.com/jamieirl/machine-love',
    'https://soundcloud.com/duranduran/invisible',
  ];
  bool isInitialized = false;
  int songNum = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              prev(--songNum);
            },
            icon: Icon(Icons.skip_previous),
            label: Text('Prev'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              play(songNum);
            },
            icon: Icon(Icons.play_arrow),
            label: Text('Play Song'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              next(++songNum);
            },
            icon: Icon(Icons.skip_next),
            label: Text('Next'),
          ),
        ],
      ),
    );
  }

  Future<void> loadTrack(String url) async {
    final track = await client.tracks.getByUrl(url);
    final streams = await client.tracks.getStreams(track.id);
    // Use the first stream (or filter for mp3 if you want)
    await player.setUrl(streams.first.url);
    isInitialized = true;
  }

  Future<void> play(int num) async {
    if (!isInitialized) {
      // Load a default track before playing
      await loadTrack(songs[num]);
    }
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> next(int songNum) async {
    if (songNum > songs.length - 1) {
      songNum = 0;
    }
    player.stop();
    isInitialized = false;
    play(songNum);
  }

  Future<void> prev(int songNum) async {
    if (songNum < 0) {
      songNum = songs.length - 1;
    }
    player.stop();
    isInitialized = false;
    play(songNum);
  }
}
