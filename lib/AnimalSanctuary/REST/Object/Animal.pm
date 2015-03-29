package AnimalFarm::REST::Object::Animal;

use Moo;

with 'AnimalFarm::REST::Role::Multilingual';
extends 'AnimalFarm::REST::Object';

has '_proxy' => (
  is   => 'ro',
);

has '_ID' => (
  is   => 'ro',
);

has 'name' => (
  is   => 'rw',
);

has 'known_as' => (
  is   => 'rw',
);

has 'sound' => (
  is   => 'rw',
);

has 'avrg_age' => (
  is   => 'rw',
);

#
# For AnimalFarm::Role::Multilingual
#

has _lang_attributes => (
  is      => 'ro',
  default => sub { return [qw(known_as sound)] },
);

has _smpl_attributes => (
  is      => 'ro',
  default => sub { return [qw(name avrg_age)] },
);

sub TO_JSON { return { %{ shift() } }; };

1;
