package BlockchainNode::View::ConflictResolution;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has message => (is=>'ro', required=>1);
has new_chain => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    'message' => $self->message,
    'new_chain' => $self->new_chain,
  };
}

__PACKAGE__->config( returns_status => [200] );
