package MailAdmin::Schema::ResultSet::Domain;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub order_by_name {
    my ($self, $search) = @_;

    return $self->search( $search, { order_by => { -asc => 'name' } } );
}

1;

