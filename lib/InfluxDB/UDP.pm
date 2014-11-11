package InfluxDB::UDP;

use strict;
use warnings;
use Carp;
use IO::Socket::IP;
use Cpanel::JSON::XS 'encode_json';

our $VERSION = '0.01';

my $PK = __PACKAGE__;

sub new {
	my ($class, $address) = @_;

	$class = ref $class || $class;
	$address ||= '127.0.0.1:4444';

	if ($address !~ /^\S+:\d+$/) {
		croak "$PK: invalid server address: '$address'";
	}

	bless {
		addr => $address,
		sock => _connect($address),
	}, $class;
}

sub DESTROY {
    shift->{sock}->close;
}

sub _connect {
	my $addr = shift;

	IO::Socket::IP->new(
		Proto    => 'udp',
		PeerAddr => $addr,
		Blocking => 0
	) or croak "$PK: cannot open socket: $@";
}

sub post {
	my ($self, $data) = @_;

	unless ($data) {
		carp "$PK: undefined or empty data";
		return undef;
	}

	# We need an arrayref
	my $reftype = ref $data;
	if ($reftype ne 'ARRAY') {
		if ($reftype eq 'HASH') {
			$data = [ $data ];
		}
		else {
			carp "$PK: wrong data type. I need an arrayref.";
			return undef;
		}
	}

	# Encode to JSON
	$data = eval { encode_json $data };
	if ($@) {
		carp "$PK: encode json: $@";
		return undef;
	}

	# Send to the server
	my $sent = $self->{sock}->send($data);
	carp "$PK: post failed" unless $sent;

	$sent;
}

1;

=encoding utf8

=head1 NAME

InfluxDB::UDP - The fastest way to send your stats to InfluxDB

=head1 VERSION

Version 0.01

=head1 SYNOPSYS

  use InfluxDB::UDP;

  my $influx = InfluxDB::UDP->new;

  $influx->post({
    name => 'cpu',
    columns => [qw(sys user idle)],
    points => [
      [20, 50, 30],
      [30, 60, 10],
    ]
  });

=head1 DESCRIPTION

This module allows you to quickly send data points to an InfluxDB server
over UDP. Contrary to the HTTP interface, you can only write data. If you
need to perform queries, manage databases and users, or delete data, you
will need to use HTTP interface.

By using UDP and an XS module for JSON encoding, the time to post your
statistics to the server is reduced to a minimum, allowing you to send
virtually as much data as you want without slowing down your application.

=head1 ATTRIBUTES

=head2 address

The InfluxDB server's address.

=head2 sock

The L<IO::Socket::IP> object.

=head1 METHODS

=head2 new

  my $influx = InfluxDB::UDP->new('logs.company.com:4444');

Creates a new InfluxDB::UDP object. The server address defaults to
C<127.0.0.1:4444>. This sub will croak if given an invalid port number.

=head2 post

  my $bytes_sent = $influx->post($data);

Send the data to InfluxDB over UDP. C<$data> can be either a hash reference or
an array reference, which allows you to send multiple records at once. The data
hash must be organized the same way as when sending data over the HTTP interface.
See the official documentation for more details. This sub returns the number of
bytes sent (as returned by C<send>) or C<undef> on error.
In this case, an error message will be printed using C<carp>, but this
function will never C<die>.

B<Warning>: if you want to include a timestamp with your data, be sure it is
expressed in seconds, and not in milliseconds or microseconds. Contrary to
the HTTP interface, you do not have a choice here. See
L<https://github.com/influxdb/influxdb/issues/841>

=head1 AUTHOR

Olivier Duclos, C<< <odc at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-influxdb-udp at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=InfluxDB-UDP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Olivier Duclos

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<InfluxDB>, for the complete HTTP interface.

L<http://influxdb.com/docs/v0.8/api/reading_and_writing_data.html>

=cut
