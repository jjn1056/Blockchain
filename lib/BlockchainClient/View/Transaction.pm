package BlockchainClient::View::Transaction;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';
 
has ['signature', 'transaction_body'] => (
 is=>'ro',
 required=>1);
 
sub TO_JSON($self) {
  return +{
    signature => $self->signature,
    transaction => $self->transaction_body,
  };
}

__PACKAGE__->config( returns_status => [200] );
