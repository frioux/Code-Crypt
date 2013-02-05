#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Crypt::CBC;
use Digest::MD5 'md5_hex';
use MIME::Base64 'encode_base64';

my $target_hostname = sprintf('% 32s', 'wanderlust');
my $cipher = Crypt::CBC->new(
   -key    => $target_hostname,
   -cipher => "Crypt::OpenSSL::AES"
);
my $bootstrap = <<'BOOTSTRAP';
#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Crypt::OpenSSL::AES;
use MIME::Base64 'decode_base64';

my $key = do {
   use Sys::Hostname;
   hostname();
};

my $cipher = Crypt::OpenSSL::AES->new($key);
my $ciphertext = do { local $/ = undef; decode_base64(<DATA>) };

eval($cipher->decrypt($ciphertext));

die $@ if $@;;;;;;;;;;
BOOTSTRAP
print length $bootstrap;
my $code = <<'CODE';
say "hello world!"
CODE

my $ciphertext = encode_base64($cipher->encrypt($code));

print <<"FINAL"
$bootstrap
__DATA__
$ciphertext
FINAL
