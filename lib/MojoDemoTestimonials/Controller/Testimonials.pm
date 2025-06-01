package MojoDemoTestimonials::Controller::Testimonials;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# This action will render a template
sub welcome ($self) {
  # Render template "example/homepage.html.ep" with message
  $self->render(msg => 'Welcome to My Personal Website!', template => "homepage");
}

sub displayLogin ($self) {
    # If already logged in then direct to home page, if not display login page
    # if(&alreadyLoggedIn($self)){
    # If you are using Mojolicious v9.25 and above use this if statement as re-rendering is forbidden
    # Thank you @Paul and @Peter for pointing this out.
    if ( $self->session('is_auth') ) { # warn '=' x 20;
        welcome($self);
    }
    else { # warn '=' x 20;
       $self->render(template => "login", error_message =>  "");
    }
}

#
# Check if user is valid and create session cookies
#
sub validUserCheck ($self) {
    # List of registered users (obviously should not be in text file)
    my %validUsers = (
      JANE => "welcome123",
      JILL => "welcome234",
      TOM  => "welcome345",
      RAJ  => "test123",
    );

    # Get the user name and password from the page
    my $user = uc $self->param('username');
    my $password = $self->param('passwd');

    # First check if the user exists
    if( $validUsers{$user} ) { # say 'user is valid';
        # Validating the password of the registered user
        if( $validUsers{$user} eq $password ) { # say 'password is valid';
            # Creating session cookies
            $self->session(is_auth => 1);             # set the logged_in flag
            $self->session(username => $user);        # keep a copy of the username
            $self->session(expiration => 600);        # expire this session in 10 minutes if no activity

            # Re-direct to home page
            welcome($self);
        }
        else {
            # If password is incorrect, re-direct to login page and then display appropriate message
            $self->render(template => "login", error_message =>  "Invalid password, please try again");
        }
    }
    else {
        # If user does not exist, re-direct to login page and then display appropriate message
        $self->render(template => "login", error_message =>  "You are not a registered user, please get the hell out of here!");
    }
}

#
# Check if user is already logged in
#
sub alreadyLoggedIn ($self) {
      # checks if session flag (is_auth) is already set
      return 1 if $self->session('is_auth');

      # If session flag not set re-direct to login page again.
      $self->render(template => "login", error_message =>  "You are not logged in, please login to access this website");
      return;
}

#
# When user clicks log out, remove session
# 
sub logout  ($self) {
    # Remove session and direct to logout page
    $self->session(expires => 1);  #Kill the Session
    $self->render(template => "logout");
}

sub loadTestimonials ($self) {
    my $all_testimonials_html;
    
    my $all_testimonials = $self->sqlite_dbh->fetch_all_testimonials;

    foreach my $testimonial ( @{$all_testimonials} ) {
        $all_testimonials_html .= qq~
        <tr>
            <td>
                <div>$testimonial->{testimonial}</div>
                <div style='text-align: right;'>
                  <i>$testimonial->{published_by} [$testimonial->{published_on}]</i>
                </div>
           </td>
        </tr>~;
    }
    $self->render(template => 'managetestimonials',msg => 'View Testimonials',alltestimonials => $all_testimonials_html);
}

sub saveTestimonial ($self) {
    my $new_testimonial = $self->param('userReview');
    my $user = $self->session('username');

    $self->sqlite_dbh->publish_testimonial($new_testimonial,$user);
    loadTestimonials($self);
}

1;
