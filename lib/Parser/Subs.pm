#########################################################################################################
# общие функции широкого спектра
#########################################################################################################
package Parser::Subs;

use Modern::Perl;
use Encode;
use utf8;
use Exporter 'import';

our @EXPORT = qw(
    str_trim
    tr_html
    cute_html
    cute_for_sql
    get_sql_time
    to_crlc
    to_crlc_str
    from_crlc
    from_crlc_str
    str_exists_in_array
    time_interval_to_text
);

# очищаем от пробелов в начале и конце
sub str_trim {
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
}

# производим замены для принятых значений, которые должны пойти на вывод в html
sub tr_html {
    my $str = shift;
    $str =~ s/&/&amp;/gs;
    $str =~ s/</&lt;/gs;
    $str =~ s/>/&gt;/gs;
    $str =~ s/'/&apos;/gs;
    $str =~ s/"/&quot;/gs;
    return $str;
}

# вырезаем html символы, портя html код
sub cute_html {
    my $str = shift;
    $str =~ s/<//gs;
    $str =~ s/'//gs;
    $str =~ s/"//gs;
    return $str;
}

# вырезаем опасные спец символы для SQL
sub cute_for_sql {
    my $str = shift || return '';
    $str =~ s!\\!!gs;
    $str =~ s/%//gs;
    $str =~ s/'//gs;
    $str =~ s/"//gs;
    return $str;
}

# формируем дату и время для базы данных, либо только дату (флаг вторым параметром)
# время можно передать в unix формате
sub get_sql_time {
    my $time = shift // time();
    my( $sec, $min, $hour, $mday, $mon, $year ) = localtime($time);
    $year = $year + 1900;
    $mon++;
    
    # добавляем ведущие нули
    $mon  = sprintf '%02d', $mon;
    $mday = sprintf '%02d', $mday;
    $hour = sprintf '%02d', $hour;
    $min  = sprintf '%02d', $min;
    $sec  = sprintf '%02d', $sec;
    
    if ($_[0] || $_[1]) {
        # запрос только на дату
        return "$year-$mon-$mday";
    }
    else {
        # запрос на дату и время
        return "$year-$mon-$mday $hour:$min:$sec";
    }
    
}

sub to_crlc {
    Encode::_utf8_on($_[0]);
    return $_[0];
}

sub to_crlc_str {
    my $str = $_[0];
    Encode::_utf8_on($str);
    return $str;
}

sub from_crlc {
    Encode::_utf8_off($_[0]);
    return $_[0];
}

sub from_crlc_str {
    my $str = $_[0];
    Encode::_utf8_off($str);
    return $str;
}

# возвращаем истину, если строка есть в массиве
sub str_exists_in_array {
    my ($str, @array) = @_;
    for my $array_current_str (@array) {
        return 1 if $array_current_str eq $str;
    }

    return;
}

# переводим количество секунд в текст
sub time_interval_to_text {
    my $diff = shift || 0;
    my ( $temp, $result ) ;

    # days
    if ($diff / 86400 >= 1) {
        $temp = int($diff / 86400);
        $diff = $diff - ($temp * 86400);
        $temp = sprintf "%02d", $temp;
        $result = $temp;
    }
    else {
        $result = '00';
    }

    # hour
    if ($diff / 3600 >= 1) {
        $temp = int($diff / 3600);
        $diff = $diff - ($temp * 3600);
        $temp = sprintf "%02d", $temp;
        $result .= ':' . $temp;
    }
    else {
        $result .= ':00';
    }

    # minutes
    if ($diff / 60 >= 1) {
        $temp = int($diff / 60);
        $diff = $diff - ($temp * 60);
        $temp = sprintf "%02d", $temp;
        $result .= ':' . $temp;
    }
    else {
        $result .= ':00';
    }

    # seconds
    $diff = sprintf "%02d", $diff;
    $result .= ':' . $diff;

    $result =~ s/^://;

    return $result;
}

1;
