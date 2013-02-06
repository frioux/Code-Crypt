package Build::AES;

use Moo;

use Crypt::CBC;
use MIME::Base64 'encode_base64';
has $_ => (is => 'ro' ) for 'get_key', 'code';

has key => (
   is => 'ro',
   # isa => check length
);

sub bootstrap {
sprintf(<<'BOOTSTRAP', $_[0]->get_key);
#!/usr/bin/env perl

use strict;
use warnings;

use Try::Tiny;
use Crypt::CBC;
use MIME::Base64 'decode_base64';

my $key = (sub {%s})->();

my $cipher = Crypt::CBC->new(
   -key => $key,
   -cipher => 'Crypt::Rijndael',
);

my $ciphertext = do { local $/ = undef; decode_base64(<DATA>) };

my $plain = $cipher->decrypt($ciphertext);
# this can't be inside of the try because apparently string eval checks for
# syntax errors and throws an exception in an..uncatchable way
if ($ENV{SHOW_CODE}) {
   require Data::Dumper::Concise;
   warn "built code was: " . Data::Dumper::Concise::Dumper($plain);
}
try { eval($plain) } catch {
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
   sprintf(<<'FINAL', $_[0]->bootstrap, encode_base64($_[0]->ciphercode));
%s
__DATA__
%s
FINAL
}

1;
