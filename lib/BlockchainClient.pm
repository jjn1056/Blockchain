package BlockchainClient;

use Catalyst qw/
  RedirectTo
  ResponseFrom
  URI
  CurrentComponents
  InjectionHelpers
  ConfigLoader
  ServeFile
/;

__PACKAGE__->inject_components(
  'Model::KeyPair' => {
    from_class=>'BlockchainClient::KeyPair', 
    adaptor=>'Factory', 
  },
  'Model::Transaction' => {
    from_class=>'BlockchainClient::Transaction', 
    adaptor=>'Factory', 
  },
  'Model::Form' => { from_component => 'Catalyst::Model::Data::MuForm' },
);

__PACKAGE__->config(
  'Controller::Root' => { namespace=>'' },
  disable_component_resolution_regex_fallback => 1,
  'request_class_traits' => ['Catalyst::TraitFor::Request::ContentNegotiationHelpers'],
);
__PACKAGE__->setup;

