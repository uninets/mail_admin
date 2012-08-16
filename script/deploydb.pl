#!/bin/sh
exec perl -x "$0" "$@"
#!perl

use strict;
use warnings;
use lib 'lib';

use MailAdmin::Schema;

my $schema = MailAdmin::Schema->connect('dbi:Pg:dbname=mailadmin;host=localhost;user=mailadmin;password=mailadmin;');
$schema->deploy;

# default admin:password
$schema->resultset('Role')->create({ name => 'admin', id => 1 });
$schema->resultset('User')->create({ login => 'admin', email => 'admin@example.com', role_id => 1, password => '$6$salt$IxDD3jeSOb5eB1CX5LBsqZFVkJdido3OUILO5Ifz5iwMuTS4XMS130MTSuDDl3aCI6WouIL9AjRbLCelDCy.g.'});

