#!/usr/bin/perl
use utf8;
use Encode;
use Data::Dumper;
use Net::Twitter;
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

&normalTweet($tw);

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
  # ツイートをoutput.txtに書き込む
  open(OUT, ">output.txt") || die "ERROR: $!";
  binmode(OUT, ":encoding(euc-jp)");

  print OUT $text;
  my $chasen_result = `chasen < output.txt`;
  my @res;
  foreach my $line (split(/\n/, $chasen_result)) {
    @words = split(/\t/, $line);
    if(@words[3] =~ "動詞") {
      push(@res, (@words[0], @words[2]));
    }
  }
  return @res;
}
