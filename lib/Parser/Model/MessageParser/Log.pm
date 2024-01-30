package Parser::Model::MessageParser::Log;
use Modern::Perl;
use utf8;
use parent 'Parser::Model::MessageParser::Object';

=begin
    Data class for log object.

    my $obj_log = Parser::Model::MessageParser::Log->new();

    or

    my $obj_log = Parser::Model::MessageParser::Log->new(
        created => '2012-02-13 14:39:24',
        int_id  => '1RwtJY-0009RI-VC',
        str     => '1RwtJY-0009RI-VC == mbpmoasgkrovo@gmail.com R=dnslookup T=remote_smtp defer (-1): domain matches queue_smtp_domains, or -odqs set',
        address => 'mbpmoasgkrovo@gmail.com',
    );

=cut

sub new {
    my $class = shift;
    my %param = @_;

    my $attr = {
        created => undef,
        int_id  => undef,
        str     => undef,
        address => undef,
    };

    # конструктор поддерживает заполнение атрибутов при инициализации
    for my $key (keys %$attr) {

        if (defined $param{$key}) {
            $attr->{$key} = $param{$key};
        }
    }

	bless $attr, $class;
}

=begin
    Function "parse".
    Description: parsing string for log object. Return 1 for success or 0.

    my $obj_log = Parser::Model::MessageParser::Log->new();
    if ($obj_log->parse('my string')) {

        say $obj_log->int_id;
        say $obj_log->created;
        say $obj_log->str;
        say $obj_log->address;
    }

=cut

# получаем строку и пытаемся выбрать из нее аттрибуты сообщения
sub parse {
    my ($self, $str) = @_;
    return unless $str;

    my %data = $self->split_str($str);

    # проверка на подходящий флаг
    return if $data{flag} eq '<=';

    # фиксируем данные в DTO
    $self->set_int_id( $data{int_id});
    $self->set_created( $data{created});
    $self->set_str( $data{str});
    $self->set_address( $data{address});
    $self->set_flag( $data{flag});

    return 1;
}

1;
