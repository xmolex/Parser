# библиотека общего логгирования
# данную библиотеку можно расширить, писать в файлы или даже взаимодействовать со сторонними системами логирования
package Parser::Log;

use Modern::Perl;
use utf8;
use Encode;
use Exporter 'import';
use Parser::Subs;
our @EXPORT = qw(
    plog
);

# запись технических действий
sub plog {
    my ( $level, $str ) = @_;
	return unless $str;

    # т.к. выводим на консоль, то нужно снять флаг utf-8
    $str = from_crlc($str);

    # если в начале перевод строки, то необходимо добавить дополнительно перевод строки
    if ( substr($str, 0, 1) eq "\n" ) {
        say "";
        $str = substr($str, 1);
    }

    say get_sql_time() . ": $level: $str";

    return 1;
}

1;
