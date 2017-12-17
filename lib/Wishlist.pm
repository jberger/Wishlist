package Wishlist;
use Mojo::Base 'Mojolicious';

use DBM::Deep;
use LinkEmbedder;

sub startup {
  my $app = shift;

  $app->helper(link => sub {
    my $c = shift;
    state $le = LinkEmbedder->new;
    return $le->get(@_);
  });

  $app->helper(users => sub {
    state $db = DBM::Deep->new('wishlist.db');
  });

  $app->helper(user => sub {
    my ($c, $name) = @_;
    $name ||= $c->stash->{name} || $c->session->{name};
    return {} unless $name;
    return $c->users->{$name} ||= {
      name => $name,
      items => {},
    };
  });

  my $r = $app->routes;
  $r->get('/' => sub {
    my $c = shift;
    my $template = $c->session->{name} ? 'list' : 'login';
    $c->render($template);
  });

  $r->get('/list/:name' => 'list');

  $r->get('/add' => sub {
    my $c = shift;
    my $link = $c->link($c->param('url'));
    $c->render('add', link => $link);
  });

  $r->post('/add' => sub {
    my $c = shift;
    my $title = $c->param('title');
    $c->user->{items}{$title} = {
      title => $title,
      url => $c->param('url'),
      purchased => 0,
    };
    $c->redirect_to('/');
  });

  $r->post('/update' => sub {
    my $c = shift;
    my $user = $c->user($c->param('user'));
    my $item = $user->{items}{$c->param('title')};
    $item->{purchased} = $c->param('purchased');
    $c->redirect_to('list', name => $user->{name});
  });

  $r->post('/remove' => sub {
    my $c = shift;
    delete $c->user->{items}{$c->param('title')};
    $c->redirect_to('/');
  });

  $r->post('/login' => sub {
    my $c = shift;
    if (my $name = $c->param('name')) {
      $c->session->{name} = $name;
    }
    $c->redirect_to('/');
  });

  $r->any('/logout' => sub {
    my $c = shift;
    $c->session(expires => 1);
    $c->redirect_to('/');
  });

}

1;

