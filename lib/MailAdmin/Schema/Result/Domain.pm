use utf8;
package MailAdmin::Schema::Result::Domain;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MailAdmin::Schema::Result::Domain

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<domains>

=cut

__PACKAGE__->table("domains");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'domains_id_seq'

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 updated_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transport

  data_type: 'varchar'
  default_value: 'dovecot'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "domains_id_seq",
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "updated_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transport",
  {
    data_type => "varchar",
    default_value => "dovecot",
    is_nullable => 0,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<domains_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("domains_name_key", ["name"]);

=head1 RELATIONS

=head2 emails

Type: has_many

Related object: L<MailAdmin::Schema::Result::Email>

=cut

__PACKAGE__->has_many(
  "emails",
  "MailAdmin::Schema::Result::Email",
  { "foreign.domain_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<MailAdmin::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "MailAdmin::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-15 00:30:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aHQyVbSlEuFer4c5SJk8qQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
