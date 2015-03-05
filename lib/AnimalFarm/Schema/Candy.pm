package AnimalFarm::Schema::Candy;

use base 'DBIx::Class::Candy';

sub base { $_[1] || 'AnimalFarm::Schema::Result' };

1;

