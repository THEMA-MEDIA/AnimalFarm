package Dancer2::Plugin::HTTP::ContentNegotiation;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Headers::ActionPack;

# use List::MoreUtils 'first_index';

our $negotiator = HTTP::Headers::ActionPack->new->get_content_negotiator;
our %negotiation_choosers = (
    'accept'          => "choose_media_type",
    'accept-language' => "choose_language",
    'accept-charset'  => "choose_charset",
    'accept-encoding' => "choose_encoding",
);

our %accept_table = (
    'type' => {
        rqst => 'Accept',
        rspn => 'Content-Type',
        vars => 'http_accept',
        ngtr => 'choose_media_type',
    },
    'lang' => {
        rqst => 'Accept-Language',
        rspn => 'Content-Language',
        vars => 'http_accept_language',
        ngtr => 'choose_language',
    },
    'char' => {
        rqst => 'Accept-Charset',
        rspn => 'Content-Language', # only valid for text as header parameter
        vars => 'http_accept_charset',
        ngtr => 'choose_charset',
    },
    'encd' => {
        rqst => 'Accept-Encodig',
        rspn => 'Content-Encoding',
        vars => 'http_accept_encoding',
        ngtr => 'choose_encoding',
    },
);

register 'http_choose_accept' => sub {
    return http_choose ( @_, 'type' );
};

register 'http_choose_accept_language' => sub {
    return http_choose ( @_, 'lang' );
};

register 'http_choose_accept_charset' => sub {
    return http_choose ( @_, 'char' );
};

register 'http_choose_accept_encoding' => sub {
    return http_choose ( @_, 'encd' );
};

sub http_choose {
    my $dsl     = shift;
    my $accept  = pop; 
    my $options = (@_ % 2) ? pop : undef;
    
    my @choices = _parse_choices(@_);
    
    # prepare for default behaviour
    # default                ... if none match, pick first in definition list
    # default => 'MIME-type' ... takes this as response, must be defined!
    # default => undef       ... do not make assumptions, return 406
    my $choice_first = ref $_[0] eq 'ARRAY' ? $_[0]->[0] : $_[0];
    my $choice_default = $options->{'default'} if exists $options->{'default'};
#   if ( $choice_default and not exists $choices{$choice_default} ) {
#       $dsl->app->log ( warning =>
#           qq|Invallid http_choose usage: |
#       .   qq|'$choice_default' does not exist in choices|
#       );
#       $dsl->status(500);
#       $dsl->halt;
#   }
    
    # choose from the provided definition
    my $selected = undef;
    my $method = $accept_table{$accept}->{'ngtr'}; # this should be avoided
    if ( $dsl->request->header($accept_table{$accept}->{'rqst'}) ) {
        $selected = $negotiator->$method (
            [ map { $_->{selector} } @choices ],
            $dsl->request->header($accept_table{$accept}->{'rqst'})
        );
    };
    # if nothing selected, use sensible default
#   $selected ||= exists $options->{'default'} ? $options->{'default'} : $choice_first;
    unless ($selected) {
        $selected = $negotiator->$method (
            [ map { $_->{selector} }  @choices ],
            exists $options->{'default'} ? $options->{'default'} : $choice_first
        );
    };
    
    # if still nothing selected, return 406 error
    unless ($selected) {
        $dsl->status(406); # Not Acceptable
        $dsl->halt;
    };
    
    $dsl->vars->{$accept_table{$accept}->{'vars'}} = $selected;
    $dsl->header($accept_table{$accept}->{'rspn'} => "$selected" );
    $dsl->header(
        'Vary'
        => join ', ', $dsl->header('Vary'), $accept_table{$accept}->{'rspn'}
    ) if @choices > 1 ;
    my @coderefs = grep {$_->{selector} eq $selected} @choices;
    return $coderefs[0]{coderef}->($dsl);
};

register 'http_accept' => sub {
    return http_accepted ( @_, 'type' );
};

register 'http_accept_language' => sub {
    return http_accepted ( @_, 'lang' );
};

register 'http_accept_charset' => sub {
    return http_accepted ( @_, 'char' );
};

register 'http_accept_encoding' => sub {
    return http_accepted ( @_, 'encd' );
};

sub http_accepted {
    my $dsl = shift;
    my $accept = pop; 
    
    unless ( exists $dsl->vars->{$accept_table{$accept}->{'vars'}} ) {
        $dsl->app->log( warning =>
            qq|'$accept' should only be used in an authenticated route|
        );
    }
    if (@_ >= 1) {
        $dsl->app->log ( error =>
            qq|'$accept' can't set to new value 'shift'|
        );
    }
    
    return unless exists $dsl->vars->{$accept_table{$accept}->{'vars'}};
    return $dsl->vars->{$accept_table{$accept}->{'vars'}};
    
} # http_accepted


on_plugin_import {
    my $dsl = shift;
    my $app = $dsl->app;
};

sub _parse_choices {
    # _parse_choices
    # unraffles a paired list into a list of hashes,
    # each hash containin a 'selector' and associated coderef.
    # since the 'key' can be an arrayref too, these are added to the list with
    # seperate values
    my @choices;
    while ( @_ ) {
        my ($choices, $coderef) = @{[ shift, shift ]};
        last unless $choices;
        # turn a single value into a ARRAY REF
        $choices = [ $choices ] unless ref $choices eq 'ARRAY';
        # so we only have ARRAY REFs to deal with
        foreach ( @$choices ) {
            if ( ref $coderef ne 'CODE' ) {
                die
                    qq{Invallid http_choose usage: }
                .   qq{'$_' needs a CODE ref};
            }
#           if ( exists $choices{$_} ) {
#               die
#                   qq{Invallid http_choose usage: }
#               .   qq{Duplicated choice '$_'};
#           }
            push @choices,
            {
                selector => $_,
                coderef  => $coderef,
            };
        }
    }
    return @choices;
}; # _parse_choices

register_plugin;

1;
