package MailAdmin;
use Mojo::Base 'Mojolicious';
use lib 'lib';

# database schema and connection manager
use MailAdmin::Schema;
use DBIx::Connector;

# to load config
use YAML;

# for encrypt helper
use String::Random;
use Crypt::Passwd::XS 'unix_sha512_crypt';

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->config( YAML::LoadFile('config.yml') );

    my $dsn = 'dbi:' . $self->config->{database}->{driver} . ':dbname=' . $self->config->{database}->{dbname} . ';host=' . $self->config->{database}->{dbhost};
    my $connector = DBIx::Connector->new($dsn, $self->config->{database}->{dbuser}, $self->config->{database}->{dbpass});

    use Data::Dumper;
    say Dumper $self->config;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->plugin('TagHelpers');

    $self->helper(
        model => sub {
            my $resultset = $_[1];
            my $dbh       = MailAdmin::Schema->connect(sub { return $connector->dbh });
            return $resultset ? $dbh->resultset($resultset) : $dbh;
        }
    );
    $self->helper(
        encrypt_password => sub {
            my ($self, $plaintext) = @_;

            my $salt = String::Random::random_string('s' x 16);
            return Crypt::Passwd::XS::unix_sha512_crypt($plaintext, $salt);
        }
    );
    $self->helper(
        user_authenticate => sub {
            my ($self, $user, $password) = @_;

            # get salt of user
            my $salt = (split /\$/, $user->{password})[2];

            # no salt? user does not exist
            return 0 unless $salt;

            # check if given pass salted and hashed matches
            return Crypt::Passwd::XS::unix_sha512_crypt($password, $salt) eq $user->{password} ? 1 : 0;
        }
    );

    $self->helper(
        trim => sub {
            my ($self, $string) = @_;
            $string =~ s/^\s*(.*)\s*$/$1/gmx;

            return $string
        }
    );

    $self->helper(
        check_user_permission => sub {
            my ($self, $check_id) = @_;

            return ($check_id == $self->session('user')->{id} || $self->session('role')->{name} eq 'admin') ? 1 : 0;
        }
    );

    my $r = $self->routes;

    $r->add_condition(
        authenticated => sub {
            my ( $r, $self ) = @_;

            unless ( $self->session('authenticated') ) {
                $self->flash( class => 'alert alert-info', message => 'Please log in first!' );
                $self->redirect_to('/login');
                return;
            }

            return 1;
        }
    );
    $r->add_condition(
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
    );

    $r->get('/')->to('auth#login');
    $r->get('/login')->to('auth#login');
    $r->post('/authenticate')->to('auth#authenticate');

    $r->get('/logout')
        ->over('authenticated')
        ->to('auth#logout');

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
        ->to('domains#update_or_create');
    $r->get('/domains/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('domains#delete');

    $r->get('/users/new')
        ->over('admin_role')
        ->to('users#add');
    $r->get('/users/edit/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('users#add');
    $r->post('/users/create')
        ->over('authenticated')
        ->to('users#update_or_create');
    $r->get('/users/list')
        ->over('admin_role')
        ->to('users#read');
    $r->get('/users')
        ->over('admin_role')
        ->to('users#read');
    $r->get('/users/delete/:id', id => qr|\d+|)
        ->over('admin_role')
        ->to('users#delete');

    $r->get('/emails/new/:domain_id')
        ->over('authenticated')
        ->to('emails#add');
    $r->get('/emails/edit/:id')
        ->over('authenticated')
        ->to('emails#add');
    $r->post('/emails/create')
        ->over('authenticated')
        ->to('emails#update_or_create');
    $r->get('/emails/delete/:id')
        ->over('authenticated')
        ->to('emails#delete');

    $r->get('/aliases/new/:email_id')
        ->over('authenticated')
        ->to('aliases#add');
    $r->post('/aliases/create')
        ->over('authenticated')
        ->to('aliases#update_or_create');
    $r->get('/aliases/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('aliases#delete');

    $r->get('/forwards/new/:email_id')
        ->over('authenticated')
        ->to('forwards#add');
    $r->post('/forwards/create')
        ->over('authenticated')
        ->to('forwards#update_or_create');
    $r->get('/forwards/delete/:id', id => qr|\d+|)
        ->over('authenticated')
        ->to('forwards#delete');
}

1;
