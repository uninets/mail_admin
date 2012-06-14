package MailAdmin::Emails;
use Mojo::Base 'Mojolicious::Controller';
use Email::Valid;

sub add {
    my $self = shift;

    my $domain = $self->model('Domain')->find({ id => $self->stash('domain_id') });

    if (!$domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain!');
    }
    elsif ($self->session('user')->{id} == $domain->user_id || $self->session('role')->{name} eq 'admin'){
        $self->stash( domain => $domain );
    }
    else {
        $self->flash(class => 'alert alert-error', message => 'You are not allowed to add emails to this domain!');
    }

    if ($self->stash('id')){
        my $email = $self->model('Email')->find({ id => $self->stash('id') });
        $self->stash( edit_email => $email );
    }

    $self->render( from => $self->req->url->path );
}

sub update_or_create {
    my $self = shift;

    my $record          = {};
    my $redirect_target = $self->stash('from');

    my $address = $self->param('address');
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $domain_id = $self->param('domain_id');
    my $id = $self->param('id');

    my $domain = $self->model('Domain')->find($domain_id);

    if (!$domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain');
    }
    elsif (!($domain->user_id == $self->session('user')->{id}) && !($self->session('role')->{name} eq 'admin') ){
        $self->flash(class => 'alert alert-error', message => 'Not authorized to add email accounts to this domain!');
    }
    elsif (!Email::Valid->address($address . '@' . $domain->name)){
        $self->flash(class => 'alert alert-error', message => $address . '@' . $domain->name . ' is no valid email address!');
    }
    elsif ($password ne $password_v){
        $self->flash(class => 'alert alert-error', message => 'Passords do not match!');
    }
    elsif ($password eq''){
        $self->flash(class => 'alert alert-error', message => 'Passord must not be empty!');
    }
    else {
        $record->{address} = $address;
        $record->{domain_id} = $domain_id;
        $record->{password} = $password;
        $record->{id} = $id if $id;

        $self->model('Email')->update_or_create($record);

        $self->flash(class => 'alert alert-info', message => $address . '@' . $domain->name . ' created');

        $redirect_target = '/domains/show/' . $domain->id;
    }

    $self->redirect_to($redirect_target);
}

sub delete {
    my $self = shift;

    $self->render();
}

1;

