/*

	Syntax Tree Printer

	- in progress

	@author George Corney

*/

package glsl.printer;

import glsl.SyntaxTree;

using glsl.printer.SyntaxTreeHelper;
using glsl.SyntaxTree.NodeEnumHelper;

class NodePrinter{
	static public function print(n:Node, pretty:Bool = false){
		//determine
		return switch n.toEnum(){
			case RootNode(n):                            n.print(pretty);
			case TypeSpecifierNode(n):                   n.print(pretty);
			case StructSpecifierNode(n):                 n.print(pretty);
			case StructFieldDeclarationNode(n):          n.print(pretty);
			case StructDeclaratorNode(n):                n.print(pretty);
			case ExpressionNode(n):                      n.print(pretty);
			case IdentifierNode(n):                      n.print(pretty);
			case PrimitiveNode(n):                       n.print(pretty);
			case BinaryExpressionNode(n):                n.print(pretty);
			case UnaryExpressionNode(n):                 n.print(pretty);
			case SequenceExpressionNode(n):              n.print(pretty);
			case ConditionalExpressionNode(n):           n.print(pretty);
			case AssignmentExpressionNode(n):            n.print(pretty);
			case FieldSelectionExpressionNode(n):        n.print(pretty);
			case ArrayElementSelectionExpressionNode(n): n.print(pretty);
			case FunctionCallNode(n):                    n.print(pretty);
			case ConstructorNode(n):                     n.print(pretty);
			case DeclarationNode(n):                     n.print(pretty);
			case PrecisionDeclarationNode(n):            n.print(pretty);
			case VariableDeclarationNode(n):             n.print(pretty);
			case DeclaratorNode(n):                      n.print(pretty);
			case ParameterDeclarationNode(n):            n.print(pretty);
			case FunctionDefinitionNode(n):              n.print(pretty);
			case FunctionPrototypeNode(n):               n.print(pretty);
			case FunctionHeaderNode(n):                  n.print(pretty);
			case StatementNode(n):                       n.print(pretty);
			case CompoundStatementNode(n):               n.print(pretty);
			case DeclarationStatementNode(n):            n.print(pretty);
			case ExpressionStatementNode(n):             n.print(pretty);
			case IterationStatementNode(n):              n.print(pretty);
			case WhileStatementNode(n):                  n.print(pretty);
			case DoWhileStatementNode(n):                n.print(pretty);
			case ForStatementNode(n):                    n.print(pretty);
			case IfStatementNode(n):                     n.print(pretty);
			case JumpStatementNode(n):                   n.print(pretty);
			case ReturnStatementNode(n):                 n.print(pretty);
		}
	}
}
class RootPrinter{
	static public function print(n:Root, pretty:Bool = false):String{
		var str = '';
		for(d in n.declarations)
			str += d.print(pretty) + (pretty ? '\n' : '');
		return str;
	}
}
class TypeSpecifierPrinter{
	static public function print(n:TypeSpecifier, pretty:Bool = false):String{
		return (n.invariant ? 'invariant' : '') + ' ' + n.qualifier.print() + ' ' + n.precision.print() + ' ' + n.dataType.print();
	}
}
class StructSpecifierPrinter{
	static public function print(n:StructSpecifier, pretty:Bool = false):String{
		var str = '';
		var name = n.name != null ? n.name : '';
		str += 'struct $name {' + (pretty ? '\n' : '');
		for(f in n.fieldDeclarations)
			str += f.print(pretty) + (pretty ? '\n' : '');
		str += '}';
		return str;
	}
}
class StructFieldDeclarationPrinter{
	static public function print(n:StructFieldDeclaration, pretty:Bool = false):String{
		var str = n.typeSpecifier.print(pretty) + ' ';
		for(i in 0...n.declarators.length){
			var dr = n.declarators[i];
			str += (pretty ? (i > 0 ? ' ' : '') : '') +//pretty leading space
					dr.print(pretty) +
					(i < n.declarators.length - 1 ? ',' : '');//trailing comma
		}
		str += ';';
		return str;
	}
}
class StructDeclaratorPrinter{
	static public function print(n:StructDeclarator, pretty:Bool = false):String{
		return n.name + (n.arraySizeExpression != null ? '['+n.arraySizeExpression.print(pretty)+']' : '');
	}
}
class ExpressionPrinter{
	static public function print(n:Expression, pretty:Bool = false):String{
		return NodePrinter.print(n, pretty);//cannot print on its own, determine subtype
	}
}
class IdentifierPrinter{
	static public function print(n:Identifier, pretty:Bool = false):String{
		return n.parenWrap ? '(${n.name})' : n.name;
	}
}
class PrimitivePrinter{
	static public function print(n:Primitive<Dynamic>, pretty:Bool = false):String{
		return n.parenWrap ? '(${n.raw})' : n.raw;
	}
}
class BinaryExpressionPrinter{
	static public function print(n:BinaryExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(BinaryExpression)';
	}
}
class UnaryExpressionPrinter{
	static public function print(n:UnaryExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(UnaryExpression)';
	}
}
class SequenceExpressionPrinter{
	static public function print(n:SequenceExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(SequenceExpression)';
	}
}
class ConditionalExpressionPrinter{
	static public function print(n:ConditionalExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ConditionalExpression)';
	}
}
class AssignmentExpressionPrinter{
	static public function print(n:AssignmentExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(AssignmentExpression)';
	}
}
class FieldSelectionExpressionPrinter{
	static public function print(n:FieldSelectionExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(FieldSelectionExpression)';
	}
}
class ArrayElementSelectionExpressionPrinter{
	static public function print(n:ArrayElementSelectionExpression, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ArrayElementSelectionExpression)';
	}
}
class FunctionCallPrinter{
	static public function print(n:FunctionCall, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(FunctionCall)';
	}
}
class ConstructorPrinter{
	static public function print(n:Constructor, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(Constructor)';
	}
}
class DeclarationPrinter{
	static public function print(n:Declaration, pretty:Bool = false):String{
		return NodePrinter.print(n, pretty);//cannot print on its own, determine subtype
	}
}
class PrecisionDeclarationPrinter{
	static public function print(n:PrecisionDeclaration, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(PrecisionDeclaration)';
	}
}
class VariableDeclarationPrinter{
	static public function print(n:VariableDeclaration, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(VariableDeclaration)';
	}
}
class DeclaratorPrinter{
	static public function print(n:Declarator, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(Declarator)';
	}
}
class ParameterDeclarationPrinter{
	static public function print(n:ParameterDeclaration, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ParameterDeclaration)';
	}
}
class FunctionDefinitionPrinter{
	static public function print(n:FunctionDefinition, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(FunctionDefinition)';
	}
}
class FunctionPrototypePrinter{
	static public function print(n:FunctionPrototype, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(FunctionPrototype)';
	}
}
class FunctionHeaderPrinter{
	static public function print(n:FunctionHeader, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(FunctionHeader)';
	}
}
class StatementPrinter{
	static public function print(n:Statement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(Statement)';
	}
}
class CompoundStatementPrinter{
	static public function print(n:CompoundStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(CompoundStatement)';
	}
}
class DeclarationStatementPrinter{
	static public function print(n:DeclarationStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(DeclarationStatement)';
	}
}
class ExpressionStatementPrinter{
	static public function print(n:ExpressionStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ExpressionStatement)';
	}
}
class IterationStatementPrinter{
	static public function print(n:IterationStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(IterationStatement)';
	}
}
class WhileStatementPrinter{
	static public function print(n:WhileStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(WhileStatement)';
	}
}
class DoWhileStatementPrinter{
	static public function print(n:DoWhileStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(DoWhileStatement)';
	}
}
class ForStatementPrinter{
	static public function print(n:ForStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ForStatement)';
	}
}
class IfStatementPrinter{
	static public function print(n:IfStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(IfStatement)';
	}
}
class JumpStatementPrinter{
	static public function print(n:JumpStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(JumpStatement)';
	}
}
class ReturnStatementPrinter{
	static public function print(n:ReturnStatement, pretty:Bool = false):String{
		return 'NOT-IMPLEMENTED(ReturnStatement)';
	}
}

//Enums
class BinaryOperatorPrinter{
	static public function print(e:BinaryOperator):String{
		return switch e{
			case LEFT_OP:      '<<';
			case RIGHT_OP:     '>>';
			case LE_OP:        '<=';
			case GE_OP:        '>=';
			case EQ_OP:        '==';
			case NE_OP:        '!=';
			case AND_OP:       '&&';
			case OR_OP:        '||';
			case XOR_OP:       '^^';
			case DASH:         '-';
			case PLUS:         '+';
			case STAR:         '*';
			case SLASH:        '/';
			case PERCENT:      '%';
			case LEFT_ANGLE:   '<';
			case RIGHT_ANGLE:  '>';
			case VERTICAL_BAR: '|';
			case CARET:        '^';
			case AMPERSAND:    '&';
		}
	}
}
class UnaryOperatorPrinter{
	static public function print(e:UnaryOperator):String{
		return switch e {
			case INC_OP: '++';
			case DEC_OP: '--';
			case BANG:   '!';
			case DASH:   '-';
			case TILDE:  '~';
			case PLUS:   '+';
		}
	}
}
class AssignmentOperatorPrinter{
	static public function print(e:AssignmentOperator):String{
		return switch e{
			case MUL_ASSIGN:   '*=';
			case DIV_ASSIGN:   '/=';
			case ADD_ASSIGN:   '+=';
			case MOD_ASSIGN:   '%=';
			case SUB_ASSIGN:   '-=';
			case LEFT_ASSIGN:  '<<=';
			case RIGHT_ASSIGN: '>>=';
			case AND_ASSIGN:   '&=';
			case XOR_ASSIGN:   '^=';
			case OR_ASSIGN:    '|=';
			case EQUAL:        '=';
		}
	}
}
class PrecisionQualifierPrinter{
	static public function print(e:PrecisionQualifier):String{
		return switch e{
			case HIGH_PRECISION:   'highp';
			case MEDIUM_PRECISION: 'mediump';
			case LOW_PRECISION:    'lowp';
		}
	}
}
class JumpModePrinter{
	static public function print(e:JumpMode):String{
		return switch e{
			case BREAK:    'break';
			case CONTINUE: 'continue';
			case RETURN:   'return';
			case DISCARD:  'discard';
		}
	}
}
class DataTypePrinter{
	static public function print(e:DataType):String{
		return switch e{
			case VOID:            'void';
			case INT:             'int';
			case FLOAT:           'float';
			case BOOL:            'bool';
			case VEC2:            'vec2';
			case VEC3:            'vec3';
			case VEC4:            'vec4';
			case BVEC2:           'bvec2';
			case BVEC3:           'bvec3';
			case BVEC4:           'bvec4';
			case IVEC2:           'ivec2';
			case IVEC3:           'ivec3';
			case IVEC4:           'ivec4';
			case MAT2:            'mat2';
			case MAT3:            'mat3';
			case MAT4:            'mat4';
			case SAMPLER2D:       'sampler2D';
			case SAMPLERCUBE:     'samplerCube';
			case USER_TYPE(name): name;
		}
	}
}
class ParameterQualifierPrinter{
	static public function print(e:ParameterQualifier):String{
		return switch e{
			case IN:    'in';
			case OUT:   'out';
			case INOUT: 'inout';
		}
	}
}
class TypeQualifierPrinter{
	static public function print(e:TypeQualifier):String{
		return switch e{
			case ATTRIBUTE: 'attribute';
			case UNIFORM:   'uniform';
			case VARYING:   'varying';
			case CONST:     'const';
		}
	}
}