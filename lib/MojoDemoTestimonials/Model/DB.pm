package MojoDemoTestimonials::Model::DB;
use Mojo::Base -base, -signatures;

has 'mysql';
has 'sqlite';

my $tbl = 'tct_mojo_testimonials';

# Subroutine to get all the testimonials
sub fetch_all_testimonials ($self) {
    my $sql = qq!select * from $tbl order by published_on desc!;
    # $self->mysql->db->query($sql)->hashes->to_array;
    $self->sqlite->db->query($sql)->hashes->to_array;
}

# Subroutine to insert the new testimonial to database
sub publish_testimonial ($self, $new_testimonial, $username) {
   my $sql = qq!insert into $tbl(published_by,testimonial) values (?,?)!;
   # $self->mysql->db->query($sql, $username, $new_testimonial);
   $self->sqlite->db->query($sql, $username, $new_testimonial);
}

1;