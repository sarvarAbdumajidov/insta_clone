import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone_first/model/member_model.dart';
import 'package:insta_clone_first/service/auth_service.dart';
import 'package:insta_clone_first/service/db_service.dart';
import 'package:insta_clone_first/service/file_service.dart';
import '../model/post_model.dart';
import '../service/log_service.dart';
import '../service/utils_service.dart';

class MyProfilePage extends StatefulWidget {
  static const String id = '/profile';

  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  List<Post> items = [];
  bool isLoading = false;
  File? _image;
  String fullName = "";
  String email = "";
  String img_url = "";
  int count_posts = 0;
  int count_followers = 0;
  int count_following = 0;
  int axisCount = 1;
  final _picker = ImagePicker();

  void _dialogSignOut() async {
    var result = await Utils.dialogCommon(
      context,
      'Insta Clone',
      'Do you want to log out?',
      false,
    );
    if (result) {
      setState(() {
        isLoading = true;
      });
      AuthService.signOut(context);

    }
  }

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
        _apiLoadPosts(),
      });
    }
  }

  Future<void> _imgFromGallery() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  Future<void> _imgFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) {
        LogService.i("Kamera yopildi yoki foydalanuvchi rasm tanlamadi.");
        return;
      }

      setState(() {
        _image = File(image.path);
      });
      _apiChangePhoto();
    } catch (e) {
      LogService.e(e.toString());
    }
  }

  void _apiLoadPosts() {
    DBService.loadPosts().then((value) => {_responseLoadPosts(value)});
  }

  void _responseLoadPosts(List<Post> posts) {
    setState(() {
      items = posts;
      count_posts = posts.length;
    });
  }

  @override
  void initState() {
    _apiLoadMember();
    _apiLoadPosts();
    super.initState();
  }

  void _apiChangePhoto() {
    if (_image == null) return;
    setState(() {
      isLoading = true;
    });
    FileService.uploadUserImage(
      _image!,
    ).then((downloadUrl) => {_apiUpdateUser(downloadUrl)});
  }

  void _apiUpdateUser(String downloadUrl) async {
    Member? member = await DBService.loadMember();

    member!.img_url = downloadUrl;
    await DBService.updateMember(member);
    _apiLoadMember();
  }

  void _apiLoadMember() {
    setState(() {
      isLoading = true;
    });
    DBService.loadMember().then((value) => {_showMemberInfo(value!)});
  }

  void _showMemberInfo(Member member) {
    setState(() {
      isLoading = false;
      this.fullName = member.fullName!;
      this.email = member.email!;
      this.img_url = member.img_url!;
      this.count_following = member.following_count;
      this.count_followers = member.followers_count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                _dialogSignOut();
              },
              icon: Icon(Icons.exit_to_app, color: Color(0xFFF56040)),
            ),
          ],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: TextStyle(
              fontFamily: "Billabong",
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                children: [
                  // #my photo
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Pick photo
                                InkWell(
                                  onTap: () {
                                    _imgFromGallery();
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.image),
                                      SizedBox(width: 10),
                                      Text('Pick Photo'),
                                    ],
                                  ),
                                ),

                                // Take photo
                                InkWell(
                                  onTap: () {
                                    // _requestCameraPermission();
                                    _imgFromCamera();
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.camera_alt_outlined),
                                      SizedBox(width: 10),
                                      Text('Take Photo'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      // _imgFromGallery();
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(70),
                            border: Border.all(
                              width: 1.5,
                              color: Color(0xFFF56040),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child:
                                img_url.isEmpty
                                    ? Image.asset(
                                      'assets/images/img.png',
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.network(
                                      img_url,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.add_circle, color: Colors.purple),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    fullName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 13),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  // #myaccoutns
                  SizedBox(
                    // margin: EdgeInsets.only(top: 20),
                    height: 80,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_posts.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'POSTS',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_followers.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'FOLLOWERS',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_following.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'FOLLOWING',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 1;
                            });
                          },
                          icon: Icon(Icons.list_alt_outlined, size: 25),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 2;
                            });
                          },
                          icon: Icon(Icons.grid_view_outlined, size: 25),
                        ),
                      ],
                    ),
                  ),

                  // #myposts
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                      child: GridView.builder(
                        key: ValueKey<int>(axisCount),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: axisCount,
                        ),
                        itemCount: items.length,
                        itemBuilder: (ctx, index) {
                          return _itemOfPost(items[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return InkWell(
      onLongPress: (){
        _dialogRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                width: double.infinity,
                imageUrl: post.img_post!,
                placeholder:
                    (context, url) => Center(
                      child: CircularProgressIndicator(color: Color(0xFFF56040)),
                    ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 3),
            Text(
              post.caption!,
              style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
