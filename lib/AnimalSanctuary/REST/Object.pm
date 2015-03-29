package AnimalSanctuary::REST::Object;

use Moo;
extends 'AnimalSanctuary::REST';

use Class::Load 'load_class';

has sub_class_name => (
  is    => 'ro',
);

has class => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    my $class_name = __PACKAGE__ . '::'  . $self->sub_class_name;
    load_class($class_name);
    return $class_name->new( );
  },
);

sub _multilingual_new { return shift->class->_multilingual_new(@_) };

1;
