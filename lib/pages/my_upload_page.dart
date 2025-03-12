import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone_first/model/post_model.dart';
import 'package:insta_clone_first/service/db_service.dart';
import 'package:insta_clone_first/service/file_service.dart';
import '../service/log_service.dart';

class MyUploadPage extends StatefulWidget {
  final PageController? pageController;
  static const String id = '/upload';

  const MyUploadPage({super.key, this.pageController});

  @override
  State<MyUploadPage> createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading = false;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  _uploadNewPost() {
    String caption = _captionController.text.trim();
    if (caption.isEmpty) return;
    if (_image == null) return;
    _apiPostImage();
  }

void  _apiPostImage(){
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(_image!).then((downloadUrl) =>{
      _responsePostImage(downloadUrl),
    });
}

  void _responsePostImage(String downloadUrl){
    String caption = _captionController.text.trim().toString();
    Post post = Post(caption, downloadUrl);
    _apiStorePost(post);
  }
  void _apiStorePost(Post post)async{
    // Post to posts
    Post posted = await DBService.storePost(post);

    // Post to feeds
    DBService.storeFeed(posted).then((value) =>{
      _moveToFeed(),
    });
  }
  _moveToFeed() {
    setState(() {
      isLoading = false;
    });
    _image = null;
    _captionController.clear();
    widget.pageController!.animateToPage(
      0,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  Future<void> _imgFromGallery() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    setState(() {
      _image = File(image!.path);
    });
  }

  Future<void> _imgFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image == null) {
        LogService.i("Kamera yopildi yoki foydalanuvchi rasm tanlamadi.");
        return;
      }

      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      LogService.e(e.toString());
    }
  }

  // Future<void> _requestCameraPermission() async {
  //   var status = await Permission.camera.request();
  //   if (status.isDenied) {
  //     LogService.i("Kamera uchun ruxsat berilmadi!");
  //   } else if (status.isPermanentlyDenied) {
  //     LogService.i("Kamera ruxsati bloklangan, iltimos, qo‘lda ruxsat bering.");
  //     openAppSettings();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Upload', style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: Icon(Icons.drive_folder_upload, color: Color(0xFFF56040)),
              onPressed: () {
                _uploadNewPost();
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    InkWell(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(0.4),
                        child:
                            _image == null
                                ? Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                )
                                : Stack(
                                  children: [
                                    Image.file(
                                      _image!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      color: Colors.black12,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _image = null;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.highlight_remove,
                                              color: Colors.white,
                                            ),
                                          ),
                                          isLoading
                                              ? Center(
                                                child:
                                                    CircularProgressIndicator(color: Color(0xFFF56040),),
                                              )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: TextField(
                        autocorrect: false,
                        controller: _captionController,
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Caption',
                          hintStyle: TextStyle(
                            fontSize: 17,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
