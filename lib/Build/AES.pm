package Build::AES;

use Moo;

use Crypt::OpenSSL::AES;
use MIME::Base64 'encode_base64';
use Data::Dumper::Concise;
has $_ => (is => 'ro' ) for 'get_key', 'code';

has key => (
   is => 'ro',
   # isa => check length
);

sub bootstrap {
sprintf(<<'BOOTSTRAP', $_[0]->get_key);
#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Crypt::OpenSSL::AES;
use MIME::Base64 'decode_base64';

my $key = (sub { %s })->();

my $cipher = Crypt::OpenSSL::AES->new($key);
my $ciphertext = do { local $/ = undef; decode_base64(<DATA>) };

eval($cipher->decrypt($ciphertext));

if ($@) {
   die "This code was probably meant to run elsewhere:\n\n$@"
}
BOOTSTRAP
}

sub ciphercode {
   my $self = shift;

   my $cipher = Crypt::OpenSSL::AES->new($self->key);
   return $cipher->encrypt($self->code)
}

sub final_code {
   sprintf(<<'FINAL', $_[0]->bootstrap, encode_base64($_[0]->ciphercode));
%s
__DATA__
%s
FINAL
}

1;
