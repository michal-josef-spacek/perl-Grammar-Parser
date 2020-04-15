
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Grammar v1.0.0 {
	use CSI::Grammar;
	use Ref::Util;
	require CSI::Language::Java::Actions;

	default_rule_action 'pass_through';
	default_token_action 'pass_through';

	register_action_lookup 'CSI::Language::Java::Actions';

	# groups
	rule keyword                            => ;
	rule keyword_identifier                 => ;
	rule keyword_type_identifier            => ;

	sub word {
		my ($keyword, @opts) = @_;
		$keyword = ucfirst lc $keyword;
		my $re = qr/ (?> \b ${\ lc $keyword } \b ) /sx;

		my @dom   = (dom => "::Token::Word::$keyword");
		my @proto = (proto => 'Prohibited_Identifier');
		my @group = (group => 'keyword');

		while (@opts) {
			my $key   = shift @opts;
			my $value = shift @opts;

			goto $key;

			dom:
			$dom[1] = $value;
			next;

			group:
			push @group, group => $value unless $value eq $group[1];
			next;

			proto:
			push @proto, proto => $value unless $value eq $proto[1];
			next;
		}

		$dom[1] =~ s/^::/CSI::Language::Java::/;

		token uc $keyword => @proto, @group, $re;
		rule  lc $keyword => @dom, [ uc $keyword ]
			unless $keyword eq '_';
	}

	sub operator {
		my ($name, $dom, @params) = @_;

		my $code = Ref::Util::is_plain_arrayref ($params[-1])
			? \& rule
			: \& token
			;

		$dom =~ s/^::/CSI::Language::Java::/;

		$code->($name, dom => $dom, @params);
	}


	start rule TOP                          => dom => 'CSI::Document',
		[qw[  compilation_unit  ]],
		[],
		;

	regex Binary_Numeral                    => qr/(?>
		0 [bB]
		[_01]+
		(?<= [01])
	)/sx;

	regex Decimal_Numeral                   => qr/(?>
		(?! 0 [_[:digit:]] )
		(?= [[:digit:]])
		[_[:digit:]]+
		(?<= [[:digit:]])
	)/sx;

	regex Escape_Sequence                   => qr/(?>
		\\
		(?:
			  (?<char_escape> (?: [btnrf\'\"\\] ))
			| (?<octal_escape> (?: (?= [0-7]) [0-3]? [0-7]{1,2} ))
			| (?: u+ (?<hex_escape> [[:xdigit:]]{4} ))
		)
	)/sx;

	regex Exponent_Part                     => qr/(?>
		[eE]
		[+-]?
		(??{ 'Decimal_Numeral' })
	)/sx;

	regex Floating_Type_Suffix              => qr/(?>
		[fFdD]
	)/sx;

	regex Hex_Numeral                       => qr/(?>
		0 [xX]
		[_[:xdigit:]]+
		(?<= [[:xdigit:]])
	)/sx;

	regex Identifier_Character              => qr/(?>
		[_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]
	)/sx;

	regex Integral_Type_Suffix              => qr/(?>
		[lL]
	)/sx;

	regex Octal_Numeral                     => qr/(?>
		0
		[_0-7]+
		(?<= [0-7])
	)/sx;

	insignificant token whitespaces         => dom => 'CSI::Language::Java::Token::Whitespace',
		qr/(?>
			\s+
		)/sx;

	insignificant token comment_c           => dom => 'CSI::Language::Java::Token::Comment::C',
		qr/(?>
			\/\*
			(?! \* [^*] )
			.*?
			\*\/
		)/sx;

	insignificant token comment_cpp         => dom => 'CSI::Language::Java::Token::Comment::Cpp',
		qr/(?>
			\/\/
			\V*
		)/sx;

	insignificant token comment_javadoc     => dom => 'CSI::Language::Java::Token::Comment::Javadoc',
		qr/(?>
			\/\*
			(?= \* [^*] )
			.*?
			\*\/
		)/sx;

	token LITERAL_CHARACTER                 => action => 'literal_unescape',
		qr/(?>
			\'
			(?<value> [^\'\\] | (??{ 'Escape_Sequence' }) )
			\'
		)/sx;

	token LITERAL_FLOAT_DECIMAL             => action => 'float_value',
		qr/(?>
			(?:
				(?<value>
					(?= \.? [[:digit:]] )
					(??{ 'Decimal_Numeral' })?
					\.
					0* (??{ 'Decimal_Numeral' }) ?
					(??{ 'Exponent_Part'   }) ?
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) ) ?
				)
			)
			|
			(?:
				(?<value>
					(??{ 'Decimal_Numeral' })
					(??{ 'Exponent_Part'   })
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) ) ?
				)
			)
			|
			(?:
				(?<value>
					(??{ 'Decimal_Numeral' })
					(??{ 'Exponent_Part'   }) ?
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) )
				)
			)
		)/sx;

	token LITERAL_INTEGRAL_BINARY           => action => 'integral_value',
		qr/(?>
			(?<binary_value>  (??{ 'Binary_Numeral'  }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_INTEGRAL_DECIMAL          => action => 'integral_value',
		qr/(?>
			(?<decimal_value> (??{ 'Decimal_Numeral' }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_INTEGRAL_HEX              => action => 'integral_value',
		qr/(?>
			(?<hex_value>     (??{ 'Hex_Numeral'     }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_INTEGRAL_OCTAL            => action => 'integral_value',
		qr/(?>
			(?<octal_value>   (??{ 'Octal_Numeral'   }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_STRING                    => action => 'literal_unescape',
		qr/(?>
			\"
			(?<value> (?: [^\"\\] | (??{ 'Escape_Sequence' }) )* )
			\"
		)/sx;

	token IDENTIFIER                        =>
        qr/(?>
			(?! \p{Digit} )
			(?! (??{ 'Prohibited_Identifier' }) (?! (??{ 'Identifier_Character' }) ) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;

	token ANNOTATION                        => dom => 'CSI::Language::Java::Token::Annotation'      => '@';
	token BRACE_CLOSE                       => dom => 'CSI::Language::Java::Token::Brace::Close'    => '}';
	token BRACE_OPEN                        => dom => 'CSI::Language::Java::Token::Brace::Open'     => '{';
	token BRACKET_CLOSE                     => dom => 'CSI::Language::Java::Token::Bracket::Close'  => ']';
	token BRACKET_OPEN                      => dom => 'CSI::Language::Java::Token::Bracket::Open'   => '[';
	token COLON                             => dom => 'CSI::Language::Java::Token::Colon'           => qr/ : (?! : )/sx;
	token COMMA                             => dom => 'CSI::Language::Java::Token::Comma'           => ',';
	token DOUBLE_COLON                      => dom => 'CSI::Language::Java::Token::Double::Colon'   => '::';
	token DOT                               => dom => 'CSI::Language::Java::Token::Dot'             => qr/ \. (?! \. )/sx;
	token ELIPSIS                           => dom => 'CSI::Language::Java::Token::Elipsis'         => '...';
	token LAMBDA                            => dom => 'CSI::Language::Java::Token::Lambda'          => '->';
	token PAREN_CLOSE                       => dom => 'CSI::Language::Java::Token::Paren::Close'    => ')';
	token PAREN_OPEN                        => dom => 'CSI::Language::Java::Token::Paren::Open'     => '(';
	token QUESTION_MARK                     => dom => 'CSI::Language::Java::Token::Question::Mark'  => '?';
	token SEMICOLON                         => dom => 'CSI::Language::Java::Token::Semicolon'       => ';';
	token TOKEN_ASTERISK                    => qr/ \* (?! [=] )/sx;
	token TOKEN_GT_AMBIGUOUS                => qr/ > (?= > ) /sx;
	token TOKEN_GT_FINAL                    => qr/ > (?! > ) /sx;
	token TOKEN_LT                          => '<';
	token TOKEN_PLUS                        => qr/ \+ (?! [=] ) (?= (?: \+ \+ )* (?! \+ ) )/sx;
	token TOKEN_MINUS                       => qr/  - (?! [=] ) (?= (?:  -  - )* (?!  - ) )/sx;
	operator ADDITION                       => '::Operator::Addition'                       => [qw[  TOKEN_PLUS  ]];
	operator ASSIGN                         => '::Operator::Assign'                         => qr/ = (?! [=] )/sx;
	operator ASSIGN_ADDITION                => '::Operator::Assign::Addition'               => '+=';
	operator ASSIGN_BINARY_AND              => '::Operator::Assign::Binary::And'            => '&=';
	operator ASSIGN_BINARY_OR               => '::Operator::Assign::Binary::Or'             => '|=';
	operator ASSIGN_BINARY_SHIFT_LEFT       => '::Operator::Assign::Binary::Shift::Left'    => '<<=';
	operator ASSIGN_BINARY_SHIFT_RIGHT      => '::Operator::Assign::Binary::Shift::Right'   => '>>=';
	operator ASSIGN_BINARY_USHIFT_RIGHT     => '::Operator::Assign::Binary::UShift::Right'  => '>>>=';
	operator ASSIGN_BINARY_XOR              => '::Operator::Assign::Binary::Xor'            => '^=';
	operator ASSIGN_DIVISION                => '::Operator::Assign::Division'               => '/=';
	operator ASSIGN_MODULUS                 => '::Operator::Assign::Modulus'                => '%=';
	operator ASSIGN_MULTIPLICATION          => '::Operator::Assign::Multiplication'         => '*=';
	operator ASSIGN_SUBTRACTION             => '::Operator::Assign::Subtraction'            => '-=';
	operator BINARY_AND                     => '::Operator::Binary::And'                    => qr/ & (?! [&=] )/sx;
	operator BINARY_COMPLEMENT              => '::Operator::Binary::Complement'             => '~';
	operator BINARY_OR                      => '::Operator::Binary::Or'                     => qr/ \| (?! [|=] )/sx;
	operator BINARY_SHIFT_LEFT              => '::Operator::Binary::Shift::Left'            => '<<';
	operator BINARY_SHIFT_RIGHT             => '::Operator::Binary::Shift::Right'           => [qw[  TOKEN_GT_AMBIGUOUS  TOKEN_GT_FINAL  ]];
	operator BINARY_USHIFT_RIGHT            => '::Operator::Binary::UShift::Right'          => [qw[  TOKEN_GT_AMBIGUOUS  TOKEN_GT_AMBIGUOUS  TOKEN_GT_FINAL  ]];
	operator BINARY_XOR                     => '::Operator::Binary::Xor'                    => qr/ \^ (?! [=] )/sx;
	operator CMP_EQUALITY                   => '::Operator::Equality'                       => '==';
	operator CMP_GREATER_THAN               => '::Operator::Greater'                        => [qw[  TOKEN_GT_FINAL ]];
	operator CMP_GREATER_THAN_OR_EQUAL      => '::Operator::Greater::Equal'                 => '>=';
	operator CMP_INEQUALITY                 => '::Operator::Inequality'                     => '!=';
	operator CMP_LESS_THAN                  => '::Operator::Less'                           => [qw[  TOKEN_LT  ]];
	operator CMP_LESS_THAN_OR_EQUAL         => '::Operator::Less::Equal'                    => '<=';
	operator DECREMENT                      => '::Operator::Decrement'                      => qr/  -  - (?= (?:  -  - )* (?!  - ) )/sx;
	operator DIVISION                       => '::Operator::Division'                       => qr/ \/ (?! [=] )/sx,
	operator INCREMENT                      => '::Operator::Increment'                      => qr/ \+ \+ (?= (?: \+ \+ )* (?! \+ ) )/sx;
	operator LOGICAL_AND                    => '::Operator::Logical::And'                   => '&&';
	operator LOGICAL_COMPLEMENT             => '::Operator::Logical::Complement'            => qr/ ! (?! [=]) /sx;
	operator LOGICAL_OR                     => '::Operator::Logical::Or'                    => '||';
	operator MODULUS                        => '::Operator::Modulus'                        => qr/  % (?! [=] )/sx;
	operator MULTIPLICATION                 => '::Operator::Multiplication'                 => [qw[  TOKEN_ASTERISK  ]];
	operator SUBTRACTION                    => '::Operator::Subtraction'                    => [qw[  TOKEN_MINUS  ]];
	operator UNARY_MINUS                    => '::Operator::Unary::Minus'                   => [qw[  TOKEN_MINUS  ]];
	operator UNARY_PLUS                     => '::Operator::Unary::Plus'                    => [qw[  TOKEN_PLUS  ]];
	word  ABSTRACT                          => ;
	word  ASSERT                            => ;
	word  BOOLEAN                           => ;
	word  BREAK                             => ;
	word  BYTE                              => ;
	word  CASE                              => ;
	word  CATCH                             => ;
	word  CHAR                              => ;
	word  CLASS                             => ;
	word  CONST                             => ;
	word  CONTINUE                          => ;
	word  DEFAULT                           => ;
	word  DO                                => ;
	word  DOUBLE                            => ;
	word  ELSE                              => ;
	word  ENUM                              => ;
	word  EXPORTS                           => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  EXTENDS                           => ;
	word  FALSE                             => ;
	word  FINAL                             => ;
	word  FINALLY                           => ;
	word  FLOAT                             => ;
	word  FOR                               => ;
	word  GOTO                              => ;
	word  IF                                => ;
	word  IMPLEMENTS                        => ;
	word  IMPORT                            => ;
	word  INSTANCEOF                        => ;
	word  INT                               => ;
	word  INTERFACE                         => ;
	word  LONG                              => ;
	word  MODULE                            => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  NATIVE                            => ;
	word  NEW                               => ;
	word  NULL                              => ;
	word  OPEN                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  OPENS                             => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  PACKAGE                           => ;
	word  PRIVATE                           => ;
	word  PROTECTED                         => ;
	word  PROVIDES                          => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  PUBLIC                            => ;
	word  REQUIRES                          => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  RETURN                            => ;
	word  SHORT                             => ;
	word  STATIC                            => ;
	word  STRICTFP                          => ;
	word  SUPER                             => ;
	word  SWITCH                            => ;
	word  SYNCHRONIZED                      => ;
	word  THIS                              => ;
	word  THROW                             => ;
	word  THROWS                            => ;
	word  TO                                => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  TRANSIENT                         => ;
	word  TRUE                              => ;
	word  TRY                               => ;
	word  USES                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  VAR                               => group => 'keyword_identifier';
	word  VOID                              => ;
	word  VOLATILE                          => ;
	word  WHILE                             => ;
	word  WITH                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  _                                 => ;

	ensure_rule_name_order;

	rule  TYPE_LIST_CLOSE                   => dom => 'CSI::Language::Java::Token::Type::List::Close',
		[qw[  TOKEN_GT_AMBIGUOUS  ]],
		[qw[  TOKEN_GT_FINAL      ]],
		;

	rule  TYPE_LIST_OPEN                    => dom => 'CSI::Language::Java::Token::Type::List::Open',
		[qw[  TOKEN_LT  ]],
		;

	rule  additional_bound                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-4.html#jls-AdditionalBound
		[qw[  BINARY_AND  class_type                    ]],
		[qw[  BINARY_AND  class_type  additional_bound  ]],
		;

	rule  additive_element                  =>
		[qw[  multiplicative_element     ]],
		[qw[  multiplicative_expression  ]],
		;

	rule  additive_elements                 =>
		[qw[  additive_element  additive_operator  additive_elements  ]],
		[qw[  additive_element  additive_operator  additive_element   ]],
		;

	rule  additive_expression               => dom => 'CSI::Language::Java::Expression::Additive',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-AdditiveExpression
		[qw[  additive_elements  ]],
		;

	rule  additive_operator                 =>
		[qw[  ADDITION     ]],
		[qw[  SUBTRACTION  ]],
		;

	rule  allowed_identifier                =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-Identifier
		[qw[  IDENTIFIER          ]],
		[qw[  keyword_identifier  ]],
		;

	rule  allowed_type_identifier           =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-TypeIdentifier
		[qw[  IDENTIFIER               ]],
		[qw[  keyword_type_identifier  ]],
		;

	rule  annotated_class_type              => dom => 'CSI::Language::Java::Type::Class',
		[qw[  annotations  type_identifier  type_arguments  ]],
		[qw[  annotations  type_identifier                  ]],
		[qw[  class_reference                               ]],
		;

	rule  annotation                        => dom => 'CSI::Language::Java::Annotation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-Annotation
		[qw[  marker_annotation          ]],
		[qw[  normal_annotation          ]],
		[qw[  single_element_annotation  ]],
		;

	rule  annotation_body                   => dom => 'CSI::Language::Java::Structure::Body::Annotation',
		[qw[  BRACE_OPEN  annotation_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                BRACE_CLOSE  ]],
		;

	rule  annotation_body_declaration       =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeMemberDeclaration
		[qw[  annotation_declaration          ]],
		[qw[  annotation_element_declaration  ]],
		[qw[  class_declaration               ]],
		[qw[  constant_declaration            ]],
		[qw[  empty_declaration               ]],
		[qw[  interface_declaration           ]],
		;

	rule  annotation_body_declarations      =>
		[qw[  annotation_body_declaration  annotation_body_declarations  ]],
		[qw[  annotation_body_declaration                                ]],
		;

	rule  annotation_declaration            => dom => 'CSI::Language::Java::Declaration::Annotation',
		[qw[  interface_modifiers  ANNOTATION  interface  type_name  annotation_body  ]],
		[qw[                       ANNOTATION  interface  type_name  annotation_body  ]],
		;

	rule  annotation_reference              => dom => 'CSI::Language::Java::Annotation::Reference',
		[qw[  qualified_identifier  ]],
		;

	rule  annotations                       =>
		[qw[  annotation  annotations  ]],
		[qw[  annotation               ]],
		;

	rule  arguments                         => dom => 'CSI::Language::Java::Arguments',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ArgumentList
		[qw[  PAREN_OPEN  expressions  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN               PAREN_CLOSE  ]],
		;

	rule  array_creation_dims               =>
		[qw[  dim_expressions  dims                     ]],
		[qw[  dim_expressions                           ]],
		[qw[                   dims  array_initializer  ]],
		;

	rule  array_creation_expression         => dom => 'CSI::Language::Java::Array::Creation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ArrayCreationExpression
		[qw[  new  primitive_type  array_creation_dims  ]],
		[qw[  new  class_type      array_creation_dims  ]],
		;

	rule  array_initializer                 => dom => 'CSI::Language::Java::Array::Initializer',
		[qw[  BRACE_OPEN  variable_initializers  COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  variable_initializers         BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                         COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                BRACE_CLOSE  ]],
		;

	rule  array_type                        => dom => 'CSI::Language::Java::Type::Array',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannArrayType
		[qw[  data_type  dim  ]],
		;

	rule  binary_and_element                =>
		[qw[  equality_element     ]],
		[qw[  equality_expression  ]],
		;

	rule  binary_and_elements               =>
		[qw[  binary_and_element  BINARY_AND  binary_and_elements  ]],
		[qw[  binary_and_element  BINARY_AND  binary_and_element   ]],
		;

	rule  binary_and_expression             => dom => 'CSI::Language::Java::Expression::Binary::And',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-AndExpression
		[qw[  binary_and_elements  ]],
		;

	rule  binary_or_element                 =>
		[qw[  binary_xor_element     ]],
		[qw[  binary_xor_expression  ]],
		;

	rule  binary_or_elements                =>
		[qw[  binary_or_element  BINARY_OR  binary_or_elements  ]],
		[qw[  binary_or_element  BINARY_OR  binary_or_element   ]],
		;

	rule  binary_or_expression              => dom => 'CSI::Language::Java::Expression::Binary::Or',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-InclusiveOrExpression
		[qw[  binary_or_elements  ]],
		;

	rule  binary_shift_element              =>
		[qw[  additive_element     ]],
		[qw[  additive_expression  ]],
		;

	rule  binary_shift_elements             =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ShiftExpression
		[qw[  binary_shift_element  binary_shift_operator  binary_shift_elements  ]],
		[qw[  binary_shift_element  binary_shift_operator  binary_shift_element   ]],
		;

	rule  binary_shift_expression           => dom => 'CSI::Language::Java::Expression::Binary::Shift',
		[qw[  binary_shift_elements ]],
		;

	rule  binary_shift_operator             =>
		[qw[  BINARY_SHIFT_LEFT    ]],
		[qw[  BINARY_SHIFT_RIGHT   ]],
		[qw[  BINARY_USHIFT_RIGHT  ]],
		;

	rule  binary_xor_element                =>
		[qw[  binary_and_element     ]],
		[qw[  binary_and_expression  ]],
		;

	rule  binary_xor_elements               =>
		[qw[  binary_xor_element  BINARY_XOR  binary_xor_elements  ]],
		[qw[  binary_xor_element  BINARY_XOR  binary_xor_element   ]],
		;

	rule  binary_xor_expression             => dom => 'CSI::Language::Java::Expression::Binary::Xor',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ExclusiveOrExpression
		[qw[  binary_xor_elements  ]],
		;

	rule  block                             => dom => 'CSI::Language::Java::Structure::Block',
		[qw[  BRACE_OPEN  block_statements  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                    BRACE_CLOSE  ]],
		;

	rule  cast_expression                   => dom => 'CSI::Language::Java::Expression::Cast',
		[qw[  cast_reference_operators  lambda_expression                 ]],
		[qw[  cast_reference_operators  prefix_element                    ]],
		[qw[  cast_reference_operators  prefix_expression_not_plus_minus  ]],
		[qw[  cast_primary_operators    prefix_expression                 ]],
		;

	rule  cast_primary_operator             => dom => 'CSI::Language::Java::Operator::Cast',
		[qw[  PAREN_OPEN  primitive_type                    PAREN_CLOSE  ]],
		;

	rule  cast_primary_operators            =>
		[qw[  cast_primary_operator  cast_primary_operators  ]],
		[qw[  cast_primary_operator                          ]],
		;

	rule  cast_reference_operator           => dom => 'CSI::Language::Java::Operator::Cast',
		[qw[  PAREN_OPEN  reference_type                    PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN  reference_type  additional_bound  PAREN_CLOSE  ]],
		;

	rule  cast_reference_operators          =>
		[qw[  cast_reference_operator  cast_reference_operators  ]],
		[qw[  cast_reference_operator                            ]],
		;

	rule  class_body                        => dom => 'CSI::Language::Java::Class::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-ClassBody
		[qw[  BRACE_OPEN  class_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                           BRACE_CLOSE  ]],
		;

	rule  class_declaration                 => dom => 'CSI::Language::Java::Class::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-NormalClassDeclaration
		[qw[  class_modifiers  class  type_name  type_parameters  class_extends  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters  class_extends                    class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters                 class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters                                   class_body  ]],
		[qw[  class_modifiers  class  type_name                   class_extends  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name                   class_extends                    class_body  ]],
		[qw[  class_modifiers  class  type_name                                  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name                                                    class_body  ]],
		[qw[                   class  type_name  type_parameters  class_extends  class_implements  class_body  ]],
		[qw[                   class  type_name  type_parameters  class_extends                    class_body  ]],
		[qw[                   class  type_name  type_parameters                 class_implements  class_body  ]],
		[qw[                   class  type_name  type_parameters                                   class_body  ]],
		[qw[                   class  type_name                   class_extends  class_implements  class_body  ]],
		[qw[                   class  type_name                   class_extends                    class_body  ]],
		[qw[                   class  type_name                                  class_implements  class_body  ]],
		[qw[                   class  type_name                                                    class_body  ]],
		;

	rule  class_extends                     => dom => 'CSI::Language::Java::Class::Extends',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-Superclass
		[qw[  extends  class_type  ]],
		;

	rule  class_implements                  => dom => 'CSI::Language::Java::Class::Implements',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-Superinterfaces
		[qw[  implements  class_types  ]],
		;

	rule  class_literal                     => dom => 'CSI::Language::Java::Literal::Class',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ClassLiteral
		[qw[  type_reference  class_literal_dims  DOT  class  ]],
		[qw[  type_reference                      DOT  class  ]],
		[qw[  primitive_type  class_literal_dims  DOT  class  ]],
		[qw[  primitive_type                      DOT  class  ]],
		[qw[  void                                DOT  class  ]],
		;

	rule  class_literal_dim                 => dom => 'CSI::Language::Java::Literal::Class::Dim',
		[qw[  BRACKET_OPEN  BRACKET_CLOSE  ]],
		;

	rule  class_literal_dims                =>
		[qw[  class_literal_dim  class_literal_dims  ]],
		[qw[  class_literal_dim                      ]],
		;

	rule  class_modifier                    => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		[qw[  abstract    ]],
		[qw[  final       ]],
		[qw[  static      ]],
		[qw[  strictfp    ]],
		;

	rule  class_modifiers                   =>
		[qw[  class_modifier  class_modifiers  ]],
		[qw[  class_modifier                   ]],
		;

	rule  class_reference                   =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannClassType
		[qw[                       type_identifier  type_arguments  ]],
		[qw[                       type_identifier                  ]],
		[qw[  qualified_identifier DOT  type_identifier             ]],
		[qw[  qualified_identifier DOT  class_type_identifiers      ]],
		;

	rule  class_type                        => dom => 'CSI::Language::Java::Type::Class',
		[qw[  class_reference  ]],
		;

	rule  class_type                        => dom => 'CSI::Language::Java::Type::Class',
		[qw[  class_reference  ]],
		;

	rule  class_type_identifier             =>
		[qw[  annotations  type_identifier  type_arguments  ]],
		[qw[  annotations  type_identifier                  ]],
		[qw[               type_identifier  type_arguments  ]],
		;

	rule  class_type_identifiers            =>
		[qw[                               class_type_identifier  ]],
		[qw[  class_type_identifiers  DOT  class_type_identifier  ]],
		[qw[  class_type_identifiers  DOT        type_identifier  ]],
		;

	rule  class_types                       =>
		[qw[  class_type  COMMA  class_types  ]],
		[qw[  class_type                      ]],
		;

	rule  compilation_unit                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-CompilationUnit
		[qw[  ordinary_compilation_unit  ]],
		[qw[  modular_compilation_unit   ]],
		;

	rule  constant_modifier                 => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  public      ]],
		[qw[  final       ]],
		[qw[  static      ]],
		;

	rule  constant_modifiers                =>
		[qw[  constant_modifier  constant_modifiers  ]],
		[qw[  constant_modifier                      ]],
		;

	rule  constructor_modifier              => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		;

	rule  constructor_modifiers             =>
		[qw[  constructor_modifier  constructor_modifiers  ]],
		[qw[  constructor_modifier                         ]],
		;

	rule  data_type                         =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannType
		[qw[  primitive_type  ]],
		[qw[  reference_type  ]],
		;

	rule  dim                               => dom => 'CSI::Language::Java::Array::Dimension',
		[qw[  annotations  BRACKET_OPEN  BRACKET_CLOSE  ]],
		[qw[               BRACKET_OPEN  BRACKET_CLOSE  ]],
		;

	rule  dim_expression                    => dom => 'CSI::Language::Java::Array::Dimension::Expression',
		[qw[  annotations  BRACKET_OPEN  expression  BRACKET_CLOSE  ]],
		[qw[               BRACKET_OPEN  expression  BRACKET_CLOSE  ]],
		;

	rule  dim_expressions                   =>
		[qw[  dim_expression  dim_expressions  ]],
		[qw[  dim_expression                   ]],
		;

	rule  dims                              =>
		[qw[  dim  dims  ]],
		[qw[  dim        ]],
		;

	rule  enum_body                         => dom => 'CSI::Language::Java::Enum::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-EnumBody
		[qw[  BRACE_OPEN  enum_constants  COMMA  enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants  COMMA                          BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants         enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants                                 BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                  COMMA  enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                  COMMA                          BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                         enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                                 BRACE_CLOSE  ]],
		;

	rule  enum_declaration                  => dom => 'CSI::Language::Java::Enum::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-EnumDeclaration
		[qw[  class_modifiers  enum  type_name  class_implements  enum_body  ]],
		[qw[  class_modifiers  enum  type_name                    enum_body  ]],
		[qw[                   enum  type_name  class_implements  enum_body  ]],
		[qw[                   enum  type_name                    enum_body  ]],
		;

	rule  equality_element                  =>
		[qw[  relational_element     ]],
		[qw[  relational_expression  ]],
		;

	rule  equality_elements                 =>
		[qw[  equality_element  equality_operator  equality_elements  ]],
		[qw[  equality_element  equality_operator  equality_element   ]],
		;

	rule  equality_expression               => dom => 'CSI::Language::Java::Expression::Equality',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-EqualityExpression
		[qw[  equality_elements  ]],
		;

	rule  equality_operator                 =>
		[qw[  CMP_EQUALITY    ]],
		[qw[  CMP_INEQUALITY  ]],
		;

	rule  expression                        =>
		[qw[  ternary_element        ]],
		[qw[  ternary_expression     ]],
		[qw[  lambda_expression      ]],
		;

	rule  expression_group                  =>
		[qw[  PAREN_OPEN  statement_expression  PAREN_CLOSE  ]],
		;

	rule  expressions                       =>
		[qw[  expression  COMMA  expressions  ]],
		[qw[  expression                      ]],
		;

	rule  field_modifier                    => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		[qw[  final       ]],
		[qw[  static      ]],
		[qw[  transient   ]],
		[qw[  volatile    ]],
		;

	rule  field_modifiers                   =>
		[qw[  field_modifier  field_modifiers  ]],
		[qw[  field_modifier                   ]],
		;

	rule  identifier                        => dom => 'CSI::Language::Java::Identifier',
		[qw[  allowed_identifier  ]],
		;

	rule  import_declaration                => dom => 'CSI::Language::Java::Import::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-ImportDeclaration
		[qw[  import  static  reference  DOT  import_type  SEMICOLON  ]],
		[qw[  import  static  reference                    SEMICOLON  ]],
		[qw[  import          reference  DOT  import_type  SEMICOLON  ]],
		[qw[  import          reference                    SEMICOLON  ]],
		;

	rule  import_declarations               =>
		[qw[  import_declaration  import_declarations  ]],
		[qw[  import_declaration                       ]],
		;

	rule  import_type                       => dom => 'CSI::Language::Java::Token::Import::Type',
		[qw[  TOKEN_ASTERISK  ]],
		;

	rule  instance_creation                 => dom => 'CSI::Language::Java::Instance::Creation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ClassInstanceCreationExpression
		[qw[  primary  DOT  new  instance_reference  arguments  class_body  ]],
		[qw[  primary  DOT  new  instance_reference  arguments              ]],
		[qw[                new  instance_reference  arguments  class_body  ]],
		[qw[                new  instance_reference  arguments              ]],
		;

	rule  instance_reference                =>
		# TODO annotated reference
		[qw[  type_arguments  reference  type_arguments  ]],
		[qw[                  reference  type_arguments  ]],
		[qw[                  reference                  ]],
		;

	rule  interface_body                    => dom => 'CSI::Language::Java::Interface::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-InterfaceBody
		[qw[  BRACE_OPEN  interface_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                               BRACE_CLOSE  ]],
		;

	rule  interface_declaration             => dom => 'CSI::Language::Java::Interface::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-NormalInterfaceDeclaration
		[qw[  interface_modifiers  interface  type_name  type_parameters   interface_extends  interface_body  ]],
		[qw[  interface_modifiers  interface  type_name  type_parameters                      interface_body  ]],
		[qw[  interface_modifiers  interface  type_name                    interface_extends  interface_body  ]],
		[qw[  interface_modifiers  interface  type_name                                       interface_body  ]],
		[qw[                       interface  type_name  type_parameters   interface_extends  interface_body  ]],
		[qw[                       interface  type_name  type_parameters                      interface_body  ]],
		[qw[                       interface  type_name                    interface_extends  interface_body  ]],
		[qw[                       interface  type_name                                       interface_body  ]],
		;

	rule  interface_extends                 => dom => 'CSI::Language::Java::Interface::Extends',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-ExtendsInterfaces
		[qw[  extends  class_types  ]],
		;

	rule  interface_method_modifier         => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  public      ]],
		[qw[  private     ]],
		[qw[  abstract    ]],
		[qw[  default     ]],
		[qw[  static      ]],
		[qw[  strictfp    ]],
		;

	rule  interface_method_modifiers        =>
		[qw[  interface_method_modifier                              ]],
		[qw[  interface_method_modifier  interface_method_modifiers  ]],
		;

	rule  interface_modifier                => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation ]],
		[qw[  public     ]],
		[qw[  protected  ]],
		[qw[  private    ]],
		[qw[  abstract   ]],
		[qw[  static     ]],
		[qw[  strictfp   ]],
		;

	rule  interface_modifiers               =>
		[qw[  interface_modifier  interface_modifiers  ]],
		[qw[  interface_modifier                       ]],
		;

	rule  invocant                          => dom => 'CSI::Language::Java::Method::Invocant',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodInvocation
		#[qw[  expression_name        ]],
		[qw[  primary                ]],
		#[qw[  type_name              ]],
		[qw[  type_name  DOT  super  ]],
		[qw[  super                  ]],
		;

	rule  lambda_body                       =>
		[qw[  statement_expression  ]],
		[qw[  block                 ]],
		;

	rule  lambda_expression                 => dom => 'CSI::Language::Java::Expression::Lambda',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-LambdaExpression
		[qw[  lambda_expression_parameters  LAMBDA  lambda_body  ]],
		;

	rule  lambda_expression_parameters      => dom => 'CSI::Language::Java::Expression::Lambda::Parameters',
		[qw[  PAREN_OPEN  lambda_parameters  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN                     PAREN_CLOSE  ]],
		[qw[  variable_name                               ]],
		;

	rule  lambda_parameter                  =>
		[qw[  variable_modifiers  variable_type  variable_declarator_id  ]],
		[qw[                      variable_type  variable_declarator_id  ]],
		[qw[                                     variable_name           ]],
		[qw[  variable_arity_parameter                                   ]],
		;

	rule  lambda_parameters                 =>
		[qw[  lambda_parameter  COMMA  lambda_parameters  ]],
		[qw[  lambda_parameter                            ]],
		;

	rule  left_hand_side                    =>
		[qw[  array_access     ]],
		#[qw[  field_access     ]],
		#[qw[  identifier       ]],
		[qw[  reference        ]],
		;

	rule  literal                           =>
		[qw[ LITERAL_CHARACTER        ]],
		[qw[ LITERAL_FLOAT_DECIMAL    ]],
		[qw[ LITERAL_INTEGRAL_BINARY  ]],
		[qw[ LITERAL_INTEGRAL_DECIMAL ]],
		[qw[ LITERAL_INTEGRAL_HEX     ]],
		[qw[ LITERAL_INTEGRAL_OCTAL   ]],
		[qw[ LITERAL_STRING           ]],
		[qw[ literal_boolean_false    ]],
		[qw[ literal_boolean_true     ]],
		[qw[ literal_null             ]],
		;

	rule  literal_boolean_false             => dom => 'CSI::Language::Java::Literal::Boolean::False',
		[qw[  false  ]],
		;

	rule  literal_boolean_true              => dom => 'CSI::Language::Java::Literal::Boolean::True',
		[qw[  true  ]],
		;

	rule  literal_null                      => dom => 'CSI::Language::Java::Literal::Null',
		[qw[  null  ]],
		;

	rule  logical_and_element               =>
		[qw[  binary_or_element     ]],
		[qw[  binary_or_expression  ]],
		;

	rule  logical_and_elements              =>
		[qw[  logical_and_element  LOGICAL_AND  logical_and_elements  ]],
		[qw[  logical_and_element  LOGICAL_AND  logical_and_element   ]],
		;

	rule  logical_and_expression            => dom => 'CSI::Language::Java::Expression::Logical::And',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ConditionalAndExpression
		[qw[  logical_and_elements  ]],
		;

	rule  logical_or_element                =>
		[qw[  logical_and_expression  ]],
		[qw[  logical_and_element     ]],
		;

	rule  logical_or_elements               =>
		[qw[  logical_or_element  LOGICAL_OR  logical_or_elements  ]],
		[qw[  logical_or_element  LOGICAL_OR  logical_or_element   ]],
		;

	rule  logical_or_expression             => dom => 'CSI::Language::Java::Expression::Logical::Or',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ConditionalOrExpression
		[qw[  logical_or_elements  ]],
		;

	rule  marker_annotation                 =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-MarkerAnnotation
		[qw[  ANNOTATION  type_reference  ]],
		;

	rule  method_invocation                 => dom => 'CSI::Language::Java::Method::Invocation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodInvocation
		[qw[  invocant  DOT  type_arguments  method_name  arguments  ]],
		[qw[  invocant  DOT                  method_name  arguments  ]],
		[qw[                                 method_name  arguments  ]],
		;

	rule  method_modifier                   => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation    ]],
		[qw[  private       ]],
		[qw[  protected     ]],
		[qw[  public        ]],
		[qw[  abstract      ]],
		[qw[  final         ]],
		[qw[  native        ]],
		[qw[  static        ]],
		[qw[  strictfp      ]],
		[qw[  synchronized  ]],
		;

	rule  method_modifiers                  =>
		[qw[  method_modifier  method_modifiers  ]],
		[qw[  method_modifier                    ]],
		;

	rule  method_name                       => dom => 'CSI::Language::Java::Method::Name',
		[qw[  identifier  ]],
		;

	rule  method_reference                  => dom => 'CSI::Language::Java::Method::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodReference
		[qw[  primary_no_reference    DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  primary_no_reference    DOUBLE_COLON                  method_name  ]],
		[qw[  class_type              DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  class_type              DOUBLE_COLON                  method_name  ]],
		[qw[  class_type  DOT  super  DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  class_type  DOT  super  DOUBLE_COLON                  method_name  ]],
		[qw[                   super  DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[                   super  DOUBLE_COLON                  method_name  ]],
		[qw[  class_type              DOUBLE_COLON  type_arguments  new          ]],
		[qw[  class_type              DOUBLE_COLON                  new          ]],
		[qw[  array_type              DOUBLE_COLON                  new          ]],
		;

	rule  multiplicative_element            =>
		[qw[  prefix_element     ]],
		[qw[  prefix_expression  ]],
		;

	rule  multiplicative_elements           =>
		# TODO: list of rules in form "DIVISION element", "MODULUS element", "MULTIPLICATION element"
		# TODO: so it can be addressed by behaviour
		[qw[  multiplicative_element  multiplicative_operator  multiplicative_elements  ]],
		[qw[  multiplicative_element  multiplicative_operator  multiplicative_element   ]],
		;

	rule  multiplicative_expression         => dom => 'CSI::Language::Java::Expression::Multiplicative',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MultiplicativeExpression
		# TODO [  'multiplicative_element',  list( multiplicative_operand ) ]
		[qw[  multiplicative_elements  ]],
		;

	rule  multiplicative_operator           =>
		[qw[  DIVISION        ]],
		[qw[  MODULUS         ]],
		[qw[  MULTIPLICATION  ]],
		;

	rule  ordinary_compilation_unit         =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-OrdinaryCompilationUnit
		[qw[  package_declaration  import_declarations  type_declarations  ]],
		[qw[  package_declaration  import_declarations                     ]],
		[qw[  package_declaration                       type_declarations  ]],
		[qw[  package_declaration                                          ]],
		[qw[                       import_declarations  type_declarations  ]],
		[qw[                       import_declarations                     ]],
		[qw[                                            type_declarations  ]],
		;

	rule  package_declaration               => dom => 'CSI::Language::Java::Package::Declaration',
		[qw[  package_modifiers  package  package_name  SEMICOLON  ]],
		[qw[                     package  package_name  SEMICOLON  ]],
		;

	rule  package_modifier                  => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		;

	rule  package_modifiers                 =>
		[qw[  package_modifier  package_modifiers  ]],
		[qw[  package_modifier                     ]],
		;

	rule  package_name                      => dom => 'CSI::Language::Java::Package::Name',
		[qw[  qualified_identifier  ]],
		;

	rule  postfix_element                   =>
		[qw[  primary  ]],
		;

	rule  postfix_expression                => dom => 'CSI::Language::Java::Expression::Postfix',
		[qw[  postfix_element     postfix_operators  ]],
		;

	rule  postfix_operator                  =>
		[qw[  DECREMENT  ]],
		[qw[  INCREMENT  ]],
		;

	rule  postfix_operators                 =>
		[qw[  postfix_operator  postfix_operators  ]],
		[qw[  postfix_operator                     ]],
		;

	rule  prefix_element                    =>
		[qw[  cast_expression            ]],
		[qw[  postfix_element            ]],
		[qw[  postfix_expression         ]],
		;

	rule  prefix_expression                 => dom => 'CSI::Language::Java::Expression::Prefix',
		[qw[  prefix_operators  prefix_element  ]],
		;

	rule  prefix_expression_not_plus_minus  => dom => 'CSI::Language::Java::Expression::Prefix',
		[qw[  unary_expression_not_plus_minus  ]],
		;

	rule  prefix_operator                   =>
		[qw[  BINARY_COMPLEMENT   ]],
		[qw[  INCREMENT           ]],
		[qw[  DECREMENT           ]],
		[qw[  LOGICAL_COMPLEMENT  ]],
		[qw[  UNARY_MINUS         ]],
		[qw[  UNARY_PLUS          ]],
		;

	rule  prefix_operators                  =>
		[qw[  prefix_operator  prefix_operators  ]],
		[qw[  prefix_operator                    ]],
		;

	rule  primary                           =>
		[qw[  array_creation_expression  ]],
		[qw[  primary_no_new_array       ]],
		;

	rule  primary_no_new_array              =>
		[qw[  primary_no_reference  ]],
		[qw[  reference             ]],
		;

	rule  primary_no_reference              =>
		[qw[  literal            ]],
		[qw[  class_literal      ]],
		[qw[  expression_group   ]],
		[qw[  instance_creation  ]],
		[qw[  array_access       ]],
		[qw[  method_invocation  ]],
		[qw[  method_reference   ]],
		[qw[  qualified_this     ]],
		;

	rule  primitive_type                    => dom => 'CSI::Language::Java::Type::Primitive',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannPrimitiveType
		[qw[  boolean       ]],
		[qw[  byte          ]],
		[qw[  char          ]],
		[qw[  double        ]],
		[qw[  float         ]],
		[qw[  int           ]],
		[qw[  long          ]],
		[qw[  short         ]],
		;

	rule  qualified_identifier              =>
		[qw[  identifier  DOT  qualified_identifier  ]],
		[qw[  identifier                             ]],
		;

	rule  qualified_this                    => dom => 'CSI::Language::Java::Expression::This',
		[qw[  qualified_identifier  DOT  this  ]],
		[qw[                             this  ]],
		;

	rule  qualified_type_identifier         =>
		[qw[  qualified_identifier  DOT  type_identifier  ]],
		[qw[                             type_identifier  ]],
		;

	rule  reference                         => dom => 'CSI::Language::Java::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-AmbiguousName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-ExpressionName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-ModuleName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-PackageName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-PackageOrTypeName
		[qw[  qualified_identifier  ]],
		;

	rule  reference_type                    =>
		[qw[  array_type       ]],
		[qw[  class_type       ]],
		;

	rule  relational_element                =>
		[qw[  binary_shift_element     ]],
		[qw[  binary_shift_expression  ]],
		;

	rule  relational_elements               =>
		# Associativity always produces compile time error
		# [qw[  relational_element  relational_operator  relational_elements  ]],
		[qw[  relational_element  relational_operator  relational_element   ]],
		[qw[  relational_element  instanceof           reference_type       ]],
		;

	rule  relational_expression             => dom => 'CSI::Language::Java::Expression::Relational',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-RelationalExpression
		[qw[  relational_elements  ]],
		;

	rule  relational_operator               =>
		[qw[  CMP_LESS_THAN              ]],
		[qw[  CMP_LESS_THAN_OR_EQUAL     ]],
		[qw[  CMP_GREATER_THAN           ]],
		[qw[  CMP_GREATER_THAN_OR_EQUAL  ]],
		;

	rule  statement_expression              =>
		[qw[  assignment                          ]],
		[qw[  instance_creation_expression        ]],
		[qw[  expression                          ]],
		;

	rule  ternary_element                   =>
		[qw[  logical_or_expression  ]],
		[qw[  logical_or_element     ]],
		;

	rule  ternary_expression                => dom => 'CSI::Language::Java::Expression::Ternary',
		[qw[  ternary_element  QUESTION_MARK  expression  COLON  expression  ]],
		;

	rule  type_argument                     =>
		[qw[  reference_type  ]],
		[qw[  type_wildcard   ]],
		;

	rule  type_argument_list                =>
		[qw[  type_argument  COMMA  type_argument_list  ]],
		[qw[  type_argument                             ]],
		;

	rule  type_arguments                    => dom => 'CSI::Language::Java::Type::Arguments',
		[qw[  TYPE_LIST_OPEN  type_argument_list  TYPE_LIST_CLOSE  ]],
		[qw[  TYPE_LIST_OPEN                      TYPE_LIST_CLOSE  ]],
		;

	rule  type_bound                        => dom => 'CSI::Language::Java::Type::Bound',
		[qw[  extends  annotated_class_type  additional_bound  ]],
		[qw[  extends  annotated_class_type                    ]],
		[qw[  extends  type_variable                 ]],
		;

	rule  type_declaration                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-TypeDeclaration
		[qw[  annotation_declaration   ]],
		[qw[  class_declaration        ]],
		[qw[  enum_declaration         ]],
		[qw[  interface_declaration    ]],
		[qw[  SEMICOLON                ]],
		;

	rule  type_declarations                 =>
		[qw[  type_declaration                     ]],
		[qw[  type_declaration  type_declarations  ]],
		;

	rule  type_identifier                   => dom => 'CSI::Language::Java::Identifier',
		[qw[  allowed_type_identifier  ]],
		;

	rule  type_name                         => dom => 'CSI::Language::Java::Type::Name',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-TypeIdentifier
		[qw[  IDENTIFIER               ]],
		[qw[  keyword_type_identifier  ]],
		;

	rule  type_parameter                    => dom => 'CSI::Language::Java::Type::Parameter',
		[qw[  type_parameter_modifiers  type_identifier  type_bound  ]],
		[qw[                            type_identifier  type_bound  ]],
		[qw[  type_parameter_modifiers  type_identifier              ]],
		[qw[                            type_identifier              ]],
		;

	rule  type_parameter_list               =>
		[qw[  type_parameter  COMMA  type_parameter_list  ]],
		[qw[  type_parameter                              ]],
		;

	rule  type_parameter_modifier           =>
		[qw[  annotation  ]],
		;

	rule  type_parameter_modifiers          =>
		[qw[  type_parameter_modifier  type_parameter_modifiers  ]],
		[qw[  type_parameter_modifier                            ]],
		;

	rule  type_parameters                   => dom => 'CSI::Language::Java::Type::Parameters',
		[qw[  TYPE_LIST_OPEN  type_parameter_list  TYPE_LIST_CLOSE  ]],
		;

	rule  type_reference                    => dom => 'CSI::Language::Java::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-TypeName
		[qw[  qualified_type_identifier  ]],
		;

	rule  type_variable                     => dom => 'CSI::Language::Java::Type::Variable',
		[qw[  class_type  type_bound  ]],
		;

	rule  type_wildcard                     => dom => 'CSI::Language::Java::Type::Wildcard',
		[qw[  annotations  QUESTION_MARK  type_wildcard_bounds  ]],
		[qw[  annotations  QUESTION_MARK                        ]],
		[qw[               QUESTION_MARK  type_wildcard_bounds  ]],
		[qw[               QUESTION_MARK                        ]],
		;

	rule  type_wildcard_bounds              =>
		[qw[  extends  reference_type  ]],
		[qw[  super    reference_type  ]],
		;

	rule  unary_element                     =>
		[qw[  prefix_element    ]],
		[qw[  unary_expression  ]],
		[qw[  cast_expression   ]],
		;

	rule  unary_expression                  =>
		[qw[  INCREMENT    unary_element       ]],
		[qw[  DECREMENT    unary_element       ]],
		[qw[  UNARY_PLUS   unary_element       ]],
		[qw[  UNARY_MINUS  unary_element       ]],
		[qw[  unary_expression_not_plus_minus  ]],
		;

	rule  unary_expression_not_plus_minus   =>
		[qw[  BINARY_COMPLEMENT   unary_element  ]],
		[qw[  LOGICAL_COMPLEMENT  unary_element  ]],
		;

	rule  variable_arity_parameter          => action => 'pass_through',
		[qw[   variable_modifiers  data_type  annotations  ELIPSIS  variable_name  ]],
		[qw[                       data_type  annotations  ELIPSIS  variable_name  ]],
		[qw[   variable_modifiers  data_type               ELIPSIS  variable_name  ]],
		[qw[                       data_type               ELIPSIS  variable_name  ]],
		;

	rule  variable_declarator_id            => dom => 'CSI::Language::Java::Variable::ID',
		[qw[  variable_name  dims  ]],
		[qw[  variable_name        ]],
		;

	rule  variable_initializer              =>
		[qw[  array_initializer  ]],
		[qw[  expression         ]],
		;

	rule  variable_initializers             =>
		[qw[  variable_initializer  COMMA  variable_initializers  ]],
		[qw[  variable_initializer                                ]],
		;

	rule  variable_modifier                 => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  final       ]],
		;

	rule  variable_modifiers                =>
		[qw[  variable_modifier  variable_modifiers  ]],
		[qw[  variable_modifier                      ]],
		;

	rule  variable_name                     => dom => 'CSI::Language::Java::Variable::Name',
		[qw[  IDENTIFIER          ]],
		[qw[  keyword_identifier  ]],
		;

	rule  variable_type                     =>
		[qw[  data_type  ]],
		[qw[  var        ]],
		;

	1;
};

__END__

	sub annotation_type_element_declaration:RULE :ACTION_DEFAULT {
		[
			[qw[  annotation_type_element_modifier_list  unann_type  identifier  PAREN_OPEN  PAREN_CLOSE  dims  default_value  SEMICOLON  ]],
			[qw[                                         unann_type  identifier  PAREN_OPEN  PAREN_CLOSE  dims  default_value  SEMICOLON  ]],
			[qw[  annotation_type_element_modifier_list  unann_type  identifier  PAREN_OPEN  PAREN_CLOSE        default_value  SEMICOLON  ]],
			[qw[                                         unann_type  identifier  PAREN_OPEN  PAREN_CLOSE        default_value  SEMICOLON  ]],
			[qw[  annotation_type_element_modifier_list  unann_type  identifier  PAREN_OPEN  PAREN_CLOSE  dims                 SEMICOLON  ]],
			[qw[                                         unann_type  identifier  PAREN_OPEN  PAREN_CLOSE  dims                 SEMICOLON  ]],
			[qw[  annotation_type_element_modifier_list  unann_type  identifier  PAREN_OPEN  PAREN_CLOSE                       SEMICOLON  ]],
			[qw[                                         unann_type  identifier  PAREN_OPEN  PAREN_CLOSE                       SEMICOLON  ]],
		];
	}

	sub annotation_type_element_modifier:RULE :ACTION_DEFAULT {
		[
			[qw[  annotation  ]],
			[qw[      PUBLIC  ]],
			[qw[    ABSTRACT  ]],
		];
	}

	sub annotation_type_element_modifier_list:RULE :ACTION_LIST {
		[
			[qw[  annotation_type_element_modifier                                        ]],
			[qw[  annotation_type_element_modifier  annotation_type_element_modifier_list ]],
		];
	}

	sub annotation_type_member_declaration:RULE :ACTION_PASS_THROUGH {
		[
			[qw[ annotation_type_element_declaration ]],
			[qw[                constant_declaration ]],
			[qw[                   class_declaration ]],
			[qw[               interface_declaration ]],
			[qw[                           SEMICOLON ]],
		];
	}

	sub annotation_type_member_declaration_list:RULE :ACTION_LIST {
		[
			[qw[ annotation_type_member_declaration                                         ]],
			[qw[ annotation_type_member_declaration annotation_type_member_declaration_list ]],
		];
	}

	sub array_access                :RULE :ACTION_DEFAULT {
		[
			[qw[      expression_name BRACKET_OPEN expression BRACKET_CLOSE ]],
			[qw[ primary_no_new_array BRACKET_OPEN expression BRACKET_CLOSE ]],
		];
	}

	sub array_type                  :RULE :ACTION_DEFAULT {
		[
			[qw[          primitive_type dims ]],
			[qw[ class_or_interface_type dims ]],
			[qw[           type_variable dims ]],
		];
	}

	sub assert_argument             :RULE :ACTION_ALIAS {
		[
			[qw[ expression ]],
		];
	}

	sub assert_statement            :RULE :ACTION_DEFAULT {
		[
			[qw[ ASSERT expression                       SEMICOLON ]],
			[qw[ ASSERT expression COLON assert_argument SEMICOLON ]],
		];
	}

	sub assignment                  :RULE :ACTION_DEFAULT {
		[
			[qw[ left_hand_side assignment_operator expression ]],
		];
	}

	sub assignment_expression       :RULE :ACTION_DEFAULT {
		[
			[qw[ conditional_expression ]],
			[qw[             assignment ]],
		];
	}

	sub assignment_operator         :RULE :ACTION_PASS_THROUGH {
		[

			[qw[ ASSIGN                      ]],
			[qw[ ASSIGN_ADD                  ]],
			[qw[ ASSIGN_AND                  ]],
			[qw[ ASSIGN_DIVIDE               ]],
			[qw[ ASSIGN_LEFT_SHIFT           ]],
			[qw[ ASSIGN_MODULO               ]],
			[qw[ ASSIGN_MULTIPLY             ]],
			[qw[ ASSIGN_OR                   ]],
			[qw[ ASSIGN_RIGHT_SHIFT          ]],
			[qw[ ASSIGN_SUB                  ]],
			[qw[ ASSIGN_UNSIGNED_RIGHT_SHIFT ]],
			[qw[ ASSIGN_XOR                  ]],
		];
	}

	sub basic_for_statement         :RULE :ACTION_DEFAULT {
		[
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON  expression  SEMICOLON  for_update  PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON  expression  SEMICOLON  for_update  PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON              SEMICOLON  for_update  PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON              SEMICOLON  for_update  PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON  expression  SEMICOLON              PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON  expression  SEMICOLON              PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON              SEMICOLON              PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON              SEMICOLON              PAREN_CLOSE statement ]],
		];
	}

	sub basic_for_statement_no_short_if:RULE :ACTION_DEFAULT {
		[
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON  expression  SEMICOLON  for_update  PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON  expression  SEMICOLON  for_update  PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON              SEMICOLON  for_update  PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON              SEMICOLON  for_update  PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON  expression  SEMICOLON              PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON  expression  SEMICOLON              PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN  for_init  SEMICOLON              SEMICOLON              PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN            SEMICOLON              SEMICOLON              PAREN_CLOSE statement_no_short_if ]],
		];
	}

	sub block_statement             :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ local_variable_declaration_statement ]],
			[qw[                    class_declaration ]],
			[qw[                            statement ]],
		];
	}

	sub block_statements            :RULE :ACTION_LIST {
		[
			[qw[ block_statement                   ]],
			[qw[ block_statement  block_statements ]],
		];
	}

	sub break_statement             :RULE :ACTION_DEFAULT {
		[
			[qw[ BREAK  identifier  SEMICOLON ]],
			[qw[ BREAK              SEMICOLON ]],
		];
	}

	sub cast_expression             :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN primitive_type                    PAREN_CLOSE unary_expression ]],
			[qw[ PAREN_OPEN reference_type  additional_bound  PAREN_CLOSE unary_expression_not_plus_minus ]],
			[qw[ PAREN_OPEN reference_type                    PAREN_CLOSE unary_expression_not_plus_minus ]],
			[qw[ PAREN_OPEN reference_type  additional_bound  PAREN_CLOSE lambda_expression ]],
			[qw[ PAREN_OPEN reference_type                    PAREN_CLOSE lambda_expression ]],
		];
	}

	sub catch_clause                :RULE :ACTION_DEFAULT {
		[
			[qw[ CATCH PAREN_OPEN catch_formal_parameter PAREN_CLOSE block ]],
		];
	}

	sub catch_formal_parameter      :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  catch_type variable_declarator_id ]],
			[qw[                           catch_type variable_declarator_id ]],
		];
	}

	sub catch_type                  :RULE :ACTION_DEFAULT {
		[
			[qw[ unann_class_type                            ]],
			[qw[ unann_class_type catch_type_class_type_list ]],
		];
	}

	sub catch_type_class_type_list  :RULE :ACTION_LIST {
		[
			[qw[ OR class_type ]],
			[qw[ OR class_type catch_type_class_type_list ]],
		]
	}

	sub catches                     :RULE :ACTION_LIST {
		[
			[qw[ catch_clause          ]],
			[qw[ catch_clause  catches ]],
		];
	}

	sub class_body_declaration      :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ class_member_declaration ]],
			[qw[     instance_initializer ]],
			[qw[       static_initializer ]],
			[qw[  constructor_declaration ]],
		];
	}

	sub class_body_declaration_list :RULE :ACTION_LIST {
		[
			[qw[ class_body_declaration                             ]],
			[qw[ class_body_declaration class_body_declaration_list ]],
		];
	}

	sub class_instance_creation_expression:RULE :ACTION_DEFAULT {
		[
			[qw[                     unqualified_class_instance_creation_expression ]],
			[qw[ expression_name DOT unqualified_class_instance_creation_expression ]],
			[qw[         primary DOT unqualified_class_instance_creation_expression ]],
		];
	}

	sub class_member_declaration    :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     field_declaration ]],
			[qw[    method_declaration ]],
			[qw[     class_declaration ]],
			[qw[ interface_declaration ]],
			[qw[             SEMICOLON ]],
		];
	}

	sub class_or_interface_type     :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     class_type ]],
			[qw[ interface_type ]],
		];
	}

	sub annotated_identifier        :RULE :ACTION_DEFAULT {
		[
			[qw[                 identifier ]],
			[qw[ annotation_list identifier ]],
		];
	}

	sub annotated_qualified_identifier :RULE :ACTION_LIST {
		[
			[qw[ annotated_identifier                          ]],
			[qw[ annotated_identifier DOT annotated_identifier ]],
		];
	}

	sub class_type                  :RULE :ACTION_DEFAULT {
		[
			[qw[                             annotation_list type_identifier type_arguments    ]],
			[qw[                             annotation_list type_identifier                   ]],
			[qw[                                             type_identifier type_arguments    ]],
			[qw[                                             type_identifier                   ]],
			[qw[            package_name DOT annotation_list type_identifier type_arguments    ]],
			[qw[            package_name DOT annotation_list type_identifier                   ]],
			[qw[            package_name DOT                 type_identifier type_arguments    ]],
			[qw[            package_name DOT                 type_identifier                   ]],
			[qw[ class_or_interface_type DOT annotation_list type_identifier type_arguments    ]],
			[qw[ class_or_interface_type DOT annotation_list type_identifier                   ]],
			[qw[ class_or_interface_type DOT                 type_identifier type_arguments    ]],
			[qw[ class_or_interface_type DOT                 type_identifier                   ]],
		];
	}

	sub constant_declaration        :RULE :ACTION_DEFAULT {
		[
			[qw[   constant_modifier_list  unann_type variable_declarator_list SEMICOLON ]],
			[qw[                           unann_type variable_declarator_list SEMICOLON ]],
		];
	}

	sub constant_expression         :RULE :ACTION_ALIAS {
		[
			[qw[ expression ]],
		];
	}

	sub constructor_body            :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  explicit_constructor_invocation   block_statements  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                    block_statements  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  explicit_constructor_invocation                     BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                                      BRACE_CLOSE ]],
		];
	}

	sub constructor_declaration     :RULE :ACTION_DEFAULT {
		[
			[qw[   constructor_modifier_list  constructor_declarator  throws  constructor_body ]],
			[qw[                              constructor_declarator  throws  constructor_body ]],
			[qw[   constructor_modifier_list  constructor_declarator          constructor_body ]],
			[qw[                              constructor_declarator          constructor_body ]],
		];
	}

	sub constructor_declarator      :RULE :ACTION_DEFAULT {
		[
			[qw[   type_parameters  simple_type_name PAREN_OPEN  receiver_parameter COMMA   formal_parameter_list  PAREN_CLOSE ]],
			[qw[                    simple_type_name PAREN_OPEN  receiver_parameter COMMA   formal_parameter_list  PAREN_CLOSE ]],
			[qw[   type_parameters  simple_type_name PAREN_OPEN                             formal_parameter_list  PAREN_CLOSE ]],
			[qw[                    simple_type_name PAREN_OPEN                             formal_parameter_list  PAREN_CLOSE ]],
			[qw[   type_parameters  simple_type_name PAREN_OPEN  receiver_parameter COMMA                          PAREN_CLOSE ]],
			[qw[                    simple_type_name PAREN_OPEN  receiver_parameter COMMA                          PAREN_CLOSE ]],
			[qw[   type_parameters  simple_type_name PAREN_OPEN                                                    PAREN_CLOSE ]],
			[qw[                    simple_type_name PAREN_OPEN                                                    PAREN_CLOSE ]],
		];
	}

	sub continue_statement          :RULE :ACTION_DEFAULT {
		[
			[qw[ CONTINUE  identifier  SEMICOLON ]],
			[qw[ CONTINUE              SEMICOLON ]],
		];
	}

	sub default_value               :RULE :ACTION_DEFAULT {
		[
			[qw[ DEFAULT element_value ]],
		];
	}

	sub dim_expr                    :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  BRACKET_OPEN expression BRACKET_CLOSE ]],
			[qw[                    BRACKET_OPEN expression BRACKET_CLOSE ]],
		];
	}

	sub dim_exprs                   :RULE :ACTION_LIST {
		[
			[qw[ dim_expr            ]],
			[qw[ dim_expr  dim_exprs ]],
		];
	}

	sub do_statement                :RULE :ACTION_DEFAULT {
		[
			[qw[ DO statement WHILE PAREN_OPEN expression PAREN_CLOSE SEMICOLON ]],
		];
	}

	sub element_value               :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ conditional_expression          ]],
			[qw[ element_value_array_initializer ]],
			[qw[ annotation                      ]],
		];
	}

	sub element_value_array_initializer:RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  element_value_list   COMMA  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                       COMMA  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  element_value_list          BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                              BRACE_CLOSE ]],
		];
	}

	sub element_value_list          :RULE :ACTION_LIST {
		[
			[qw[ element_value                           ]],
			[qw[ element_value COMMA element_value_list  ]],
		];
	}

	sub element_value_pair          :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier ASSIGN element_value ]],
		];
	}

	sub element_value_pair_list     :RULE :ACTION_LIST {
		[
			[qw[ element_value_pair                               ]],
			[qw[ element_value_pair COMMA element_value_pair_list ]],
		];
	}

	sub empty_statement             :RULE :ACTION_DEFAULT {
		[
			[qw[ SEMICOLON ]],
		];
	}

	sub enhanced_for_statement      :RULE :ACTION_DEFAULT {
		[
			[qw[ FOR PAREN_OPEN  variable_modifier_list  local_variable_type variable_declarator_id COLON expression PAREN_CLOSE statement ]],
			[qw[ FOR PAREN_OPEN                          local_variable_type variable_declarator_id COLON expression PAREN_CLOSE statement ]],
		];
	}

	sub enhanced_for_statement_no_short_if:RULE :ACTION_DEFAULT {
		[
			[qw[ FOR PAREN_OPEN  variable_modifier_list  local_variable_type variable_declarator_id COLON expression PAREN_CLOSE statement_no_short_if ]],
			[qw[ FOR PAREN_OPEN                          local_variable_type variable_declarator_id COLON expression PAREN_CLOSE statement_no_short_if ]],
		];
	}

	sub enum_body_declarations      :RULE :ACTION_DEFAULT {
		[
			[qw[ SEMICOLON  class_body_declaration_list   ]],
			[qw[ SEMICOLON                                ]],
		];
	}

	sub enum_constant               :RULE :ACTION_DEFAULT {
		[
			[qw[   enum_constant_modifier_list  enum_constant_name  PAREN_OPEN argument_list  PAREN_CLOSE  class_body   ]],
			[qw[   enum_constant_modifier_list  enum_constant_name  PAREN_OPEN argument_list  PAREN_CLOSE               ]],
			[qw[   enum_constant_modifier_list  enum_constant_name  PAREN_OPEN                PAREN_CLOSE  class_body   ]],
			[qw[   enum_constant_modifier_list  enum_constant_name  PAREN_OPEN                PAREN_CLOSE               ]],
			[qw[   enum_constant_modifier_list  enum_constant_name                                         class_body   ]],
			[qw[   enum_constant_modifier_list  enum_constant_name                                                      ]],
			[qw[                                enum_constant_name  PAREN_OPEN argument_list  PAREN_CLOSE  class_body   ]],
			[qw[                                enum_constant_name  PAREN_OPEN argument_list  PAREN_CLOSE               ]],
			[qw[                                enum_constant_name  PAREN_OPEN                PAREN_CLOSE  class_body   ]],
			[qw[                                enum_constant_name  PAREN_OPEN                PAREN_CLOSE               ]],
			[qw[                                enum_constant_name                                         class_body   ]],
			[qw[                                enum_constant_name                                                      ]],
		];
	}

	sub enum_constant_list          :RULE :ACTION_LIST {
		[
			[qw[ enum_constant                          ]],
			[qw[ enum_constant COMMA enum_constant_list ]],
		];
	}

	sub enum_constant_modifier      :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ annotation ]],
		];
	}

	sub enum_constant_modifier_list :RULE :ACTION_LIST {
		[
			[qw[ enum_constant_modifier                             ]],
			[qw[ enum_constant_modifier enum_constant_modifier_list ]],
		];
	}

	sub enum_constant_name          :RULE :ACTION_ALIAS {
		[
			[qw[ identifier ]],
		];
	}

	sub exception_type              :RULE :ACTION_PASS_THROUGH {
		[
			[qw[    class_type ]],
			[qw[ type_variable ]],
		];
	}

	sub exception_type_list         :RULE :ACTION_LIST {
		[
			[qw[ exception_type                           ]],
			[qw[ exception_type COMMA exception_type_list ]],
		];
	}

	sub explicit_constructor_invocation:RULE :ACTION_DEFAULT {
		[
			[qw[                      type_arguments   THIS PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[                                       THIS PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[                      type_arguments   THIS PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[                                       THIS PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[                      type_arguments  SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[                                      SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[                      type_arguments  SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[                                      SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[ expression_name DOT  type_arguments  SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[ expression_name DOT                  SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[ expression_name DOT  type_arguments  SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[ expression_name DOT                  SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[         primary DOT  type_arguments  SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[         primary DOT                  SUPER PAREN_OPEN  argument_list  PAREN_CLOSE SEMICOLON ]],
			[qw[         primary DOT  type_arguments  SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
			[qw[         primary DOT                  SUPER PAREN_OPEN                 PAREN_CLOSE SEMICOLON ]],
		];
	}

	sub expression                  :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     lambda_expression ]],
			[qw[ assignment_expression ]],
		];
	}

	sub expression_list             :RULE :ACTION_LIST {
		[
			[qw[ expression                        ]],
			[qw[ expression COMMA  expression_list ]],
		];
	}

	sub expression_name             :RULE :ACTION_DEFAULT {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub expression_statement        :RULE :ACTION_DEFAULT {
		[
			[qw[ statement_expression SEMICOLON ]],
		];
	}

	sub field_access                :RULE :ACTION_DEFAULT {
		[
			[qw[             primary DOT identifier ]],
			[qw[               SUPER DOT identifier ]],
			[qw[ type_name DOT SUPER DOT identifier ]],
		];
	}

	sub field_declaration           :RULE :ACTION_DEFAULT {
		[
			[qw[   field_modifier_list  unann_type variable_declarator_list SEMICOLON ]],
			[qw[                        unann_type variable_declarator_list SEMICOLON ]],
		];
	}

	sub finally                     :RULE :ACTION_DEFAULT {
		[
			[qw[ FINALLY block ]],
		];
	}

	sub for_init                    :RULE :ACTION_DEFAULT {
		[
			[qw[  statement_expression_list ]],
			[qw[ local_variable_declaration ]],
		];
	}

	sub for_statement               :RULE :ACTION_PASS_THROUGH {
		[
			[qw[    basic_for_statement ]],
			[qw[ enhanced_for_statement ]],
		];
	}

	sub for_statement_no_short_if   :RULE :ACTION_PASS_THROUGH {
		[
			[qw[    basic_for_statement_no_short_if ]],
			[qw[ enhanced_for_statement_no_short_if ]],
		];
	}

	sub for_update                  :RULE :ACTION_ALIAS {
		[
			[qw[ statement_expression_list ]],
		];
	}

	sub formal_parameter            :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  unann_type variable_declarator_id ]],
			[qw[                           unann_type variable_declarator_id ]],
			[qw[                                    variable_arity_parameter ]],
		];
	}

	sub formal_parameter_list       :RULE :ACTION_LIST {
		[
			[qw[ formal_parameter                             ]],
			[qw[ formal_parameter COMMA formal_parameter_list ]],
		];
	}

	sub identifier                  :RULE :ACTION_ALIAS {
		[
			[qw[ IDENTIFIER ]],
		];
	}

	sub identifier_list             :RULE :ACTION_LIST {
		[
			[qw[ identifier                        ]],
			[qw[ identifier COMMA  identifier_list ]],
		];
	}

	sub if_then_else_statement      :RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement_no_short_if ELSE statement ]],
		];
	}

	sub if_then_else_statement_no_short_if:RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement_no_short_if ELSE statement_no_short_if ]],
		];
	}

	sub if_then_statement           :RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement ]],
		];
	}

	sub instance_initializer        :RULE :ACTION_DEFAULT {
		[
			[qw[ block ]],
		];
	}

	sub interface_member_declaration:RULE :ACTION_PASS_THROUGH {
		[
			[qw[         constant_declaration ]],
			[qw[ interface_method_declaration ]],
			[qw[            class_declaration ]],
			[qw[        interface_declaration ]],
			[qw[                    SEMICOLON ]],
		];
	}

	sub interface_member_declaration_list:RULE :ACTION_LIST {
		[
			[qw[ interface_member_declaration                                   ]],
			[qw[ interface_member_declaration interface_member_declaration_list ]],
		];
	}

	sub interface_method_declaration:RULE :ACTION_DEFAULT {
		[
			[qw[   interface_method_modifier_list  method_header method_body ]],
			[qw[                                   method_header method_body ]],
		];
	}

	sub labeled_statement           :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier COLON statement ]],
		];
	}

	sub labeled_statement_no_short_if:RULE :ACTION_DEFAULT {
		[
			[qw[ identifier COLON statement_no_short_if ]],
		];
	}

	sub lambda_parameter            :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  lambda_parameter_type variable_declarator_id ]],
			[qw[                           lambda_parameter_type variable_declarator_id ]],
			[qw[                                               variable_arity_parameter ]],
		];
	}

	sub lambda_parameter_list       :RULE :ACTION_LIST {
		[
			[qw[ lambda_parameter                             ]],
			[qw[ lambda_parameter COMMA lambda_parameter_list ]],
		];
	}

	sub lambda_parameter_type       :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_type ]],
			[qw[        VAR ]],
		];
	}

	sub lambda_parameters           :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN  lambda_parameter_list  PAREN_CLOSE ]],
			[qw[ PAREN_OPEN  identifier_list        PAREN_CLOSE ]],
			[qw[ PAREN_OPEN                         PAREN_CLOSE ]],
			[qw[                                     identifier ]],
		];
	}

	sub left_hand_side              :RULE :ACTION_DEFAULT {
		[
			[qw[ expression_name ]],
			[qw[    field_access ]],
			[qw[    array_access ]],
		];
	}

	sub local_variable_declaration  :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  local_variable_type variable_declarator_list ]],
			[qw[                           local_variable_type variable_declarator_list ]],
		];
	}

	sub local_variable_declaration_statement:RULE :ACTION_DEFAULT {
		[
			[qw[ local_variable_declaration SEMICOLON ]],
		];
	}

	sub local_variable_type         :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_type ]],
			[qw[        VAR ]],
		];
	}

	sub method_body                 :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     block ]],
			[qw[ SEMICOLON ]],
		];
	}

	sub method_declaration          :RULE :ACTION_DEFAULT {
		[
			[qw[   method_modifier_list  method_header method_body ]],
			[qw[                         method_header method_body ]],
		];
	}

	sub method_declarator           :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier PAREN_OPEN                                                    PAREN_CLOSE         ]],
			[qw[ identifier PAREN_OPEN                                                    PAREN_CLOSE  dims   ]],
			[qw[ identifier PAREN_OPEN                             formal_parameter_list  PAREN_CLOSE         ]],
			[qw[ identifier PAREN_OPEN                             formal_parameter_list  PAREN_CLOSE  dims   ]],
			[qw[ identifier PAREN_OPEN  receiver_parameter COMMA                          PAREN_CLOSE         ]],
			[qw[ identifier PAREN_OPEN  receiver_parameter COMMA                          PAREN_CLOSE  dims   ]],
			[qw[ identifier PAREN_OPEN  receiver_parameter COMMA   formal_parameter_list  PAREN_CLOSE         ]],
			[qw[ identifier PAREN_OPEN  receiver_parameter COMMA   formal_parameter_list  PAREN_CLOSE  dims   ]],
		];
	}

	sub method_header               :RULE :ACTION_DEFAULT {
		[
			[qw[                                   result method_declarator  throws   ]],
			[qw[                                   result method_declarator           ]],
			[qw[ type_parameters  annotation_list  result method_declarator  throws   ]],
			[qw[ type_parameters  annotation_list  result method_declarator           ]],
			[qw[ type_parameters                   result method_declarator  throws   ]],
			[qw[ type_parameters                   result method_declarator           ]],
		];
	}

	sub method_name                 :RULE :ACTION_ALIAS {
		[
			[qw[ identifier ]],
		];
	}

	sub modular_compilation_unit    :RULE :ACTION_DEFAULT {
		[
			[qw[   import_declaration_list  module_declaration ]],
			[qw[                            module_declaration ]],
		];
	}

	sub module_declaration          :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list   OPEN  MODULE module_name BRACE_OPEN  module_directive_list  BRACE_CLOSE ]],
			[qw[                     OPEN  MODULE module_name BRACE_OPEN  module_directive_list  BRACE_CLOSE ]],
			[qw[   annotation_list         MODULE module_name BRACE_OPEN  module_directive_list  BRACE_CLOSE ]],
			[qw[                           MODULE module_name BRACE_OPEN  module_directive_list  BRACE_CLOSE ]],
			[qw[   annotation_list   OPEN  MODULE module_name BRACE_OPEN                         BRACE_CLOSE ]],
			[qw[                     OPEN  MODULE module_name BRACE_OPEN                         BRACE_CLOSE ]],
			[qw[   annotation_list         MODULE module_name BRACE_OPEN                         BRACE_CLOSE ]],
			[qw[                           MODULE module_name BRACE_OPEN                         BRACE_CLOSE ]],
		];
	}

	sub module_directive            :RULE :ACTION_DEFAULT {
		[
			[qw[   REQUIRES requires_modifier_list  module_name SEMICOLON ]],
			[qw[   REQUIRES                         module_name SEMICOLON ]],
			[qw[   EXPORTS  package_name  TO module_name_list   SEMICOLON ]],
			[qw[   EXPORTS  package_name                        SEMICOLON ]],
			[qw[   OPENS    package_name  TO module_name_list   SEMICOLON ]],
			[qw[   OPENS    package_name                        SEMICOLON ]],
			[qw[   USES     type_name                           SEMICOLON ]],
			[qw[   PROVIDES type_name WITH type_name_list       SEMICOLON ]],
		];
	}

	sub module_directive_list       :RULE :ACTION_LIST {
		[
			[qw[ module_directive                       ]],
			[qw[ module_directive module_directive_list ]],
		];
	}

	sub module_name                 :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub module_name_list            :RULE :ACTION_LIST {
		[
			[qw[ module_name                        ]],
			[qw[ module_name COMMA module_name_list ]],
		];
	}

	sub package_or_type_name        :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		]
	}

	sub primitive_type              :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  numeric_type ]],
			[qw[                    numeric_type ]],
			[qw[        annotation_list  BOOLEAN ]],
			[qw[                         BOOLEAN ]],
		]
	}

	sub receiver_parameter          :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  unann_type  identifier DOT  THIS ]],
			[qw[                    unann_type  identifier DOT  THIS ]],
			[qw[   annotation_list  unann_type                  THIS ]],
			[qw[                    unann_type                  THIS ]],
		]
	}

	sub reference_type              :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ class_or_interface_type ]],
			[qw[           type_variable ]],
			[qw[              array_type ]],
		]
	}

	sub requires_modifier           :RULE :ACTION_DEFAULT {
		[
			[qw[ TRANSITIVE ]],
			[qw[ STATIC ]],
		]
	}

	sub requires_modifier_list      :RULE :ACTION_LIST {
		[
			[qw[ requires_modifier                        ]],
			[qw[ requires_modifier requires_modifier_list ]],
		]
	}

	sub resource                    :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  local_variable_type identifier ASSIGN expression ]],
			[qw[                           local_variable_type identifier ASSIGN expression ]],
			[qw[   variable_access                                                          ]],
		]
	}

	sub resource_list               :RULE :ACTION_LIST {
		[
			[qw[ resource                         ]],
			[qw[ resource SEMICOLON resource_list ]],
		]
	}

	sub resource_specification      :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN resource_list  SEMICOLON  PAREN_CLOSE ]],
			[qw[ PAREN_OPEN resource_list             PAREN_CLOSE ]],
		]
	}

	sub result                      :RULE :ACTION_DEFAULT {
		[
			[qw[ unann_type ]],
			[qw[       VOID ]],
		]
	}

	sub return_statement            :RULE :ACTION_DEFAULT {
		[
			[qw[ RETURN  expression  SEMICOLON ]],
			[qw[ RETURN              SEMICOLON ]],
		]
	}

	sub simple_type_name            :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub statement                   :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ statement_without_trailing_substatement ]],
			[qw[                       labeled_statement ]],
			[qw[                       if_then_statement ]],
			[qw[                  if_then_else_statement ]],
			[qw[                         while_statement ]],
			[qw[                           for_statement ]],
		]
	}

	sub statement_expression_list   :RULE :ACTION_LIST {
		[
			[qw[ statement_expression ]],
			[qw[ statement_expression COMMA statement_expression_list  ]],
		]
	}

	sub statement_no_short_if       :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ statement_without_trailing_substatement ]],
			[qw[           labeled_statement_no_short_if ]],
			[qw[      if_then_else_statement_no_short_if ]],
			[qw[             while_statement_no_short_if ]],
			[qw[               for_statement_no_short_if ]],
		]
	}

	sub statement_without_trailing_substatement:RULE :ACTION_PASS_THROUGH {
		[
			[qw[                  block ]],
			[qw[        empty_statement ]],
			[qw[   expression_statement ]],
			[qw[       assert_statement ]],
			[qw[       switch_statement ]],
			[qw[           do_statement ]],
			[qw[        break_statement ]],
			[qw[     continue_statement ]],
			[qw[       return_statement ]],
			[qw[ synchronized_statement ]],
			[qw[        throw_statement ]],
			[qw[          try_statement ]],
		]
	}

	sub static_initializer          :RULE :ACTION_DEFAULT {
		[
			[qw[ STATIC block ]],
		]
	}

	sub switch_block                :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  switch_block_statement_group_list   switch_labels  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                      switch_labels  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  switch_block_statement_group_list                  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                                     BRACE_CLOSE ]],
		]
	}

	sub switch_block_statement_group:RULE :ACTION_DEFAULT {
		[
			[qw[ switch_labels block_statements ]],
		]
	}

	sub switch_block_statement_group_list:RULE :ACTION_LIST {
		[
			[qw[ switch_block_statement_group                                   ]],
			[qw[ switch_block_statement_group switch_block_statement_group_list ]],
		]
	}

	sub switch_label                :RULE :ACTION_DEFAULT {
		[
			[qw[ CASE constant_expression COLON ]],
			[qw[ CASE  enum_constant_name COLON ]],
			[qw[                  DEFAULT COLON ]],
		]
	}

	sub switch_labels               :RULE :ACTION_LIST {
		[
			[qw[ switch_label               ]],
			[qw[ switch_label switch_labels ]],
		]
	}

	sub switch_statement            :RULE :ACTION_DEFAULT {
		[
			[qw[ SWITCH PAREN_OPEN expression PAREN_CLOSE switch_block ]],
		]
	}

	sub synchronized_statement      :RULE :ACTION_DEFAULT {
		[
			[qw[ SYNCHRONIZED PAREN_OPEN expression PAREN_CLOSE block ]],
		]
	}

	sub throw_statement             :RULE :ACTION_DEFAULT {
		[
			[qw[ THROW expression SEMICOLON ]],
		]
	}

	sub throws                      :RULE :ACTION_DEFAULT {
		[
			[qw[ THROWS exception_type_list ]],
		]
	}

	sub try_statement               :RULE :ACTION_DEFAULT {
		[
			[qw[ TRY block catches          ]],
			[qw[ TRY block catches  finally ]],
			[qw[ TRY block          finally ]],
			[qw[ try_with_resources_statement ]],
		]
	}

	sub try_with_resources_statement:RULE :ACTION_DEFAULT {
		[
			[qw[ TRY resource_specification block  catches   finally   ]],
			[qw[ TRY resource_specification block            finally   ]],
			[qw[ TRY resource_specification block  catches             ]],
			[qw[ TRY resource_specification block                      ]],
		]
	}

	sub type_name                   :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub type_name_list              :RULE :ACTION_LIST {
		[
			[qw[ type_name                       ]],
			[qw[ type_name COMMA  type_name_list ]],
		]
	}

	sub type_variable               :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  type_identifier ]],
			[qw[                    type_identifier ]],
		]
	}

	sub unann_array_type            :RULE :ACTION_DEFAULT {
		[
			[qw[          unann_primitive_type dims ]],
			[qw[ unann_class_or_interface_type dims ]],
			[qw[           unann_type_variable dims ]],
		]
	}

	sub unann_class_or_interface_type:RULE :ACTION_PASS_THROUGH {
		[
			[qw[     unann_class_type ]],
			[qw[ unann_interface_type ]],
		]
	}

	sub unann_class_type            :RULE :ACTION_DEFAULT {
		[
			[qw[                                                     type_identifier  type_arguments   ]],
			[qw[                                                     type_identifier                   ]],
			[qw[                  package_name DOT  annotation_list  type_identifier  type_arguments   ]],
			[qw[                  package_name DOT                   type_identifier  type_arguments   ]],
			[qw[                  package_name DOT  annotation_list  type_identifier                   ]],
			[qw[                  package_name DOT                   type_identifier                   ]],
			[qw[ unann_class_or_interface_type DOT  annotation_list  type_identifier  type_arguments   ]],
			[qw[ unann_class_or_interface_type DOT                   type_identifier  type_arguments   ]],
			[qw[ unann_class_or_interface_type DOT  annotation_list  type_identifier                   ]],
			[qw[ unann_class_or_interface_type DOT                   type_identifier                   ]],
		]
	}

	sub unann_interface_type        :RULE :ACTION_ALIAS {
		[
			[qw[ unann_class_type ]],
		]
	}

	sub unann_reference_type        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_class_or_interface_type ]],
			[qw[           unann_type_variable ]],
			[qw[              unann_array_type ]],
		]
	}

	sub unann_type_variable         :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub unary_expression_not_plus_minus:RULE :ACTION_DEFAULT {
		[
			[qw[          postfix_expression ]],
			[qw[ BIT_NEGATE unary_expression ]],
			[qw[        NOT unary_expression ]],
			[qw[             cast_expression ]],
		]
	}

	sub variable_access             :RULE :ACTION_DEFAULT {
		[
			[qw[ expression_name ]],
			[qw[    field_access ]],
		]
	}

	sub variable_arity_parameter    :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  unann_type  annotation_list  ELIPSIS identifier ]],
			[qw[                           unann_type  annotation_list  ELIPSIS identifier ]],
			[qw[   variable_modifier_list  unann_type                   ELIPSIS identifier ]],
			[qw[                           unann_type                   ELIPSIS identifier ]],
		]
	}

	sub variable_declarator         :RULE :ACTION_DEFAULT {
		[
			[qw[ variable_declarator_id  ASSIGN variable_initializer   ]],
			[qw[ variable_declarator_id                                ]],
		]
	}

	sub variable_declarator_id      :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier  dims   ]],
			[qw[ identifier         ]],
		]
	}

	sub variable_declarator_list    :RULE :ACTION_LIST {
		[
			[qw[ variable_declarator                                ]],
			[qw[ variable_declarator COMMA variable_declarator_list ]],
		]
	}

	sub while_statement             :RULE :ACTION_DEFAULT {
		[
			[qw[ WHILE PAREN_OPEN expression PAREN_CLOSE statement ]],
		]
	}

	sub while_statement_no_short_if :RULE :ACTION_DEFAULT {
		[
			[qw[ WHILE PAREN_OPEN expression PAREN_CLOSE statement_no_short_if ]],
		]
	}

	1
};

