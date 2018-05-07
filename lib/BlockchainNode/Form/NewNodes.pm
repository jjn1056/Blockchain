package  BlockchainNode::Form::NewNodes;

use signatures;
use Moo;
use Data::MuForm::Meta;

extends 'Data::MuForm';

has_field 'nodes' => (
  type => 'Text',
  required => 1 );

sub as_nodes_array($self) {
  if($self->validated) {
    my $nodes = $self->fif->{nodes};
    $nodes =~s/ //g;
    return my @nodes = split(',',$nodes);
  } else {
    return ();
  }
}

1;
