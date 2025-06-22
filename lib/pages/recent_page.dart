import 'package:flutter/material.dart';
import 'package:musesync/main.dart';
import 'package:provider/provider.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

class RecentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final style = Theme.of(context).textTheme.displayMedium!.copyWith(
      color: Theme.of(context).colorScheme.inverseSurface,
      fontWeight: FontWeight.normal,
      fontSize: 25.0,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            appState.currentAlbumUrl,
            scale: 0.4,
            width: 250,
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: 400,
              child: Text(
                appState.currentSongTitle,
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton.filled(
                  onPressed: () {
                    appState.prev();
                  },
                  icon: Icon(Icons.skip_previous),
                  color: Theme.of(context).colorScheme.onSecondary,
                  iconSize: 30.0,
                  padding: EdgeInsets.all(12.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton.filled(
                  onPressed: () {
                    appState.play();
                  },
                  icon: Icon(
                    appState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  iconSize: 50.0,
                  padding: EdgeInsets.all(12.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton.filled(
                  onPressed: () {
                    appState.next();
                  },
                  icon: Icon(Icons.skip_next),
                  color: Theme.of(context).colorScheme.onSecondary,
                  iconSize: 30.0,
                  padding: EdgeInsets.all(12.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
