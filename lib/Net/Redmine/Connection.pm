package Net::Redmine::Connection;
use Moo;
use URI;
use Params::Validate;
use Net::Redmine::IssueStatuses;

has url =>      ( is => "rw",  required => 1 );
has user     => ( is => "rw",  required => 1 );
has password => ( is => "rw",  required => 0 );
has apikey   => ( is => "rw",  required => 0 );

has is_logined  => ( is => "rw");
has rest_failed => ( is => "rw");
has rest_tested => ( is => "rw");
has is_mech     => ( is => "rw");

has base_url => ( is => "rw", lazy => 1, builder => 1);
has issue_statuses => ( is => "rw", lazy =>1, builder =>1);
has mechanize => ( is => "rw", lazy => 1, builder => 1);
has project => ( is => "rw", lazy => 1, builder => 1);
has rest => ( is => "rw", lazy => 1, builder => 1);

has _live_ticket_objects => ( is => "rw", lazy=>1, builder => 1);

use WWW::Mechanize;
use REST::Client;
use JSON;

sub _build_issue_statuses {
   my ($self)=@_;
   return Net::Redmine::IssueStatuses->load(
      connection=>$self
   );
}

sub _build__live_ticket_objects { return {} };

sub live_ticket_objects { return $_[0]->_live_ticket_objects };

sub _prep_request {
   my ($self,%args)=@_;

   my $headers;    

   my $url=$self->base_url().'/'.$args{service};
   $url=$url.'/'.$args{id} if ( defined($args{id}) );
   $url=$url.'.json';

   $headers->{'Content-Type'}='application/json';
   my $content;
   if ( $args{content} ) {
      $args{content}->{key}=$self->apikey if ($self->apikey );
      $content=encode_json $args{content} 
   }
   return ($url,$content,$headers);
}

sub POST {
   my ($self,%args)=@_;

   my ($url,$data,$headers) = $self->_prep_request(%args);
   my $rest=$self->rest;
   $rest->POST($url,$data,$headers);

   my ($code,$content)=($rest->responseCode, $rest->responseContent);
   $self->rest_tested(1);
   if ( $code == 201 && $content ) {
      $content=decode_json $content; 
   } else {
      $self->test_rest_connection() unless ($self->rest_failed ); 
   }
   return ($code,$content);
}

sub PUT {
   my ($self,%args)=@_;
   my ($url,$data,$headers) = $self->_prep_request(%args);
   my $rest=$self->rest;
   $rest->PUT($url,$data,$headers);

   my ($code,$content)=($rest->responseCode, $rest->responseContent);
   $self->rest_tested(1);
   if ( $code == 200 && $content ) {
      $content=decode_json $content;
   } {
      $self->test_rest_connection() unless ($self->rest_failed ); 
   }
   return ($code,$content);
}

sub DELETE {
   my ($self,$url)=@_;
   return $self->_submit_id_only($url,'DELETE');
}

sub GET {
   my ($self,$url)=@_;
   return $self->_submit_id_only($url,'GET');
}

sub _submit_id_only {
   my ($self,$url,$action)=@_;

   $action='GET' unless ($action);

   die '$action:needs url' unless ( $url );
   my $rest=$self->rest;
   my $apikey=($self->apikey || '');
   my $delim='?';
   $delim='&' if ($url =~ /\.json\?/ );
   $rest->$action($url.${delim}.'key=' . $apikey);

   my ($code,$content)=($rest->responseCode, $rest->responseContent);
   if ( $code == 200 && $content ) {
      $content=decode_json $content;
   } else {
      $self->test_rest_connection() unless ($self->rest_tested ); 
   }
   return ($code,$content);
}

sub rest_works {
   my ( $self,%args ) = @_;
   $self->test_rest_connection unless ( $self->rest_tested );
   if ( $self->rest_tested ) {
      return 1 unless ( $self->rest_failed() ) 
   }
   return 0; 
}

sub test_rest_connection {
   my ( $self,%args ) = @_;
   return if ( $self->rest_tested() );
   $self->rest_tested(1);
   my ( $code,$content) = $self->projects_list();
   if ( $code && $code == 200 ) {
      return 1;
   } else {
      $self->rest_failed(1);
   }
}

sub projects_list {
   my ( $self,%args ) = @_;
   my ( $code,$content) = $self->GET($self->base_url . '/projects.json' );
   return  ( $code,$content);
}

sub _build_project {
   my ($self) = @_;
   my ($project,$base_url)=$self->_parse_url();
   return $project;
}

sub _build_base_url {
   my ($self) = @_;
   my ($project,$base_url)=$self->_parse_url();
   $self->project($project) unless ( $self->project ); 
   return $base_url;
}

sub _parse_url {
    my ($self) = @_;
    my $url=$self->url();
    my $o_uri = URI->new($url);
    if ( $o_uri->path  ) {
         if ( my ($project) = ($o_uri->path =~ m/^\/projects\/(.*)\s*$/i ) ) {
              my ($base) = ($url =~ m/^\s*(.*)\/projects/i );
              return ($project,$base);
         }
      }
      return (' ',$url);;
}

sub _build_mechanize {
    my ($self) = @_;
    my $mech = WWW::Mechanize->new(autocheck => 0);
    return $mech;
}

sub _build_rest {
    my ($self) = @_;
    my $rtn = REST::Client->new();
    return $rtn;
}

sub get_login_page {
    my $self= shift;

    my $uri = URI->new($self->url);
    $uri->path("/login");
    $self->mechanize->get( $uri->as_string );

    return $self;
}

sub assert_login {

    my ($self) = @_;
    return 1 if ( $self->is_logined );
    my $mech = $self->get_login_page->mechanize;
    my $form_n = 0;
    my @forms = $mech->forms;
    for (@forms) {
        $form_n++;
        if ($_->method eq 'POST' && $_->action eq $mech->uri) {
            last;
        }
    }

    if ($form_n > @forms) {
        die "There is no login form on the login page. (@{[ $mech->uri ]})";
    }

    my $res = $mech->submit_form( #1 based not zero based
        form_number => $form_n,
        fields => {
            username => $self->user,
            password => $self->password
        }
    );
    my $d_c = $res->decoded_content;
    if ( $d_c =~ /<div class="flash error"/ ) {
        die "Can't login, invalid login or password !";
    }
    $self->is_logined(1);
    return 1;

}

sub get_project_overview {
    my ($self,%args) = @_;
    $self->assert_login();

    $self->mechanize->get( $self->url );
    return $self;
}

sub get_issues_page {
    my ($self, $id) = @_;
    $self->get_project_overview();
      
    my $mech = $self->mechanize;

    if ($id) {
        $mech->submit_form(form_number => 1, fields => { q => "#" . $id });
        die "Failed to get the ticket(id = $id)\n" unless $mech->response->is_success;
        die "No such ticket id = $id\n" unless $mech->uri =~ m[/issues/(?:show/)?${id}$];
    }
    else {
        $mech->follow_link( url_regex => qr[/issues$] );
        die "Failed to get the ticket overview page\n" unless $mech->response->is_success;
    }

    return $self;
}

sub get_new_issue_page {
    my ($self) = @_;

    my $mech = $self->get_project_overview->mechanize;
    $mech->follow_link( url_regex => qr[/issues/new$] );

    die "Failed to get the 'New Issue' page\n" unless $mech->response->is_success;

    return $self;
}

sub get_user_page {
    my $self = shift;
    validate(@_, { id => 1 });

    my %args = @_;
    my $mech = $self->mechanize;

    my $uri = URI->new($mech->uri);

    $uri->path("/users/$args{id}");
    $mech->get($uri->as_string);

    unless ($mech->response->is_success) {
        $uri->path("/account/show/$args{id}");
        $mech->get($uri->as_string);

        unless ($mech->response->is_success) {
            die "Fail to guess user page on this redmine server.\n"
        }
    }

    return $self;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Redmine::Connection

=head1 SYNOPSIS

    # Initialize a redmine connection object
    my $redmine = Net::Redmine::Connection->new(
        url => 'http://redmine.example.com/projects/show/fooproject'
        user => 'hiro',
        password => 'yatta'
    );

    # Passed it to other classes
    my $ticket = Net::Redmine::Ticket->new(connection => $redmine);

=head1 DESCRIPTION



=cut
