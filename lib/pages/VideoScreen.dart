import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/youtube_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final List<YoutubeVideo> youtubeVideo;
  final int index;
  final String videoId;
  final Function(YoutubeVideo youtubeVideo) onChange;

  VideoScreen({this.youtubeVideo,this.index,this.onChange,this.videoId});
  @override
  _VideoScreenState createState() => _VideoScreenState(youtubeVideo);
}

class _VideoScreenState extends State<VideoScreen> {
  final List<YoutubeVideo> youtubeVideo;
  _VideoScreenState(this.youtubeVideo);

  @override
  Widget build(BuildContext context) {
    String videoId1 = YoutubePlayer.convertUrlToId(
       "https://www.youtube.com/watch?v=nuGgJqWn9Rs");
    print(videoId1);
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId1.toString(),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    return Scaffold(
      body: Center(
        child: Container(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    );
  }
}
