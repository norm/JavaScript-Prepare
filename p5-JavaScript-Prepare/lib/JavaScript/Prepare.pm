package JavaScript::Prepare;

use 5.010;
use strict;
use warnings;

use FileHandle;
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

sub process_file {
    my $self = shift;
    my $file = shift;
    
    my $content = $self->read_file( $file );
    return '' unless $content;
    
    return $self->process_string( $content );
}
sub read_file {
    my $self = shift;
    my $file = shift;
    
    my $handle = FileHandle->new( $file )
        or return;
    
    my $content = do {
        local $/;
        <$handle>
    };
    
    return $content;
}

sub process_directory {
    my $self      = shift;
    my $directory = shift;
    
    my @files = $self->get_files_in_directory( $directory );
    my $minified;
    
    foreach my $file ( @files ) {
        $minified .= $self->process_file( $file );
    }
    
    return $minified;
}

sub get_files_in_directory {
    my $self      = shift;
    my $directory = shift;
    
    opendir my $handle, $directory
        or return;
    
    my @files;
    my @directories;
    while ( my $entry = readdir $handle ) {
        next if $entry =~ m{^\.};
        
        my $target = "$directory/$entry";
        
        push( @files, $target ) if -f $target;
        push( @directories, $target ) if -d $target;
    }
    closedir $handle;
    
    foreach my $dir ( @directories ) {
        my @subfiles;
        
        foreach my $file ( $self->get_files_in_directory( $dir ) ) {
            push @subfiles, $file;
        }
        
        @files = ( @subfiles, @files );
    }
    
    return @files;
}

1;
