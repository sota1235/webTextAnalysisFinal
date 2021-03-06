#!/usr/bin/perl
use utf8;
use Encode;
use Data::Dumper;
use Net::Twitter;
use Text::MeCab;
binmode(STDOUT,":encoding(utf-8)");

# consumer_key / access_token
require './keys_local.pl';
require './data/tweets.pl';

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
%timeline = &getTweets($tw, 10);
$flag = 1;

# Test
# %timeline = %falseTestCase;

# 一つ一つのツイートをチェック、処理する
while(my($key, $value) = each(%timeline)) {
  # print "Tweet Data-> User:".$key." Tweet: ".$value."\n";
  @words = &analyse($value);
  if(@words) {
    # print "\t含まれていた動詞:".@words[0].@words[3]."\n\n";
    if(&check(@words)) {
      # print "ら抜きはこいつだ！ @".$key." Tweet: ".$value."\n";
      $cor = @words[0]."ら".@words[3];
      $mis = @words[0].@words[3];
      noticeTweet($tw, $key, $mis, $cor);
      $flag = 0;
    }
  }
}

# 誰も文法をミスってなかった場合、平和ツイート
if(flag) {
  &normalTweet($tw);
}

# タイムライン取得
sub getTweets {
  my ($tw, $num) = @_;
  my $option = { count => $num };
  my $timeline = $tw->home_timeline($option);
  my %hash;
  # hashにツイートとユーザ名を追加
  foreach $t (@$timeline) {
    my $user_name = $t->{user}{screen_name};
    my $text      = $t->{text};
    # print $text;
    $hash{ $user_name } = $text;
  };
  return %hash;
}

# 平和ツイート
sub normalTweet {
  my ($tw) = @_;
  my $length = $#normalTweets;
  my $tweet = @normalTweets[int(rand($length))];
  $tweet = decode('utf-8', $tweet);
  # ツイート
  my $body = { status => $tweet };
  eval { $tw->update($body) };
  if($@) { print "Error: $@\n" }
}

# 激おこツイート
sub noticeTweet {
  my ($tw, $mention, $mis, $cor) = @_;
  $cor = encode('utf-8', $cor);
  $mis = encode('utf-8', $mis);
  my $length = $#noticeTweets;
  my $tweet = "@".$mention." ".@noticeTweets[int(rand($length))];
  $tweet =~ s/true/$cor/;
  $tweet =~ s/false/$mis/;
  $tweet = decode('utf-8', $tweet);
  # ツイート
  my $body = { status => $tweet };
  eval { $tw->update($body) };
  if($@) {
    print "Error: $@\n"
  } else {
    print "Tweet success: ".$tweet."\n";
    open(DATAFILE, ">", "./data/tweets.log") or die("Error: $!");
    print DATAFILE $tweet;
  };
}

# 形態素解析し、動詞が含まれた二次元配列のみreturn
sub analyse {
  my ($text) = @_;
  my @res;
  my $flag = 0;
  my $mecab  = Text::MeCab->new;
  $node = $mecab->parse($text);
  while($node) {
    my $surface = decode_utf8 $node->surface;
    my $feature = decode_utf8 $node->feature;
    my @f = split(/,/, $feature);
    if(@f[0] eq "動詞") {
      $flag = 1;
      push(@res, ($surface, @f[6], @f[7]));
    }
    $length = $#res + 1;
    if($length == 6) {
      last;
    }
    $node = $node->next;
  }
  if($flag) {
    return @res;
  } else {
    return ();
  }
}

# ら抜き言葉になってるかどうかチェック
# @param  @words @body, @tailの情報が入ってる
# @return 1 or 0 (True or False)
sub check {
  my (@words) = @_;
  print @words[2];
  if(chop(@words[2]) =~ /イ|キ|ギ|シ|ジ|チ|ヂ|ニ|ヒ|ビ|ミ|リ|エ|ケ|ゲ|セ|ゼ|テ|デ|ネ|ヘ|ベ|メ|レ/) {
    if(substr(@words[3], 0, 1) eq "れ") {
      return 1;
    }
  }
  return 0;
}
