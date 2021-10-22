import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/post.dart';

class PostService {
  /// Get all posts
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/posts', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get post by id
  static Future<Post> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/posts/$id');

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Create post
  static Future<Post> create(FormData formData) async {
    try {
      var response = await DioProvider().dio().post('/posts', data: formData);

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Update post
  static Future<Post> update(String postId, FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/posts/$postId', data: formData);

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Delete post
  static Future<Post> delete(String postId) async {
    try {
      var response = await DioProvider().dio().delete('/posts/$postId');

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //Top 10 products
  static Future<dynamic> getTopPosts() async {
    try {
      var response = await DioProvider().dio().get('/posts/topten');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
