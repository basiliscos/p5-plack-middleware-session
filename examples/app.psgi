#!/usr/bin/perl

use Plack::Session;
use Plack::Session::State;
use Plack::Session::State::Cookie;
use Plack::Session::Store;
use Plack::Middleware::Session;

my $app = Plack::Middleware::Session->wrap(
    sub {
        my $env = shift;
        my $r   = Plack::Request->new( $env );

        return [ 404, [], [] ] if $r->path_info =~ /favicon.ico/;

        my $session = $env->{'plack.session'};

        my $id      = $session->id;
        my $counter = $session->get('counter') || 0;

        $session->set( 'counter' => $counter + 1 );

        my $resp;

        if ( $r->param( 'logout' ) ) {
            $session->expire;
            $resp = $r->new_response;
            $resp->redirect( $r->path_info );
        }
        else {
            $resp = $r->new_response(
                200,
                [ 'Content-Type' => 'text/html' ],
                [
                    qq{
                        <html>
                        <head>
                            <title>Plack::Middleware::Session Example</title>
                        </head>
                        <body>
                            <h1>Session Id: ${id}</h1>
                            <h2>Counter: ${counter}</h2>
                            <hr/>
                            <a href="/?logout=1">Logout</a>
                        </body>
                        </html>
                    }
                ]
            );
        }

        $resp->finalize;
    },
    state => Plack::Session::State::Cookie->new,
    store => Plack::Session::Store->new,
);