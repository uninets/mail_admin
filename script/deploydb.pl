#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';

use MailAdmin::Schema;

my $schema = MailAdmin::Schema->connect('dbi:Pg:dbname=mailadmin;host=localhost;user=mailadmin;password=mailadmin;');
$schema->deploy;

# default admin:password
$schema->resultset('Role')->create({ name => 'admin', id => 1 });
$schema->resultset('User')->create({ login => 'admin', email => 'admin@example.com', role_id => 1, password => '5f4dcc3b5aa765d61d8327deb882cf99'});

