import 'package:flutter/material.dart';
import 'package:myownflashcard/parts/button_with_icon.dart';
import 'package:myownflashcard/screens/test_screen.dart';
import 'package:myownflashcard/screens/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //ラジオボタンが２択なのでgroupvalueに設定
  //暗記済の単語を含める＝false
  bool isIncludedMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: Image.asset("assets/images/image_title.png")),
            _titleText(),
            // ヨコ線,
            Divider(
              height: 30.0,
              color: Colors.white,
              indent: 8.0,
              endIndent: 8.0,
            ),
            // 確認テストボタン,
            ButtonWithIcon(
              //自作クラスで外出し
              onPressed: () => _startTestScreen(context), // 確認テスト押す操作
              icon: Icon(Icons.play_arrow),
              label: "かくにんテストをする",
              color: Colors.brown,
            ),
            SizedBox(
              height: 10.0,
            ),
            // ラジオボタン,
            //_radioButtons(), //自作メソッドで外出し
            //切り替えトグルSwitch
            _switch(),
            SizedBox(
              height: 30.0,
            ),
            // 単語一覧を見るボタン,
            ButtonWithIcon(
              //自作クラスで外出し
              onPressed: () => _starWordListScreen(context), //
              icon: Icon(Icons.list),
              label: "単語一覧をみる",
              color: Colors.grey,
            ),
            SizedBox(
              height: 60.0,
            ),
            Text(
              "powered by Telulu LLC 2020",
              style: TextStyle(fontFamily: "Mont"),
            ),
            SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText() {
    return Column(
      children: <Widget>[
        Text(
          "私だけの単語帳",
          style: TextStyle(fontSize: 40.0),
        ),
        Text(
          "My Own Frashcard",
          style: TextStyle(fontFamily: "Mont", fontSize: 24.0),
        ),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: <Widget>[
          RadioListTile(
            //valueとgroupValueが一致した時選択される
            //暗記済みの単語を除外するということ(valueのこと)は暗記済の単語を含む(isIncludedMemorizedWords)がイエスにの時false
            value: false,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を含む",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludedMemorizedWords = value; //選んだ選択肢にgroupValueを変えてやる
      print("$valueが選ばれた");
    });
  }

  _starWordListScreen(BuildContext context) {
    //ページ遷移 chap140,141,187参照
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    //コンストラクタ経由でプロパティの値(暗記済の単語を含むかどうか(true or false))を渡す
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  isIncludedMemorizedWords: isIncludedMemorizedWords,
                )));
  }

  Widget _switch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SwitchListTile(
        title: Text("暗記済の単語を含む"),
        value: isIncludedMemorizedWords,
        onChanged: (value){
          setState(() {
            isIncludedMemorizedWords = value;
          });
        },
        secondary: Icon(Icons.sort),
      ),
    );
  }
}
