import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone_first/model/member_model.dart';
import 'package:insta_clone_first/service/auth_service.dart';
import 'package:insta_clone_first/service/db_service.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  static const String id = '/signup';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _validateName(String? res) {
    String value = res!.trim();
    if (value == null || value.trim().isEmpty) {
      return 'Enter your name!';
    }
    final RegExp nameExp = RegExp(r"^[a-zA-Z'`’]+$");
    if (!nameExp.hasMatch(value)) {
      return 'The name must contain only letters!';
    }
    if (value.trim().length < 2) {
      return 'The name is too short!';
    }
    return null; // Agar hammasi to‘g‘ri bo‘lsa
  }

  String? _validateEmail(String? res) {
    String value = res!.trim();
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email!';
    }

    final RegExp emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailExp.hasMatch(value)) {
      return 'Invalid email format!';
    }

    return null;
  }

  String? _validatePassword(String? res) {
    String value = res!.trim();
    if (value == null || value.trim().isEmpty) {
      return 'Enter the password!';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long!';
    }

    final RegExp passwordExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
    );
    if (!passwordExp.hasMatch(value)) {
      return 'Password must contain at least 1 letter and 1 number!';
    }

    return null;
  }

  String? _validateConfirmPassword(String? res, String pass) {
    String value = res!.trim();
    String password = pass.trim();
    if (value == null || value.trim().isEmpty) {
      return 'Re-enter the password!';
    }

    if (value != password) {
      return 'Passwords did not match!';
    }

    return null;
  }

  _doSignUp() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmController.text.trim();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });
    var response = await AuthService.signUpUser(fullName, email, password);
    Member member = Member(fullName, email);
    DBService.storeMember(member).then((value) => {storeMemberToDB(member)});
  }

  void storeMemberToDB(Member member) {
    setState(() {
      isLoading = false;
    });
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  _callSignIn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFCAF45), Color(0xFFF56040)],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Insta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontFamily: 'Billabong',
                            ),
                          ),

                          // #name
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextFormField(
                              validator: _validateName,
                              autocorrect: false,
                              controller: _fullNameController,
                              keyboardType: TextInputType.name,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'FullName',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),

                          // #email
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextFormField(
                              validator: _validateEmail,
                              autocorrect: false,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),

                          // #password
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextFormField(
                              validator: _validatePassword,
                              autocorrect: false,
                              obscureText: true,
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),

                          // #confirmPassword
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextFormField(
                              validator:
                                  (value) => _validateConfirmPassword(
                                    value,
                                    _passwordController.text.trim(),
                                  ),
                              autocorrect: false,
                              obscureText: true,
                              controller: _confirmController,
                              keyboardType: TextInputType.visiblePassword,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Confirm password',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),

                          // #signin button
                          InkWell(
                            onTap: () {
                              _doSignUp();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.white,
                                ),
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already hava an account?",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              _callSignIn();
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF56040),
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
