package MailAdmin::Controller::Users;
use lib 'lib';
use Mojo::Base 'MailAdmin::Controller';
use Email::Valid;
use DateTime;

sub add {
    my $self = shift;

    if (!$self->session->{role}->{name} eq 'admin'){
        $self->flash( class => 'alert alert-error', message => 'Only admins can create users!');
        $self->redirect('/');
    }

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {}, ajax => 1 );
    }

    $self->render();
}

sub edit {
    my $self = shift;

    if (my $id = $self->stash('id')){
        my $user = $self->model('User')->find($id);

        if (!$self->check_user_permission($user->id)){
            $self->flash( class => 'alert alert-error', message => 'You can not change other users!');
            $self->redirect('/');
        }
        $self->stash( user => $user );
    }
    elsif (!$self->session->{role}->{name} eq 'admin'){
        $self->flash( class => 'alert alert-error', message => 'Only admins can create users!');
        $self->redirect('/');
    }

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {}, ajax => 1 );
    }

    $self->render();
}

sub create {
    my $self = shift;

    my $record = {};

    my $username = $self->trim($self->param('login'));
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $email = $self->trim($self->param('email'));

    if (!$self->_validate_form({
                    user_id => $self->session->{user}->{id},
                    username => $username,
                    email => $email,
                    password => $password,
                    password_v => $password_v,
                })){
        $self->redirect_to('/domains');
    }
    else {
        $record->{login} = $username;
        $record->{password} = $self->encrypt_password($password);
        $record->{email} = $email;

        $self->model('User')->update_or_create($record);

        $self->flash(class => 'alert alert-success', message => "User $username created");

        $self->redirect_to($self->session->{role}->{name} eq 'admin' ? '/users/list' : '/domains');
    }
}

sub update {
    my $self = shift;

    my $record = {};

    my $username = $self->param('login');
    my $id = $self->param('id');
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $email = $self->param('email');

    if (!$self->_validate_form({
                    user_id => $self->session->{user}->{id},
                    username => $username,
                    email => $email,
                    password => $password,
                    password_v => $password_v,
                })){
        $self->redirect_to('/domains');
    }
    else {
        $record->{id} = $id if $id;
        $record->{login} = $self->trim($username);
        $record->{password} = $self->encrypt_password($password);
        $record->{email} = $email;
        $record->{updated_at} = DateTime->now->strftime('%F %T');

        $self->model('User')->update_or_create($record);

        $self->flash(class => 'alert alert-success', message => $id ? "User $username saved" : "User $username created");

        # update session data
        if ($id && $self->session('user')->{id} == $id){
            my $user = $self->model('User')->as_hash($id);
            my $role = $self->model('Role')->as_hash({ name => $self->session('role')->{name} });

            $self->session( user => undef, authenticated => undef );
            delete $user->{password};
            $self->session( authenticated => 1, user => $user, role => $role ? $role : { name => 'none' } );
        }

        $self->redirect_to( $self->session->{role}->{name} eq 'admin' ? '/users/list' : '/domains' );
    }
}

sub read {
    my $self = shift;

    my $userlist = [$self->model('User')->all];

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {}, ajax => 1 );
    }

    $self->render( userlist => $userlist );
}

sub delete {
    my $self = shift;

    my $user = $self->model('User')->find( $self->stash('id'));
    my $name = $user->login;

    # checks basically if a user has the 'admin' role but does not delete himself
    if ($self->check_user_permission($user->id) && $user->id != $self->session->{user}->{id}){
        $user->delete;
        $self->flash(class => 'alert alert-info', message => "Deleted $name" );
    }
    else {
        $self->flash(class => 'alert alert-error', message => "You can not delete $name!" );
    }

    $self->redirect_to('/users');
}

sub _validate_form {
    my ($self, $data) = @_;

    if (!$self->check_user_permission($data->{user_id})){
        $self->flash(class => 'alert alert-error', message => 'Not authorized to add email accounts to this domain!');
        return 0;
    }
    elsif (!Email::Valid->address($data->{email})){
        $self->flash(class => 'alert alert-error', message => 'Invalid email address!');
        return 0;
    }
    elsif ($data->{password} ne $data->{password_v}){
        $self->flash(class => 'alert alert-error', message => 'Passwords do not match!');
        return 0;
    }
    elsif ($data->{password} eq ''){
        $self->flash(class => 'alert alert-error', message => 'Password must not be empty!');
        return 0;
    }
    elsif ($data->{username} !~ /[a-zA-Z]{3,10}/){
        $self->flash(class => 'alert alert-error', message => 'Username must match /[a-zA-Z]{3,10}/!');
        return 0;
    }

    return 1;
}

1;

