package MailAdmin::Controller;

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';

# for encrypt helper
use String::Random;
use Crypt::Passwd::XS 'unix_sha512_crypt';

sub check_user_permission {
    my ($self, $check_id) = @_;

    return ($check_id == $self->session('user')->{id} || $self->session('role')->{name} eq 'admin') ? 1 : 0;
}

sub encrypt_password {
    my ($self, $plaintext) = @_;

    my $salt = String::Random::random_string('s' x 16);
    return Crypt::Passwd::XS::unix_sha512_crypt($plaintext, $salt);
}

sub trim {
    my ($self, $string) = @_;
    $string =~ s/^\s*(.*)\s*$/$1/gmx;

    return $string
}

1;

