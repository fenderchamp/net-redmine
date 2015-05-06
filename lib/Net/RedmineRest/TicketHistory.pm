package Net::RedmineRest::TicketHistory;
use Moo;
use DateTime::Format::DateParse;

use Net::RedmineRest::Issue;
use Net::RedmineRest::User;
use URI;

has connection       => (is => "rw", required => 1);
has id               => (is => "rw", required => 1);

has ticket_id        => (is => "rw", lazy=>1, builder=>1);
has date             => (is => "rw", lazy=>1, builder => 1);
has note             => (is => "rw", lazy=>1, builder => 1);
has property_changes => (is => "rw", lazy=>1, builder => 1);
has author           => (is => "ro", lazy=>1, builder => 1);
has journal          => (is => "ro", lazy=>1, builder => 1);

has ticket => (
    is => "ro",
    lazy=>1,
    builder => 1
);

use pQuery;

sub _build_journal {
   my ($self)           = @_;
   my $json=$self->ticket->json;
   if ( $json && $json->{journals} ) {
        my @journals=@{$json->{journals}};
        my $slot=$self->id - 1;
        $slot=0 unless ( $slot > 0 );
        return $journals[$slot];
   }
   return [];
}

sub _build_property_changes {
   my ($self)           = @_;
   my $property_changes = {};
   foreach my $change (@{$self->journal->{details}}) {
      my $name = $change->{name};
      my $from = $change->{old_value};
      my $to = $change->{ new_value};
      if ( $self->id == 0 ) {
         $property_changes->{$name} = { from => "", to => $from };
      } else  {
         $property_changes->{$name} = { from => $from, to => $to };
      }
   }
   return $property_changes;

}

sub _build_ticket {
    my ($self) = @_;
    return Net::RedmineRest::Issue->load(id => $self->ticket_id, connection => $self->connection);
}

sub _build_ticket_id {
    my ($self) = @_;
    return $self->ticket->ticket_id;
}

use Encode;

sub _build_note {
    my ($self) = @_;
    if ($self->id == 0) {
      return "";
    }
    return Encode::encode_utf8($self->journal->{notes}) if $self->journal->{notes} ;
    return "";
}

sub _build_date {
    my ($self) = @_;
    if ($self->id == 0) {
      return DateTime::Format::DateParse->parse_datetime($self->ticket->created_on);
    }
    return DateTime::Format::DateParse->parse_datetime($self->journal->{created_on}) if $self->journal->{created_on} ;
    return "";
}

sub _build_author {
    my ($self) = @_;
    return Net::RedmineRest::User->load(id => $self->journal->{user}->{id},connection => $self->connection) if $self->journal->{user}->{id};
    return "";
}

__PACKAGE__->meta->make_immutable;
1;
