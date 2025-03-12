import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_clone_first/model/member_model.dart';
import 'package:insta_clone_first/service/auth_service.dart';
import 'package:insta_clone_first/service/log_service.dart';
import 'package:insta_clone_first/service/utils_service.dart';

import '../model/post_model.dart';

class DBService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String folder_users = 'users';
  static const String folder_posts = 'posts';
  static const String folder_feeds = 'feeds';
  static const String folder_followers = 'followers';
  static const String folder_following = 'following';

  /**
   * Member
   */

  /// **Foydalanuvchini Firestore-ga saqlash**
  static Future<void> storeMember(Member member) async {
    member.uid = AuthService.currentUserId();
    Map<String, dynamic> params = await Utils.deviceParams();

    LogService.i('Params: $params');

    member
      ..device_id = params['device_id']
      ..device_type = params['device_type']
      ..device_token = params['device_token'];

    await _firestore
        .collection(folder_users)
        .doc(member.uid)
        .set(member.toJson());
  }

  /// **Foydalanuvchi ma'lumotlarini yuklash**
  static Future<Member?> loadMember() async {
    String uid = AuthService.currentUserId();
    DocumentSnapshot<Map<String, dynamic>> value =
        await _firestore.collection(folder_users).doc(uid).get();

    Member member = Member.fromJson(value.data()!);

    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(uid)
            .collection(folder_followers)
            .get();

    member.followers_count = querySnapshot.docs.length;
    var querySnapshot2 =
        await _firestore
            .collection(folder_users)
            .doc(uid)
            .collection(folder_following)
            .get();

    member.following_count = querySnapshot2.docs.length;

    return member;
  }

  /// **Foydalanuvchini yangilash**
  static Future<void> updateMember(Member member) async {
    await _firestore
        .collection(folder_users)
        .doc(member.uid)
        .update(member.toJson());
  }

  /// **Foydalanuvchilarni qidirish**
  static Future<List<Member>> searchMembers(String keyword) async {
    String uid = AuthService.currentUserId();
    List<Member> members = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore
            .collection(folder_users)
            .where('email', isGreaterThanOrEqualTo: keyword)
            .where(
              'email',
              isLessThan: keyword + '\uf8fff',
            ) // Yaxshi qidiruv natijalari uchun
            .get();

    for (var result in querySnapshot.docs) {
      Member member = Member.fromJson(result.data());
      if (uid != member.uid) {
        members.add(member);
      }
    }

    return members;
  }

  /**
   * Post
   */
  static Future<Post> storePost(Post post) async {
    Member? member = await loadMember();
    post.uid = member!.uid;
    post.fullName = member.fullName;
    post.img_user = member.img_url;
    post.date = Utils.currentDate();

    String postId =
        _firestore
            .collection(folder_users)
            .doc(member.uid)
            .collection(folder_posts)
            .doc()
            .id;
    post.id = postId;
    await _firestore
        .collection(folder_users)
        .doc(member.uid)
        .collection(folder_posts)
        .doc(postId)
        .set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String uid = AuthService.currentUserId();
    await _firestore
        .collection(folder_users)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];

    String uid = AuthService.currentUserId();
    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(uid)
            .collection(folder_posts)
            .get();

    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJson(result.data()));
    });

    return posts;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];

    String uid = AuthService.currentUserId();

    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(uid)
            .collection(folder_feeds)
            .get();

    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJson(result.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    });

    return posts;
  }

  static Future likePost(Post post, bool liked) async {
    String uid = AuthService.currentUserId();
    post.liked = liked;
    await _firestore
        .collection(folder_users)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .set(post.toJson());

    if (uid == post.uid) {
      await _firestore
          .collection(folder_users)
          .doc(uid)
          .collection(folder_posts)
          .doc(post.id)
          .set(post.toJson());
    }
  }

  static Future<List<Post>> loadLikes() async {
    List<Post> posts = [];
    String uid = AuthService.currentUserId();

    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(uid)
            .collection(folder_feeds)
            .where("liked", isEqualTo: true)
            .get();
    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJson(result.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    });

    return posts;
  }

  static Future<Member> followMember(Member someone) async {
    Member? me = await loadMember();

    // I followed to someone
    await _firestore
        .collection(folder_users)
        .doc(me!.uid)
        .collection(folder_following)
        .doc(someone.uid)
        .set(someone.toJson());

    // I am someone's followers
    await _firestore
        .collection(folder_users)
        .doc(someone.uid)
        .collection(folder_followers)
        .doc(me.uid)
        .set(me.toJson());
    return someone;
  }

  static Future<Member> unFollowMember(Member someone) async {
    Member? me = await loadMember();

    // I unfollowed to someone
    await _firestore
        .collection(folder_users)
        .doc(me!.uid)
        .collection(folder_following)
        .doc(someone.uid)
        .delete();

    // I am  not someone's followers
    await _firestore
        .collection(folder_users)
        .doc(someone.uid)
        .collection(folder_followers)
        .doc(me.uid)
        .delete();
    return someone;
  }

  static Future storePostsToMyFeed(Member someone) async {
    List<Post> posts = [];
    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(someone.uid)
            .collection(folder_posts)
            .get();

    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJson(result.data());
      post.liked = false;
      posts.add(post);
    });

    for (Post post in posts) {
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(Member someone) async {
    List<Post> posts = [];
    var querySnapshot =
        await _firestore
            .collection(folder_users)
            .doc(someone.uid)
            .collection(folder_posts)
            .get();

    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJson(result.data()));
    });

    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String uid = AuthService.currentUserId();
    return await _firestore
        .collection(folder_users)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .delete();
  }

  static Future removePos(Post post) async {
    String uid = AuthService.currentUserId();
    await removeFeed(post);
    return await _firestore
        .collection(folder_users)
        .doc(uid)
        .collection(folder_posts)
        .doc(post.id)
        .delete();
  }
}
