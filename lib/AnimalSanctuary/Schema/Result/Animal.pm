package AnimalSanctuary::Schema::Result::Animal;

use utf8;

use AnimalSanctuary::Schema::Candy;

table "animals";

column "ID" => { 
    data_type            => 'integer', 
    is_auto_increment    => 1, 
#   sequence             => 'news_news_id_seq', 
}; 

column "scientific_name" => { 
    data_type            => 'text', 
}; 

column "max_age" => {
    data_type            => 'integer',
};

primary_key "ID";

has_many "localizations" => "AnimalSanctuary::Schema::Result::AnimalLocalized",
    { "foreign.animal_ID" => "self.ID" },
    {}
;

=head1 COPYRIGHT

(c) 2014 - Th.J. van Hoesel - THEMA-MEDIA NL

=cut

1;
