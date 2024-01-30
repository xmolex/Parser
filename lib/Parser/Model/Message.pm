package Parser::Model::Message;
use Modern::Perl;
use utf8;
use Parser::Subs;
use Parser::Log;
use Parser::DB;
use Parser::Model::MessageParser::Log;
use Parser::Model::MessageParser::Message;

use constant MAX_COUNT => 100; # лимит вывода сообщений при поиске

=begin
	Interface for processing message objects.

	my $obj_message = Parser::Model::Message->new();

=cut

sub new {
    my $class = shift;
	bless {}, $class;
}

=begin
	Function "search".
	Description: search records from database.
	Return elements list.

	my $obj_message = Parser::Model::Message->new();
	my @list = $obj_message->search(
		email => 'xmolex@list.ru',
	);

	# count elements to @list
	say $obj_message->search_count;

	# count elements from request without limit
	say $obj_message->search_count_total;

=cut

# поиск сообщений по email
sub search {
    my $self = shift;
    my %param = @_;
    return unless $param{email};

	# вырезаем опасные символы для SQL
	$param{email} = cute_for_sql($param{email});

	# для поиска буду использовать временные таблицы, т.к. предполагаю, что раз это логи, то выборки могут быть огромными
	my $tmp_table_name = _get_tmp_table_name();
    my $sql = qq|
        CREATE TEMPORARY TABLE $tmp_table_name (int_id CHAR(16));
        INSERT INTO $tmp_table_name (int_id) SELECT DISTINCT(int_id) FROM log WHERE address = ?;

        SELECT created, str FROM (
			SELECT created, int_id, str FROM log WHERE int_id IN (SELECT int_id FROM $tmp_table_name)
			UNION
			SELECT created, int_id, str FROM message WHERE int_id IN (SELECT int_id FROM $tmp_table_name)
        ) AS tbl
        ORDER BY int_id, created LIMIT | . MAX_COUNT . q|
    |;

	my $strin = db->prepare($sql);
	$strin->execute($param{email});
	if (db->errstr) {
	    plog( 'ERROR', "Parser::Model::Message::search: database error: '" . db->errstr . "'" );
	    return;
	}

	my @result;
	while ( my $val = $strin->fetchrow_hashref ) {
		push @result, $val;
	}
	$self->set_search_count( scalar(@result));

	# повторный запрос, чтобы выбрать количество всех значений
	$sql = qq|
        SELECT COUNT(created) FROM (
			SELECT created, int_id, str FROM log WHERE int_id IN (SELECT int_id FROM $tmp_table_name)
			UNION
			SELECT created, int_id, str FROM message WHERE int_id IN (SELECT int_id FROM $tmp_table_name)
        ) AS tbl
    |;

	$strin = db->prepare($sql);
	$strin->execute();
	if (db->errstr) {
		plog( 'ERROR', "Parser::Model::Message::search: database error: '" . db->errstr . "'" );
		return;
	}

	my @val = $strin->fetchrow_array;
	$self->set_search_count_total( $val[0] || 0);

	# удаляем временную таблицу
	db->do("DROP TABLE IF EXISTS $tmp_table_name;");
	if (db->errstr) {
		plog( 'ERROR', "Parser::Model::Message::search: database error: '" . db->errstr . "'" );
		return;
	}

	return @result;
}

=begin
	Function "create".
	Description: create record to database, require Parser::Model::MessageParser::Log or Parser::Model::MessageParser::Message object with data.
	Return 1 if success or 0.

	my $obj_message = Parser::Model::Message->new();
	my $obj_log = Parser::Model::MessageParser::Log->new(
		created => '2012-02-13 14:39:24',
		int_id  => '1RwtJY-0009RI-VC',
		str     => '1RwtJY-0009RI-VC == mbpmoasgkrovo@gmail.com R=dnslookup T=remote_smtp defer (-1): domain matches queue_smtp_domains, or -odqs set',
		address => 'mbpmoasgkrovo@gmail.com',
	);

	if ($obj_message->create(
		object => $obj_log,
	)) {
		say 'success';
	};

=cut

# создаем запись в зависимости от объекта
sub create {
    my $self = shift;
	my %param = @_;
	return unless $param{object};

    # проверяем на подходящий тип объекта
    my $class = ref($param{object});
    return unless str_exists_in_array(
        $class,
        'Parser::Model::MessageParser::Message',
        'Parser::Model::MessageParser::Log'
    );

    # проверяем на заполненность данных
    return unless $param{object}->int_id;
    return unless $param{object}->created;
    return unless $param{object}->str;

	# иногда у нас возникают ситуации, что нет ID, хотя это Message, поле у нас обязательное, поэтому приходится выйти
	# example: 2012-02-13 14:41:20 1RwtLU-0004Mx-Ca <= <> R=1RwtJu-0009RI-Ac U=mailnull P=local S=2293
	if ( $class eq 'Parser::Model::MessageParser::Message'
		&& !$param{object}->id ) {

		plog( 'ERROR', "\nDon't get 'id' from '" . $param{object}->str . "', skip create to DB...");
		return;
	}

    # добавляем в базу в зависимости от объекта
	my $sql = q|
        INSERT INTO | .( $class eq 'Parser::Model::MessageParser::Message' ? 'message' : 'log' ) . q|
            (created, int_id, str, | . ( $class eq 'Parser::Model::MessageParser::Message' ? 'id' : 'address' ) . q|)
        VALUES
            (?, ?, ?, ?);
    |;
    my $strin = db->prepare($sql);
	$strin->execute(
		$param{object}->created,
		$param{object}->int_id,
		$param{object}->str,
        ( $class eq 'Parser::Model::MessageParser::Message' ? $param{object}->id : $param{object}->address ),
	);
	if (db->errstr) {
	    plog( 'ERROR', "\nParser::Model::Message::create: database error: '" . db->errstr . "'" );
		plog( 'ERROR', $sql);
		plog( 'ERROR', ( 'INT_ID => ' . $param{object}->int_id . ', CREATED => ' . $param{object}->created ));
		plog( 'ERROR', ( $class eq 'Parser::Model::MessageParser::Message' ? ('ID => ' . $param{object}->id) : ('ADDRESS => ' . $param{object}->address) ));
	    return;
	}

    return 1;
}

=begin
	Function "trim".
	Description: truncate all data from DB tables: message and log.
	Return 1 if success or 0.

	my $obj_message = Parser::Model::Message->new();
	$obj_message->trim();

=cut

# чистим все таблицы
sub trim {
	my $self = shift;

	db->do("TRUNCATE TABLE message;");
	if (db->errstr) {
		plog( 'ERROR', "Parser::Model::Message::trim: database error: '" . db->errstr . "'" );
		return;
	}

	db->do("TRUNCATE TABLE log;");
	if (db->errstr) {
		plog( 'ERROR', "Parser::Model::Message::trim: database error: '" . db->errstr . "'" );
		return;
	}

	plog( 'DEBUG', "Parser::Model::Message::trim: delete data from tables: message, log" );

	return 1;
}

# имя для временной таблицы
sub _get_tmp_table_name {

	return ('tmp_' . int(rand(1000000)));
}

# аксессоры
sub search_count {return $_[0]->{search_count}}
sub search_count_total {return $_[0]->{search_count_total}}

sub set_search_count { $_[0]->{search_count} = $_[1]; }
sub set_search_count_total { $_[0]->{search_count_total} = $_[1]; }

1;
