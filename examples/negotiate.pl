use Dancer2;

use lib '../lib';
use Dancer2::Plugin::HTTP::ContentNegotiation;

use AnimalFarm;

my $animalfarm = AnimalFarm->new();
$animalfarm->collection('Animals')->set_language( 'nl', 'en', 'fr' );

get '/animals' => sub {
  my @animals = $animalfarm->collection('Animals')->all;
};

get '/animals/:id' => sub {
  my $animal = $animalfarm->collection('Animals')->find( params->{id} );
  unless ($animal) {
    status 400;
    return "Animal with ${ params->{id} } not found";
  };
  http_choose_accept (
    'application/json'
      => sub { http_choose_accept_language ( $animal->get_language
        => sub {
          $animal->set_language = http_accept_language;
          to_json $animal
      })},
#   'application/xml'
#     => sub { to_xml $animal },
    [ 'image/png', 'image/gif', 'image/jpeg' ]
      => sub {
      },
  )
};

post '/animals' => sub {
  my $animal = $animalfarm->object('Animal')->new( ... );
  my $lang = request->headers('Content-Language')
          || $animalfarm->collection('Animals')->get_language;
  $animal->set_language($lang);
  my $id = $animalfarm->collection('Animals')->insert($animal);
};

put '/animals/:id' => sub {
  my $animal = $animalfarm->collection('Animals')->find( params->{id} );
  unless ($animal) {
    status 400;
    return "Animal with ${ params->{id} } not found";
  };
  my $lang = request->headers('Content-Language')
          || $animalfarm->collection('Animals')->get_language;
  $animal->add_language($lang => ... );
};

del 'animals/:id' => sub {
  my $animal = $animalfarm->collection('Animals')->find( params->{id} );
  unless ($animal) {
    status 400;
    return "Animal with ${ params->{id} } not found";
  };
  my $lang = request->headers('Content-Language');
  if ($lang) {
    $animal->del_language($lang);
  } else {
    $animalfarm->collection('Animals')->remove($animal);
  }
  
};

dance;

