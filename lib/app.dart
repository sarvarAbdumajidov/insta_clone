import 'package:flutter/material.dart';
import 'package:insta_clone_first/pages/home_page.dart';
import 'package:insta_clone_first/pages/my_feed_page.dart';
import 'package:insta_clone_first/pages/my_likes_page.dart';
import 'package:insta_clone_first/pages/my_profile_page.dart';
import 'package:insta_clone_first/pages/my_search_page.dart';
import 'package:insta_clone_first/pages/my_upload_page.dart';
import 'package:insta_clone_first/pages/siginin_page.dart';
import 'package:insta_clone_first/pages/signup_page.dart';
import 'package:insta_clone_first/pages/splash_page.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashPage.id,
      routes: {
        SplashPage.id :(context) => SplashPage(),
        HomePage.id:(context) => HomePage(),
        SignupPage.id : (context) => SignupPage(),
        SignInPage.id:(context) => SignInPage(),
        MyProfilePage.id:(context) =>MyProfilePage(),
        MyLikesPage.id:(context) => MyLikesPage(),
        MyUploadPage.id:(context) => MyUploadPage(),
        MySearchPage.id:(context) =>MySearchPage(),
        MyFeedPage.id:(context) =>MyFeedPage(),
      },
    );
  }
}
