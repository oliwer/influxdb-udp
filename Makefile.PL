use 5.008;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'InfluxDB::UDP',
    AUTHOR           => 'Olivier Duclos <odc@cpan.org>',
    VERSION_FROM     => 'lib/InfluxDB/UDP.pm',
    ABSTRACT_FROM    => 'lib/InfluxDB/UDP.pm',
    LICENSE          => 'Artistic_2_0',
    MIN_PERL_VERSION => 5.008,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Carp'             => 0,
        'Cpanel::JSON::XS' => 0,
        'IO::Socket::IP'   => 0,
    },
    META_MERGE       => {
        requires     => { perl => '5.008' },
        resources    => {
            license    => 'http://www.opensource.org/licenses/artistic-license-2.0',
            repository => 'http://github.com/oliwer/influxdb-udp',
            bugtracker => 'http://github.com/oliwer/influxdb-udp/issues'
        },
        no_index     => { directory => ['t'] }
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'InfluxDB-UDP-*' },
);
