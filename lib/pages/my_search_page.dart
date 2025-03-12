import 'package:flutter/material.dart';
import 'package:insta_clone_first/model/member_model.dart';
import 'package:insta_clone_first/service/db_service.dart';

class MySearchPage extends StatefulWidget {
  static const String id = '/search';

  const MySearchPage({super.key});

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  bool isLoading = false;
  final _searchController = TextEditingController();
  List<Member> items = [];

  void _apiFollowMember(Member someone)async{
    setState(() {
      isLoading = true;
    });
    await DBService.followMember(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });
    DBService.storePostsToMyFeed(someone);

  }

  void _apiUnFollowMember(Member someone)async{
    setState(() {
      isLoading = true;
    });
    await DBService.unFollowMember(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });
    DBService.removePostsFromMyFeed(someone);
  }



  void _apiSearchMember(String keyword) {
    setState(() {
      isLoading = true;
    });
    DBService.searchMembers(
      keyword,
    ).then((users) => {_respSearchMembers(users)});
  }

  void _respSearchMembers(List<Member> members) {
    setState(() {
      items = members;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _apiSearchMember("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Search',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // #search member
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        icon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // #member list
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        return _itemOfMember(items[index]);
                      },
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

  Widget _itemOfMember(Member member) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(width: 1.5, color: Color(0xFFF56040)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child:
                  member.img_url!.isEmpty
                      ? Image(
                        image: AssetImage('assets/images/img.png'),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      )
                      : Image(
                        image: NetworkImage(member.img_url!),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3),
              Text(member.email!, style: TextStyle(color: Colors.black54)),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if(member.followed){
                     setState(() {
                       _apiUnFollowMember(member);
                     });
                    }else{
                      setState(() {
                        _apiFollowMember(member);
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: member.followed ? Text('Following') : Text('Follow'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
