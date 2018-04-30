package BlockchainNode;

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
  'Model::Blockchain' => {
    from_class=>'BlockchainNode::Blockchain', 
    adaptor=>'Factory', 
  },
);

__PACKAGE__->config(
  'Controller::Root' => { namespace=>'' },
  disable_component_resolution_regex_fallback => 1,
  'request_class_traits' => ['Catalyst::TraitFor::Request::ContentNegotiationHelpers'],
);

__PACKAGE__->setup;

