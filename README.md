Parser
======================

DESCRIPTION

Проект работы с логами: парсинг и поиск по email.
Тестировалось на CentOS 7 и Postgresql 9.

INSTALLATION

Работает без установки, достаточно скопировать проект в директорию:

    # скопируем проект
    cd ~;
    git clone https://github.com/xmolex/Parser.git
    cd Parser;

    # создадим БД и таблицы
    psql < install/database/schema.postgresql.sql;

    # отредактируем конфиг
    vi config.yml

    # запуск парсинга логов с очисткой таблиц и выводом дополнительной информации (параметры опционально)
    scripts/cmd.pl --module=Message::Parser --file='install/example/out' --trim=1 --debug=1

    # запуск web сервера, страничка доступна по адресу: http://localhost:5005
    # для примера можно поискать email 'ldtyzggfqejxo@mail.ru'
    /usr/local/bin/plackup -p 5005 bin/app.psgi

DEPENDENCIES

This module requires these other modules and libraries:

    Dancer2  https://metacpan.org/pod/Dancer2
    DBI      https://metacpan.org/pod/DBI
    DBD::Pg  https://metacpan.org/pod/DBD::Pg
    DateTime https://metacpan.org/pod/DateTime

COPYRIGHT AND LICENCE

Copyright (C) 2024 by Konstantin Titov
This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.