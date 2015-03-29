package AnimalSanctuary::REST;

use Moo;

use AnimalSanctuary::Schema;
use AnimalSanctuary::REST::DataStore;
use AnimalSanctuary::REST::Object;

use Class::Load 'load_class';

use MooX::Types::MooseLike::Base 'HashRef';

has storage_engine => (
  is      => 'ro',
  default => sub {
    return AnimalSanctuary::Schema->connect('dbi:SQLite:../etc/database.sqlite');
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
    my $class_name = __PACKAGE__ . '::DataStore::' . $name;
    load_class($class_name);
    $self->class_datastore->{$name}
    = $class_name->new(
      storage_engine => $self->storage_engine
    );
  };
  return $self->class_datastore->{$name};
};

sub object {
  my $self = shift;
  my $name = shift;
  unless (exists $self->class_object->{$name}) {
    my $class_name = __PACKAGE__ . '::Object::' . $name;
    load_class($class_name);
    $self->class_object->{$name}
    = $class_name->new(
      storage_engine => $self->storage_engine
    );
  };
  return $self->class_object->{$name};
};

# sub datastore {
#   my $self = shift;
#   my $name = shift;
#   unless (exists $self->class_datastore->{$name}) {
#     $self->class_datastore->{$name}
#     = AnimalSanctuary::REST::DataStore->new(
#       sub_class_name    => $name,
#       storage_engine    => $self->storage_engine,
# #     default_languages => $self->default_languages,
#     );
#   };
#   return $self->class_datastore->{$name}
# };

# sub object {
#   my $self = shift;
#   my $name = shift;
#   unless (exists $self->class_object->{$name}) {
#     $self->class_object->{$name}
#     = AnimalSanctuary::REST::Object->new(
#       sub_class_name    => $name,
#       storage_engine    => $self->storage_engine,
# #     default_languages => $self->default_languages,
#     );
#   };
#   return $self->class_object->{$name}
# };

1;
