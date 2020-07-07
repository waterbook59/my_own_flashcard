import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  TextColumn get strQuestion => text()();

  TextColumn get strAnswer => text()();

  //暗記済かどうかのテーブルの列項目(登録時に有効)
  BoolColumn get isMemorized => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {strQuestion};
}

@UseMoor(tables: [Words])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  //統合処理 データベースの構造が変更されるときは必須 前のverを移行する(migration)
  MigrationStrategy get migration =>
      MigrationStrategy(
          onCreate: (Migrator m) {
            return m.createAll();
          },
          onUpgrade: (Migrator m, int from, int to) async {
            if (from == 1) { //schemaVersion1から2を開けた時はcolumnを追加する
              await m.addColumn(words, words.isMemorized);
            }
          }
      );

  //Create
  Future addWord(Word word) => into(words).insert(word);

  //Read データの抽出（全てデータ取ってくる）
  Future<List<Word>> get allWords => select(words).get();

  //Read データの抽出（暗記済単語除外）Writing queries参照
  Future<List<Word>> get allWordsExcludedMemorized =>
      (select(words)
        ..where((table) => table.isMemorized.equals(false))).get();

  //Read データを暗記済が下になるようにソートをかけて取ってくる chap246参照
  /*並び替えデフォルトはasc（昇）順（小=>大）、OrderingTermの第二引数をmode:OrderingMode.descにすると降順
  bool型はtrueが上にきて(true=0)falseが下にくる(false=1)
   */
  Future<List<Word>> get allWordsSorted =>
      (select(words)
        ..orderBy([(table)=> OrderingTerm(expression: table.isMemorized, )])).get();

  //Update
  Future updateWord(Word word) => update(words).replace(word);

  //Delete primaryKeyに設定したstrQuestionで抽出
  Future deleteWord(Word word) =>
      (delete(words)
        ..where((t) => t.strQuestion.equals(word.strQuestion)))
          .go(); //cascade notationでコードを単純に
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    //下のフォルダ・ファイル作って開くのを非同期で実行している
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory(); //スマホ内にフォルダつくる
    final file = File(p.join(dbFolder.path, 'words.db')); //上で作ったフォルダにファイルつくる
    return VmDatabase(file); //作ったファイルを開く
  });
}
