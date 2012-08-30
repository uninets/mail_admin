#!/bin/sh
exec perl -x "$0" "$@"
#!perl

use strict;
use warnings;
use lib 'lib';

use YAML;
use MailAdmin::Schema;

my $config = YAML::LoadFile('config.yml');
my $dsn    = 'dbi:' . $config->{database}->{driver} . ':dbname=' . $config->{database}->{dbname} . ';host=' . $config->{database}->{dbhost};

my $schema = MailAdmin::Schema->connect($dsn, $config->{database}->{dbuser}, $config->{database}->{dbpass});
$schema->deploy;

# default admin:password
$schema->resultset('Role')->create({ name => 'admin', id => 1 });
$schema->resultset('User')->create({ login => 'admin', email => 'admin@example.com', role_id => 1, password => '$6$salt$IxDD3jeSOb5eB1CX5LBsqZFVkJdido3OUILO5Ifz5iwMuTS4XMS130MTSuDDl3aCI6WouIL9AjRbLCelDCy.g.'});

