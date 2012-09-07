use utf8;

package MailAdmin::Schema::Result::Session;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table('sessions');

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => 'sessions_is_seq',
    },
    sid => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 40,
    },
    expires => {
        data_type   => 'integer',
        is_nullable => 0,
    },
    data => {
        data_type   => 'text',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint('sessions_sid_key', [ 'sid' ]);

