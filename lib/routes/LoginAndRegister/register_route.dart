import 'package:flutter/material.dart';
import 'package:untitled/db/UserDB/user_db_manager.dart';
import 'package:drift/drift.dart' as drift;
import 'package:untitled/routes/loginRoute.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class RegisterRoute extends StatefulWidget {
  @override
  _RegisterRouteState createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String  _password, _verificationCode;
  bool isCodeSent = false;
  // 定义TextEditingController
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("注册宠爱"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            SizedBox(height: 20),
            // 可以添加一个图片
            Image.asset(
              'assets/image/login/2.png', // 替换为你的图片路径
              height: 200, // 根据需要调整
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController, // 使用控制器
              decoration: InputDecoration(labelText: '请输入邮箱'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '邮箱不能为空';
                } else if (!isEmailValid(value)) {
                  // 使用isEmailValid函数检查邮箱格式
                  return '请输入有效的邮箱地址';
                }
                return null;
              },

            ),
            TextFormField(
              decoration: InputDecoration(labelText: '请输入密码'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '密码不能为空';
                } else if (!isPasswordValid(value)) {
                  return '密码需8-16位，包含字母和数字，不含特殊字符';
                }
                return null;
              },
              onSaved: (value) => _password = value!,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: '请输入验证码'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '验证码不能为空';
                      }
                      return null;
                    },
                    onSaved: (value) => _verificationCode = value!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 直接从控制器中获取手机号
                    String email = _emailController.text;
                    print("邮箱如下: $email");
                    if (email.isNotEmpty) {
                      sendVerificationCode(email);
                      setState(() {
                        isCodeSent = true;
                      });
                    } else {
                      // 提示用户输入邮箱
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("请输入邮箱")));
                    }
                  },
                  child: Text('发送验证码'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // 调用验证码验证函数
                  bool verificationPassed = await checkVerificationCode(_emailController.text, _verificationCode);
                  if (verificationPassed) {
                    // 实例化UserDBManager
                    final dbManager = UserDBManager();

                    // 创建UsersCompanion对象
                    final user = UsersCompanion(
                      email: drift.Value(_emailController.text),
                      password: drift.Value(_password), // 注意: 实际应用中应先加密密码
                      name: drift.Value("火锅配油碟"), // 设置默认用户名
                      avatar: drift.Value("assets/avatar/avatar1.jpg"), // 设置默认头像
                      address: drift.Value("重庆"), // 设置默认地址
                    );

                    // 调用addUser方法插入数据
                    await dbManager.addUser(user).then((userId) {
                      // 注册成功后的逻辑，比如提示用户注册成功或跳转到登录页面
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("注册成功，用户ID: $userId")));
                      // 跳转到登录页面
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRoute()));
                    }).catchError((error) {
                      // 处理可能出现的错误，比如邮箱已存在等
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("注册失败: $error")));
                    });
                  } else {
                    // 验证码不正确的处理逻辑
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("验证码错误")));
                  }
                }
              },
              child: Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  bool isEmailValid(String email) {
    // 一般邮箱的正则表达式
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    // 密码的正则表达式，要求至少8-16个字符，至少包含一个字母和一个数字，不允许特殊字符
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Future<void> sendVerificationCode(String email) async {
    print("执行sendVerificationCode！");
    final uri = Uri.parse('http://10.230.8.14:8081/api/user/code');
    final response = await http.post(uri, body: {
      'email': email,
      // 可能还需要其他参数，根据API的要求
    });
    if (response.statusCode == 200) {
      // 请求成功，处理响应
      final data = jsonDecode(response.body);
      print('验证码发送成功: $data');
      // 根据返回的数据进行处理，比如更新UI提示用户验证码已发送
    } else {
      // 请求失败，处理错误
      print('验证码发送失败: ${response.body}');
      // 根据错误进行处理，比如提示用户重试
    }
  }

  // 假设添加一个新函数checkVerificationCode，用于验证验证码
  Future<bool> checkVerificationCode(String email, String verificationCode) async {
    print("执行checkVerificationCode");
    final uri = Uri.parse('http://10.230.8.14:8081/api/user/login');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json', // 设置请求头
      },
      body: jsonEncode({
        'email': email,
        'code': verificationCode, // 用户输入的验证码
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success']; // 假设API返回的格式中有个success字段表示验证是否成功
    } else {
      // 如果请求失败，可以根据需要处理，比如打印日志或者返回false
      print('验证码验证失败: ${response.body}');
      return false;
    }
  }


}
