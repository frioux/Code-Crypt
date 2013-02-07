package Build::Nester;

use Moo;

has code => (
   is => 'ro',
);

has builders => (
   is => 'ro',
);

sub _builder_at { $_[0]->builders->[$_[1]] }
sub _innermost_builder { $_[0]->_builder_at(0) }
sub _outermost_builder { $_[0]->_builder_at($_[0]->_final_builder_index) }
sub _final_builder_index { scalar @{$_[0]->builders} - 1 }

sub final_code {
   my $self = shift;

   $self->_innermost_builder->code($self->code);

   for my $builder_id (1 .. $self->_final_builder_index) {
      my $builder = $self->_builder_at($builder_id);
      my $wrapped_builder = $self->_builder_at($builder_id - 1);
      $builder->code($wrapped_builder->final_code);
   }
   $self->_outermost_builder->final_code
}

1;
