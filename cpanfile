requires "Sub::Override" => "0";
requires "Class::Load" => "0";
requires "Clone" => "0";
requires "Data::Dumper" => "0";
requires "Exception::Class" => "0";
requires "Exporter::Tiny" => "0";
requires "List::Util" => "0";
requires "Marpa::R2" => "0";
requires "Marpa::XS" => "0";
requires "Moo" => "0";
requires "Moose" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "Ref::Util" => "0";
requires "Scalar::Util" => "0";
requires "Syntax::Construct" => "1.008";
requires "constant" => "0";
requires "namespace::clean" => "0";
requires "overload" => "0";
requires "parent" => "0";
requires "perl" => "5.014";
requires "strict" => "0";
requires "utf8" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Carp::Always" => "0";
  requires "Context::Singleton" => "0";
  requires "Data::Printer" => "0";
  requires "Encode" => "0";
  requires "FindBin" => "0";
  requires "Hash::Util" => "0";
  requires "Path::Tiny" => "0";
  requires "Test::Deep" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0.94";
  requires "Test::Warnings" => "0";
  requires "lib" => "0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::More" => "0";
  requires "Test::Perl::Critic" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
