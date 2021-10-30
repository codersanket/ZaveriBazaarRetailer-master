import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/post.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class PostService {
  /// Get all posts
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/posts', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get all post in Post Page', e.toString())));
    }
  }

  /// Get post by id
  static Future<Post> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/posts/$id');

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get post on id', e.toString())));
    }
  }

  /// Create post
  static Future<Post> create(FormData formData) async {
    try {
      var response = await DioProvider().dio().post('/posts', data: formData);

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Create post', e.toString())));
    }
  }

  /// Update post
  static Future<Post> update(String postId, FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/posts/$postId', data: formData);

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Update post', e.toString())));
    }
  }

  /// Delete post
  static Future<Post> delete(String postId) async {
    try {
      var response = await DioProvider().dio().delete('/posts/$postId');

      return Future.value(Post.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Delete post', e.toString())));
    }
  }

  //Top 10 products
  static Future<dynamic> getTopPosts() async {
    try {
      var response = await DioProvider().dio().get('/posts/topten');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Top 10 Post', e.toString())));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
