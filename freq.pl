#!/usr/bin/perl
use utf8;
use Encode;
use Data::Dumper;
use Net::Twitter;
binmode(STDOUT,":encoding(utf-8)");

# consumer_key / access_token
require './keys_local.pl'

# Net::Twitter
$tw = Net::Twitter->new(
  traits => [qw/API::RESTv1_1/],
  consumer_key        => $consumer_key,
  consumer_secret     => $consumer_key_secret,
  access_token        => $access_token,
  access_token_secret => $access_token_secret,
  ssl => 1,
);

# 自分のタイムラインを取得
$timeline = &getTweets(10);
warn Dumper $rakuni;
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

sub getTweets {
  my ($tw, $num) = @_;
  my $option = { count => $num };
  my $timeline = $tw->home_timeline($option);
  my %hash;
  # hashにツイートとユーザ名を追加
  foreach $t (@$timeline) {
    my $user_name = $t->{user}{screen_name};
    my $text      = $t->{text};
    $hash{ $user_name } = $text;
  };
  return %hash;
}
