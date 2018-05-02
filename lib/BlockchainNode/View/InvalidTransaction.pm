package BlockchainNode::View::InvalidTransaction;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';
 
sub TO_JSON($self) {
  return +{
    message => 'Invalid Transaction!',
  };
}

__PACKAGE__->config( returns_status => [406] );
