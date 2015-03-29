package AnimalSanctuary::Schema::Result::AnimalLocalized;

use utf8;

use AnimalSanctuary::Schema::Candy;

table "animals_localized";

column "ID" => { 
    data_type            => 'integer', 
    is_auto_increment    => 1, 
#   sequence             => 'news_news_id_seq', 
}; 

column "animal_ID" => {
    data_type            => 'integer',
};

column "language_tag" => {
    data_type            => 'text',
};

column "common_name" => { 
    data_type            => 'text', 
}; 

column "sound" => {
    data_type            => 'text',
};

primary_key "ID";

belongs_to "animal" => "AnimalSanctuary::Schema::Result::Animal",
    { "foreign.ID" => "self.animal_ID" },
    {}
;

=head1 COPYRIGHT

(c) 2014 - Th.J. van Hoesel - THEMA-MEDIA NL

=cut

1;
