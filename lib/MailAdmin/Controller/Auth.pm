package MailAdmin::Controller::Auth;
use lib 'lib';
use Mojo::Base 'MailAdmin::Controller';
use DBIx::Class::ResultClass::HashRefInflator;

sub login {
    my $self = shift;

    $self->render();
}

sub authenticate {
    my $self = shift;
    my $redirect_target = '/domains';

    my $username = $self->param('username');
    my $password = $self->param('password');

    my $user = $self->model('User')->find({ login => $username }, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' });
    my $role = $self->model('Role')->find($user->{role_id}, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' });

    if ($self->_user_authenticate($user, $password)){
        $self->session( user => undef, authenticated => undef );
        delete $user->{password};
        $self->session( authenticated => 1, user => $user, role => $role ? $role : { name => 'none' } );
        $self->flash(class => 'alert alert-success', message => 'Login successful!');
    }
    else {
        $redirect_target = '/login';
        $self->flash(class => 'alert alert-error', message => "Login failed!");
    }

    $self->redirect_to($redirect_target);
}

sub logout {
    my $self = shift;

    $self->session( user => undef, authenticated => undef, role => undef );

    $self->flash(class => 'alert alert-info', message => 'Logged out!');
    $self->redirect_to('/login');
}

sub _user_authenticate {
    my ($self, $user, $password) = @_;

    # get salt of user
    my $salt = (split /\$/, $user->{password})[2];

    # no salt? user does not exist
    return 0 unless $salt;

    # check if given pass salted and hashed matches
    return Crypt::Passwd::XS::unix_sha512_crypt($password, $salt) eq $user->{password} ? 1 : 0;
}

1;

