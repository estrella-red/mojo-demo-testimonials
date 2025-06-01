-- 1 up
create table if not exists tct_mojo_testimonials (
  id  integer primary key autoincrement,
  published_by text,
  published_on datetime default current_timestamp,
  testimonial text
);

-- 1 down
drop table if exists posts;
