package MailAdmin::Controller::Domains;
use lib 'lib';
use Mojo::Base 'MailAdmin::Controller';
use Data::Validate::Domain;
use Try::Tiny;

sub add {
    my $self = shift;

    if ( $self->session('role') && $self->session('role')->{name} eq 'admin' ) {
        $self->stash( userlist => [ $self->model('User')->all ] );
    }

    if ( $self->stash('id') ) {
        $self->stash( edit_domain => $self->model('Domain')->find( $self->stash('id') ) );
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

    my $domain_name = $self->param('name');
    my $user_id     = undef;

    if ( $self->session('role')->{name} eq 'admin') {
        $user_id = $self->param('user_id');
    }
    else {
        $user_id = $self->session('user')->{id};
    }

    my $domain = $self->model('Domain')->find( { name => $domain_name } );

    if ( !is_domain($domain_name) ) {
        $self->flash( class => 'alert alert-error', message => 'Not a valid domain name!' );
        $self->redirect_to('/domains');
    }
    elsif ( defined $domain ){
        $self->flash( class => 'alert alert-error', message => 'Domain exist!' );
        $self->redirect_to('/domains');
    }
    else {
        $record->{name}    = $self->trim($domain_name);
        $record->{user_id} = $user_id;

        my $result = undef;

        try {
            $result = $self->model('Domain')->create($record);
        };

        if (defined $result){
            $self->flash( class => 'alert alert-success', message => "Domain $domain_name created" );
            $self->redirect_to('domains/show/' . $result->id);
        }
        else {
            $self->flash( class => 'alert alert-error', message => 'Oops! Something went wrong saving the domain!' );
            $self->redirect_to('/domains');
        }
    }
}

sub read {
    my $self = shift;

    if ( $self->session('role') && $self->session('role')->{name} eq 'admin' ) {
        $self->stash( domainlist => [ $self->model('Domain')->order_by_name({}) ] );
    }
    else {
        $self->stash( domainlist => [ $self->model('Domain')->order_by_name( { user_id => $self->session('user')->{id} } ) ] );
    }

    if ( $self->stash('id') ) {
        $self->stash( active => $self->model('Domain')->find( $self->stash('id') ));
    }
    else {
        if ( $self->stash('domainlist')->[0] ){
            $self->stash( active => $self->model('Domain')->find( $self->stash('domainlist')->[0]->id ));
        }
    }

    my $emails = {};
    if ($self->stash('active')){
        $emails = [$self->model('Email')->search({ domain_id => $self->stash('active')->id }, { order_by => { -asc => 'address' }})];
    }

    $self->stash( emails => $emails );

    $self->render();
}

sub delete {
    my $self = shift;

    my $domain = $self->model('Domain')->find( { id => $self->stash('id') } );
    my $domain_name = $domain->name;

    if ( $self->check_user_permission($domain->user_id) ) {
        $domain->delete;
        $self->flash( class => 'alert alert-info', message => "Deleted $domain_name" );
    }
    else {
        $self->flash( class => 'alert alert-error', message => 'You have no permission to do that!' );
    }

    $self->redirect_to('/domains');
}

1;

