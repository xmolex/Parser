package Parser::Controller::Ajx::Message;
use Dancer2 appname => 'Parser';
use Modern::Perl;
use utf8;
our $VERSION = '0.1';
use Parser::Subs;
use Parser::ValidateSubs;
use Parser::Model::Message

prefix '/ajx/messages';

# список заметок
get '' => sub {

    header( 'Content-Type' => 'text/json' );

    my $email = query_parameters->get('email');

    # проверка на email
    if (! is_email($email)) {

        status(400);
        return to_crlc(encode_json({
            is_success => \0,
            error_mess => {
                email => to_crlc_str("ожидается валидный email адрес"),
            },
        }));
    }

    # производим поиск
    my $obj_message = Parser::Model::Message->new();
    my @messages = $obj_message->search(
        email => $email,
    );

    # экранируем строки, т.к. отдаем в html
    map { $_->{str} = tr_html($_->{str}) } @messages;

    return to_crlc(encode_json({
        is_success         => \1,
        messages           => \@messages,
        search_count       => ( $obj_message->search_count  || 0 ),
        search_count_total => ( $obj_message->search_count_total || 0 ),
    }));
};

1;
