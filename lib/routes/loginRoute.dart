/// 登录页面
/// 登录拼写检查和对照正确
/// 可直接点击login button登录
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'portal.dart';
import 'package:untitled/routes/LoginAndRegister/register_route.dart';
import 'package:untitled/db/UserDB/user_db_manager.dart';
import 'package:untitled/routes/LoginAndRegister/forget_password_route.dart';
import 'package:untitled/db/UserDB/UserInfo.dart';
class LoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isObscure = true;
  Color _eyeColor = Colors.grey;
  final List _loginMethod = [
    {
      "title": "facebook",
      "icon": Icons.facebook,
    },
    {
      "title": "google",
      "icon": Icons.fiber_dvr,
    },
    {
      "title": "twitter",
      "icon": Icons.account_balance,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 60),
            buildEmailTextField(), // 输入邮箱
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            buildForgetPasswordText(context), // 忘记密码
            const SizedBox(height: 60),
            buildLoginButton(context), // 登录按钮
            const SizedBox(height: 40),
            buildOtherLoginText(), // 其他账号登录
            buildOtherMethod(context), // 其他登录方式
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('没有账号?'),
            GestureDetector(
              child: const Text('点击注册', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterRoute()),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // 第三方登录
  Widget buildOtherMethod(context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(builder: (context) {
        return IconButton(
            icon: Icon(item['icon'],
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              //TODO: 第三方登录方法
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${item['title']}登录'),
                    action: SnackBarAction(
                      label: '取消',
                      onPressed: () {},
                    )),
              );
            });
      }))
          .toList(),
    );
  }

  Widget buildOtherLoginText() {
    return const Center(
      child: Text(
        '其他账号登录',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  // login登录按钮
  Widget buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('Login',
              style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async {
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              final dbManager = UserDBManager();
              final user = await dbManager.validateUser(_email, _password);
              // 在登录按钮的onPressed方法中，登录成功后获取用户信息并跳转
              if (user != null) {
                // 登录成功, 获取用户信息
                final userInfo = await dbManager.getUserInfo(_email);
                if (userInfo != null) {
                  // userInfo不为null，安全地导航到PortalRoute
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortalRoute(userInfo: userInfo),
                    ),
                  );
                } else {
                  // 处理userInfo为null的情况，比如显示错误消息
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("无法获取用户信息")),
                  );
                }
              } else {
                // 登录失败
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("邮箱或密码错误")),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // 忘记密码
  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordRoute()));
          },
          child: const Text("忘记密码？", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  /// 密码栏
  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
        obscureText: _isObscure, // 是否显示文字
        onSaved: (v) => _password = v!,
        validator: (v) {
          if (v!.isEmpty) {
            return '请输入密码';
          }
        },
        decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = (_isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color)!;
                });
              },
            )));
  }

  /// 邮箱地址输入框
  Widget buildEmailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Email Address'),
      validator: (v) {
        var emailReg = RegExp(
            r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        if (!emailReg.hasMatch(v!)) {
          return '请输入正确的邮箱地址';
        }
      },
      onSaved: (v) => _email = v!,
    );
  }

  /// 标题下方的横线
  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  /// 标题
  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 42),
        ));
  }
}


