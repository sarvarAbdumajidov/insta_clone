class Member {
  String? uid ;
  String? fullName ;
  String? email ;
  String? password ;
  String? img_url ;
  String? device_id ;
  String? device_token ;
  String? device_type ;

  bool followed = false;
  int followers_count = 0;
  int following_count = 0;

  Member(this.fullName, this.email);

  Member.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    fullName = json['fullName'];
    email = json['email'];
    password = json["password"];
    img_url = json["img_url"];
    device_id = json["device_id"];
    device_token = json["device_token"];
    device_type = json["device_type"];
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'password': password,
    'img_url': img_url,
    'device_id': device_id,
    'device_token': device_token,
    'device_type': device_type,
  };
}
