#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Build::AES;

my $code = <<'CODE';
print "hello world!\n";
print "this code is secret and cannot be read unless the user has the key\n";
CODE
print Build::AES->new(
   code => $code,
   get_key => q{
   require Sys::Hostname;
   sprintf('% 32s', $] . Sys::Hostname::hostname());
},
   key => sprintf('% 32s', $] . 'wanderlust'),
)->final_code;
