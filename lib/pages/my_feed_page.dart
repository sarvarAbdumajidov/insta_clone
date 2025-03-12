import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone_first/service/db_service.dart';
import 'package:insta_clone_first/service/utils_service.dart';

import '../model/post_model.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;
  static const String id = '/myfeed';

  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
      context,
      'Insta Clone',
      'Do yo want to delete this post?',
      false,
    );
    if (result) {
      setState(() {
        isLoading = true;
      });
      DBService.removePos(post).then((value) =>{
        _apiLoadFeeds(),
      });
    }
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DBService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnLike(Post post) async {
    await DBService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }

  void _apiLoadFeeds() {
    setState(() {
      isLoading = true;
    });
    DBService.loadFeeds().then((posts) => {_resLoadFeeds(posts)});
  }

  void _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _apiLoadFeeds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Instagram',
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Billabong",
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                widget.pageController!.animateToPage(
                  2,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              },
              icon: Icon(Icons.camera_alt, color: Color(0xFFF56040)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return _itemOfPost(items[index]);
              },
            ),
            isLoading
                ? Center(
                  child: CircularProgressIndicator(color: Color(0xFFF56040)),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),

          // #user info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child:
                          post.img_user == null
                              ? Image.asset(
                                "assets/images/img.png",
                                width: 40,
                                height: 40,
                              )
                              : Image.network(
                                post.img_user!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          post.date!,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(
                      onPressed: () {
                        _dialogRemovePost(post);
                      },
                      icon: Icon(Icons.more_horiz),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),

          // #post image
          SizedBox(height: 8),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post!,
            placeholder:
                (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          // #like share
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (!post.liked) {
                        _apiPostLike(post);
                      } else {
                        _apiPostUnLike(post);
                      }
                    },
                    icon:
                        post.liked
                            ? Icon(EvaIcons.heart, color: Colors.red)
                            : Icon(EvaIcons.heartOutline, color: Colors.black),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(EvaIcons.share)),
                ],
              ),
            ],
          ),

          // #caption
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: "${post.caption}",
                style: TextStyle(color: Colors.black),
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
