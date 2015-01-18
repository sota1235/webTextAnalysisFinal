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

while(my($key, $value) = each(%timeline)) {
  print $value."\n";
  @words = &analyse($value);
  if(@words) {
    print @words."\n";
    if(&check(@words)) {
      # notice tweet
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
  $tweet = decode("utf-8", $tweet);
  # ツイート
  my $body = { status => $tweet };
  eval { $tw->update($body) };
  if($@) { print "Error: $@\n" }
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
  if(@words[2] =~ /イ|キ|シ|チ|ニ|ヒ|ミ|リ|エ|ケ|セ|テ|ネ|ヘ|メ|レ/) {
    if(substr(@words[3], 0, 1) eq "れ") {
      return 1;
    }
  }
  return 0;
}
