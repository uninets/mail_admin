use utf8;
package MailAdmin::Schema::Result::Email;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MailAdmin::Schema::Result::Email

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

=head1 TABLE: C<emails>

=cut

__PACKAGE__->table("emails");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'emails_id_seq'

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

=head2 address

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 domain_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "emails_id_seq",
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
  "address",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "domain_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<emails_domain_id_address_key>

=over 4

=item * L</domain_id>

=item * L</address>

=back

=cut

__PACKAGE__->add_unique_constraint("emails_domain_id_address_key", ["domain_id", "address"]);

=head1 RELATIONS

=head2 aliases

Type: has_many

Related object: L<MailAdmin::Schema::Result::Alias>

=cut

__PACKAGE__->has_many(
  "aliases",
  "MailAdmin::Schema::Result::Alias",
  { "foreign.email_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 domain

Type: belongs_to

Related object: L<MailAdmin::Schema::Result::Domain>

=cut

__PACKAGE__->belongs_to(
  "domain",
  "MailAdmin::Schema::Result::Domain",
  { id => "domain_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 forwards

Type: has_many

Related object: L<MailAdmin::Schema::Result::Forward>

=cut

__PACKAGE__->has_many(
  "forwards",
  "MailAdmin::Schema::Result::Forward",
  { "foreign.email_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-15 00:30:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O6g5I2vML2/os3mU++Xzfg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
