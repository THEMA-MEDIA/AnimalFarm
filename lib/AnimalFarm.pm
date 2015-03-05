package AnimalFarm;

use Moo;

has provider => (
  is      => 'ro'
 #isa     => Object,
);

sub collection {
  my $self = shift;
  return AnimalFarm::Collection->new(@_);
};

1;
