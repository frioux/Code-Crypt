#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Build::AES;
use Build::Nester;

print Build::Nester->new(
   code => 'print "hello world!\n";',
   builders => [
      Build::AES->new(
         get_key => q{ $] },
         key => $],
      ),
      Build::AES->new(
         get_key => q{ $^O },
         key => $^O,
      ),
      Build::AES->new(
         get_key => q{
            require Sys::Hostname;
            Sys::Hostname::hostname();
         },
         key => 'wanderlust',
      ),
   ],
)->final_code
