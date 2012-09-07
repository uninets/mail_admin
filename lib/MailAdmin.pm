package MailAdmin;
use Mojo::Base 'Mojolicious';
use lib 'lib';

# database schema and connection manager
use MailAdmin::Schema;
use MailAdmin::Controller;
use DBIx::Connector;

# to load config
use YAML;

# This method will run once at server start
sub startup {
    my $self = shift;

    # load config
    $self->config( YAML::LoadFile('config.yml') );

    # add coffee script
    $self->types->type(coffee => 'text/coffeescript; charset=utf-8');

    # configuration
    my $config_file = 'config.yml';

    my $default_config = {
        database => {
            driver => 'Pg',
            dbuser => 'mailadmin',
            dbname => 'mailadmin',
            dbpass => 'mailadmin',
            dbhost => 'localhost',
        },
        session_secret => 'dQiGD3lE0CUwPQAXAod9hhi6sBSV0DqQDIWoPCd0Ukglu6NiA2maJWhVxfWPH05',
        loglevel => 'info',
        mode => 'production',
        hypnotoad => {
            listen => ['http://*:8080'],
        },
    };

    my $config = {};

    if (-f $config_file){
        $config = YAML::LoadFile($config_file);
    }

    # merge loaded config with default config
    $self->config( { (%$default_config, %$config) } );

    # set session secret
    $self->secret( $self->config->{session_secret} );

    # set loglevel
    $self->app->log->level( $self->config->{loglevel} );

    # set mode
    $self->app->mode( $self->config->{mode} );

    # set controller class
    $self->controller_class('MailAdmin::Controller');
    $self->routes->namespace('MailAdmin::Controller');

    # build dsn from config
    my $dsn = 'dbi:' . $self->config->{database}->{driver} . ':dbname=' . $self->config->{database}->{dbname} . ';host=' . $self->config->{database}->{dbhost};
    # prefork save connection handling
    my $connector = DBIx::Connector->new($dsn, $self->config->{database}->{dbuser}, $self->config->{database}->{dbpass});

    my $helpers = {
        model => sub {
            my $resultset = $_[1];
            my $dbh       = MailAdmin::Schema->connect(sub { return $connector->dbh });
            return $resultset ? $dbh->resultset($resultset) : $dbh;
        },
    };

    for (keys %$helpers){
        $self->helper( $_ => $helpers->{$_} );
    }

    my $r = $self->routes;

    my $conditions = {
        authenticated => sub {
            my ( $r, $self ) = @_;

            unless ( $self->session('authenticated') ) {
                $self->flash( class => 'alert alert-info', message => 'Please log in first!' );
                $self->redirect_to('/login');
                return;
            }

            return 1;
        },
        admin_role => sub {
            my ( $r, $self ) = @_;

            my $role = $self->session('role');
            unless ( $role->{name} eq 'admin' ) {
                $self->flash( class => 'alert alert-error', message => "You are no administrator" );
                $self->redirect_to('/login');
                return;
            }

            return 1;
        }
    };

    # add conditions
    for (keys %$conditions){
        $r->add_condition( $_ => $conditions->{$_} );
    }

    $r->get('/')->to('auth#login');
    $r->get('/login')->to('auth#login');
    $r->post('/authenticate')->to('auth#authenticate');

    $r->get('/logout')
        ->over('authenticated')
        ->to('auth#logout');

    # domains
    $r->get('/domains')
        ->over('authenticated')
        ->to('domains#read');
    $r->get('/domains/new')
        ->over('authenticated')
        ->to('domains#add');
    $r->get('/domains/show/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('domains#read');
    $r->post('/domains/create')
        ->over('authenticated')
        ->to('domains#create');
    $r->get('/domains/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('domains#delete');

    # users
    $r->get('/users/new')
        ->over('admin_role')
        ->to('users#add');
    $r->get('/users/edit/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('users#edit');
    $r->post('/users/update')
        ->over('authenticated')
        ->to('users#update');
    $r->post('/users/create')
        ->over('admin_role')
        ->to('users#create');
    $r->get('/users/list')
        ->over('admin_role')
        ->to('users#read');
    $r->get('/users')
        ->over('admin_role')
        ->to('users#read');
    $r->get('/users/delete/:id', id => qr|\d+|)
        ->over('admin_role')
        ->to('users#delete');

    # emails
    $r->get('/emails/new/:domain_id')
        ->over('authenticated')
        ->to('emails#add');
    $r->post('/emails/create')
        ->over('authenticated')
        ->to('emails#create');

    $r->get('/emails/edit/:id')
        ->over('authenticated')
        ->to('emails#edit');
    $r->post('/emails/update')
        ->over('authenticated')
        ->to('emails#update');

    $r->get('/emails/delete/:id')
        ->over('authenticated')
        ->to('emails#delete');

    # aliases
    $r->get('/aliases/new/:email_id')
        ->over('authenticated')
        ->to('aliases#add');
    $r->post('/aliases/create')
        ->over('authenticated')
        ->to('aliases#create');
    $r->get('/aliases/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('aliases#delete');

    # forwards
    $r->get('/forwards/new/:email_id')
        ->over('authenticated')
        ->to('forwards#add');
    $r->post('/forwards/create')
        ->over('authenticated')
        ->to('forwards#update_or_create');
    $r->get('/forwards/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('forwards#delete');

    $self->defaults(
        elements => {
            topnav => 1,
            footer => 1,
            flash  => 1,
        },
        layout => 'mailadmin',
        env_mode => $self->config->{mode},
    );
}

1;
