package Parser::Model::Command::Base;
use Modern::Perl;
use utf8;
no warnings qw(redefine);

sub new {
    my $class = shift;
	bless {}, $class;
}

sub pre_run {
    return 1;
}

sub post_run {
    return 1;
}

sub configure {
    return 1;
}

sub run {
    return 1;
}

sub description {
    my ( $self, $description ) = @_;

    $self->set_description($description);
    return $self->description;
}

# аксессоры
sub description {return $_[0]->{description}}
sub set_description { $_[0]->{description} = $_[1]; }

1;
