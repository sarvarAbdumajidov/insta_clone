import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:insta_clone_first/service/auth_service.dart';
import 'package:insta_clone_first/service/log_service.dart';

class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static final folder_user = "user_images";
  static final folder_post = "post_images";

  static Future<String> uploadUserImage(File _image) async {
    String uid = AuthService.currentUserId();
    String img_name = uid;
    var firebaseStorageRef = _storage.child(folder_user).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    final String downloadUrl = await firebaseStorageRef.getDownloadURL();
    LogService.d("DOWNLOAD URL $downloadUrl");
    return downloadUrl;
  }

  static Future<String> uploadPostImage(File _image) async {
    String uid = AuthService.currentUserId();
    String img_name = "${uid}_${DateTime.now()}";
    var firebaseStorageRef = _storage.child(folder_post).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    final String downloadUrl = await firebaseStorageRef.getDownloadURL();
    LogService.d("DOWNLOAD URL $downloadUrl");
    return downloadUrl;
  }
}
