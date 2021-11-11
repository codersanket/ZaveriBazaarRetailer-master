import 'dart:convert';

class YoutubeVideo {
  String id;
  String title;
  String url;
  String createdAt;
  YoutubeVideo({this.id, this.title, this.url, this.createdAt});

  factory YoutubeVideo.fromJson(Map<String, dynamic> parsedJson) {
    return YoutubeVideo(
      id: parsedJson['id']?.toString(),
      title: parsedJson['title']?.toString(),
      url: parsedJson['url']?.toString(),
      createdAt:parsedJson['created_at']?.toString(),
    );
  }
  static List<YoutubeVideo> listFromJson(List<dynamic> list) {
    List<YoutubeVideo> rows =
    list.map((i) => YoutubeVideo.fromJson(i)).toList();
    return rows;
  }
  static List<YoutubeVideo> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<YoutubeVideo>((json) => YoutubeVideo.fromJson(json)).toList();
  }
  Map<String, dynamic> toJson() => {
    'id':id,
    'title':title,
    'url':url,
    'createdAt': createdAt,
  };
}
