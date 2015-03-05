package AnimalFarm::Object::Animal;

use utf8;

use Moo;

extends AnimalFarm::Object;

has 'ID' => {
  is   => 'ro',
};

has 'scientific_name' => {
  is   => 'ro',
};

has 'common_name' => {
  is   => 'ro',
};

has 'sound' => {
  is   => 'ro',
};

has '_language_tag' => {
  is   => 'ro',
};

