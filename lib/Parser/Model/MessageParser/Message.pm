package Parser::Model::MessageParser::Message;
use Modern::Perl;
use utf8;
use parent 'Parser::Model::MessageParser::Object';

=begin
    Data class for message object.

    my $obj_message = Parser::Model::MessageParser::Message->new();

    or

    my $obj_message = Parser::Model::MessageParser::Message->new(
        created => '2012-02-13 14:39:24',
        id      => '120213143602.COM_FM_END.972717@whois.somehost.ru',
        int_id  => '1RwtJY-0009RI-VC',
        str     => '1RwtJY-0009RI-VC <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=1366 id=120213143602.COM_FM_END.972717@whois.somehost.ru',
    );
=cut

sub new {
    my $class = shift;
    my %param = @_;

    my $attr = {
        created => undef,
        int_id  => undef,
        str     => undef,
        id      => undef,
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
    Description: parsing string for message object. Return 1 for success or 0.

    my $obj_message = Parser::Model::MessageParser::Message->new();
    if ($obj_message->parse('my string')) {

        say $obj_message->id;
        say $obj_message->int_id;
        say $obj_message->created;
        say $obj_message->str;
    }
=cut

# получаем строку и пытаемся выбрать из нее аттрибуты сообщения
sub parse {
    my ($self, $str) = @_;
    return unless $str;

    my %data = $self->split_str($str);

    # проверка на подходящий флаг
    return unless $data{flag} eq '<=';

    # фиксируем данные в DTO
    $self->set_int_id( $data{int_id});
    $self->set_created( $data{created});
    $self->set_str( $data{str});
    $self->set_id( $data{id});
    $self->set_flag( $data{flag});

    return 1;
}

1;
