package AnimalSanctuary::REST::DataStore::Animals;

use Moo;

extends 'AnimalSanctuary::REST::DataStore';

use AnimalSanctuary::REST::Object::Animal;

sub _RESTobject { {
  Object => 'AnimalSanctuary::REST::Object::Animal',
  Attributes => [
    name => {
      storage => 'Animal',
      handles => 'scientific_name',
      },
    avrg_age => {
      storage => 'Animal',
      handles => 'max_age',
    },
    known_as => {
      storage => 'Animal',
      multilingual => 'localizations',
      language_tag => 'language_tag',
      handles => 'common_name',
    },
    sound => {
      storage => 'Animal',
      multilingual => 'localizations',
      language_tag => 'language_tag',
      handles => 'sound',
    },
  ],
} };

use DDP; my $struct = _RESTobject; p $struct;

sub insert {
  my $clss = shift;
  my $objt = shift;
  
  # create the primitive in the storage
  my $rslt = $clss->storage_engine->resultset('Animal')
    ->create( {
      'scientific_name' => $objt->{'name'},
      'max_age'         => $objt->{'avrg_age'},
    } );
  
  # create related language variants for each recorded mutation
  foreach my $lang (keys %{ $objt->_multilingual_mut } ) {
    $rslt -> create_related ('localizations', {
      'language_tag'    => $lang,
      'common_name'     => $objt->{'known_as'}->{$lang},
      'sound'           => $objt->{'sound'}->{$lang},
    } );
    delete $objt->_multilingual_mut->{$lang}; # has been handled now
  };
  
  return $rslt->get_column('ID');
};

sub lookup {
  my $clss = shift;
  my @keys = @_;
  
  # find the primitive for this class
  my $prim = $clss->storage_engine->resultset('Animal')
    ->find(@keys) or return undef;
  
  # inflate class attributes with primitive columns
  my %prms = (
    _proxy   => $prim,
    _ID      => $prim->get_column('ID'),
    name     => $prim->get_column('scientific_name'),
    avrg_age => $prim->get_column('max_age'),
    known_as => {},
    sound    => {},
  );
  
  # search localized data
  my @lclz = $prim->search_related('localizations')->all;
  
  # inflate class attributes with multilingual hashes
  foreach my $locl (@lclz) {
    $prms{'known_as'}
      ->{$locl->language_tag} = $locl->get_column('common_name');
    $prms{'sound'}
      ->{$locl->language_tag} = $locl->get_column('sound');
  };
  
  # create the class object
  return AnimalSanctuary::REST::Object::Animal->new(%prms);
};

sub update {
  my $clss = shift;
  my $objt = shift;
  
  # deflate class object into primitive proxy and update
  $objt->_proxy->set_column('scientific_name' => $objt->{'name'});
  $objt->_proxy->set_column('max_age'         => $objt->{'avrg_age'});
  $objt->_proxy->update;
  
  # itterate over all 'recorded mutations'
  foreach my $lang (keys %{ $objt->_multilingual_mut } ) {
  
    # check if there is
    my $rslt = $objt->_proxy->find_related ('localizations', {
      'language_tag'    => $lang});
    if ($rslt) { # is there a localized version
      if ($objt->_multilingual_mut->{$lang}) { # does it need update
        $rslt->set_column('common_name' => $objt->{'known_as'}->{$lang});
        $rslt->set_column('sound'       => $objt->{'sound'   }->{$lang});
        $rslt->update;
      }
      else { # it does not need update, it needs delete
        $rslt->delete;
      }
    }
    else { # no translation available
      if ($objt->_multilingual_mut->{$lang}) { # does it need update
        $rslt = $objt->_proxy->create_related ('localizations', {
          'language_tag'    => $lang,
          'common_name'     => $objt->{'known_as'}->{$lang},
          'sound'           => $objt->{'sound'}->{$lang},
        } );
      }
      else { # that is weird ... delete straight after new translation
      }
    }
    delete $objt->_multilingual_mut->{$lang}; # has been handled now
  };
  return;
};

sub remove {
  my $clss = shift;
  my $objt = shift;
  
  # remove the entire record, first the related, then the primitive
  # this might be handled by proper DB cascading
  $objt->_proxy->delete_related ('localizations');
  $objt->_proxy->delete;
  return;
};

1;

