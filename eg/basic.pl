#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Build::AES;

print Build::AES->new(
   code => 'print "helowr\n"',
   get_key => q{
   require Sys::Hostname;
   sprintf('% 32s', $] . Sys::Hostname::hostname());
},
   key => sprintf('% 32s', $] . 'wanderlust'),
)->final_code;
