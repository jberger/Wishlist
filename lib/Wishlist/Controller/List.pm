package Wishlist::Controller::List;
use Mojo::Base 'Mojolicious::Controller';

sub show_add {
  my $c = shift;
  my $link = $c->link($c->param('url'));
  $c->render('add', link => $link);
}

sub do_add {
  my $c = shift;
  my $title = $c->param('title');
  $c->user->{items}{$title} = {
    title => $title,
    url => $c->param('url'),
    purchased => 0,
  };
  $c->redirect_to('/');
}

sub update {
  my $c = shift;
  my $user = $c->user($c->param('user'));
  my $item = $user->{items}{$c->param('title')};
  $item->{purchased} = $c->param('purchased');
  $c->redirect_to('list', name => $user->{name});
}

sub remove {
  my $c = shift;
  delete $c->user->{items}{$c->param('title')};
  $c->redirect_to('/');
}

1;

