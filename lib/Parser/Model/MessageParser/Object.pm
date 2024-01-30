package Parser::Model::MessageParser::Object;
use Modern::Perl;
use utf8;
use Parser::Subs;

sub new {
    my $class = shift;
	bless {}, $class;
}

# разбиваем строку, разделитель пробел, нас интересуют только шесть параметров
sub split_str {
    my ($self, $str) = @_;

    $self->set_current_str($str);

    my $created = $self->_get_part() . ' ' . $self->_get_part();
    $str        = $self->current_str() // '';
    my $int_id  = $self->_get_part() // '';
    my $flag    = $self->_get_part() // '';
    my $address = $self->_get_part() // '';

    # дополнительно ищем ID
    my $id  = '';
    my $pos = index $self->current_str(), ' id=';
    if ($pos != -1) {

        $id = substr($self->current_str(), ($pos + 4));
    }

    return (
        created => $created,
        str     => $str,
        int_id  => $int_id,
        flag    => $flag,
        address => $address,
        id      => $id,
    );
}

# доходим до первого символа пробела и возвращаем комбинацию до него
sub _get_part {
    my $self = shift;

    my $current_str = $self->current_str();
    my $pos = index $current_str, ' ';
    return if $pos == -1;

    my $str = substr $current_str, 0, $pos;
    $self->set_current_str( substr( $current_str, ++$pos ));

    return $str;
}

# собираем структуру из параметров
sub for_json {
    my $self = shift;

    my $param = {};
    for my $key qw(int_id created str address id flag) {
        $param->{$key} = $self->{$key};
    };

    return $param;
}

# аксессоры
sub int_id {return $_[0]->{int_id}}
sub created {return $_[0]->{created}}
sub str {return $_[0]->{str}}
sub address {return $_[0]->{address}}
sub id {return $_[0]->{id}}
sub flag {return $_[0]->{flag}}
sub current_str {return $_[0]->{current_str}}

sub set_int_id { $_[0]->{int_id} = $_[1]; }
sub set_created { $_[0]->{created} = $_[1]; }
sub set_str { $_[0]->{str} = $_[1]; }
sub set_address { $_[0]->{address} = $_[1]; }
sub set_id { $_[0]->{id} = $_[1]; }
sub set_flag { $_[0]->{flag} = $_[1]; }
sub set_current_str { $_[0]->{current_str} = $_[1]; }
1;
