package Net::RedmineRest::User;
use Moo;
use DateTimeX::Easy;
use Net::RedmineRest::Base;
extends 'Net::RedmineRest::Base';

my $ENTITY='user';

has  entity => ( is=>"rw",default=>${ENTITY});

has api_key        => (is => "rw");
has auth_source_id => (is => "rw");
has _created_on    => (is => "rw");
has created_on     => (
   is => "rw",
   lazy => 1,
   builder => 1
);
has _last_login_on  => (is => "rw");
has last_login_on  => (
   is => "rw",
   lazy => 1,
   builder => 1
);
has firstname      => (is => "rw");
has id             => (is => "rw");
has lastname       => (is => "rw");
has login          => (is => "rw");
has mail           => (is => "rw");
has mail_notification    => (is => "rw");
has must_change_password => (is => "rw");
has password             => (is => "rw");
has status               => (is => "rw");

has json => (is => "rw");


sub email {
   my ($self)=@_;
   return $self->mail();
}

sub _build_created_on {
   my ($self)=@_;
   return DateTimeX::Easy->new($self->_created_on) if ( $self->_created_on);
}

sub _build_last_login_on {
   my ($self)=@_;
   return DateTimeX::Easy->new($self->_last_login_on) if ( $self->_last_login_on);
}

sub _provide_data {

    my ($self)=@_;
    my $data;  

    $data->{auth_source_id}=$self->auth_source_id if (defined($self->auth_source_id) );
    $data->{firstname}=$self->firstname if (defined($self->firstname) );
    $data->{lastname}=$self->lastname if (defined($self->lastname) );
    $data->{login}=$self->login if (defined($self->login) );
    $data->{mail}=$self->mail if (defined($self->mail) );
    $data->{password}=$self->password if (defined($self->password) );
    $data->{mail_notification}=$self->mail_notification if (defined($self->mail_notification) );
    $data->{must_change_password}=$self->must_change_password if (defined($self->must_change_password) );

    my $content;
    $content->{$self->entity}=$data;

   return $content;

}

sub refresh_from_json {

   my ($self,%args)=@_;
   my $json=$self->json;
   return unless ( $json );

   $self->_created_on($json->{created_on});
   $self->_last_login_on($json->{last_login_on});

   $self->api_key($json->{api_key});
   $self->id($json->{id});
   $self->firstname($json->{firstname});
   $self->lastname($json->{lastname});
   $self->login($json->{login});
   $self->mail($json->{mail});
   $self->mail_notification($json->{mail_notification});
   $self->must_change_password($json->{must_change_password});
   $self->password($json->{password});
   
}

sub has_required_load_args {
    my ($self, %attr) = @_;
    die "need specify id." unless defined $attr{id};
    my $id = $attr{id};
    return {id=>$id};
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::RedmineRest::User - Represents a user.

=head1 SYNOPSIS
#
{"user":{"id":4,"login":"net-redmine-unit-tests","firstname":"justanother","lastname":"perlhacker","mail":"invalid@email.com","created_on":"2015-04-22T15:42:25Z","last_login_on":"2015-04-29T15:12:35Z","api_key":"7b7ae7e9f9aed7ffed823f55701bf745c119338c","status":1}}

user (required): a hash of the user attributes, including:
login (required): the user login
password: the user password
firstname (required)
lastname (required)
mail (required)
auth_source_id: authentication mode id
mail_notification: only_my_events, none, etc.
must_change_passwd: true or false


=head1 DESCRIPTION



=cut
