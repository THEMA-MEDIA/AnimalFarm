package AnimalSanctuary::REST::Role::Multilingual;

use Moo::Role;
use List::Util 'first';
use JSON;



################################################################################
#
# keep track of language mutations, needed for the storage engine
# 1: new or updated
# 0: delete
#
################################################################################

has _multilingual_mut => (
  is    => 'rw',
  default => sub { return {}; },
);



################################################################################
#
# create a new object for this class for a specific language
#
# for those attributes in _lang_attributes a hash will be created
#
################################################################################

sub _multilingual_new {
  my $self = shift;
  my $lang = shift || $self->default_languages->[0];
  my $prms = shift;
  
  # for all the multilingual attributes, turn the simple params into hashes
  foreach my $param ($self->_lang_attributes) {
    next unless (exists $prms->{$param} );
    $prms->{$param} = { $lang => $prms->{$param} };
  };
  my $objt = $self->new ($prms);
  
  # keep record of the mutation
  $objt->_multilingual_mut->{$lang} = 1;
  
  return $objt
};



################################################################################
#
# updates an existing object with the param for a specific language
#
# for those attributes in _lang_attributes the hash will be updated
#
################################################################################

sub _multilingual_upd {
  my $self = shift;
  my $lang = shift || $self->default_languages->[0];
  my $prms = shift;
  
  # update the language variant params
  foreach my $param ($self->_lang_attributes) {
    next unless (exists $prms->{$param} );
    $self->{$param}->{$lang} = delete $prms->{$param};
  };
  # update the remaining params
  foreach my $param (keys %{$prms}) {
    $self->{$param} = delete $prms->{$param};
  };
  
  # keep record of the mutation
  $self->_multilingual_mut->{$lang} = 1;
  
  return
};



################################################################################
#
# remove the language variant part and mark the mutation for deletetion
#
# for those attributes in _lang_attributes the key of hash will be deleted
#
################################################################################

sub _multilingual_del {
  my $self = shift;
  my $lang = shift or die;
  
  # remove the keys for the multilingual hashes
  foreach my $param ($self->_lang_attributes) {
    delete $self->{$param}->{$lang};
  };
  
  # keep record of the mutation
  $self->_multilingual_mut->{$lang} = 0;
  return;
};



################################################################################
#
# returns a list of language being used in the object
#
# NB: not guranteed that each and every attribute is available in that language
#
################################################################################

sub _multilingual_lst {
  my $self = shift;
  my %lang;

  # increase the keys for the multilingual hashes
  foreach my $param ($self->_lang_attributes) {
    $lang{$_}++ for keys %{ $self->{$param} };
  };
  return keys %lang;
};

sub _to_json {
  my $self = shift;
  my $opts = shift;
  my @lang = (defined $opts and exists $opts->{'lang'}) ?
    $opts->{'lang'} : $self->default_languages;
  my $attr = {};
  foreach my $attribute ($self->_smpl_attributes) {
    $attr->{$attribute} = $self->{$attribute};
  };
  foreach my $attribute ($self->_lang_attributes) {
    $attr->{$attribute} = $self->{$attribute}->{
      first { exists ($self->{$attribute}->{$_})} @lang
    }
  };
  my $json = to_json( $attr , { pretty=>1} );
  return $json;
};

1;
