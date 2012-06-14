#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';

use MailAdmin::Schema;

my $schema = MailAdmin::Schema->connect('dbi:Pg:dbname=mailadmin;host=localhost;user=mailadmin;password=mailadmin;');
$schema->deploy;

$schema->resultset('Role')->create({ name => 'admin', id => 1 });
$schema->resultset('User')->create({ login => 'admin', email => 'admin@example.com', role_id => 1, password => 'CY9rzUYh03PK3k6DJie09g'});

