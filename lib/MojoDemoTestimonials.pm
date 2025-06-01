package MojoDemoTestimonials;
use Mojo::Base 'Mojolicious', -signatures;

use Mojo::mysql;
use Mojo::SQLite;
use MojoDemoTestimonials::Model::DB;

# This method will run once at server start
sub startup ($self) {

  # load autoreload plugin;
  $self->plugin('AutoReload');

  # Load configuration from config file
  my $config = $self->plugin('Config'); # or NotYAMLConfig

  # Configure the application
  $self->secrets($config->{secrets});

  # Invoking Database handle 
  $self->helper( mysql => sub {
      state $mysql = Mojo::mysql->new(shift->config('mysql'))
  });
  $self->helper( sqlite => sub {
    state $sql = Mojo::SQLite->new->from_filename(shift->config('sqlite'))
  });
  $self->helper( mysql_dbh => sub {
      state $testdb = MojoDemoTestimonials::Model::DB->new(mysql => shift->mysql)
  });
  $self->helper( sqlite_dbh => sub {
    state $testdb = MojoDemoTestimonials::Model::DB->new(sqlite => shift->sqlite)
  });

  # Migrate to latest version if necessary
  my $path = $self->home->child('migrations', 'testimonials.sql');
  $self->sqlite->auto_migrate(1)->migrations->name('testimonials')->from_file($path);

  # Router
  my $r = $self->routes;

  # Normal route to controller
  # $r->get('/')->to('Testimonials#welcome');
  $r->get('/')->to('Testimonials#displayLogin');
  $r->post('/login')->to('Testimonials#validUserCheck');
  $r->any('/logout')->to('Testimonials#logout');

  my $authorized = $r->under('/')->to('Testimonials#alreadyLoggedIn');
  $authorized->get('/testimonials')->to('Testimonials#loadTestimonials');
  $authorized->post('/testimonials')->to('Testimonials#saveTestimonial');
}

1;
