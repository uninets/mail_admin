package MailAdmin::Schema::ResultSet::Role;

use base 'DBIx::Class::ResultSet';

sub as_hash {
    my ($self, $search) = @_;

    return $self->find( $search, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } );
}

1;
