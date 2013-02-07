#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Build::AES;

my $code = <<'CODE';
my $c = <<'INNER';
print "hello world!\n";
INNER

require Build::AES;
eval(Build::AES->new(
   code => $c,
   get_key => q{ $] },
   key => $],
)->final_code)
CODE
print Build::AES->new(
   code => $code,
   get_key => q{
   require Sys::Hostname;
   Sys::Hostname::hostname();
},
   key => 'wanderlust',
)->final_code;
