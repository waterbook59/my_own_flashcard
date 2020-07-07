import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';
import 'package:myownflashcard/screens/word_list_screen.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT } //状態のよって表示を変えるenum トップレベルプロパティに設定

class EditScreen extends StatefulWidget {
  //産みの親
  final EditStatus status;
  final Word word;

  EditScreen({@required this.status, this.word}); //引数付きコンストラクタ

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  //育ての親
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = ""; //初期値""空にしておく

  bool _isQuestionEnabled;

  @override
  void initState() {
    //word_list_screenから受け継いだstatus情報を元に表示を変える
    super.initState();
    if (widget.status == EditStatus.ADD) {
      //育ての親で受け取った値を産みの親へ渡すwiget.xx
      _isQuestionEnabled = true; //新しく追加の時は入力できる
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false; //編集時は入力できない(主キーなので)
      _titleText = "登録した単語の修正";
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    //WillPopScope使うときはbuildの直下に設定
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(), //リファレンス的にはFuture<bool>の関数
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText), //titleは状態によって変わるので変数
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: "登録",
              onPressed: () =>
                  _onWordRegistered(), //_insertWord()から処理を新規登録と更新で分岐
            ),
          ],
        ),
        body: SingleChildScrollView(
          //textFieldが出てきた時に下が切れないように自動でスクロールされる
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Text(
                  "問題とこたえを入力して「登録」ボタンを押してください",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              //問題入力
              _questionInputPart(),
              SizedBox(
                height: 50.0,
              ),
              //答え入力
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      //padding+symmetric,horizontalで左右空き、only(left:30.0,right:30.0)と同じ
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      //padding+symmetric,horizontalで左右空き、only(left:30.0,right:30.0)と同じ
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "こたえ",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Future<bool> _backToWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  _insertWord() async {
    //問題・答えの欄が埋まってないと登録できない
    if (questionController.text == "" || answerController.text == "") {
      // 埋めてくださいのメッセージ出すとか
      Toast.show("問題とこたえの両方を入力しないと登録できません。", context,
          duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(context: context,builder: (_)=>AlertDialog(
      title: Text("登録"),
      content: Text("登録していいですか？"),
      actions: <Widget>[
        FlatButton(
          child: Text("はい"),
          onPressed: ()async{
            //1.Create文の変数をメソッド内で宣言->2.addWordメソッドで登録
            var word = Word(
              strQuestion: questionController.text, //問題のTextFieldに入力したやつ
              strAnswer: answerController.text,
            );

            //同じプラマイリーキーをもつ言葉を登録した時にエラーメッセージを出す
            try {
              //addWordメソッド=>CRUD戻り値全てFutureなので投げる側ではasync await
              await database.addWord(word);
              print("OK");
              //入力したものをクリア
              questionController.clear();
              answerController.clear();
              // 登録完了メッセージ
              Toast.show("登録が完了しました", context, duration: Toast.LENGTH_LONG);
            } on SqliteException catch (e) {
              Toast.show("この問題はすでに登録されているので登録できません", context,
                  duration: Toast.LENGTH_LONG);
              // return; //finallyの処理を実行させるためにfinallyをつける
            }finally{//finallyはtryの場合でもcatchの場合でも実行する
              Navigator.pop(context);
            }
          },
        ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: ()=>Navigator.pop(context),
        ),
      ],
    ));


  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      // 埋めてくださいのメッセージ出すとか
      Toast.show("問題とこたえの両方を入力しないと登録できません。", context,
          duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(context: context ,builder: (_)=>AlertDialog(
      title: Text("${questionController.text}の変更"),
      content: Text("変更してもいいですか"),
      actions: <Widget>[
        FlatButton(
          child: Text("はい"),
          onPressed: () async{
            var word = Word(
              strQuestion: questionController.text, //問題のTextFieldに入力したやつ
              strAnswer: answerController.text,
              //isMemorizedも構造として初めから設定しておかないと構造変更前のデータが使えずエラー
              isMemorized: false,);

            try {
              await database.updateWord(word);
              //finallyのところではなく、先にAlertDialogを消した後でpushReplacementを行う chap251参照(要復習)
              Navigator.pop(context);

              _backToWordListScreen(); //pushReplaceメソッドで戻る
              Toast.show("修正が完了しました。", context, duration: Toast.LENGTH_LONG);
            } on SqliteException catch (e) {
              Toast.show("何らかの問題が発生して登録できませんでした。:$e", context,
                  duration: Toast.LENGTH_LONG);
              Navigator.pop(context);
            }
          },
        ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ));


  }
}
