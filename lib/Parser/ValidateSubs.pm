#########################################################################################################
# функции проверки различных значений
#########################################################################################################
package Parser::ValidateSubs;

use Modern::Perl;
use utf8;
use Exporter 'import';

our @EXPORT = qw(
    is_email
);

# истина, если в строке валидный email адрес
sub is_email {
    my $str = shift || return;
    return 1 if $str =~ m/^[a-zA-Z_\.-][a-zA-Z0-9_\.\-\d]*\@[a-zA-Z\.\-\d]+\.[a-zA-Z]{2,4}$/;
    return;
}

1;
