
use v5.14;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";

BEGIN { require "test-helper-csi.pl" }

use CSI::Language::Java::Grammar;
require Ref::Util;

proclaim 'csi-language' => 'CSI::Language::Java::Grammar';

sub expect_element;
sub expect_token;
sub expect_word;
sub expect_word_false;
sub expect_word_null;
sub expect_word_true;

######################################################################

sub _list_with_separator                {
	my $separator = [];
	my $transform = sub { @_ };

	$separator = shift if Ref::Util::is_plain_arrayref $_[0];
	$transform = shift if Ref::Util::is_plain_coderef  $_[0];

	my @content = map $transform->($_), @_;

	return @content if @content < 2;

	my $head = shift @content;

	return ($head, map { @$separator, $_ } @content);
}

######################################################################

sub expect_element                      {
	my ($name, @expect_content) = @_;

	$name =~ s/^::/CSI::Language::Java::/;

	+{ $name => @expect_content ? \@expect_content : Test::Deep::ignore };
}

sub expect_token                        {
	my ($token, $value) = @_;

	$token =~ s/^::/CSI::Language::Java::/;

	+{ $token => $value // ignore };
}

sub expect_literal_false                { expect_element '::Literal::Boolean::False', expect_word_false  }
sub expect_literal_null                 { expect_element '::Literal::Null',           expect_word_null   }
sub expect_literal_true                 { expect_element '::Literal::Boolean::True',  expect_word_true   }
sub expect_literal_character            { expect_token LITERAL_CHARACTER        => @_ }
sub expect_literal_string               { expect_token LITERAL_STRING           => @_ }
sub expect_literal_floating_decimal     { expect_token LITERAL_FLOAT_DECIMAL    => @_ }
sub expect_literal_integral_binary      { expect_token LITERAL_INTEGRAL_BINARY  => @_ }
sub expect_literal_integral_decimal     { expect_token LITERAL_INTEGRAL_DECIMAL => @_ }
sub expect_literal_integral_hex         { expect_token LITERAL_INTEGRAL_HEX     => @_ }
sub expect_literal_integral_octal       { expect_token LITERAL_INTEGRAL_OCTAL   => @_ }
sub expect_word                         {
	my ($dom) = @_;

	my ($word) = (split '::', $dom)[-1];

	expect_token ($dom => lc $word);
}

sub expect_word_abstract                { expect_word '::Token::Word::Abstract'     }
sub expect_word_assert                  { expect_word '::Token::Word::Assert'       }
sub expect_word_boolean                 { expect_word '::Token::Word::Boolean'      }
sub expect_word_break                   { expect_word '::Token::Word::Break'        }
sub expect_word_byte                    { expect_word '::Token::Word::Byte'         }
sub expect_word_case                    { expect_word '::Token::Word::Case'         }
sub expect_word_catch                   { expect_word '::Token::Word::Catch'        }
sub expect_word_char                    { expect_word '::Token::Word::Char'         }
sub expect_word_class                   { expect_word '::Token::Word::Class'        }
sub expect_word_const                   { expect_word '::Token::Word::Const'        }
sub expect_word_continue                { expect_word '::Token::Word::Continue'     }
sub expect_word_default                 { expect_word '::Token::Word::Default'      }
sub expect_word_do                      { expect_word '::Token::Word::Do'           }
sub expect_word_double                  { expect_word '::Token::Word::Double'       }
sub expect_word_else                    { expect_word '::Token::Word::Else'         }
sub expect_word_enum                    { expect_word '::Token::Word::Enum'         }
sub expect_word_exports                 { expect_word '::Token::Word::Exports'      }
sub expect_word_extends                 { expect_word '::Token::Word::Extends'      }
sub expect_word_false                   { expect_word '::Token::Word::False'        }
sub expect_word_final                   { expect_word '::Token::Word::Final'        }
sub expect_word_finally                 { expect_word '::Token::Word::Finally'      }
sub expect_word_float                   { expect_word '::Token::Word::Float'        }
sub expect_word_for                     { expect_word '::Token::Word::For'          }
sub expect_word_goto                    { expect_word '::Token::Word::Goto'         }
sub expect_word_if                      { expect_word '::Token::Word::If'           }
sub expect_word_implements              { expect_word '::Token::Word::Implements'   }
sub expect_word_import                  { expect_word '::Token::Word::Import'       }
sub expect_word_instanceof              { expect_word '::Token::Word::Instanceof'   }
sub expect_word_int                     { expect_word '::Token::Word::Int'          }
sub expect_word_interface               { expect_word '::Token::Word::Interface'    }
sub expect_word_long                    { expect_word '::Token::Word::Long'         }
sub expect_word_module                  { expect_word '::Token::Word::Module'       }
sub expect_word_native                  { expect_word '::Token::Word::Native'       }
sub expect_word_new                     { expect_word '::Token::Word::New'          }
sub expect_word_null                    { expect_word '::Token::Word::Null'         }
sub expect_word_open                    { expect_word '::Token::Word::Open'         }
sub expect_word_opens                   { expect_word '::Token::Word::Opens'        }
sub expect_word_package                 { expect_word '::Token::Word::Package'      }
sub expect_word_private                 { expect_word '::Token::Word::Private'      }
sub expect_word_protected               { expect_word '::Token::Word::Protected'    }
sub expect_word_provides                { expect_word '::Token::Word::Provides'     }
sub expect_word_public                  { expect_word '::Token::Word::Public'       }
sub expect_word_requires                { expect_word '::Token::Word::Requires'     }
sub expect_word_return                  { expect_word '::Token::Word::Return'       }
sub expect_word_short                   { expect_word '::Token::Word::Short'        }
sub expect_word_static                  { expect_word '::Token::Word::Static'       }
sub expect_word_strictfp                { expect_word '::Token::Word::Strictfp'     }
sub expect_word_super                   { expect_word '::Token::Word::Super'        }
sub expect_word_switch                  { expect_word '::Token::Word::Switch'       }
sub expect_word_synchronized            { expect_word '::Token::Word::Synchronized' }
sub expect_word_this                    { expect_word '::Token::Word::This'         }
sub expect_word_throw                   { expect_word '::Token::Word::Throw'        }
sub expect_word_throws                  { expect_word '::Token::Word::Throws'       }
sub expect_word_to                      { expect_word '::Token::Word::To'           }
sub expect_word_transient               { expect_word '::Token::Word::Transient'    }
sub expect_word_true                    { expect_word '::Token::Word::True'         }
sub expect_word_try                     { expect_word '::Token::Word::Try'          }
sub expect_word_underline               { expect_word '::Token::Word::_'            }
sub expect_word_uses                    { expect_word '::Token::Word::Uses'         }
sub expect_word_var                     { expect_word '::Token::Word::Var'          }
sub expect_word_void                    { expect_word '::Token::Word::Void'         }
sub expect_word_volatile                { expect_word '::Token::Word::Volatile'     }
sub expect_word_while                   { expect_word '::Token::Word::While'        }
sub expect_word_with                    { expect_word '::Token::Word::With'         }

1;

