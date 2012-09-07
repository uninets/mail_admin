package MailAdmin::Controller::Emails;
use lib 'lib';
use Mojo::Base 'MailAdmin::Controller';
use Email::Valid;
use Try::Tiny;
use DateTime;

sub add {
    my $self = shift;
    my $domain;

    if ($self->stash('domain_id')){
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

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {} );
    }

    $self->render();
}

sub edit {
    my $self = shift;
    my $domain;

    # edit
    if ($self->stash('id')){
        my $email = $self->model('Email')->find({ id => $self->stash('id') });
        $self->stash( edit_email => $email );
        $domain = $self->model('Domain')->find({ id => $email->domain_id });
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

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {} );
    }

    $self->render();
}

sub create {
    my $self = shift;

    my $record          = {};

    my $address = $self->trim($self->param('address'));
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $domain_id = $self->param('domain_id');

    my $domain = $self->model('Domain')->find($domain_id);

    if (!defined $domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain!');
        $self->redirect_to('/domains');
    }
    elsif (!$self->_validate_form({
                    user_id => $domain->user_id,
                    address => $address . '@' . $domain->name,
                    password => $password,
                    password_v => $password_v,
                })){
        $self->redirect_to('/domains');
    }
    else {
        $record->{address} = $address;
        $record->{domain_id} = $domain_id;
        $record->{password} = $self->encrypt_password($password);

        my $result = undef;

        try {
            $result = $self->model('Email')->create($record);
        };

        if (defined $result){
            $self->flash(class => 'alert alert-info', message => $address . '@' . $domain->name . ' created');
        }
        else {
            $self->flash(class => 'alert alert-error', message => 'Oops! Something went wrong creating the email address!');
            $self->redirect_to('/domains');
        }

        $self->redirect_to('/domains/show/' . $domain->id);
    }
}

sub update {
    my $self = shift;

    my $record          = {};
    my $redirect_target = $self->stash('from');

    my $address = $self->trim($self->param('address'));
    my $password = $self->param('password');
    my $password_v = $self->param('password_verify');
    my $id = $self->param('id');

    my $domain_id = $self->model('Email')->find($id)->domain_id;
    my $domain = $self->model('Domain')->find($domain_id);

    if (!$domain){
        $self->flash(class => 'alert alert-error', message => 'No such domain');
        $self->redirect_to('/domains');
    }
    elsif (!$domain_id){
        $self->flash(class => 'alert alert-error', message => 'Address does not exist!');
        $self->redirect_to('/domains');
    }
    elsif (!$self->_validate_form({
                    user_id => $domain->user_id,
                    address => $address . '@' . $domain->name,
                    password => $password,
                    password_v => $password_v,
                })){
        $self->redirect_to('/domains');
    }
    else {
        $record->{address} = $address;
        $record->{domain_id} = $domain_id;
        $record->{password} = $self->encrypt_password($password);
        $record->{id} = $id;
        $record->{updated_at} = DateTime->now->strftime('%F %T');

        my $result = undef;

        try {
            $result = $self->model('Email')->update_or_create($record);
        }
        catch {
            say $_;
        };

        if (defined $result){
            $self->flash(class => 'alert alert-info', message => 'Updated ' . $address . '@' . $domain->name );
        }
        else {
            $self->flash(class => 'alert alert-error', message => 'Oops! Something went wrong saving the email address!');
            $self->redirect_to('/domains');
        }

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

sub _validate_form {
    my ($self, $data) = @_;

    if (!$self->check_user_permission($data->{user_id})){
        $self->flash(class => 'alert alert-error', message => 'Not authorized to add email accounts to this domain!');
        return 0;
    }
    elsif (!Email::Valid->address( $data->{address} )){
        $self->flash(class => 'alert alert-error', message => $data->{address} . ' is no valid email address!');
        return 0;
    }
    elsif ($data->{password} ne $data->{password_v}){
        $self->flash(class => 'alert alert-error', message => 'Passwords do not match!');
        return 0;
    }
    elsif ($data->{password} eq ''){
        $self->flash(class => 'alert alert-error', message => 'Passord must not be empty!');
        return 0;
    }

    return 1;
}

1;

