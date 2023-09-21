import 'package:boilerplate/domain/entity/post/post.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/post/post_detail.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String detailPost = '/detail-post';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    detailPost: (BuildContext context) => PostDetailScreen(
        post: ModalRoute.of(context)?.settings.arguments as Post)
  };
}
