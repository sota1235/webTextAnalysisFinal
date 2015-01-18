package Ranuki;

use utf8;
use Encode;

binmode(STDOUT, ":encoding(utf-8)");

# Constructor
sub new {
  my ($ck, $csk, $at, $ats) = @_;

  my $nt = Net::Twitter->new(
    consumer_key        => $ck,
    consumer_secret     => $csk,
    access_token        => $at,
    access_token_secret => $ats,
    ssl => 1
  );

  # ツイートパターンを格納
  my $normalTweets;

  return bless {
    nt => $nt,
    normalTweets => $normalTweets
  };
}

# 平和なツイートをする
sub normalTweet {
  my $self = shift;
  # ツイートパターンの数を取得
  my $arrayLength = $#normalTweets+1;
  my $tweet = $normalTweets->[int(rand($arrayLength))];
  # ツイート
  my $body = { status => $tweet };
  eval { $self->{nt}->update($body) };
  if($@) print "Error: $@\n";
}

sub noticeTweet {
}

# 指定された数だけTLのツイートを取得
# @param  $num    取得するツイート数
# @return $tweets 取得したツイート, ユーザ名
sub getTweets {
  my $self = shift;
  my $num  = @_;
  my $option = { count => $num };
  my $timeline = $self->{nt}->home_timeline($option);
  my %hash;
  # hashにツイートとユーザ名を追加
  foreach $t (@$timeline) {
    %hash{$t->{user}{screen_name}} = $t->{text};
  }
  return %hash;
}

# 形態素解析して動詞のみ返す
# @param  $text  解析する文章
# @return @words 解析した文章(動詞２つ)
sub analyse {
}

# ら抜き言葉かどうかチェックする
# @param  @words 動詞２つ
# @return $flag  1 or 0
sub check {
}

1;
