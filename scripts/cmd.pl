#!/usr/bin/perl --
# cmd.pl
# скрипт запуска команд
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Modern::Perl;
use Parser::Subs;
use Parser::Log;
use Encode;
use Parser::Model::Command;

init();
sub init {

    my %argv = _parse_argv();

    if (! exists $argv{module} ) {

        if ( !$argv{silent} ) {

            plog( 'ERROR', "cmd.pl: module is null, use '--module=MODULE::MODULE', exit..." );
        }
        return;
    }

    my $obj_cmd = Parser::Model::Command->new(
        $argv{module},
        %argv,
    );
    return unless $obj_cmd;

    say "Run $argv{module}" unless $argv{silent};

    # run module
    $obj_cmd->run(
        interface => 'console',
        %argv,
    );

    say ("Start => " . $obj_cmd->start_time) unless $argv{silent};
    say ("Stop  => " . $obj_cmd->stop_time) unless $argv{silent};
    say ("Diff  => " . $obj_cmd->diff_time) unless $argv{silent};

    return;
}

# разбираем переданные аргументы
sub _parse_argv {
    my %argv;

    for my $arg (@ARGV) {

        $arg =~ s/^\s+//;
        $arg =~ s/\s+$//;

        # все аргументы начинаются на --
        next unless $arg =~ m/^--\w/;

        # находим параметр и значение
        my $pos = index $arg, '=';
        next if $pos == -1;

        my $name = substr $arg, 2, ($pos - 2);
        $argv{$name} = substr $arg, ($pos + 1);
    }

    return %argv;
}
