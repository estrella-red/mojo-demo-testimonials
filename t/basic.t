use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('MojoDemoTestimonials');
$t->get_ok('/')->status_is(200)->content_like(qr/Quote of the day/i);

done_testing();
