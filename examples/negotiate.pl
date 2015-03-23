use Dancer2;

use strict;
use warnings;

use lib '../lib';
use Dancer2::Plugin::HTTP::ContentNegotiation;

use AnimalFarm::REST;

my $farm = AnimalFarm::REST->new( default_languages => [ 'en', 'nl', 'fr' ] );



get '/animals' => sub {
  my @animals = $farm->datastore('Animals')->all;
};



post '/animals' => sub {
  
  # only accept JSON requests
  unless ( lc request->content_type eq 'application/json' ) {
    status 400;
    return "Bad content type " . request->content_type;
  };
  
  # use the Content-Language or a default to remain backward compatible
  my $lang = request->header('Content-Language')
    || $farm->default_languages->[0];
  my $animal = $farm->object('Animal')
    ->_multilingual_new($lang => from_json(request->body) );
  
  # insert the newly created Animal Object
  my $id = $farm->datastore('Animals')->insert($animal);
  
  # return the proper status message for a created resource
  if ($id) {
    status 201; # Created
    push_header 'Location' => "/animals/$id";
  }
  else {
    status 400; # Error
  };
};



get '/animals/:id' => sub {
  
  # check if there is any animal with this ID
  my $animal = $farm->datastore('Animals')->lookup( params->{id} );
  unless ($animal) {
    status 404;
    return "Animal with @{[ params->{id} ]} not found";
  };
  
  # do content negotiaton
  http_choose_accept_language (
    [$animal->_multilingual_lst] => sub {
      return $animal->_to_json({ lang => http_accept_language });
    },
    { default => $farm->default_languages->[0] }
  );
    
};



put '/animals/:id' => sub {
  
  # check if there is any animal with this ID
  my $animal = $farm->datastore('Animals')->lookup( params->{id} );
  unless ($animal) {
    status 404;
    return "Animal with @{[ params->{id} ]} not found";
  };
  
  # only accept JSON requests
  unless ( lc request->content_type eq 'application/json' ) {
    status 400;
    return "Bad content type " . request->content_type;
  };

  # use the Content-Language or a default to remain backward compatible
  my $lang = request->header('Content-Language')
    || $farm->default_languages->[0];
  
  # update the object
  $animal->_multilingual_upd( $lang => from_json(request->body) );
  
  # update the datastore
  $farm->datastore('Animals')->update($animal);
};



del '/animals/:id' => sub {
  
  # check if there is any animal with this ID
  my $animal = $farm->datastore('Animals')->lookup( params->{id} );
  unless ($animal) {
    status 404;
    return "Animal with @{[ params->{id} ]} not found";
  };
  
  # use the Content-Language or a default to remain backward compatible
  my $lang = request->header('Content-Language');
  
  if ($lang) {
    # delete the language variant inside the object
    $animal->_multilingual_del($lang);
    # update the datastore
    $farm->datastore('Animals')->update($animal);
  } else {
    # cascade remove the object from the datastore
    $farm->datastore('Animals')->remove($animal);
  }
  
};



dance;

