#!/usr/bin/perl
use utf8;
use Encode;
use Net::Twitter;

# consumer_key / access_token
require './keys_local.pl'

# 画面に表示するときは EUC で表示
# ターミナルに応じて shift-jis, euc-jp にすることもできます．
binmode(STDOUT,":encoding(utf-8)");

# 頻度を格納する連想配列
%hash = ();

# okashira.txt.chasen の読み込み
# chasen < okashira.txt > okashira.txt.chasen として
# あらかじめ作成しておく
open(IN,"tweet.txt.chasen") || die "ERROR: $!";

# okashira.txt.chasen は EUC で書かれているので EUC として読み込む
binmode(IN,":encoding(euc-jp)");

# IN から一行ずつ読み込む
# $_ に値が格納されていることに注意
while(<IN>){
  # $_ の末尾のを取り除く
  chomp;

  # 読み込んだ行が EOS (文末)の場合
  if(/^EOS/){
    # 何もしない
  }else{
    # 読み込んだ行をタブ区切りで配列化
    # 配列には，単語，読み，標準形，品詞・・・が入っている
    # どのような行か，okashira.txt.chasen の中身をエディタで確認してみましょう．
    @list = split(/\t/);

    # 名詞の場合だけ頻度表を更新する
    if($list[3] =~ /^名詞.*/){
      # すでに連想配列に単語が入っている場合
      if(defined($hash{$list[0]})){
        # 単語の頻度を１増やす
        $hash{$list[0]}++;
      }else{
        # 単語の頻度を１にする
        $hash{$list[0]} = 1;
      }
    }
  }
}
# ファイルを閉じる
close(IN);

# 連想配列のキー（表の左側）を
# 一つずつ $word という変数に入れて処理
foreach $word (keys %hash){
  # 単語，頻度を表示
  print "$word\t$hash{$word}\n";
}

# end of file
