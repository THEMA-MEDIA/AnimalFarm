package AnimalSanctuary::REST::DataStore;

use Moo;
# extends 'AnimalSanctuary::REST';

has storage_engine => (
  is => 'ro'
);

sub insert { return shift->class->insert(@_) };
sub lookup { return shift->class->lookup(@_) };
sub update { return shift->class->update(@_) };
sub remove { return shift->class->remove(@_) };
sub search { return shift->class->search(@_) };

sub all    { my $prompt = "ALL"; use DDP; p $prompt; return};
sub next   { };

1;
