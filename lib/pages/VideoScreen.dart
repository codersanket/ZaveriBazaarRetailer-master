import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/youtube_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final YoutubeVideo youtubeVideo;
  final int index;
  final String videoId;
  //final Function(YoutubeVideo youtubeVideo) onChange;

  VideoScreen({this.youtubeVideo,this.index,this.videoId});
  @override
  _VideoScreenState createState() => _VideoScreenState(youtubeVideo);
}

class _VideoScreenState extends State<VideoScreen> {
  //final List<YoutubeVideo> youtubeVideo;
  final YoutubeVideo youtubeVideo;
  _VideoScreenState(this.youtubeVideo);

  @override
  Widget build(BuildContext context) {
    String videoId1 = YoutubePlayer.convertUrlToId(
    //   "https://www.youtube.com/watch?v=nuGgJqWn9Rs"
    youtubeVideo.url
    );
    // String videoId1 = YoutubePlayer.convertUrlToId(
    //     widget.videoId);
    print(videoId1);
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId1.toString(),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(youtubeVideo.title, overflow: TextOverflow.fade,),),
      body: Center(
        child: Container(
          color: Colors.black,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    );
  }
}
