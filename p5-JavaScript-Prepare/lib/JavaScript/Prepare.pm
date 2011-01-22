package JavaScript::Prepare;

use 5.010;
use strict;
use warnings;

use JavaScript::Minifier::XS    qw( minify );



sub new {
    my $class = shift;
    
    my $self = {};
    bless $self, $class;
    
    return $self;
}

sub process_string {
    my $self = shift;
    my $js   = shift;
    
    my $minified = minify($js);
    
    return "${minified}\n"
        if defined $minified && length $minified;
    return '';
}

1;
