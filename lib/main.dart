import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/DiseaseDB/init_db.dart';
import 'db/MedicineDB/init_medicine_db.dart';
import 'routes/test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/DiseaseDB/init_db.dart';
import 'db/MedicineDB/init_medicine_db.dart';
import 'db/PostDB/init_post_db.dart';
import 'routes/test.dart';
import 'db/DailyRecordDB/dailyrecord_db_manager.dart';
import 'db/DailyRecordDB/init_dailyrecord.dart';
import 'common/global.dart';
import 'routes/loginRoute.dart';
import 'routes/intro_page/intro_page_view.dart';

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeDatabase();
  // await initializeMedicineDatabase();
  // await initializePostDatabase();
  // await initializeDailyRecordDatabase();
  runApp(const MyApp());
}

// void main() => Global.init().then((e) => runApp(MyApp()));
// MyAPP是应用的入口Widgt

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  MaterialColor convertToMaterialColor(ColorSwatch colorSwatch) {
    Map<int, Color> swatchColors = colorSwatch as Map<int, Color>;
    return MaterialColor(colorSwatch[500]!.value, swatchColors);
  }

  // MaterialAPP依赖ThemeModel和LocalModel，当APP主题或语言改变时，MaterialAPP重构
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_)=>ThemeModel()),
        ChangeNotifierProvider(create: (_)=>UserModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (BuildContext content, themeModel,child){
          // 下面这一句是设置主题的 但是加上有问题
          // MaterialColor materialColor = convertToMaterialColor(themeModel.theme);
          return MaterialApp(
            title: '宠爱',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              // primarySwatch: materialColor,
            ),
            // home: const MyHomePage(title: 'Flutter Demo Home Page22222'),
            // home: HomeRoute(),
            home: IntroPageView(),

            // locale: localeModel.getLocale(),
            routes: <String, WidgetBuilder>{
              "login": (context) => LoginRoute(),
              // "themes": (context) => ThemeChangeRoute(),
              // "language": (context) => LanguageRoute(),
            },
          );
        },
      ),
    );
  }
}


// 以下为app创建时自带页面
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
