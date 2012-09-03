package MailAdmin::Forwards;
use Mojo::Base 'Mojolicious::Controller';
use Email::Valid;

sub add {
    my $self = shift;

    unless ( $self->stash('email_id') ){
        $self->flash(class => 'alert alert-error', message => 'No email id given!');
        $self->redirect_to('/domains');
    }

    my $email = $self->model('Email')->find($self->stash('email_id'));

    if ($self->req->is_xhr){
        $self->layout(undef);
        $self->stash( elements => {} );
    }

    if ($self->req->is_xhr){
        $self->stash( elements => {}, ajax => 1 );
    }

    $self->render( email => $email );
}

sub update_or_create {
    my $self = shift;

    my $record = {};

    my $address = $self->param('address');
    my $email_id = $self->param('email_id');

    my $email = $self->model('Email')->find($email_id);

    if (!$self->check_user_permission($email->domain->user->id)){
        $self->flash(class => 'alert alert-error', message => 'Not authorized to add forwards to this address!');
        $self->redirect_to('/domains');
    }
    elsif (!(Email::Valid->address($address))){
        $self->flash(class => 'alert alert-error', message => $address . ' is not a valid email address!');
        $self->redirect_to('/domains');
    }
    else {
        $self->flash(class => 'alert alert-info', message => 'Created forward ' . $address );
        $self->model('Forward')->update_or_create({ email_id => $email_id, address => $self->trim($address) });
    }

    $self->redirect_to('/domains/show/' . $email->domain->id);
}

sub read {
    my $self = shift;

    $self->render();
}

sub delete {
    my $self = shift;

    my $domain = $self->model('Forward')->find($self->stash('id'))->email->domain;

    if (!$self->check_user_permission($domain->user_id)){
        $self->flash(class => 'alert alert-error', message => 'Not authorized!');
        $self->redirect_to('/domains');
    }
    else {
        my $fw = $self->model('Forward')->find($self->stash('id'));
        my $address = $fw->address;
        $fw->delete;
        $self->flash(class => 'alert alert-info', message => 'Deleted ' . $address . ' from forwards.' );
    }

    $self->redirect_to('/domains/show/' . $domain->id );
}

1;

