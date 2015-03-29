package AnimalSanctuary::Schema::Candy;

use base 'DBIx::Class::Candy';

sub base { $_[1] || 'AnimalSanctuary::Schema::Result' };

1;

