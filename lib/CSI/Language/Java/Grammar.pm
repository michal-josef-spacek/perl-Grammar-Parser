
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Grammar v1.0.0 {
	use CSI::Grammar;
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

		$code->(
			$name,
			dom => "CSI::Language::Java::Operator::$dom",
			@params,
		);
	}

	start rule TOP                          => dom => 'CSI::Document',
		[qw[  compilation_unit  ]],
		[],
		;

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

	1;
};

__END__
	sub Decimal_Numeral             :REGEX {
		qr/(?>
			(?! 0 [_[:digit:]] )
			(?= [[:digit:]])
			[_[:digit:]]+
			(?<= [[:digit:]])
		)/sx;
	}

	sub Hex_Numeral                 :REGEX {
		qr/(?>
			0 [xX]
			[_[:xdigit:]]+
			(?<= [[:xdigit:]])
		)/sx;
	}

	sub Octal_Numeral               :REGEX {
		qr/(?>
			0
			[_0-7]+
			(?<= [0-7])
		)/sx;
	}

	sub Binary_Numeral              :REGEX {
		qr/(?>
			0 [bB]
			[_01]+
			(?<= [01])
		)/sx;
	}

	sub Integer_Type_Suffix         :REGEX {
		qr/
			[lL]
		/sx;
	}

	sub Identifier_Character        :REGEX {
		qr/[_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]/sx;
	}

	sub Escape_Sequence             :REGEX {
		qr/(?>
			\\
			(?:
				  (?<char_escape> (?: [btnrf\'\"\\] ))
				| (?<octal_escape> (?: (?= [0-7]) [0-3]? [0-7]{1,2} ))
				| (?: u+ (?<hex_escape> [[:xdigit:]]{4} ))
			)
		)/sx;
	}

	sub LITERAL_INTEGER             :TOKEN :TRANSFORM(integer_value) :ACTION_LITERAL_VALUE {
		qr/(?>
			(?:
				  (?<decimal_value> (??{ 'Decimal_Numeral' }) )
				| (?<hex_value>     (??{ 'Hex_Numeral'     }) )
				| (?<octal_value>   (??{ 'Octal_Numeral'   }) )
				| (?<binary_value>  (??{ 'Binary_Numeral'  }) )
			)
			(?<type_suffix> (??{ 'Integer_Type_Suffix' }) )?
			\b
		)/sx;
	}

	sub LITERAL_CHARACTER           :TOKEN :ACTION_LITERAL_VALUE {
		qr/(?>
			\'
			(?<value> [^\'\\] | (??{ 'Escape_Sequence' }) )
			\'
		)/sx;
	}

	sub LITERAL_STRING              :TOKEN :ACTION_LITERAL_VALUE {
		qr/(?>
			\"
			(?<value> (?: [^\"\\] | (??{ 'Escape_Sequence' }) )* )
			\"
		)/sx;
	}

	sub IDENTIFIER                  :TOKEN :ACTION_LITERAL_VALUE {
        qr/(?>
			(?!  \p{Digit} )
			(?!  (??{ 'Keyword' }) )
			(?!  (??{ 'Literal_Boolean' }) )
			(?!  (??{ 'Literal_Null' }) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;
	}

	sub type_identifier             :TOKEN :ACTION_LITERAL_VALUE {
        qr/(?>
			(?!  \p{Digit} )
			(?!  (??{ 'Keyword' }) )
			(?!  (??{ 'Literal_Boolean' }) )
			(?!  (??{ 'Literal_Null' }) )
			(?!  (??{ 'VAR' }) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;
	}


	sub SEMICOLON                   :TOKEN {
		';'
	}

	sub DOT                         :TOKEN {
		'.'
	}

	sub BRACE_OPEN                  :TOKEN {
		'{'
	}

	sub BRACE_CLOSE                 :TOKEN {
		'}'
	}

	sub PAREN_OPEN                  :TOKEN {
		'('
	}

	sub PAREN_CLOSE                 :TOKEN {
		')'
	}

	sub BRACKET_OPEN                :TOKEN {
		'['
	}

	sub BRACKET_CLOSE               :TOKEN {
		']'
	}

	sub COMMA                       :TOKEN {
		','
	}

	sub AT                          :TOKEN {
		'@'
	}

	sub TYPE_PARAMETER_LIST_OPEN    :TOKEN {
		'<'
	}

	sub TYPE_PARAMETER_LIST_CLOSE   :TOKEN {
		'>'
	}

	sub DOUBLE_COLON                :TOKEN {
		'::'
	}

	sub LAMBDA                      :TOKEN {
		'->'
	}

	sub ELIPSIS                     :TOKEN {
		'...'
	}

	sub COLON                       :TOKEN {
		':'
	}

	sub QUESTION_MARK               :TOKEN {
		'?'
	}

	sub AND                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&';
	}

	sub ASSIGN                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'=';
	}

	sub ASSIGN_ADD                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'+=';
	}

	sub ASSIGN_AND                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&=';
	}

	sub ASSIGN_DIVIDE               :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'/=';
	}

	sub ASSIGN_LEFT_SHIFT           :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<<=';
	}

	sub ASSIGN_MULTIPLY             :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'*=';
	}

	sub ASSIGN_MODULO               :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'%=';
	}

	sub ASSIGN_OR                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'|=';
	}

	sub ASSIGN_RIGHT_SHIFT          :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>=';
	}

	sub ASSIGN_SUB                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'-=';
	}

	sub ASSIGN_UNSIGNED_RIGHT_SHIFT :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>>=';
	}

	sub ASSIGN_XOR                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'^=';
	}

	sub DECREMENT                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'--';
	}

	sub DIVIDE                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'/';
	}

	sub EQUALS                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'==';
	}

	sub GREATER_THAN                :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>';
	}

	sub GREATER_THAN_OR_EQUALS      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>=';
	}

	sub INCREMENT                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'++';
	}

	sub LESS_THAN                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<';
	}

	sub LESS_THAN_OR_EQUALS         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<=';
	}

	sub LOGICAL_OR                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'||';
	}

	sub LOGICAL_AND                 :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&&';
	}

	sub MINUS                       :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'-';
	}

	sub NOT                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'!';
	}

	sub NOT_EQUALS                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'!=';
	}

	sub OR                          :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'|';
	}

	sub PLUS                        :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'+';
	}

	sub RIGHT_SHIFT                 :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>';
	}

	sub MULTIPLY                    :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'*'
	}

	sub MODULO                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'%'
	}

	sub LEFT_SHIFT                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<<'
	}

	sub UNSIGNED_RIGHT_SHIFT        :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>>'
	}

	sub XOR                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'^'
	}

	sub BIT_NEGATE                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'~'
	}

	1;
};

1;

__END__
	sub additional_bound            :RULE :ACTION_LIST {
		[
			[qw[  AND  interface_type                    ]],
			[qw[  AND  interface_type  additional_bound  ]],
		];
	}

	sub additive_expression         :RULE :ACTION_LIST {
		[
			[qw[  multiplicative_expression                           ]],
			[qw[  multiplicative_expression PLUS  additive_expression ]],
			[qw[  multiplicative_expression MINUS additive_expression ]],
		];
	}

	sub and_expression              :RULE :ACTION_LIST {
		[
			[qw[  equality_expression                    ]],
			[qw[  equality_expression AND and_expression ]],
		];
	}

	sub annotation                  :RULE :ACTION_ALIAS {
		[
			[qw[  normal_annotation          ]],
			[qw[  marker_annotation          ]],
			[qw[  single_element_annotation  ]],
		];
	}

	sub annotation_list             :RULE :ACTION_LIST {
		[
			[qw[  annotation                  ]],
			[qw[  annotation  annotation_list ]],
		];
	}

	sub annotation_type_body        :RULE :ACTION_ALIAS {
		[
			[qw[  BRACE_OPEN  annotation_type_member_declaration_list  BRACE_CLOSE  ]],
			[qw[  BRACE_OPEN                                           BRACE_CLOSE  ]],
		];
	}

	sub annotation_type_declaration :RULE :ACTION_DEFAULT {
		[
			[qw[  interface_modifier_list  AT  INTERFACE  type_identifier  annotation_type_body  ]],
			[qw[                           AT  INTERFACE  type_identifier  annotation_type_body  ]],
		];
	}

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

	sub argument_list               :RULE :ACTION_LIST {
		[
			[qw[ expression                      ]],
			[qw[ expression COMMA  argument_list ]],
		];
	}

	sub array_access                :RULE :ACTION_DEFAULT {
		[
			[qw[      expression_name BRACKET_OPEN expression BRACKET_CLOSE ]],
			[qw[ primary_no_new_array BRACKET_OPEN expression BRACKET_CLOSE ]],
		];
	}

	sub array_creation_expression   :RULE :ACTION_DEFAULT {
		[
			[qw[ NEW          primitive_type dim_exprs                         ]],
			[qw[ NEW          primitive_type dim_exprs  dims                   ]],
			[qw[ NEW class_or_interface_type dim_exprs                         ]],
			[qw[ NEW class_or_interface_type dim_exprs  dims                   ]],
			[qw[ NEW          primitive_type            dims array_initializer ]],
			[qw[ NEW class_or_interface_type            dims array_initializer ]],
		];
	}

	sub array_initializer           :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  variable_initializer_list   COMMA  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                              COMMA  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  variable_initializer_list          BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                     BRACE_CLOSE ]],
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

	sub block                       :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  block_statements  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                    BRACE_CLOSE ]],
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

	sub class_body                  :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  class_body_declaration_list  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                               BRACE_CLOSE ]],
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

	sub class_declaration           :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ normal_class_declaration ]],
			[qw[         enum_declaration ]],
		];
	}

	sub class_instance_creation_expression:RULE :ACTION_DEFAULT {
		[
			[qw[                     unqualified_class_instance_creation_expression ]],
			[qw[ expression_name DOT unqualified_class_instance_creation_expression ]],
			[qw[         primary DOT unqualified_class_instance_creation_expression ]],
		];
	}

	sub class_literal               :RULE :ACTION_DEFAULT {
		[
			[qw[    type_name                            DOT CLASS ]],
			[qw[    type_name BRACKET_OPEN BRACKET_CLOSE DOT CLASS ]],
			[qw[ numeric_type                            DOT CLASS ]],
			[qw[ numeric_type BRACKET_OPEN BRACKET_CLOSE DOT CLASS ]],
			[qw[      BOOLEAN                            DOT CLASS ]],
			[qw[      BOOLEAN BRACKET_OPEN BRACKET_CLOSE DOT CLASS ]],
			[qw[         VOID                            DOT CLASS ]],
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

	sub class_modifier              :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC     ]],
			[qw[ PROTECTED  ]],
			[qw[ PRIVATE    ]],
			[qw[ ABSTRACT   ]],
			[qw[ STATIC     ]],
			[qw[ FINAL      ]],
			[qw[ STRICTFP   ]],
		];
	}

	sub class_modifier_list         :RULE :ACTION_LIST {
		[
			[qw[ class_modifier                     ]],
			[qw[ class_modifier class_modifier_list ]],
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

	sub class_or_interface_type_to_instantiate:RULE :ACTION_DEFAULT {
		[
			[qw[ annotated_qualified_identifier  type_arguments_or_diamond   ]],
			[qw[ annotated_qualified_identifier                              ]],
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

	sub compilation_unit            :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ ordinary_compilation_unit ]],
			[qw[  modular_compilation_unit ]],
		];
	}

	sub conditional_and_expression  :RULE :ACTION_LIST {
		[
			[qw[ inclusive_or_expression                                        ]],
			[qw[ inclusive_or_expression LOGICAL_AND conditional_and_expression ]],
		];
	}

	sub conditional_expression      :RULE :ACTION_DEFAULT {
		[
			[qw[ conditional_or_expression                                                       ]],
			[qw[ conditional_or_expression QUESTION_MARK expression COLON conditional_expression ]],
			[qw[ conditional_or_expression QUESTION_MARK expression COLON lambda_expression      ]],
		];
	}

	sub conditional_or_expression   :RULE :ACTION_LIST {
		[
			[qw[ conditional_and_expression                                      ]],
			[qw[ conditional_and_expression LOGICAL_OR conditional_or_expression ]],
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

	sub constant_modifier           :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC     ]],
			[qw[ STATIC     ]],
			[qw[ FINAL      ]],
		];
	}

	sub constant_modifier_list      :RULE :ACTION_LIST {
		[
			[qw[ constant_modifier                        ]],
			[qw[ constant_modifier constant_modifier_list ]],
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

	sub constructor_modifier        :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC ]],
			[qw[ PROTECTED ]],
			[qw[ PRIVATE ]],
		];
	}

	sub constructor_modifier_list   :RULE :ACTION_LIST {
		[
			[qw[ constructor_modifier                           ]],
			[qw[ constructor_modifier constructor_modifier_list ]],
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

	sub diamond                     :RULE :ACTION_SYMBOL {
		[
			[qw[ LESS_THAN GREATER_THAN ]],
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

	sub dim                         :RULE :ACTION_DEFAULT {
		[
			[qw[                 BRACKET_OPEN BRACKET_CLOSE ]],
			[qw[ annotation_list BRACKET_OPEN BRACKET_CLOSE ]],
		];
	}

	sub dims                        :RULE :ACTION_LIST {
		[
			[qw[ dim      ]],
			[qw[ dim dims ]],
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

	sub enum_body                   :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN                                                       BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                               enum_body_declarations  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                       COMMA                           BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                       COMMA   enum_body_declarations  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  enum_constant_list                                   BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  enum_constant_list           enum_body_declarations  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  enum_constant_list   COMMA                           BRACE_CLOSE ]],
			[qw[ BRACE_OPEN  enum_constant_list   COMMA   enum_body_declarations  BRACE_CLOSE ]],
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

	sub enum_declaration            :RULE :ACTION_DEFAULT {
		[
			[qw[                        ENUM type_identifier                   enum_body ]],
			[qw[                        ENUM type_identifier  superinterfaces  enum_body ]],
			[qw[   class_modifier_list  ENUM type_identifier                   enum_body ]],
			[qw[   class_modifier_list  ENUM type_identifier  superinterfaces  enum_body ]],
		];
	}

	sub equality_expression         :RULE :ACTION_DEFAULT {
		[
			[qw[ relational_expression                                ]],
			[qw[ relational_expression     EQUALS equality_expression ]],
			[qw[ relational_expression NOT_EQUALS equality_expression ]],
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

	sub exclusive_or_expression     :RULE :ACTION_LIST {
		[
			[qw[ and_expression                             ]],
			[qw[ and_expression XOR exclusive_or_expression ]],
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

	sub extends_interfaces          :RULE :ACTION_DEFAULT {
		[
			[qw[ EXTENDS interface_type_list ]],
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

	sub field_modifier              :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC     ]],
			[qw[ PROTECTED  ]],
			[qw[ PRIVATE    ]],
			[qw[ STATIC     ]],
			[qw[ FINAL      ]],
			[qw[ TRANSIENT  ]],
			[qw[ VOLATILE   ]],
		];
	}

	sub field_modifier_list         :RULE :ACTION_LIST {
		[
			[qw[ field_modifier                     ]],
			[qw[ field_modifier field_modifier_list ]],
		];
	}

	sub finally                     :RULE :ACTION_DEFAULT {
		[
			[qw[ FINALLY block ]],
		];
	}

	sub floating_point_type         :RULE :ACTION_DEFAULT {
		[
			[qw[ FLOAT  ]],
			[qw[ DOUBLE ]],
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

	sub import_all                  :RULE :ACTION_SYMBOL {
		[
			[qw[ DOT MULTIPLY ]],
		];
	}

	sub import_declaration_list     :RULE :ACTION_LIST {
		[
			[qw[ import_declaration                         ]],
			[qw[ import_declaration import_declaration_list ]],
		];
	}

	sub import_declaration          :RULE :ACTION_DEFAULT {
		[
			[qw[ IMPORT STATIC qualified_identifier import_all SEMICOLON ]],
			[qw[ IMPORT STATIC qualified_identifier            SEMICOLON ]],
			[qw[ IMPORT        qualified_identifier            SEMICOLON ]],
			[qw[ IMPORT        qualified_identifier import_all SEMICOLON ]],
		];
	}

	sub inclusive_or_expression     :RULE :ACTION_LIST {
		[
			[qw[ exclusive_or_expression                            ]],
			[qw[ exclusive_or_expression OR inclusive_or_expression ]],
		];
	}

	sub instance_initializer        :RULE :ACTION_DEFAULT {
		[
			[qw[ block ]],
		];
	}

	sub integral_type               :RULE :ACTION_DEFAULT {
		[
			[qw[ BYTE ]],
			[qw[ SHORT ]],
			[qw[ INT ]],
			[qw[ LONG ]],
			[qw[ CHAR ]],
		];
	}

	sub interface_body              :RULE :ACTION_DEFAULT {
		[
			[qw[ BRACE_OPEN  interface_member_declaration_list  BRACE_CLOSE ]],
			[qw[ BRACE_OPEN                                     BRACE_CLOSE ]],
		];
	}

	sub interface_declaration       :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ normal_interface_declaration ]],
			[qw[  annotation_type_declaration ]],
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

	sub interface_method_modifier   :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC ]],
			[qw[ PRIVATE ]],
			[qw[ ABSTRACT ]],
			[qw[ DEFAULT ]],
			[qw[ STATIC ]],
			[qw[ STRICTFP ]],
		];
	}

	sub interface_method_modifier_list:RULE :ACTION_LIST {
		[
			[qw[ interface_method_modifier                                ]],
			[qw[ interface_method_modifier interface_method_modifier_list ]],
		];
	}

	sub interface_modifier          :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC ]],
			[qw[ PROTECTED ]],
			[qw[ PRIVATE ]],
			[qw[ ABSTRACT ]],
			[qw[ STATIC ]],
			[qw[ STRICTFP ]],
		];
	}

	sub interface_modifier_list     :RULE :ACTION_LIST {
		[
			[qw[ interface_modifier                         ]],
			[qw[ interface_modifier interface_modifier_list ]],
		];
	}

	sub interface_type              :RULE :ACTION_ALIAS {
		[
			[qw[ class_type ]],
		];
	}

	sub interface_type_list         :RULE :ACTION_LIST {
		[
			[qw[ interface_type                            ]],
			[qw[ interface_type COMMA interface_type_list  ]],
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

	sub lambda_body                 :RULE :ACTION_DEFAULT {
		[
			[qw[ expression ]],
			[qw[      block ]],
		];
	}

	sub lambda_expression           :RULE :ACTION_DEFAULT {
		[
			[qw[ lambda_parameters LAMBDA lambda_body ]],
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

	sub literal                     :RULE :ACTION_DEFAULT {
		[
			[qw[ literal_integer ]],
			#TODO [qw[ literal_floating_point ]],
			[qw[ literal_boolean ]],
			[qw[ literal_character ]],
			[qw[ literal_string ]],
			[qw[ literal_null ]],
		];
	}



	sub literal_boolean             :RULE :ACTION_ALIAS {
		[
			[qw[ FALSE ]],
			[qw[ TRUE  ]],
		];
	}

	sub literal_character           :RULE :ACTION_ALIAS {
		[
			[qw[ LITERAL_CHARACTER ]],
		];
	}

	sub literal_integer             :RULE :ACTION_ALIAS {
		[
			[qw[ LITERAL_INTEGER ]],
		];
	}

	sub literal_null                :RULE :ACTION_ALIAS {
		[
			[qw[ NULL ]],
		];
	}

	sub literal_string              :RULE :ACTION_ALIAS {
		[
			[qw[ LITERAL_STRING ]],
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

	sub marker_annotation           :RULE :ACTION_DEFAULT {
		[
			[qw[ AT type_name ]],
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

	sub method_invocation           :RULE :ACTION_DEFAULT {
		[
			[qw[                                          method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[                                          method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[           type_name DOT  type_arguments  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[           type_name DOT                  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[           type_name DOT  type_arguments  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[           type_name DOT                  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[     expression_name DOT  type_arguments  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[     expression_name DOT                  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[     expression_name DOT  type_arguments  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[     expression_name DOT                  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[             primary DOT  type_arguments  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[             primary DOT                  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[             primary DOT  type_arguments  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[             primary DOT                  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[               SUPER DOT  type_arguments  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[               SUPER DOT                  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[               SUPER DOT  type_arguments  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[               SUPER DOT                  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[ type_name DOT SUPER DOT  type_arguments  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[ type_name DOT SUPER DOT                  method_name PAREN_OPEN  argument_list  PAREN_CLOSE ]],
			[qw[ type_name DOT SUPER DOT  type_arguments  method_name PAREN_OPEN                 PAREN_CLOSE ]],
			[qw[ type_name DOT SUPER DOT                  method_name PAREN_OPEN                 PAREN_CLOSE ]],
		];
	}

	sub method_modifier             :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
			[qw[ PUBLIC ]],
			[qw[ PROTECTED ]],
			[qw[ PRIVATE ]],
			[qw[ ABSTRACT ]],
			[qw[ STATIC ]],
			[qw[ FINAL ]],
			[qw[ SYNCHRONIZED ]],
			[qw[ NATIVE ]],
			[qw[ STRICTFP ]],
		],
	}

	sub method_modifier_list        :RULE :ACTION_LIST {
		[
			[qw[ method_modifier                      ]],
			[qw[ method_modifier method_modifier_list ]],
		];
	}

	sub method_name                 :RULE :ACTION_ALIAS {
		[
			[qw[ identifier ]],
		];
	}

	sub method_reference            :RULE :ACTION_DEFAULT {
		[
			[qw[     expression_name DOUBLE_COLON  type_arguments  method_name ]],
			[qw[     expression_name DOUBLE_COLON                  method_name ]],
			[qw[             primary DOUBLE_COLON  type_arguments  method_name ]],
			[qw[             primary DOUBLE_COLON                  method_name ]],
			[qw[      reference_type DOUBLE_COLON  type_arguments  method_name ]],
			[qw[      reference_type DOUBLE_COLON                  method_name ]],
			[qw[               SUPER DOUBLE_COLON  type_arguments  method_name ]],
			[qw[               SUPER DOUBLE_COLON                  method_name ]],
			[qw[ type_name DOT SUPER DOUBLE_COLON  type_arguments  method_name ]],
			[qw[ type_name DOT SUPER DOUBLE_COLON                  method_name ]],
			[qw[          class_type DOUBLE_COLON  type_arguments  NEW         ]],
			[qw[          class_type DOUBLE_COLON                  NEW         ]],
			[qw[          array_type DOUBLE_COLON                  NEW         ]],
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

	sub multiplicative_expression   :RULE :ACTION_LIST {
		[
			[qw[ unary_expression                                    ]],
			[qw[ unary_expression MULTIPLY multiplicative_expression ]],
			[qw[ unary_expression DIVIDE   multiplicative_expression ]],
			[qw[ unary_expression MODULO   multiplicative_expression ]],
		];
	}

	sub normal_annotation           :RULE :ACTION_DEFAULT {
		[
			[qw[ AT type_name PAREN_OPEN  element_value_pair_list  PAREN_CLOSE ]],
			[qw[ AT type_name PAREN_OPEN                           PAREN_CLOSE ]],
		]
	}

	sub normal_class_declaration    :RULE :ACTION_DEFAULT {
		[
			[qw[                        CLASS type_identifier                                                  class_body ]],
			[qw[                        CLASS type_identifier                                 superinterfaces  class_body ]],
			[qw[                        CLASS type_identifier                    superclass                    class_body ]],
			[qw[                        CLASS type_identifier                    superclass   superinterfaces  class_body ]],
			[qw[                        CLASS type_identifier  type_parameters                                 class_body ]],
			[qw[                        CLASS type_identifier  type_parameters                superinterfaces  class_body ]],
			[qw[                        CLASS type_identifier  type_parameters   superclass                    class_body ]],
			[qw[                        CLASS type_identifier  type_parameters   superclass   superinterfaces  class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier                                                  class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier                                 superinterfaces  class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier                    superclass                    class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier                    superclass   superinterfaces  class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier  type_parameters                                 class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier  type_parameters                superinterfaces  class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier  type_parameters   superclass                    class_body ]],
			[qw[   class_modifier_list  CLASS type_identifier  type_parameters   superclass   superinterfaces  class_body ]],
		]
	}

	sub normal_interface_declaration:RULE :ACTION_DEFAULT {
		[
			[qw[   interface_modifier_list  INTERFACE type_identifier  type_parameters   extends_interfaces  interface_body ]],
			[qw[                            INTERFACE type_identifier  type_parameters   extends_interfaces  interface_body ]],
			[qw[   interface_modifier_list  INTERFACE type_identifier                    extends_interfaces  interface_body ]],
			[qw[                            INTERFACE type_identifier                    extends_interfaces  interface_body ]],
			[qw[   interface_modifier_list  INTERFACE type_identifier  type_parameters                       interface_body ]],
			[qw[                            INTERFACE type_identifier  type_parameters                       interface_body ]],
			[qw[   interface_modifier_list  INTERFACE type_identifier                                        interface_body ]],
			[qw[                            INTERFACE type_identifier                                        interface_body ]],
		]
	}

	sub numeric_type                :RULE :ACTION_PASS_THROUGH {
		[
			[qw[       integral_type ]],
			[qw[ floating_point_type ]],
		]
	}

	sub ordinary_compilation_unit   :RULE :ACTION_DEFAULT {
		[
			[qw[   package_declaration   import_declaration_list   type_declaration_list   ]],
			[qw[                         import_declaration_list   type_declaration_list   ]],
			[qw[   package_declaration                             type_declaration_list   ]],
			[qw[                                                   type_declaration_list   ]],
			[qw[   package_declaration   import_declaration_list                           ]],
			[qw[                         import_declaration_list                           ]],
			[qw[   package_declaration                                                     ]],
		];
	}

	sub package_declaration         :RULE :ACTION_DEFAULT {
		[
			[qw[ package_modifier_list PACKAGE package_name SEMICOLON ]],
			[qw[                       PACKAGE package_name SEMICOLON ]],
		];
	}

	sub package_modifier            :RULE :ACTION_DEFAULT {
		[
			[qw[ annotation ]],
		]
	}

	sub package_modifier_list       :RULE :ACTION_LIST {
		[
			[qw[ package_modifier                       ]],
			[qw[ package_modifier package_modifier_list ]],
		];
	}

	sub package_name                :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub package_or_type_name        :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		]
	}

	sub post_decrement_expression   :RULE :ACTION_DEFAULT {
		[
			[qw[ postfix_expression DECREMENT ]],
		]
	}

	sub post_increment_expression   :RULE :ACTION_DEFAULT {
		[
			[qw[ postfix_expression INCREMENT ]],
		]
	}

	sub postfix_expression          :RULE :ACTION_PASS_THROUGH {
		[
			[qw[                   primary ]],
			[qw[           expression_name ]],
			[qw[ post_increment_expression ]],
			[qw[ post_decrement_expression ]],
		]
	}

	sub pre_decrement_expression    :RULE :ACTION_DEFAULT {
		[
			[qw[ DECREMENT unary_expression ]],
		]
	}

	sub pre_increment_expression    :RULE :ACTION_DEFAULT {
		[
			[qw[ INCREMENT unary_expression ]],
		]
	}

	sub primary                     :RULE :ACTION_PASS_THROUGH {
		[
			[qw[      primary_no_new_array ]],
			[qw[ array_creation_expression ]],
		]
	}

	sub primary_no_new_array        :RULE :ACTION_DEFAULT {
		[
			[qw[                            literal ]],
			[qw[                      class_literal ]],
			[qw[                               THIS ]],
			[qw[                 type_name DOT THIS ]],
			[qw[  PAREN_OPEN expression PAREN_CLOSE ]],
			[qw[ class_instance_creation_expression ]],
			[qw[                       field_access ]],
			[qw[                       array_access ]],
			[qw[                  method_invocation ]],
			[qw[                   method_reference ]],
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

	sub qualified_identifier        :RULE :ACTION_LIST {
		[
			[qw[ identifier                          ]],
			[qw[ identifier DOT qualified_identifier ]],
		];
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

	sub relational_expression       :RULE :ACTION_DEFAULT {
		[
			[qw[ shift_expression                                              ]],
			[qw[ shift_expression LESS_THAN              relational_expression ]],
			[qw[ shift_expression LESS_THAN_OR_EQUALS    relational_expression ]],
			[qw[ shift_expression GREATER_THAN           relational_expression ]],
			[qw[ shift_expression GREATER_THAN_OR_EQUALS relational_expression ]],
			[qw[ relational_expression INSTANCEOF reference_type ]],
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

	sub shift_expression            :RULE :ACTION_LIST {
		[
			[qw[ additive_expression                                       ]],
			[qw[ additive_expression LEFT_SHIFT           shift_expression ]],
			[qw[ additive_expression RIGHT_SHIFT          shift_expression ]],
			[qw[ additive_expression UNSIGNED_RIGHT_SHIFT shift_expression ]],
		]
	}

	sub simple_type_name            :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub single_element_annotation   :RULE :ACTION_DEFAULT {
		[
			[qw[ AT type_name PAREN_OPEN element_value PAREN_CLOSE ]],
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

	sub statement_expression        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[                         assignment ]],
			[qw[           pre_increment_expression ]],
			[qw[           pre_decrement_expression ]],
			[qw[          post_increment_expression ]],
			[qw[          post_decrement_expression ]],
			[qw[                  method_invocation ]],
			[qw[ class_instance_creation_expression ]],
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

	sub superclass                  :RULE :ACTION_DEFAULT {
		[
			[qw[ EXTENDS class_type ]],
		]
	}

	sub superinterfaces             :RULE :ACTION_DEFAULT {
		[
			[qw[ IMPLEMENTS interface_type_list ]],
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

	sub type_argument               :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ reference_type ]],
			[qw[       wildcard ]],
		]
	}

	sub type_argument_list          :RULE :ACTION_LIST {
		[
			[qw[ type_argument ]],
			[qw[ type_argument COMMA type_argument_list  ]],
		]
	}

	sub type_arguments              :RULE :ACTION_DEFAULT {
		[
			[qw[ LESS_THAN type_argument_list GREATER_THAN ]],
		]
	}

	sub type_arguments_or_diamond   :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_arguments ]],
			[qw[        diamond ]],
		]
	}

	sub type_bound                  :RULE :ACTION_DEFAULT {
		[
			[qw[ EXTENDS type_variable                              ]],
			[qw[ EXTENDS class_or_interface_type  additional_bound  ]],
			[qw[ EXTENDS class_or_interface_type                    ]],
		]
	}

	sub type_declaration            :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     class_declaration ]],
			[qw[ interface_declaration ]],
			[qw[             SEMICOLON ]],
		]
	}

	sub type_declaration_list       :RULE :ACTION_LIST {
		[
			[qw[ type_declaration                       ]],
			[qw[ type_declaration type_declaration_list ]],
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

	sub type_parameter              :RULE :ACTION_DEFAULT {
		[
			[qw[   type_parameter_modifier_list  type_identifier  type_bound   ]],
			[qw[                                 type_identifier  type_bound   ]],
			[qw[   type_parameter_modifier_list  type_identifier               ]],
			[qw[                                 type_identifier               ]],
		]
	}

	sub type_parameter_list         :RULE :ACTION_LIST {
		[
			[qw[ type_parameter                           ]],
			[qw[ type_parameter COMMA type_parameter_list ]],
		]
	}

	sub type_parameter_modifier     :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ annotation ]],
		]
	}

	sub type_parameter_modifier_list:RULE :ACTION_LIST {
		[
			[qw[ type_parameter_modifier                              ]],
			[qw[ type_parameter_modifier type_parameter_modifier_list ]],
		]
	}

	sub type_parameters             :RULE :ACTION_DEFAULT {
		[
			[qw[ LESS_THAN type_parameter_list GREATER_THAN ]],
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

	sub unann_primitive_type        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ numeric_type ]],
			[qw[      BOOLEAN ]],
		]
	}

	sub unann_reference_type        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_class_or_interface_type ]],
			[qw[           unann_type_variable ]],
			[qw[              unann_array_type ]],
		]
	}

	sub unann_type                  :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_primitive_type ]],
			[qw[ unann_reference_type ]],
		]
	}

	sub unann_type_variable         :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub unary_expression            :RULE :ACTION_DEFAULT {
		[
			[qw[        pre_increment_expression ]],
			[qw[        pre_decrement_expression ]],
			[qw[           PLUS unary_expression ]],
			[qw[          MINUS unary_expression ]],
			[qw[ unary_expression_not_plus_minus ]],
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

	sub unqualified_class_instance_creation_expression:RULE :ACTION_DEFAULT {
		[
			[qw[ NEW  type_arguments  class_or_interface_type_to_instantiate PAREN_OPEN  argument_list  PAREN_CLOSE  class_body   ]],
			[qw[ NEW                  class_or_interface_type_to_instantiate PAREN_OPEN  argument_list  PAREN_CLOSE  class_body   ]],
			[qw[ NEW  type_arguments  class_or_interface_type_to_instantiate PAREN_OPEN                 PAREN_CLOSE  class_body   ]],
			[qw[ NEW                  class_or_interface_type_to_instantiate PAREN_OPEN                 PAREN_CLOSE  class_body   ]],
			[qw[ NEW  type_arguments  class_or_interface_type_to_instantiate PAREN_OPEN  argument_list  PAREN_CLOSE               ]],
			[qw[ NEW                  class_or_interface_type_to_instantiate PAREN_OPEN  argument_list  PAREN_CLOSE               ]],
			[qw[ NEW  type_arguments  class_or_interface_type_to_instantiate PAREN_OPEN                 PAREN_CLOSE               ]],
			[qw[ NEW                  class_or_interface_type_to_instantiate PAREN_OPEN                 PAREN_CLOSE               ]],
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

	sub variable_initializer        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[        expression ]],
			[qw[ array_initializer ]],
		]
	}

	sub variable_initializer_list   :RULE :ACTION_LIST {
		[
			[qw[ variable_initializer                                 ]],
			[qw[ variable_initializer COMMA variable_initializer_list ]],
		]
	}

	sub variable_modifier           :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ annotation ]],
			[qw[      FINAL ]],
		]
	}

	sub variable_modifier_list      :RULE :ACTION_LIST {
		[
			[qw[ variable_modifier                        ]],
			[qw[ variable_modifier variable_modifier_list ]],
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

	sub wildcard                    :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  QUESTION_MARK  wildcard_bounds   ]],
			[qw[                    QUESTION_MARK  wildcard_bounds   ]],
			[qw[   annotation_list  QUESTION_MARK                    ]],
			[qw[                    QUESTION_MARK                    ]],
		]
	}

	sub wildcard_bounds             :RULE :ACTION_DEFAULT {
		[
			[qw[ EXTENDS reference_type ]],
			[qw[   SUPER reference_type ]],
		]
	}

	1
};

