#########################################################################################################
# общие функции широкого спектра для консольного запуска
#########################################################################################################
package Parser::ConsoleSubs;

use Modern::Perl;
use utf8;
use Fcntl qw(:DEFAULT :flock);
use Exporter 'import';

our @EXPORT = qw(
    get_settings_in_argv
    is_running
);

# функция получения строки из массива
sub get_settings_in_argv {
    my ($str, @array) = @_;
    for my $array_current_str (@array) {
        return 1 if $array_current_str eq $str;

        if ( index( $array_current_str, $str . '=' ) + 1 ) {
            return substr( $array_current_str, ( index( $array_current_str, '=' ) + 1 ) );
        }
    }

    return;
}

# функция проверки запуска копии скрипта
sub is_running {
    my $pidfile = shift;
    my $result;

    sysopen LOCK, $pidfile, O_RDWR|O_CREAT or die "Невозможно открыть файл $pidfile: $!";

    # пытаемся заблокировать файл
    if ( flock LOCK, LOCK_EX|LOCK_NB  ) {
        # блокировка удалась, поэтому запишем в файл наш идентификатор процесса
        truncate LOCK, 0 or warn "Невозможно усечь файл $pidfile: $!";
        my $old_fh = select LOCK;
        $| = 1;
        select $old_fh;
        print LOCK $$;
        # оставим файл открытым и заблокированным
    }
    else {
        # заблокировать не удалось, т.к. кто-то уже заблокировал файл
        $result = <LOCK>;

        # получим идентификатор процесса
        if (defined $result) {
            chomp $result;
        }
        else {
            warn "Отсутствует PID в пид-файле $pidfile";
            $result = 'block';
        }
    }

    return $result;
}

1;
