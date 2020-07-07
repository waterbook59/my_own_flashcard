import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;

  TestScreen({this.isIncludedMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _txtQuestion = ""; // 問題表示
  String _txtAnswer = ""; //
  bool _isMemorized = false;

  //各パーツを表示する・しないを管理するbool型変数
  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;

  //database.dart内でFuture<List<Word>>で定義されているため戻り値として取得した結果を格納するList<Word>を定義
  List<Word> _testDataList = List();
  TestStatus _testStatus; //表示分岐させるために状態を管理する

  //問題の何問目を表示するかを管理する行番号
  int _index = 0; //今何問目か
  //取ってきたdatabase１行分の情報を格納する変数
  Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      //暗記済の単語を含む場合
      _testDataList =
          await database.allWords; //databaseへの問い合わせした結果はFutureで返ってくるのでawait
    } else {
      _testDataList = await database.allWordsExcludedMemorized;
    }

    //取得したデータをシャッフル
    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;

    print(_testDataList.toString());

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;

      _numberOfQuestion = _testDataList.length; //databaseから取ってきた行の数が問題数になる
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>_finishTestScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("かくにんテスト"),
          centerTitle: true,
        ),
        //floatingActionButtonはScaffoldが持ってるので、Scaffold直下
        floatingActionButton: _isFabVisible
            ? FloatingActionButton(
                //FAB部分
                onPressed: () => _getNextStatus(),
                //floatingActionButtonを押して条件によって表示を変える
                child: Icon(Icons.skip_next),
                tooltip: "次に進む", //tooltipはStringなので直接文字列入れられる
              )
            : null,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //リスト内は<Widget>なので外出しするメソッドの戻り値の型はWidget
                SizedBox(
                  height: 10.0,
                ),
                _numberOfQuestionsPart(), //残り問題数表示部分
                SizedBox(
                  height: 25.0,
                ),
                _questionCardPart(), //問題カード表示部分
                SizedBox(
                  height: 10.0,
                ),
                _answerCardPart(), //答えカード表示部分
                SizedBox(
                  height: 20.0,
                ),
                _isMemorizedCheckPart(), //暗記済チェック部分
              ],
            ),
            _endMessage(), //テスト終了メッセージ
          ],
        ),
      ),
    );
  }

  // 残り問題数表示部分 Textを横に２つ並べる=>Row()
  Widget _numberOfQuestionsPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "のこり問題数",
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(
          width: 30.0,
        ),
        //変数をint型に設定したが、そのままでは表示できないので、string型へ変更
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  // 問題カード表示部分
  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _txtQuestion,
            style: TextStyle(fontSize: 30.0, color: Colors.blueGrey[800]),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // 答えカード表示部分
  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _txtAnswer,
            style: TextStyle(fontSize: 30.0, color: Colors.black87),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // 暗記済チェック部分
  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: CheckboxListTile(
          title: Text(
            "暗記済にする場合はチェックを入れて下さい",
            style: TextStyle(fontSize: 14.0),
          ),
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value;
            });
          }, //onChanged
//        dense: true,
        ),
      );
    } else {
      return Container();
    }
  }

  //テスト終了メッセージ 戻り値の型はWidget
  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(
          child: Text(
        "テスト終了",
        style: TextStyle(fontSize: 50.0),
      ));
    } else {
      return Container();
    }
  }

  //floatingActionButtonを押して条件によって表示を変える
  _getNextStatus() async {
    //onPressedの戻り値はなし(voidCallback void Function)
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        //BEFOre_STARTの状態の時に次の状態へ_testStatusを変更する
        _testStatus = TestStatus.SHOW_QUESTION;
        //SHOW_QUESTIONの状態の時に問題を表示するためには、一つ前の段階で次の表示（問題を表示する）のための関数
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        //残り問題数の有無で分岐する前にデータベースへ暗記済か否かのチェック状態を登録(先に処理分岐走らないようにawait)
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {//終わったらテスト終了表示する
            _isFabVisible = false;
            _testStatus = TestStatus.FINISHED;
          });

        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED: //終わりの時は何もしないので即break
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index]; //取得したデータベースのそれぞれの１行分のデータ
    setState(() {
      //問題とFabを表示
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _txtQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion -= 1; //残り問題数を１減らす
    _index += 1; //indexを増やして次の行データへいく
  }

  void _showAnswer() {
    setState(() {
      //問題と回答とチェックボックスとFabを表示
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFabVisible = true;
      _txtAnswer = _currentWord.strAnswer;
      //すでにチェックが入っているものはチェックがついた状態で表示する
      //_currentWordリストの中に_isMemorizedの項目設定済
      _isMemorized = _currentWord.isMemorized;
      /*ここで設定すると、_isMemorizedCheckPart()内のCheckboxListTile内の
      value: _isMemorizedによりvalueが変更=>onChanged属性が変更されて状態が反映される
       */
    });
  }

  //データベースへ暗記済か否かのチェック状態を登録
  //_updateMemorizedFlag()をawaitにしたので、戻り値をvoidからFutureに変更しないといけない
  Future<void> _updateMemorizedFlag() async {
    //chap243なぜ２回async await設定しないといけないか
    //データベース１行分のインスタンス作る
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized);
    //上記で設定sたupdateWord変数をデータベースアップデートの式の引数として入れる
    await database.updateWord(updateWord);
    //このメソッド内でデータベース更新処理の後に何も処理こない=>awaitいらない
    print(updateWord.toString());
  }

  //WillPopCallbackの戻り値がFuture<bool>且つshowDialogを非同期処理
  Future<bool> _finishTestScreen() async{

    return await showDialog(context: context,builder: (_) => AlertDialog(
      title:Text("テストの終了"),
      content: Text("テストを終了してもいいですか？"),
      actions: <Widget>[
        FlatButton(
          child: Text("はい"),
          //はいの場合は、AlertDialogだけでなく、test_screenも除く必要ありpopメソッド２回
          onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: ()=>Navigator.pop(context),
        ),
      ],
//三項条件演算子でtrueだとNavigator.popがデフォルトでもう閉じるものない状態になってしまう
    //showDialogの戻り値はbool型ではないので、入れないとnullになってエラーが出てしまう
    )) ?? false;
  }
}
