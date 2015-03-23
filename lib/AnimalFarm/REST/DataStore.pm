package AnimalFarm::REST::DataStore;

use Moo;
# extends 'AnimalFarm::REST';

use Class::Load 'load_class';

has sub_class_name => (
  is    => 'ro',
);

has storage_engine => ( is => 'ro' );

has class => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    my $class_name = __PACKAGE__ . '::'  . $self->sub_class_name;
    load_class($class_name);
    my $class = $class_name->new( storage_engine => $self->storage_engine );
    return $class;
  },
);

sub insert { return shift->class->insert(@_) };
sub lookup { return shift->class->lookup(@_) };
sub update { return shift->class->update(@_) };
sub remove { return shift->class->remove(@_) };
sub search { return shift->class->search(@_) };

sub all    { };
sub next   { };

1;
