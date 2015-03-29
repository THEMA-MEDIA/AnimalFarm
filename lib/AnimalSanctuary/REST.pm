package AnimalFarm::REST;

use Moo;

use AnimalFarm::Schema;
use AnimalFarm::REST::DataStore;
use AnimalFarm::REST::Object;

use MooX::Types::MooseLike::Base 'HashRef';

has storage_engine => (
  is      => 'ro',
  default => sub {
    return AnimalFarm::Schema->connect('dbi:SQLite:../etc/database.sqlite');
  },
);

has default_languages => (
  is      => 'rw',
);

has class_object => (
  is      => 'rw',
  isa     => HashRef,
  default => sub { return { } },
);

has class_datastore => (
  is      => 'rw',
  isa     => HashRef,
  default => sub { return { } },
);

sub datastore {
  my $self = shift;
  my $name = shift;
  unless (exists $self->class_datastore->{$name}) {
    $self->class_datastore->{$name}
    = AnimalFarm::REST::DataStore->new(
      sub_class_name    => $name,
      storage_engine    => $self->storage_engine,
#     default_languages => $self->default_languages,
    );
  };
  return $self->class_datastore->{$name}
};

sub object {
  my $self = shift;
  my $name = shift;
  unless (exists $self->class_object->{$name}) {
    $self->class_object->{$name}
    = AnimalFarm::REST::Object->new(
      sub_class_name    => $name,
      storage_engine    => $self->storage_engine,
#     default_languages => $self->default_languages,
    );
  };
  return $self->class_object->{$name}
};

1;
