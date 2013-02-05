#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Crypt::OpenSSL::AES;
use Digest::MD5 'md5_hex';
use MIME::Base64 'encode_base64';

my $target_hostname = sprintf('% 32s', 'wanderlust');
my $cipher = Crypt::OpenSSL::AES->new($target_hostname);

my $bootstrap = <<'BOOTSTRAP';
#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Crypt::OpenSSL::AES;
use MIME::Base64 'decode_base64';

my $key = do {
   use Sys::Hostname;
   sprintf('% 32s', hostname())
};

my $cipher = Crypt::OpenSSL::AES->new($key);
my $ciphertext = do { local $/ = undef; decode_base64(<DATA>) };

eval($cipher->decrypt($ciphertext));

die $@ if $@
BOOTSTRAP

my $code = <<'CODE';
say "helowrld!"
CODE

my $ciphertext = encode_base64($cipher->encrypt($code));

print <<"FINAL"
$bootstrap
__DATA__
$ciphertext
FINAL
