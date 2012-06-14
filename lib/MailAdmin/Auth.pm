package MailAdmin::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Digest::MD5 'md5_base64';
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

    my $md5sum = md5_base64($password);
    my $user = $self->model('User')->find({ login => $username }, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' });
    my $role = $self->model('Role')->find($user->{role_id}, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' });

    if ($md5sum ne $user->{password}){
        $redirect_target = '/login';
        $self->flash(class => 'alert alert-error', message => "Login failed!");
    }
    else {
        $self->session( user => undef, authenticated => undef );
        $self->session( authenticated => 1, user => $user, role => $role ? $role : { name => 'none' } );
        $self->flash(class => 'alert alert-success', message => 'Login successful!');
    }

    $self->redirect_to($redirect_target);
}

sub logout {
    my $self = shift;

    $self->session( user => undef, authenticated => undef, role => undef );

    $self->flash(class => 'alert alert-info', message => 'Logged out!');
    $self->redirect_to('/login');
}

1;

