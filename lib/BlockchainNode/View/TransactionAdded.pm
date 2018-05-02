package BlockchainNode::View::TransactionAdded;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has transaction_result => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    message => "Transaction will be added to Block ${\$self->transaction_result}"
  };
}

__PACKAGE__->config( returns_status => [201] );
