package Parser::Model::Command;
use Modern::Perl;
use utf8;
use DateTime;
use Parser::Log;
use Parser::Subs;
use constant TIMEZONE => 'Europe/Moscow';

sub new {
    my $class  = shift || return;
    my $module = shift || return;
    my %param = @_;

    $module = 'Parser::Model::Command::' . $module;

    eval {
        my $filename = $module =~ s{::}{/}smxgr;
        require $filename . '.pm';
    };

    if ($@) {

        if ( !$param{silent} ) {
            plog('ERROR', "Parser::Model::Command::new: don't require '$module': $@");
        }
        return;
    }

	bless {
	    module     => $module,
	    silent     => $param{silent},
        start_time => DateTime->now( time_zone => TIMEZONE ),
        stop_time  => undef,
        diff_time  => undef,
	}, $class;
}

sub run {
    my ( $self, %param ) = @_;
	return unless $self;

    my $result;
    my $backend = $self->module->new();

    $backend->configure(%param);
    $backend->pre_run(%param);
    $result = $backend->run(%param);
    $backend->post_run(%param);

    # производим подсчет времени выполнения
    $self->calculate_timer();

    return $result;
}

# статистика времени
sub calculate_timer {
    my $self = shift || return;

    $self->set_stop_time( DateTime->now( time_zone => TIMEZONE ) );
    $self->set_diff_time(
        time_interval_to_text( $self->stop_time->epoch - $self->start_time->epoch )
    );
    $self->set_start_time( $self->start_time->ymd . ' ' . $self->start_time->hms );
    $self->set_stop_time( $self->stop_time->ymd . ' ' . $self->stop_time->hms );

    return 1;
}

# аксессоры
sub module {return $_[0]->{module}}
sub silent {return $_[0]->{silent}}
sub start_time {return $_[0]->{start_time}}
sub stop_time  {return $_[0]->{stop_time}}
sub diff_time  {return $_[0]->{diff_time}}

sub set_start_time { $_[0]->{start_time} = $_[1]; }
sub set_stop_time  { $_[0]->{stop_time}  = $_[1]; }
sub set_diff_time  { $_[0]->{diff_time}  = $_[1]; }

1;
