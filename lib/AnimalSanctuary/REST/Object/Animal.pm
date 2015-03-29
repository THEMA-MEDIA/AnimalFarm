package AnimalSanctuary::REST::Object::Animal;

use Moo;

with 'AnimalSanctuary::REST::Role::Multilingual';
extends 'AnimalSanctuary::REST::Object';

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
# For AnimalSanctuary::Role::Multilingual
#

sub _lang_attributes { (
  'known_as', 
  'sound',
) };

sub _smpl_attributes { (
  'name',
  'avrg_age',
) };


sub TO_JSON { return { %{ shift() } }; };

1;
