import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'my_feed_page.dart';
import 'my_likes_page.dart';
import 'my_profile_page.dart';
import 'my_search_page.dart';
import 'my_upload_page.dart';

class HomePage extends StatefulWidget {
  static const String id = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController? _pageController;
  int _currentTap = 0;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          MyFeedPage(pageController: _pageController),
          MySearchPage(),
          MyUploadPage(pageController: _pageController),
          MyLikesPage(),
          MyProfilePage(),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTap = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (int index) {
          setState(() {
            _currentTap = index;
            _pageController!.animateToPage(
              index,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          });
        },
        currentIndex: _currentTap,
        activeColor: Color(0xFFF56040),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.add_box, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 32)),
        ],
      ),
    );
  }
}
