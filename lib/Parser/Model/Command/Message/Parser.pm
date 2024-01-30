package Parser::Model::Command::Message::Parser;
use Modern::Perl;
use utf8;
use Parser::Subs;
use Parser::Log;
use Parser::DB;
use Parser::ConsoleSubs;
use Dancer2 appname => 'Parser';
use parent 'Parser::Model::Command::Base';
use Parser::Model::MessageParser;
use Parser::Model::Message;
use Data::Dumper;

use constant PID => '/tmp/parser.pid'; # файл блокировки для исключения мультизапуска парсера

sub configure {
    my ( $self, %param ) = @_;

    $self->description('Разбираем файл лога');

    return;
}

sub run {
    my ( $self, %param ) = @_;
    return unless $self;

    # защита от запуска нескольких обработчиков
    if ( is_running(PID) ) {
        plog( 'ERROR', "Parser::Model::Command::Message::Parser: already run, exit..." );
        return;
    }

    # запрос на очистку таблиц с данными
    if ( exists $param{trim} && $param{trim} ) {

        my $obj_message = Parser::Model::Message->new();
        $obj_message->trim();

        # успешно выходим, если запрос был только на очистку
        return 1 unless exists $param{file};
    }

    # файл для разбора
    my $analyze_file = $param{file};
    unless ( $analyze_file && -f $analyze_file ) {
        plog( 'ERROR', "Parser::Model::Command::Message::Parser: broken source file, use --file='/tmp/file.log', exit..." );
        return;
    }

    # открываем файл для чтения
    my $fh;
    if (! open $fh, "<", $analyze_file ) {
        plog( 'ERROR', "Parser::Model::Command::Message::Parser: don't open file '$analyze_file': $!, exit..." );
        return;
    }

    # статистика
    my $stat_message = 0;
    my $stat_log = 0;
    my $stat_skip = 0;
    my $stat_error = 0;
    my $file_size = _get_file_size($analyze_file);
    my $str_size = 0;

    # парсим файл
    while (defined( my $current_str = <$fh>)) {

        $str_size += length($current_str);
        chomp($current_str);

        my $obj_parser = Parser::Model::MessageParser->new();
        my $obj_element = $obj_parser->parse(
            $current_str,
        );

        if ($obj_element) {

            if ( $param{interface} eq 'console' && !$param{silent} && $param{debug} ) {
                say "\ntype => " . ref($obj_element);
                say Dumper $obj_element->for_json();
            }

            # запись в БД
            my $obj_message = Parser::Model::Message->new();
            if ($obj_message->create(
                object => $obj_element,
            )) {

                # подсчет статистики
                if (ref($obj_element) eq 'Parser::Model::MessageParser::Log') {

                    $stat_log++;
                }
                else {

                    $stat_message++;
                }
            }
            else {

                # не удалось добавить
                $stat_error++;
            }
        }
        else {

            # подсчет статистики, парсер не смог определить к чему относится строка
            $stat_skip++;
        }

        # если запрос из консоли, то будет удобно выводить проценты
        if ( $param{interface} eq 'console' && !$param{silent} && $file_size) {
            my $percent = int( $str_size * 100 / $file_size);
            print "\rStatus processing => $percent%";
        }
    }

    # если запрос из консоли, то будет удобно выводить проценты
    if ( $param{interface} eq 'console' && !$param{silent}) {
        say "\rStatus processing => 100%";
    }

    # закрываем файл
    close $fh;

    my $mess = qq|
    Parser::Model::Command::Message::Parser:
        messages: $stat_message
        logs: $stat_log
        skip: $stat_skip
        error: $stat_error
|;
    plog('DEBUG', $mess);

    return 1;
}

# размер файла в байтах
sub _get_file_size {
    my $path = shift || return;
    return unless -f $path;

    my @stats = stat $path;
    return $stats[7];
}

1;
