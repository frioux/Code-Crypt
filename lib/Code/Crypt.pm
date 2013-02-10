package Code::Crypt;

use Moo;

use Crypt::CBC;
use MIME::Base64 'encode_base64';
has code => ( is => 'rw' );

has [qw( key get_key cipher )] => (
   is => 'ro',
   required => 1,
);

sub bootstrap {
sprintf(<<'BOOTSTRAP', $_[0]->get_key, $_[0]->cipher );
use strict;
use warnings;

use Crypt::CBC;
use MIME::Base64 'decode_base64';

my $key = do {%s};

my $cipher = Crypt::CBC->new(
   -key => $key,
   -cipher => '%s',
);

my $ciphertext = decode_base64(<<'DATA');
%%sDATA

my $plain = $cipher->decrypt($ciphertext);
local $@ = undef;
eval($plain);
if ($@) {
   local $_ = $@;
   if ($ENV{SHOW_CODE}) {
      require Data::Dumper::Concise;
      warn "built code was: " . Data::Dumper::Concise::Dumper($plain);
   }
   die "This code was probably meant to run elsewhere:\n\n$_"
}
BOOTSTRAP
}

sub ciphercode {
   my $self = shift;

   my $cipher = Crypt::CBC->new(
      -key => $self->key,
      -cipher => $self->cipher,
   );

   my $code = $self->code;
   return $cipher->encrypt($code)
}

sub final_code { sprintf $_[0]->bootstrap, encode_base64($_[0]->ciphercode) }

1;
