#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Code::Crypt;
use Code::Crypt::Graveyard;

print "#!/usr/bin/env perl\n\n" . Code::Crypt::Graveyard->new(
   code => 'print "hello world!\n";',
   builders => [
      Code::Crypt->new(
         get_key => q{ $] },
         key => $],
      ),
      Code::Crypt->new(
         get_key => q{ $^O },
         key => $^O,
      ),
      Code::Crypt->new(
         get_key => q{
            require Sys::Hostname;
            Sys::Hostname::hostname();
         },
         key => 'wanderlust',
      ),
   ],
)->final_code
