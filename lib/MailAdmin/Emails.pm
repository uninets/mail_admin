package MailAdmin::Emails;
use Mojo::Base 'Mojolicious::Controller';
use Email::Valid;

sub add {
    my $self = shift;
    my $domain;

    # edit
    if ($self->stash('id')){
        my $email = $self->model('Email')->find({ id => $self->stash('id') });
        $self->stash( edit_email => $email );
        $domain = $self->model('Domain')->find({ id => $email->domain_id });
    }
    # create
    elsif ($self->stash('domain_id')){
        $domain = $self->model('Domain')->find({ id => $self->stash('domain_id') });
    }

    if (!$domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain!');
    }
    elsif ($self->check_user_permission($domain->user_id)){
        $self->stash( domain => $domain );
    }
    else {
        $self->flash(class => 'alert alert-error', message => 'You are not allowed to add emails to this domain!');
    }

    $self->layout(undef) if $self->req->is_xhr;
    $self->render();
}

sub update_or_create {
    my $self = shift;

    my $record          = {};
    my $redirect_target = $self->stash('from');

    my $address = $self->param('address');
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $id = $self->param('id');
    my $domain_id = $self->param('domain_id');

    $domain_id = $self->model('Email')->find($id)->domain_id unless $domain_id;
    my $domain = $self->model('Domain')->find($domain_id);

    if (!$domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain');
    }
    elsif (!$self->check_user_permission($domain->user_id) ){
        $self->flash(class => 'alert alert-error', message => 'Not authorized to add email accounts to this domain!');
    }
    elsif (!Email::Valid->address($address . '@' . $domain->name)){
        $self->flash(class => 'alert alert-error', message => $address . '@' . $domain->name . ' is no valid email address!');
    }
    elsif ($password ne $password_v){
        $self->flash(class => 'alert alert-error', message => 'Passords do not match!');
    }
    elsif ($password eq ''){
        $self->flash(class => 'alert alert-error', message => 'Passord must not be empty!');
    }
    else {
        $record->{address} = $self->trim($address);
        $record->{domain_id} = $domain_id;
        $record->{password} = $self->encrypt_password($password);
        $record->{id} = $id if $id;

        $self->model('Email')->update_or_create($record);

        $self->flash(class => 'alert alert-info', message => $address . '@' . $domain->name . ' created');

        $redirect_target = '/domains/show/' . $domain->id;
    }

    $self->redirect_to('/domains/show/' . $domain->id);
}

sub delete {
    my $self = shift;

    my $domain = $self->model('Email')->find($self->stash('id'))->domain;

    if (!$self->check_user_permission($domain->user_id)){
        $self->flash(class => 'alert alert-error', message => 'Not authorized!');
        $self->redirect_to('/domains');
    }
    else {
        my $email = $self->model('Email')->find($self->stash('id'));
        my $address = $email->address;
        $email->delete;
        $self->flash(class => 'alert alert-info', message => 'Deleted ' . $address . '@' . $domain->name . '.' );
    }

    $self->redirect_to('/domains/show/' . $domain->id );
}

1;

