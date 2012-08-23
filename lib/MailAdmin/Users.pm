package MailAdmin::Users;
use Mojo::Base 'Mojolicious::Controller';
use Email::Valid;

sub add {
    my $self = shift;

    if (my $id = $self->stash('id')){
        my $user = $self->model('User')->find($id);

        if (!$self->check_user_permission($user->id)){
            $self->flash( class => 'alert alert-error', message => 'You can not change other users!');
            $self->redirect('/');
        }
        $self->stash( edit_user => $user );
    }
    elsif (!$self->session->{role}->{name} eq 'admin'){
        $self->flash( class => 'alert alert-error', message => 'Only admins can create users!');
        $self->redirect('/');
    }

    $self->render();
}

sub update_or_create {
    my $self = shift;

    my $record = {};
    my $redirect_target = '/users/new';

    my $username = $self->param('login');
    my $id = $self->param('id');
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $email = $self->param('email');

    if (!Email::Valid->address($email)){
        $self->flash(class => 'alert alert-error', message => 'Invalid email address!');
    }
    elsif ($password ne $password_v){
        $self->flash(class => 'alert alert-error', message => 'Passwords do not match!');
    }
    elsif ($password eq ''){
        $self->flash(class => 'alert alert-error', message => 'Password must not be empty!');
    }
    elsif ($username !~ /[a-zA-Z]{3,10}/){
        $self->flash(class => 'alert alert-error', message => 'Username must match /[a-zA-Z]{3,10}/!');
    }
    else {
        $record->{id} = $id if $id;
        $record->{login} = $self->trim($username);
        $record->{password} = $self->encrypt_password($password);
        $record->{email} = $email;

        $self->model('User')->update_or_create($record);

        $self->flash(class => 'alert alert-success', message => $id ? "User $username saved" : "User $username created");

        # update session data
        if ($self->session('user')->{id} == $id){
            my $user = $self->model('User')->as_hash($id);
            my $role = $self->model('Role')->as_hash({ name => $self->session('role')->{name} });

            $self->session( user => undef, authenticated => undef );
            delete $user->{password};
            $self->session( authenticated => 1, user => $user, role => $role ? $role : { name => 'none' } );
        }

        $redirect_target = $self->session->{role}->{name} eq 'admin' ? '/users/list' : '/domains';
    }

    $self->redirect_to($redirect_target);
}

sub read {
    my $self = shift;

    my $userlist = [$self->model('User')->all];

    $self->render( userlist => $userlist );
}

sub delete {
    my $self = shift;

    my $user = $self->model('User')->find( $self->stash('id'));
    my $name = $user->login;

    if ($user->id == $self->session('user')->{'id'}){
        $self->flash(class => 'alert alert-error', message => "You can not delete yourself!" );
    }
    else {
        $user->delete;
        $self->flash(class => 'alert alert-info', message => "Deleted $name" );
    }

    $self->redirect_to('/users');
}

1;

