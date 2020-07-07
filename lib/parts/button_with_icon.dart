import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  //field(プロパティ)として設定したものをRaisedButton内に設定
  //finalは引き継いだ値を変えれない状態にする（石(immutable)の中に値が変わるものを設定してはいけない）
  final VoidCallback onPressed;
  final Icon icon;
  final String label;
  final Color color;

  //呼び出す側(使う側)で設定された値がButtonWithIconの中に格納されて、プロパティとして設定されて、build内へ反映される
  //名前付きコンストラクタ(名前は何でも良いchp142,143,180参照)
  ButtonWithIcon({this.onPressed, this.icon, this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: RaisedButton.icon(
          onPressed: onPressed,
          icon: icon,
          //変数指定していないfonSizeはこのクラス呼び出したときは18.0で固定
          label: Text(label,style: TextStyle(fontSize: 18.0),),
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
