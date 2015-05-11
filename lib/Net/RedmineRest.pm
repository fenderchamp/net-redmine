package Net::RedmineRest;
use Moo;
our $VERSION = '0.09';
use Net::RedmineRest::Connection;
use Net::RedmineRest::Issue;
use Net::RedmineRest::Project;
use Net::RedmineRest::ProjectList;
use Net::RedmineRest::User;
#use Net::RedmineRest::Search;

has connection => (
    is => "rwp",
    required => 1
);

sub BUILDARGS {
    my $class = shift;
    my %args = @_;
    $args{connection} = Net::RedmineRest::Connection->new(
        url      => delete $args{url},
        user     => delete $args{user},
        password => delete $args{password},
        apikey => delete $args{apikey}
    );

    if ( $args{project} ) {
        $args{connection}->project($args{project}); 
        delete $args{project}; 
    }

    return $class->SUPER::BUILDARGS(%args);
}

sub reset_connection {

   my ($self,%args)=@_;

   my $url=($args{url} || $self->connection->url);
   my $user=($args{user} || $self->connection->user);
   my $password=($args{password} || $self->connection->password);
   my $apikey=($args{apikey} || $self->connection->apikey);
    $self->_set_connection ( Net::RedmineRest::Connection->new(
        url      => $url, 
        user     => $user,
        password => $password,
        apikey =>  $apikey
      )
   );

}

sub create {
    my ($self, %args) = @_;
    return $self->create_ticket(%{$args{ticket}}) if $args{ticket};
}

sub copy {
    my ( $self, %args ) = @_;
    my $orig = $self->lookup_ticket(%$_) if $_ = $args{ticket};
    delete $args{ticket}{id};
    my @list = $orig->meta->get_attribute_list;
    foreach my $attr (@list) {
        next if ( $attr =~ /^(id|connection)$/ );
        next if ( exists $args{ticket}{$attr} );
        $args{ticket}{$attr} = $orig->$attr if defined $orig->$attr;
    }
    return $self->create_ticket(%$_) if $_ = $args{ticket};
}

sub lookup {
    my ($self, %args) = @_;
    return $self->lookup_project(%$_) if $_ = $args{project};
    return $self->lookup_ticket(%$_) if $_ = $args{ticket};
    return $self->lookup_user(%$_) if $_ = $args{user};
}

sub create_ticket {
    my ($self, %args) = @_;
    my $t = Net::RedmineRest::Issue->create(
        connection => $self->connection,
        %args
    );
    return $self->lookup_ticket(id => $t->id);
}

sub load_projects {
    my ($self, %args) = @_;
    my $project_list=Net::RedmineRest::ProjectList->load(connection => $self->connection, %args);
    return $project_list->projects;
}

sub lookup_project {
    my ($self, %args) = @_;
    if ($args{id} || $args{identifier} ) {
        return Net::RedmineRest::Project->load(connection => $self->connection, %args);
    }
}

sub lookup_ticket {
    my ($self, %args) = @_;
    if (my $id = $args{id} ) {
        return Net::RedmineRest::Issue->load(connection => $self->connection, id => $id);
    }
}



sub search_ticket {
    my ($self, $query) = @_;

    my $search;
    #my $search = Net::RedmineRest::Search->new(
    #    connection => $self->connection,
    #    type => ['ticket'],
    #    query => $query
    #);
    return $search;
}

sub lookup_user {
    my ($self, %args) = @_;
    if (my $id = $args{id}) {
        return Net::RedmineRest::User->load(connection => $self->connection, id => $id);
    }
}

1;
__END__

=head1 NAME

Net::RedmineRest - A mechanized-based programming API against redmine server.

=head1 SYNOPSIS

  use Net::RedmineRest;

  my $r = Net::RedmineRest->new(
      url => $server,
      user => $user,
      password => $password
  );

  # Create a new ticket
  my $t1 = $r->create(
      ticket => {
          subject => "bug in the bag!",
          description => "please eliminate the bug for me",
      }
  );

  # Load an existing one.
  my $t2 = $r->lookup(
      ticket => {
          id => 42
      }
  );

  # copy a ticket
  my $t3 = $r->copy (
      ticket => {
          id => 42,  # id of the original ticket we want to copy
          subject => "new subject",
          description => "a description",
      }
  );

=head1 DESCRIPTION

Net::RedmineRest is an mechanized-based programming API against redmine server.

=head1 METHODS

=over

=item new(url => ..., user => ..., password => ...)

Constructor. You need to construct a C<Net::RedmineRest> object before you
can do anything. The parameters to this function is a list of
key-value pairs. All of these 3 pairs are required.

The C<url> should points to a project url. Like http://example.org/projects/foo.
It's the one that points you to the project overview tab.

The user and the password are the login credentials to login this
project.

Notice: One C<Net::RedmineRest> object can only handles one project on a
redmine server. You should create multiple C<Net::RedmineRest> objects if
you're trying to manipulate multiple project at the same program.

=item create( ticket => { ... } )

The C<create> instance method can create tickets. In the future releases
it could also be used to create other kinds of assets.

The value to the C<ticket> key is a HashRef that should at least
contain C<subject> and <description> of the ticket. For example:

    my $t = $r->create(ticket => {
        subject => "Got a bug",
        description => "Found a bug in the bag"
    });

The returned value of this method is a C<Net::RedmineRest::Issue> object.
Also read the document of that class to see how to use it.

=item copy( ticket => {id => Integer, ... } }

The C<copy> instance method can copy an existing ticket. The id is the id
of the original ticket we want to copy. The other values to the C<ticket>
key is the same hasref as for C<create>.

=item lookup( ticket => { id => Integer } }

Given a ticket id, this instance method load the ticket content from
the server, it also returns a C<Net::RedmineRest::Issue> object.

At this point, only C<id> can be specified.

=back

=head1 AUTHOR

Kang-min Liu E<lt>gugod@gugod.orgE<gt>

=head1 SEE ALSO

L<http://redmine.org>, L<Net::Trac>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT (X11) License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
