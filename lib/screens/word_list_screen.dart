import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';
import 'package:toast/toast.dart';

import 'edit_screen.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  //database.dart内でFuture<List<Word>>で定義されているため戻り値として取得した結果を格納するList<Word>を定義
  //単語一覧を表示するためのデータを格納するためのListプロパティ
  List<Word> _wordList = List();

  @override
  void initState() {
    super.initState();
    _getAllWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("単語一覧"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: "暗記済の単語を下になるようにソート",
            onPressed: () => _sortWords(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //Scaffoldが元々持っている要素
        onPressed: () => addNewWord(), //押すと編集画面へ chap191引数にcontextがいらないのはなぜ？
        child: Icon(Icons.add), //+表示
        tooltip: "新しい単語の登録", //長押しするとボタンが何してくれるかの情報補足
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _wordListWidget(),
      ), // body入力
    );
  }

  //ページ遷移するのにaddNewWordの引数にBuildContext contextをセットしなくて良いのはなぜか？？
  addNewWord() {
    //編集した内容を反映させるためにpushReplacement
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditScreen(
                  //編集したい文字はないのでstatusだけedit_screenへ持っていく
                  status: EditStatus.ADD,
                )));
  }

  void _getAllWords() async {
    //なぜdatabase.allWordsで取ってこれる？databaseはmain.dartで定義
    _wordList = await database.allWords;
    //asyncとawaitの結果をbuild回る前に反映させるためににasync/await終わった瞬間setState回す
    setState(() {});
  }

  Widget _wordListWidget() {
    //ListerView引数付きコンストラクタで
    return ListView.builder(
        itemCount: _wordList.length, //リストの中の行数(設定必須)
        //positionはwordList内の特定の行番号
        itemBuilder: (context, int position) => _wordItem(position));
  }

  Widget _wordItem(int position) {
    //リストの１行分のwidgetをitemBuilderから外出し
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
      color: Colors.blueAccent.shade200,
      child: ListTile(
        title: Text(
            "${_wordList[position].strQuestion}" //"${プロパティにアクセス}"で文字列内に持ってこれる
        ),
        subtitle: Text(
          "${_wordList[position].strAnswer}",
          style: TextStyle(fontFamily: "Mont"),
        ),
        //暗記済チェックマークを出す出さないの三項条件分岐isMemorizedがtrueならアイコン出す
        trailing:
        _wordList[position].isMemorized ? Icon(Icons.check_circle) : null,
        onTap: () => _editWord(_wordList[position]),
        onLongPress: () => _deleteWord(_wordList[position]),
      ),
    ); //return文の終わりはセミコロン
  }

  _deleteWord(Word selectedWord) async {
    showDialog(context: context,
        barrierDismissible:false,
        builder: (_) =>
        AlertDialog(
          title: Text(selectedWord.strQuestion),
          content: Text("削除しても良いですか?"),
          actions: <Widget>[
            FlatButton(child: Text("はい"),
              onPressed: () async {
                await database.deleteWord(selectedWord);
                //database内の削除は行われるが、取ってきて格納した_wordListは更新されていない＝＞削除後もう一度データ取ってこれば良い
                Toast.show("削除完了しました", context);
                _getAllWords();
                Navigator.pop(context);
              },),
            FlatButton(child: Text("いいえ"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ));
  }

  _editWord(Word selectedWord) {
    //編集したい文字の行情報とstatusの２つをedit_screenへ持っていく
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }

  //database.dartに記載したクエリメソッドを使って呼び出しchap247
  //今回はソートだが、暗記済の単語を出したり消えたりする実装があっても良い
  _sortWords() async {
    _wordList = await database.allWordsSorted;
    setState(() {

    });
  }
}
