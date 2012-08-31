package MailAdmin::Websocket;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use Mojo::JSON;

sub chat {
    my $self = shift;

    my $name = $self->session->{user}->{login};
    my $clients = $self->clients($name, $self->tx);

    $self->on(
        message => sub {
            my ($self, $msg) = @_;
            my $token = $self->config->{keep_alive_token};

            # do nothing if message is a keep-alive token
            unless ($msg ~~ /$token/){
                my $json = Mojo::JSON->new;
                my $dt   = DateTime->now( time_zone => 'Europe/Berlin');

                for (keys %$clients) {
                    say $_;
                    $clients->{$_}->send(
                        $json->encode({
                            name => $name,
                            hms  => $dt->hms,
                            text => $msg,
                        })
                    );
                }
            }
        }
    );
}

1;

