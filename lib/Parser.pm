package Parser;
use Dancer2;

our $VERSION = '0.1';
our $VERSION_DB = 1;

use Parser::Controller::Ajx::Message;

prefix undef;

get '/' => sub {

    template 'index.tt', {
        'title' => 'Parser'
    }, { layout => 'main.tt' };
};

true;
