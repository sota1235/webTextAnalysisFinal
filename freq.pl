#!/usr/bin/perl
use utf8;
use Encode;
use Net::Twitter;
binmode(STDOUT,":encoding(utf-8)");

# consumer_key / access_token
require './keys_local.pl'

# Net::Twitter
$twitter = Net::Twitter->new(
  traits => [qw/API::RESTv1_1/],
  consumer_key        => $consumer_key,
  consumer_secret     => $consumer_key_secret,
  access_token        => $access_token,
  access_token_secret => $access_token_secret,
  ssl => 1,
);

# 自分のタイムラインを取得
$option = { count => 10 };
$timeline = $twitter->home_timeline($option);
$flag   = 0; # ら抜き注意対象が１人でも入れば1(true)に変更

foreach $tweet (@$timeline) {
  open(OUT, ">output.txt") || die "ERROR: $!";
  binmode(OUT, ":encoding(euc-jp)");

  # ツイートをoutput.txtに書き込み
  print OUT $tweet->{text}."\n";
  # チェック
  ($result, $tStr, $fStr) = &checkTweet;
  if($result) {
    # flag変更
    $flag = 1;
    # もしら抜き言葉があればリプライ
    $text = '@' + $tweet->{user}{screen_name} +  &makeNoticeTweet($tStr, $fStr);
    $body = { status => $text };
    eval { $twitter->update($body); };
    if($@) print "Error: $@\n";
  };

  close(OUT);
}

# もし一人もら抜き言葉を間違えていなければ平和ツイート
if($flag) {
  $text = &makeNormalTweet;
  $body = { status => $text };
  eval { $twitter->update($body); }
  if($@) print "Error: $@\n";
}

# chasenを用いてら抜き言葉があるかどうか解析
# @param  $tweet   ツイート
# @return $result  解析結果
# @return $tStr    正しいら抜き言葉   $resultがfalseの場合null
# @return $fStr    間違ったら抜き言葉 $resultがfalseの場合null
sub checkTweet {
  $tweet = @_;

}

# ツイートパターンからランダムに決定して注意用ツイートを作成
# @param  $tStr  正しいら抜き言葉
# @param  $fStr  間違ったら抜き言葉
# @return $tweet ツイート
sub makeNoticeTweet {
  ($tStr, $fStr) = @_;
}

# ツイートパターンからランダムにツイートを返す
# @return $tweet ツイート
sub makeNormalTweet {

}
