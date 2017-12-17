package Wishlist;
use Mojo::Base 'Mojolicious';

use DBM::Deep;
use Mojo::File;
use LinkEmbedder;

has users => sub {
  my $app = shift;
  my $file = $app->config->{database} || 'wishlist.db';
  $file = Mojo::File->new($file);
  unless ($file->is_abs) {
    $file = $app->home->child("$file");
  }
  return DBM::Deep->new("$file");
};

sub startup {
  my $app = shift;

  $app->plugin('Config' => {
    default => {},
  });

  if (my $secrets = $app->config->{secrets}) {
    $app->secrets($secrets);
  }

  $app->helper(link => sub {
    my $c = shift;
    state $le = LinkEmbedder->new;
    return $le->get(@_);
  });

  $app->helper(user => sub {
    my ($c, $name) = @_;
    $name ||= $c->stash->{name} || $c->session->{name};
    return {} unless $name;
    return $c->app->users->{$name} ||= {
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

  $r->get('/list/:name')->to(template => 'list')->name('list');

  $r->get('/add')->to('List#show_add')->name('show_add');
  $r->post('/add')->to('List#do_add')->name('do_add');

  $r->post('/update')->to('List#update')->name('update');
  $r->post('/remove')->to('List#remove')->name('remove');

  $r->post('/login')->to('Access#login')->name('login');
  $r->any('/logout')->to('Access#logout')->name('logout');

}

1;

