package BlockchainClient::View::WalletKey;
 
use signatures;
use Crypt::Misc;
use Moo;
 
extends 'Catalyst::View::Base::JSON';
 
has ['private_key', 'public_key'] => (
 is=>'ro',
 required=>1);
 
sub TO_JSON($self) {
  return +{
    private_key => $self->private_key,
    public_key => $self->public_key,
  };
}

__PACKAGE__->config( returns_status => [200] );
