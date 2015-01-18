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
}

sub normalTweet {
}

sub noticeTweet {
}

sub getTweets {
}

sub analyse {
}

sub check {
}