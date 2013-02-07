package Build::AES;

use Moo;

use Crypt::CBC;
use MIME::Base64 'encode_base64';
has code => ( is => 'rw' );
has get_key => (is => 'ro' );

has key => ( is => 'ro' );

sub bootstrap {
sprintf(<<'BOOTSTRAP', $_[0]->get_key);
use strict;
use warnings;

use Crypt::CBC;
use MIME::Base64 'decode_base64';

my $key = do {%s};

my $cipher = Crypt::CBC->new(
   -key => $key,
   -cipher => 'Crypt::Rijndael',
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
      -cipher => 'Crypt::Rijndael',
   );

   my $code = $self->code;
   return $cipher->encrypt($code)
}

sub final_code {
   sprintf($_[0]->bootstrap, encode_base64($_[0]->ciphercode));
}

1;
