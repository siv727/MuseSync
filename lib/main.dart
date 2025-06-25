import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/player_page.dart';
import 'pages/search_page.dart';
import 'pages/recent_page.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'MuseSync',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
        ),

        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final String defaultAlbumCover =
      'https://upload.wikimedia.org/wikipedia/commons/3/3c/No-album-art.png';
  final SoundcloudClient client = SoundcloudClient();
  final AudioPlayer player = AudioPlayer();
  final List<String> songs = [
    'https://soundcloud.com/no-no-376380923/persona-3-reload-dont-by-azumi',
    'https://soundcloud.com/tribaltrapmusic/tucadonka',
    'https://soundcloud.com/ersona4ancingllight/dance',
    'https://soundcloud.com/jamieirl/machine-love',
    'https://soundcloud.com/lczvfx/atlxs-passo-bem-solto-slowed',
  ];
  bool isInitialized = false;
  bool isPlaying = false;
  bool shuffleOn = false;
  int songNum = 0;
  int previous = 0;
  String currentTitle = '';
  Uri? currentAlbum;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  MyAppState() {
    player.playerStateStream.listen((state) {
      final playing = state.playing;
      if (playing != isPlaying) {
        isPlaying = playing;
        notifyListeners();
      }
      if (isPlaying == true && position.inSeconds == duration.inSeconds) {
        next();
      }
    });

    player.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });

    player.durationStream.listen((d) {
      duration = d!;
      notifyListeners();
    });
  }

  // THIS ENTIRE BATCH OF FUNCTIONS ARE FOR BASIC MUSIC PLAYER CONTROLS
  Future<void> loadTrack(String url) async {
    final track = await client.tracks.getByUrl(url);
    position = Duration(seconds: 0);
    currentTitle = track.title;
    currentAlbum = track.artworkUrl;
    notifyListeners();
    final streams = await client.tracks.getStreams(track.id);
    // Use the first stream (or filter for mp3 if you want)
    await player.setUrl(streams.first.url);
    isInitialized = true;
  }

  Future<void> play() async {
    if (!isInitialized) {
      // Load a default track before playing
      if (shuffleOn) {
        songNum = Random().nextInt(songs.length);
        if (songNum == previous) {
          songNum += 2;
        }
      }
      previous = songNum;
      await loadTrack(songs[songNum]);
    }
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> playPickedSong(String url) async {
    await loadTrack(url);
    await player.play();
  }

  Future<void> next() async {
    if (++songNum > songs.length - 1) {
      songNum = 0;
    }
    player.stop();
    currentTitle = '';
    currentAlbum = null;
    isInitialized = false;
    play();
  }

  Future<void> prev() async {
    if (--songNum < 0) {
      songNum = songs.length - 1;
    }
    player.stop();
    currentTitle = '';
    currentAlbum = null;
    isInitialized = false;
    play();
  }

  // TRACK DETAILS
  String get currentAlbumUrl => currentAlbum?.toString() ?? defaultAlbumCover;

  String get currentSongTitle => currentTitle;

  // PLAYER SLIDER
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  // TEMPORARY SHUFFLE METHOD (FIXED SONG LIST)
  // To handle prev method I was thinking a stack of previously played; a history of sorts in the final implementation
  void shuffle() {
    shuffleOn = !shuffleOn;
    notifyListeners();
  }

  final Map<String, Map<String, dynamic>> _trackDetailsCache = {};

  Future<String> getTitleFromUrl(String url) async {
    try {
      if (_trackDetailsCache.containsKey(url)) {
        return _trackDetailsCache[url]!['title'] as String;
      }

      final track = await client.tracks.getByUrl(url);

      _trackDetailsCache[url] = {
        'title': track.title,
        'artworkUrl': track.artworkUrl,
      };

      return track.title;
    } catch (e) {
      return 'Unknown Track';
    }
  }

  Future<Uri?> getArtworkFromUrl(String url) async {
    try {
      if (_trackDetailsCache.containsKey(url)) {
        return _trackDetailsCache[url]!['artworkUrl'] as Uri?;
      }

      final track = await client.tracks.getByUrl(url);

      _trackDetailsCache[url] = {
        'title': track.title,
        'artworkUrl': track.artworkUrl,
      };

      return track.artworkUrl;
    } catch (e) {
      return null;
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = RecentPage();
      case 1:
        page = SearchPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: page,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('MuseSync'),
      ),
      body: Column(
        children: [
          Expanded(child: mainArea),
          SafeArea(
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
