/*

	Syntax Tree Printer
	@author George Corney

	@!todo
		- faster indentation?
*/

package glsl.printer;

import glsl.SyntaxTree;

using glsl.printer.SyntaxTreeHelper;
using glsl.SyntaxTree.NodeEnumHelper;

class NodePrinter{
	//Node cannot be printed, determine sub type and print
	static public function print(n:Node, indentWith:String, indentLevel:Int = 0){
		var pretty = (indentWith != null);
		return switch n.toEnum(){
			case RootNode(n):                            n.print(indentWith, indentLevel);
			case TypeSpecifierNode(n):                   n.print(indentWith, indentLevel);
			case StructSpecifierNode(n):                 n.print(indentWith, indentLevel);
			case StructFieldDeclarationNode(n):          n.print(indentWith, indentLevel);
			case StructDeclaratorNode(n):                n.print(indentWith, indentLevel);
			case ExpressionNode(n):                      n.print(indentWith, indentLevel);
			case IdentifierNode(n):                      n.print(indentWith, indentLevel);
			case PrimitiveNode(n):                       n.print(indentWith, indentLevel);
			case BinaryExpressionNode(n):                n.print(indentWith, indentLevel);
			case UnaryExpressionNode(n):                 n.print(indentWith, indentLevel);
			case SequenceExpressionNode(n):              n.print(indentWith, indentLevel);
			case ConditionalExpressionNode(n):           n.print(indentWith, indentLevel);
			case AssignmentExpressionNode(n):            n.print(indentWith, indentLevel);
			case FieldSelectionExpressionNode(n):        n.print(indentWith, indentLevel);
			case ArrayElementSelectionExpressionNode(n): n.print(indentWith, indentLevel);
			case FunctionCallNode(n):                    n.print(indentWith, indentLevel);
			case ConstructorNode(n):                     n.print(indentWith, indentLevel);
			case DeclarationNode(n):                     n.print(indentWith, indentLevel);
			case PrecisionDeclarationNode(n):            n.print(indentWith, indentLevel);
			case VariableDeclarationNode(n):             n.print(indentWith, indentLevel);
			case DeclaratorNode(n):                      n.print(indentWith, indentLevel);
			case ParameterDeclarationNode(n):            n.print(indentWith, indentLevel);
			case FunctionDefinitionNode(n):              n.print(indentWith, indentLevel);
			case FunctionPrototypeNode(n):               n.print(indentWith, indentLevel);
			case FunctionHeaderNode(n):                  n.print(indentWith, indentLevel);
			case StatementNode(n):                       n.print(indentWith, indentLevel);
			case CompoundStatementNode(n):               n.print(indentWith, indentLevel);
			case DeclarationStatementNode(n):            n.print(indentWith, indentLevel);
			case ExpressionStatementNode(n):             n.print(indentWith, indentLevel);
			case IterationStatementNode(n):              n.print(indentWith, indentLevel);
			case WhileStatementNode(n):                  n.print(indentWith, indentLevel);
			case DoWhileStatementNode(n):                n.print(indentWith, indentLevel);
			case ForStatementNode(n):                    n.print(indentWith, indentLevel);
			case IfStatementNode(n):                     n.print(indentWith, indentLevel);
			case JumpStatementNode(n):                   n.print(indentWith, indentLevel);
			case ReturnStatementNode(n):                 n.print(indentWith, indentLevel);
			case null, _:
				throw 'Node cannot be printed: $n';
		}
	}
}
class RootPrinter{
	static public function print(n:Root, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		for(i in 0...n.declarations.length){
			var d = n.declarations[i];
			var unit:String = d.print(indentWith, 0);
			//node-specific rules
			var currentNodeEnum = d.toEnum();
			var nextNodeEnum = n.declarations[i+1].toEnum();
			if(pretty){
				//group similar nodes, (excluding FunctionDefinitions)
				if(nextNodeEnum != null){
					unit = unit + '\n';
					if(
						currentNodeEnum.getIndex() != nextNodeEnum.getIndex() ||
						currentNodeEnum.match(FunctionDefinitionNode(_))
					)
						unit = unit + '\n';
				}
			}else{
				//preprocessor tokens need to have their own line
				if(currentNodeEnum.match(PreprocessorDirectiveNode(_)))
					unit = unit + '\n';
				else if(nextNodeEnum != null && nextNodeEnum.match(PreprocessorDirectiveNode(_)))
					unit = unit + '\n';
			}

			str += unit;
		}
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class TypeSpecifierPrinter{
	static public function print(n:TypeSpecifier, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		switch n.toEnum(){
			case StructSpecifierNode(n): return n.print(indentWith, indentLevel);
			default:
		}
		var str = '';
		var qualifiers:Array<String> = [];
		if(n.invariant) qualifiers.push('invariant');
		if(n.storage != null) qualifiers.push(n.storage.print());
		if(n.precision != null) qualifiers.push(n.precision.print());
		if(n.dataType  != null) qualifiers.push(n.dataType.print());
		str += qualifiers.join(' ');
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class StructSpecifierPrinter{
	static public function print(n:StructSpecifier, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		//qualifiers
		var qualifiers:Array<String> = [];
		if(n.invariant) qualifiers.push('invariant');
		if(n.storage != null) qualifiers.push(n.storage.print());
		if(n.precision != null) qualifiers.push(n.precision.print());
		str += qualifiers.join(' ') + (qualifiers.length > 0 ? ' ' : '');
		//add struct declaration
		var name = n.name != null ? n.name : '';
		str += 'struct $name{' + (pretty ? '\n' : '');
		//add fields
		str += n.fieldDeclarations.map(function(fd)
			return fd.print(indentWith, 1)
		).join(pretty ? '\n' : '');
		//close
		str += (pretty ? '\n' : '') + '}';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class StructFieldDeclarationPrinter{
	static public function print(n:StructFieldDeclaration, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.typeSpecifier.print(indentWith, 0) + ' ';

		str += n.declarators.map(function(dr)
			return dr.print(indentWith)
		).join(pretty ? ', ' : ',');

		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class StructDeclaratorPrinter{
	static public function print(n:StructDeclarator, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.name + (n.arraySizeExpression != null ? '['+n.arraySizeExpression.print(indentWith, 0)+']' : '');
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ExpressionPrinter{
	static public function print(n:Expression, indentWith:String, indentLevel:Int = 0):String{
		return switch n.toEnum(){
			case IdentifierNode(n):                      n.print(indentWith, indentLevel);
			case PrimitiveNode(n):                       n.print(indentWith, indentLevel);
			case BinaryExpressionNode(n):                n.print(indentWith, indentLevel);
			case UnaryExpressionNode(n):                 n.print(indentWith, indentLevel);
			case SequenceExpressionNode(n):              n.print(indentWith, indentLevel);
			case ConditionalExpressionNode(n):           n.print(indentWith, indentLevel);
			case AssignmentExpressionNode(n):            n.print(indentWith, indentLevel);
			case FieldSelectionExpressionNode(n):        n.print(indentWith, indentLevel);
			case ArrayElementSelectionExpressionNode(n): n.print(indentWith, indentLevel);
			case FunctionCallNode(n):                    n.print(indentWith, indentLevel);
			case ConstructorNode(n):                     n.print(indentWith, indentLevel);//extends FunctionCall
			case null, _:
				throw 'Expression cannot be printed: $n';
		}
	}
}
class IdentifierPrinter{
	static public function print(n:Identifier, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.name;
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class PrimitivePrinter{
	static public function print(n:Primitive<Dynamic>, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.raw;
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class BinaryExpressionPrinter{
	static public function print(n:BinaryExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		str += n.left.print(indentWith);
		str += (pretty ? ' ' + n.op.print() + ' ' : n.op.print());
		str += n.right.print(indentWith);
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class UnaryExpressionPrinter{
	static public function print(n:UnaryExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		if(n.isPrefix) str += n.op.print() + n.arg.print(indentWith);
		else str += n.arg.print(indentWith) + n.op.print();
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class SequenceExpressionPrinter{
	static public function print(n:SequenceExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.expressions.map(function (e)
			return e.print(indentWith)
		).join(pretty ? ', ' : ',');
		str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ConditionalExpressionPrinter{
	static public function print(n:ConditionalExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.test.print(indentWith)
				+ (pretty ? ' ? ' : '?')
				+ n.consequent.print(indentWith)
				+ (pretty ? ' : ' : ':')
				+ n.alternate.print(indentWith);
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class AssignmentExpressionPrinter{
	static public function print(n:AssignmentExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		str += n.left.print(indentWith);
		str += (pretty ? ' ' + n.op.print() + ' ' : n.op.print());
		str += n.right.print(indentWith);
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class FieldSelectionExpressionPrinter{
	static public function print(n:FieldSelectionExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.left.print(indentWith) + '.' + n.field.print(indentWith);
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ArrayElementSelectionExpressionPrinter{
	static public function print(n:ArrayElementSelectionExpression, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.left.print(indentWith) + '[' + n.arrayIndexExpression.print(indentWith) + ']';
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class FunctionCallPrinter{
	static public function print(n:FunctionCall, indentWith:String, indentLevel:Int = 0):String{
		switch n.toEnum(){
			case ConstructorNode(n): return n.print(indentWith, indentLevel);
			default:
		}
		var pretty = (indentWith != null);
		var str = n.name + '(';
		str += n.parameters.map(function(e)
			return e.print(indentWith)
		).join(pretty ? ', ' : ',');
		str += ')';
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ConstructorPrinter{
	static public function print(n:Constructor, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.dataType.print() + '(';
		str += n.parameters.map(function(e)
			return e.print(indentWith)
		).join(pretty ? ', ' : ',');
		str += ')';
		if(n.parenWrap) str = '($str)';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class DeclarationPrinter{
	static public function print(n:Declaration, indentWith:String, indentLevel:Int = 0):String{
		return switch n.toEnum(){
			case PrecisionDeclarationNode(n):  n.print(indentWith, indentLevel);
			case VariableDeclarationNode(n):   n.print(indentWith, indentLevel);
			case FunctionPrototypeNode(n):     n.print(indentWith, indentLevel);
			case FunctionDefinitionNode(n):    n.print(indentWith, indentLevel);
			case PreprocessorDirectiveNode(n): n.print(indentWith, indentLevel);
			case null, _:
				throw 'Declaration cannot be printed: $n';
		}
	}
}
class PrecisionDeclarationPrinter{
	static public function print(n:PrecisionDeclaration, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = 'precision ${n.precision.print()} ${n.dataType.print()};';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class VariableDeclarationPrinter{
	static public function print(n:VariableDeclaration, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.typeSpecifier.print(indentWith, 0) + (n.declarators.length > 0 ? ' ' : '');
		str += n.declarators.map(function(dr)
			return dr.print(indentWith)
		).join(pretty ? ', ' : ',');
		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class DeclaratorPrinter{
	static public function print(n:Declarator, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		str += n.name
			+ (n.arraySizeExpression != null ? '['+n.arraySizeExpression.print(indentWith, 0)+']' : '')
			+ (n.initializer != null ? (pretty ? ' = ' : '=') + n.initializer.print(indentWith, 0) : '');
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ParameterDeclarationPrinter{
	static public function print(n:ParameterDeclaration, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		str += (n.parameterQualifier != null ? n.parameterQualifier.print() + ' ' : '');
		str += n.typeSpecifier.print(indentWith) + ' ';
		str += n.name;
		str += (n.arraySizeExpression != null ? '['+n.arraySizeExpression.print(indentWith)+']' : '');
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class FunctionDefinitionPrinter{
	static public function print(n:FunctionDefinition, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.header.print(indentWith);
		str += n.body.print(indentWith);
		//FunctionDefinition is technically not a declaration, but an external_declaration, so it doesn't require a semicolon
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class FunctionPrototypePrinter{
	static public function print(n:FunctionPrototype, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.header.print(indentWith) + ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class FunctionHeaderPrinter{
	static public function print(n:FunctionHeader, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.returnType.print(indentWith) + ' ' + n.name + '(';
		str += n.parameters.map(function(p)
			return p.print(indentWith)
		).join(pretty ? ', ' : ',');
		str += ')';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class StatementPrinter{
	static public function print(n:Statement, indentWith:String, indentLevel:Int = 0):String{
		return switch n.toEnum(){
			case CompoundStatementNode(n):     n.print(indentWith, indentLevel);
			case DeclarationStatementNode(n):  n.print(indentWith, indentLevel);
			case ExpressionStatementNode(n):   n.print(indentWith, indentLevel);
			case IterationStatementNode(n):    n.print(indentWith, indentLevel);
			case WhileStatementNode(n):        n.print(indentWith, indentLevel);
			case DoWhileStatementNode(n):      n.print(indentWith, indentLevel);
			case ForStatementNode(n):          n.print(indentWith, indentLevel);
			case IfStatementNode(n):           n.print(indentWith, indentLevel);
			case JumpStatementNode(n):         n.print(indentWith, indentLevel);
			case ReturnStatementNode(n):       n.print(indentWith, indentLevel);
			case PreprocessorDirectiveNode(n): n.print(indentWith, indentLevel);
			case null, _:
				throw 'Statement cannot be printed: $n';
		}
	}
}
class CompoundStatementPrinter{
	static public function print(n:CompoundStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = '';
		str += '{' + (pretty ? '\n' : '');
		//enumerate statements
		for(i in 0...n.statementList.length){
			var smt = n.statementList[i];
			var smtStr = smt.print(indentWith, 1);
			//node-specific rules
			var currentNodeEnum = smt.toEnum();
			var nextNodeEnum = n.statementList[i + 1].toEnum();
			if(pretty){
				//group similar statements:
				//if current and next are different node types, add newline
				if(nextNodeEnum != null){
					smtStr = smtStr + '\n';
					if(
						currentNodeEnum.getIndex() != nextNodeEnum.getIndex() ||
					  	Std.is(smt, IterationStatement)
					)
						smtStr = smtStr + '\n';
				}
			}else{
				//preprocessor tokens need to have their own line
				var previousNodeEnum = n.statementList[i - 1].toEnum();
				if(currentNodeEnum.match(PreprocessorDirectiveNode(_))){
					smtStr = smtStr + '\n';
					if(previousNodeEnum == null) smtStr = '\n' + smtStr;
				}else if(nextNodeEnum != null && nextNodeEnum.match(PreprocessorDirectiveNode(_)))
					smtStr = smtStr + '\n';
			}
			str += smtStr;
		}
		str += (pretty ? '\n' : '') + '}';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class DeclarationStatementPrinter{
	static public function print(n:DeclarationStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.declaration.print(indentWith);
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ExpressionStatementPrinter{
	static public function print(n:ExpressionStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.expression != null ? n.expression.print(indentWith) : '';
		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class IfStatementPrinter{
	static public function print(n:IfStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var compoundConsequent = n.consequent.toEnum().match(CompoundStatementNode(_));
		var str = 'if(' + n.test.print(indentWith) + ')';
		str += (pretty && !compoundConsequent ? ' ' : ''); //trailing space
		str += n.consequent.print(indentWith);
		if(n.alternate != null){
			str += (pretty && !compoundConsequent ? '\n' : '');
			var compoundAlternate = n.alternate.toEnum().match(CompoundStatementNode(_));
			str += 'else';
			str += (!compoundAlternate ? ' ' : ''); //trailing space
			str += n.alternate.print(indentWith);
		}
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class JumpStatementPrinter{
	static public function print(n:JumpStatement, indentWith:String, indentLevel:Int = 0):String{
		switch n.toEnum(){
			case ReturnStatementNode(n): n.print(indentWith, indentLevel);
			default:
		}
		var pretty = (indentWith != null);
		var str = n.mode.print();
		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ReturnStatementPrinter{
	static public function print(n:ReturnStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.mode.print();
		if(n.returnExpression != null) str += ' ' + n.returnExpression.print(indentWith);
		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class IterationStatementPrinter{
	static public function print(n:IterationStatement, indentWith:String, indentLevel:Int = 0):String{
		return switch n.toEnum(){
			case WhileStatementNode(n):   n.print(indentWith, indentLevel);
			case DoWhileStatementNode(n): n.print(indentWith, indentLevel);
			case ForStatementNode(n):     n.print(indentWith, indentLevel);
			case null, _:
				throw 'IterationStatement cannot be printed: $n';
		}
	}
}
class WhileStatementPrinter{
	static public function print(n:WhileStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = 'while(' + n.test.print(indentWith) + ')';
		str += n.body.print(indentWith);
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class DoWhileStatementPrinter{
	static public function print(n:DoWhileStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var compoundBody = n.body.toEnum().match(CompoundStatementNode(_));
		var str = 'do';
		str += (!compoundBody ? ' ' : ''); //trailing space
		str += n.body.print(indentWith);
		str += (!compoundBody && pretty ? '\n' : ''); //trailing space
		str += 'while(' + n.test.print(indentWith) + ')';
		str += ';';
		return Utils.indent(str, indentWith, indentLevel);
	}
}
class ForStatementPrinter{
	static public function print(n:ForStatement, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = 'for';
		str += '('
			+ n.init.print(indentWith)
			+ (pretty ? ' ' : '')
			+ n.test.print(indentWith)
			+ (pretty ? '; ' : ';')
			+ n.update.print(indentWith)
			+ ')';
		str += n.body.print(indentWith);
		return Utils.indent(str, indentWith, indentLevel);
	}
}
//non-spec preprocessor nodes
@:publicFields
class PreprocessorDirectivePrinter{
	static public function print(n:PreprocessorDirective, indentWith:String, indentLevel:Int = 0):String{
		var pretty = (indentWith != null);
		var str = n.content;
		return Utils.indent(str, indentWith, indentLevel);
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
			case null:         '';
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
			case null:   '';
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
			case null:         '';
		}
	}
}
class PrecisionQualifierPrinter{
	static public function print(e:PrecisionQualifier):String{
		return switch e{
			case HIGH_PRECISION:   'highp';
			case MEDIUM_PRECISION: 'mediump';
			case LOW_PRECISION:    'lowp';
			case null:             '';
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
			case null:     '';
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
			case null:            '';
		}
	}
}
class ParameterQualifierPrinter{
	static public function print(e:ParameterQualifier):String{
		return switch e{
			case IN:    'in';
			case OUT:   'out';
			case INOUT: 'inout';
			case null:  '';
		}
	}
}
class StorageQualifierPrinter{
	static public function print(e:StorageQualifier):String{
		return switch e{
			case ATTRIBUTE: 'attribute';
			case UNIFORM:   'uniform';
			case VARYING:   'varying';
			case CONST:     'const';
			case null:      '';
		}
	}
}