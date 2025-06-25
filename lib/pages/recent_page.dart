import 'package:flutter/material.dart';
import 'package:musesync/main.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
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
            scale: 0.1,
            width: 360,
            height: 360,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: 365,
              height: 30,
              child:
                  (appState.currentSongTitle.isEmpty ||
                      appState.currentSongTitle.length <= 20)
                  ? Text(
                      appState.currentSongTitle,
                      style: style,
                      textAlign: TextAlign.start,
                    )
                  : Marquee(
                      text: appState.currentSongTitle,
                      style: style,
                      blankSpace: 20,
                      pauseAfterRound: const Duration(seconds: 3),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      velocity: 60,
                      accelerationDuration: const Duration(seconds: 1),
                      decelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      fadingEdgeEndFraction: 0.3,
                      textDirection: TextDirection.ltr,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 23.0, right: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appState.formatDuration(appState.position)),
                Text(appState.formatDuration(appState.duration)),
              ],
            ),
          ),
          Center(
            child: Slider(
              min: 0.0,
              max: appState.duration.inSeconds.toDouble(),
              value: appState.position.inSeconds.toDouble(),
              onChanged: appState.handleSeek,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  onPressed: () {
                    appState.shuffle();
                  },
                  icon: Icon(
                    appState.shuffleOn
                        ? Icons.shuffle_on_outlined
                        : Icons.shuffle_outlined,
                  ),
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      enableDrag: true,
                      showDragHandle: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Song Queue',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: appState.songs.length,
                                  itemBuilder: (context, index) {
                                    final String song = appState.songs[index];
                                    return ListTile(
                                      onTap: () {
                                        appState.playPickedSong(song);
                                      },
                                      leading: FutureBuilder<Uri?>(
                                        future: appState.getArtworkFromUrl(
                                          song,
                                        ),
                                        builder: (context, snapshot) {
                                          return Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  snapshot.data?.toString() ??
                                                      appState
                                                          .defaultAlbumCover,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      title: FutureBuilder<String>(
                                        future: appState.getTitleFromUrl(song),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'Loading...',
                                            style: TextStyle(
                                              fontWeight:
                                                  // isCurrentSong
                                                  //     ? FontWeight.bold:
                                                  FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textWidthBasis:
                                                TextWidthBasis.parent,
                                            maxLines: 1,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.queue_music),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
