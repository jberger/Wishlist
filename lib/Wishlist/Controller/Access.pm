package Wishlist::Controller::Access;
use Mojo::Base 'Mojolicious::Controller';

sub login {
  my $c = shift;
  if (my $name = $c->param('name')) {
    $c->session->{name} = $name;
  }
  $c->redirect_to('/');
}

sub logout {
  my $c = shift;
  $c->session(expires => 1);
  $c->redirect_to('/');
}

1;

