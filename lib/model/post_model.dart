class Post {
  String? uid;
  String? fullName;
  String? img_user;
  String? id;
  String? date;
  bool liked = false;
  bool mine = false;
  String? img_post;
  String? caption;

  Post(this.caption, this.img_post);

  Post.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    fullName = json['fullName'];
    img_user = json['img_user'];
    id = json['id'];
    date = json['date'];
    liked = json['liked'];
    img_post = json['img_post'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "img_user": img_user,
    "id": id,
    "date": date,
    "liked": liked,
    "img_post": img_post,
    "caption": caption,
  };
}
