package Parser::Model::MessageParser;
use Modern::Perl;
use utf8;
use Parser::Model::MessageParser::Log;
use Parser::Model::MessageParser::Message;

=begin
    Parser class.

    my $obj_parser = Parser::Model::MessageParser->new();

=cut

sub new {
    my $class = shift;
	bless {}, $class;
}

=begin
    Function "parse".
    Description: parsing string.
    Return Parser::Model::MessageParser::Log object or Parser::Model::MessageParser::Message object or undef;

    my $obj_parser = Parser::Model::MessageParser->new();
    my $obj_element = $obj_parser->parse('my string');

    say $obj_element->int_id;
    say $obj_element->created;
    say $obj_element->str;
=cut

# получаем строку и пытаемся выбрать из нее аттрибуты сообщения
sub parse {
    my ($self, $str) = @_;
    return unless $str;

    # пытаемся распарсить как сообщение
    my $obj = Parser::Model::MessageParser::Message->new();
    return $obj if ($obj->parse($str));

    # пытаемся распарсить как лог
    $obj = Parser::Model::MessageParser::Log->new();
    return $obj if ($obj->parse($str));

    # ничего не подошло
	return;
}

1;
