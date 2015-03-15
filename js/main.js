(function () { "use strict";
var console = (1,eval)('this').console || {log:function(){}};
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = ["EReg"];
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw "EReg::matched";
	}
	,split: function(s) {
		var d = "#__delim__#";
		return s.replace(this.r,d).split(d);
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Main = function() {
	this.inputChanged = false;
	var _g = this;
	this.jsonContainer = window.document.getElementById("json-container");
	this.messagesElement = window.document.getElementById("messages");
	this.warningsElement = window.document.getElementById("warnings");
	this.successElement = window.document.getElementById("success");
	var savedInput = this.loadInput();
	if(savedInput != null) Editor.setValue(savedInput);
	Editor.on("change",function(e) {
		_g.inputChanged = true;
	});
	var reparseTimer = new haxe.Timer(500);
	reparseTimer.run = function() {
		if(_g.inputChanged) _g.parseAndEvaluate();
	};
	this.parseAndEvaluate();
};
Main.__name__ = ["Main"];
Main.main = function() {
	new Main();
};
Main.prototype = {
	parseAndEvaluate: function() {
		var input = Editor.getValue();
		try {
			var tokens = glslparser.Tokenizer.tokenize(input);
			var ast = glslparser.Parser.parseTokens(tokens);
			this.displayAST(ast);
			glslparser.Eval.evaluateConstantExpressions(ast);
			this.saveInput(input);
			this.showErrors(glslparser.Parser.warnings.concat(glslparser.Tokenizer.warnings));
		} catch( e ) {
			this.showErrors([e]);
			this.jsonContainer.innerHTML = "";
		}
		this.inputChanged = false;
	}
	,displayAST: function(ast) {
		this.jsonContainer.innerHTML = "";
		this.jsonContainer.appendChild((renderjson.set_show_to_level(5).set_sort_objects(true))(ast));
	}
	,showErrors: function(warnings) {
		if(warnings.length > 0) {
			this.warningsElement.innerHTML = warnings.join("<br>");
			this.successElement.innerHTML = "";
			this.messagesElement.className = "error";
		} else {
			this.successElement.innerHTML = "GLSL parsed without error";
			this.warningsElement.innerHTML = "";
			this.messagesElement.className = "";
		}
	}
	,saveInput: function(input) {
		js.Browser.getLocalStorage().setItem("glsl-input",input);
	}
	,loadInput: function() {
		return js.Browser.getLocalStorage().getItem("glsl-input");
	}
	,__class__: Main
};
Math.__name__ = ["Math"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.compare = function(a,b) {
	if(a == b) return 0; else if(a > b) return 1; else return -1;
};
Reflect.isEnumValue = function(v) {
	return v != null && v.__enum__ != null;
};
var Std = function() { };
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
};
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
Std.parseFloat = function(x) {
	return parseFloat(x);
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	return js.Boot.getClass(o);
};
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
var glslparser = {};
glslparser.Node = function() {
	this.nodeTypeName = Type.getClassName(Type.getClass(this)).split(".").pop();
};
glslparser.Node.__name__ = ["glslparser","Node"];
glslparser.Node.prototype = {
	__class__: glslparser.Node
};
glslparser.TypeSpecifier = function(typeClass,typeName,qualifier,precision) {
	this.typeName = typeName;
	this.typeClass = typeClass;
	this.qualifier = qualifier;
	this.precision = precision;
	glslparser.Node.call(this);
};
glslparser.TypeSpecifier.__name__ = ["glslparser","TypeSpecifier"];
glslparser.TypeSpecifier.__super__ = glslparser.Node;
glslparser.TypeSpecifier.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.TypeSpecifier
});
glslparser.StructSpecifier = function(name,structDeclarations) {
	this.structDeclarations = structDeclarations;
	glslparser.TypeSpecifier.call(this,glslparser.TypeClass.STRUCT,name);
};
glslparser.StructSpecifier.__name__ = ["glslparser","StructSpecifier"];
glslparser.StructSpecifier.__super__ = glslparser.TypeSpecifier;
glslparser.StructSpecifier.prototype = $extend(glslparser.TypeSpecifier.prototype,{
	__class__: glslparser.StructSpecifier
});
glslparser.StructDeclaration = function(typeSpecifier,declarators) {
	this.typeSpecifier = typeSpecifier;
	this.declarators = declarators;
	glslparser.Node.call(this);
};
glslparser.StructDeclaration.__name__ = ["glslparser","StructDeclaration"];
glslparser.StructDeclaration.__super__ = glslparser.Node;
glslparser.StructDeclaration.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.StructDeclaration
});
glslparser.StructDeclarator = function(name) {
	this.name = name;
	glslparser.Node.call(this);
};
glslparser.StructDeclarator.__name__ = ["glslparser","StructDeclarator"];
glslparser.StructDeclarator.__super__ = glslparser.Node;
glslparser.StructDeclarator.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.StructDeclarator
});
glslparser.StructArrayDeclarator = function(name,arraySizeExpression) {
	this.arraySizeExpression = arraySizeExpression;
	glslparser.StructDeclarator.call(this,name);
};
glslparser.StructArrayDeclarator.__name__ = ["glslparser","StructArrayDeclarator"];
glslparser.StructArrayDeclarator.__super__ = glslparser.StructDeclarator;
glslparser.StructArrayDeclarator.prototype = $extend(glslparser.StructDeclarator.prototype,{
	__class__: glslparser.StructArrayDeclarator
});
glslparser.Expression = function() {
	glslparser.Node.call(this);
};
glslparser.Expression.__name__ = ["glslparser","Expression"];
glslparser.Expression.__super__ = glslparser.Node;
glslparser.Expression.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.Expression
});
glslparser.Identifier = function(name) {
	this.name = name;
	glslparser.Expression.call(this);
};
glslparser.Identifier.__name__ = ["glslparser","Identifier"];
glslparser.Identifier.__super__ = glslparser.Expression;
glslparser.Identifier.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.Identifier
});
glslparser.Literal = function(value,raw,typeClass) {
	this.value = value;
	this.raw = raw;
	this.typeClass = typeClass;
	glslparser.Expression.call(this);
};
glslparser.Literal.__name__ = ["glslparser","Literal"];
glslparser.Literal.__super__ = glslparser.Expression;
glslparser.Literal.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.Literal
});
glslparser.BinaryExpression = function(op,left,right) {
	this.op = op;
	this.left = left;
	this.right = right;
	glslparser.Expression.call(this);
};
glslparser.BinaryExpression.__name__ = ["glslparser","BinaryExpression"];
glslparser.BinaryExpression.__super__ = glslparser.Expression;
glslparser.BinaryExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.BinaryExpression
});
glslparser.UnaryExpression = function(op,arg,isPrefix) {
	this.op = op;
	this.arg = arg;
	this.isPrefix = isPrefix;
	glslparser.Expression.call(this);
};
glslparser.UnaryExpression.__name__ = ["glslparser","UnaryExpression"];
glslparser.UnaryExpression.__super__ = glslparser.Expression;
glslparser.UnaryExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.UnaryExpression
});
glslparser.SequenceExpression = function(expressions) {
	this.expressions = expressions;
	glslparser.Expression.call(this);
};
glslparser.SequenceExpression.__name__ = ["glslparser","SequenceExpression"];
glslparser.SequenceExpression.__super__ = glslparser.Expression;
glslparser.SequenceExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.SequenceExpression
});
glslparser.ConditionalExpression = function(test,consequent,alternate) {
	this.test = test;
	this.consequent = consequent;
	this.alternate = alternate;
	glslparser.Expression.call(this);
};
glslparser.ConditionalExpression.__name__ = ["glslparser","ConditionalExpression"];
glslparser.ConditionalExpression.__super__ = glslparser.Expression;
glslparser.ConditionalExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.ConditionalExpression
});
glslparser.AssignmentExpression = function(op,left,right) {
	this.op = op;
	this.left = left;
	this.right = right;
	glslparser.Expression.call(this);
};
glslparser.AssignmentExpression.__name__ = ["glslparser","AssignmentExpression"];
glslparser.AssignmentExpression.__super__ = glslparser.Expression;
glslparser.AssignmentExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.AssignmentExpression
});
glslparser.FieldSelectionExpression = function(left,field) {
	this.left = left;
	this.field = field;
	glslparser.Expression.call(this);
};
glslparser.FieldSelectionExpression.__name__ = ["glslparser","FieldSelectionExpression"];
glslparser.FieldSelectionExpression.__super__ = glslparser.Expression;
glslparser.FieldSelectionExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.FieldSelectionExpression
});
glslparser.ArrayElementSelectionExpression = function(left,arrayIndexExpression) {
	this.left = left;
	this.arrayIndexExpression = arrayIndexExpression;
	glslparser.Expression.call(this);
};
glslparser.ArrayElementSelectionExpression.__name__ = ["glslparser","ArrayElementSelectionExpression"];
glslparser.ArrayElementSelectionExpression.__super__ = glslparser.Expression;
glslparser.ArrayElementSelectionExpression.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.ArrayElementSelectionExpression
});
glslparser.FunctionCall = function(name,parameters,constructor) {
	if(constructor == null) constructor = false;
	this.name = name;
	if(parameters != null) this.parameters = parameters; else this.parameters = [];
	this.constructor = constructor;
	glslparser.Expression.call(this);
};
glslparser.FunctionCall.__name__ = ["glslparser","FunctionCall"];
glslparser.FunctionCall.__super__ = glslparser.Expression;
glslparser.FunctionCall.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.FunctionCall
});
glslparser.Declaration = function() {
	glslparser.Expression.call(this);
};
glslparser.Declaration.__name__ = ["glslparser","Declaration"];
glslparser.Declaration.__super__ = glslparser.Expression;
glslparser.Declaration.prototype = $extend(glslparser.Expression.prototype,{
	__class__: glslparser.Declaration
});
glslparser.PrecisionDeclaration = function(precision,typeSpecifier) {
	this.precision = precision;
	this.typeSpecifier = typeSpecifier;
	glslparser.Declaration.call(this);
};
glslparser.PrecisionDeclaration.__name__ = ["glslparser","PrecisionDeclaration"];
glslparser.PrecisionDeclaration.__super__ = glslparser.Declaration;
glslparser.PrecisionDeclaration.prototype = $extend(glslparser.Declaration.prototype,{
	__class__: glslparser.PrecisionDeclaration
});
glslparser.VariableDeclaration = function(typeSpecifier,declarators) {
	this.typeSpecifier = typeSpecifier;
	this.declarators = declarators;
	glslparser.Declaration.call(this);
};
glslparser.VariableDeclaration.__name__ = ["glslparser","VariableDeclaration"];
glslparser.VariableDeclaration.__super__ = glslparser.Declaration;
glslparser.VariableDeclaration.prototype = $extend(glslparser.Declaration.prototype,{
	__class__: glslparser.VariableDeclaration
});
glslparser.Declarator = function(name,initializer,invariant) {
	if(invariant == null) invariant = false;
	this.name = name;
	this.initializer = initializer;
	this.invariant = invariant;
	glslparser.Node.call(this);
};
glslparser.Declarator.__name__ = ["glslparser","Declarator"];
glslparser.Declarator.__super__ = glslparser.Node;
glslparser.Declarator.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.Declarator
});
glslparser.ArrayDeclarator = function(name,arraySizeExpression) {
	this.arraySizeExpression = arraySizeExpression;
	glslparser.Declarator.call(this,name,null,false);
};
glslparser.ArrayDeclarator.__name__ = ["glslparser","ArrayDeclarator"];
glslparser.ArrayDeclarator.__super__ = glslparser.Declarator;
glslparser.ArrayDeclarator.prototype = $extend(glslparser.Declarator.prototype,{
	__class__: glslparser.ArrayDeclarator
});
glslparser.ParameterDeclaration = function(name,typeSpecifier,parameterQualifier,typeQualifier,arraySizeExpression) {
	this.name = name;
	this.typeSpecifier = typeSpecifier;
	this.parameterQualifier = parameterQualifier;
	this.typeQualifier = typeQualifier;
	this.arraySizeExpression = arraySizeExpression;
	glslparser.Declaration.call(this);
};
glslparser.ParameterDeclaration.__name__ = ["glslparser","ParameterDeclaration"];
glslparser.ParameterDeclaration.__super__ = glslparser.Declaration;
glslparser.ParameterDeclaration.prototype = $extend(glslparser.Declaration.prototype,{
	__class__: glslparser.ParameterDeclaration
});
glslparser.FunctionDefinition = function(header,body) {
	this.header = header;
	this.body = body;
	glslparser.Declaration.call(this);
};
glslparser.FunctionDefinition.__name__ = ["glslparser","FunctionDefinition"];
glslparser.FunctionDefinition.__super__ = glslparser.Declaration;
glslparser.FunctionDefinition.prototype = $extend(glslparser.Declaration.prototype,{
	__class__: glslparser.FunctionDefinition
});
glslparser.FunctionPrototype = function(header) {
	this.header = header;
	glslparser.Declaration.call(this);
};
glslparser.FunctionPrototype.__name__ = ["glslparser","FunctionPrototype"];
glslparser.FunctionPrototype.__super__ = glslparser.Declaration;
glslparser.FunctionPrototype.prototype = $extend(glslparser.Declaration.prototype,{
	__class__: glslparser.FunctionPrototype
});
glslparser.FunctionHeader = function(name,returnType,parameters) {
	this.name = name;
	this.returnType = returnType;
	if(parameters != null) this.parameters = parameters; else this.parameters = [];
	glslparser.Node.call(this);
};
glslparser.FunctionHeader.__name__ = ["glslparser","FunctionHeader"];
glslparser.FunctionHeader.__super__ = glslparser.Node;
glslparser.FunctionHeader.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.FunctionHeader
});
glslparser.Statement = function(newScope) {
	this.newScope = newScope;
	glslparser.Node.call(this);
};
glslparser.Statement.__name__ = ["glslparser","Statement"];
glslparser.Statement.__super__ = glslparser.Node;
glslparser.Statement.prototype = $extend(glslparser.Node.prototype,{
	__class__: glslparser.Statement
});
glslparser.CompoundStatement = function(statementList,newScope) {
	this.statementList = statementList;
	glslparser.Statement.call(this,newScope);
};
glslparser.CompoundStatement.__name__ = ["glslparser","CompoundStatement"];
glslparser.CompoundStatement.__super__ = glslparser.Statement;
glslparser.CompoundStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.CompoundStatement
});
glslparser.DeclarationStatement = function(declaration) {
	this.declaration = declaration;
	glslparser.Statement.call(this,false);
};
glslparser.DeclarationStatement.__name__ = ["glslparser","DeclarationStatement"];
glslparser.DeclarationStatement.__super__ = glslparser.Statement;
glslparser.DeclarationStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.DeclarationStatement
});
glslparser.ExpressionStatement = function(expression) {
	this.expression = expression;
	glslparser.Statement.call(this,false);
};
glslparser.ExpressionStatement.__name__ = ["glslparser","ExpressionStatement"];
glslparser.ExpressionStatement.__super__ = glslparser.Statement;
glslparser.ExpressionStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.ExpressionStatement
});
glslparser.IterationStatement = function(body) {
	this.body = body;
	glslparser.Statement.call(this,false);
};
glslparser.IterationStatement.__name__ = ["glslparser","IterationStatement"];
glslparser.IterationStatement.__super__ = glslparser.Statement;
glslparser.IterationStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.IterationStatement
});
glslparser.WhileStatement = function(test,body) {
	this.test = test;
	glslparser.IterationStatement.call(this,body);
};
glslparser.WhileStatement.__name__ = ["glslparser","WhileStatement"];
glslparser.WhileStatement.__super__ = glslparser.IterationStatement;
glslparser.WhileStatement.prototype = $extend(glslparser.IterationStatement.prototype,{
	__class__: glslparser.WhileStatement
});
glslparser.DoWhileStatement = function(test,body) {
	this.test = test;
	glslparser.IterationStatement.call(this,body);
};
glslparser.DoWhileStatement.__name__ = ["glslparser","DoWhileStatement"];
glslparser.DoWhileStatement.__super__ = glslparser.IterationStatement;
glslparser.DoWhileStatement.prototype = $extend(glslparser.IterationStatement.prototype,{
	__class__: glslparser.DoWhileStatement
});
glslparser.ForStatement = function(init,test,update,body) {
	this.init = init;
	this.test = test;
	this.update = update;
	glslparser.IterationStatement.call(this,body);
};
glslparser.ForStatement.__name__ = ["glslparser","ForStatement"];
glslparser.ForStatement.__super__ = glslparser.IterationStatement;
glslparser.ForStatement.prototype = $extend(glslparser.IterationStatement.prototype,{
	__class__: glslparser.ForStatement
});
glslparser.IfStatement = function(test,consequent,alternate) {
	this.test = test;
	this.consequent = consequent;
	this.alternate = alternate;
	glslparser.Statement.call(this,false);
};
glslparser.IfStatement.__name__ = ["glslparser","IfStatement"];
glslparser.IfStatement.__super__ = glslparser.Statement;
glslparser.IfStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.IfStatement
});
glslparser.JumpStatement = function(mode) {
	this.mode = mode;
	glslparser.Statement.call(this,false);
};
glslparser.JumpStatement.__name__ = ["glslparser","JumpStatement"];
glslparser.JumpStatement.__super__ = glslparser.Statement;
glslparser.JumpStatement.prototype = $extend(glslparser.Statement.prototype,{
	__class__: glslparser.JumpStatement
});
glslparser.ReturnStatement = function(returnValue) {
	this.returnValue = returnValue;
	glslparser.JumpStatement.call(this,glslparser.JumpMode.RETURN);
};
glslparser.ReturnStatement.__name__ = ["glslparser","ReturnStatement"];
glslparser.ReturnStatement.__super__ = glslparser.JumpStatement;
glslparser.ReturnStatement.prototype = $extend(glslparser.JumpStatement.prototype,{
	__class__: glslparser.ReturnStatement
});
glslparser.BinaryOperator = { __ename__ : true, __constructs__ : ["STAR","SLASH","PERCENT","PLUS","DASH","LEFT_OP","RIGHT_OP","LEFT_ANGLE","RIGHT_ANGLE","LE_OP","GE_OP","EQ_OP","NE_OP","AMPERSAND","CARET","VERTICAL_BAR","AND_OP","XOR_OP","OR_OP"] };
glslparser.BinaryOperator.STAR = ["STAR",0];
glslparser.BinaryOperator.STAR.toString = $estr;
glslparser.BinaryOperator.STAR.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.SLASH = ["SLASH",1];
glslparser.BinaryOperator.SLASH.toString = $estr;
glslparser.BinaryOperator.SLASH.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.PERCENT = ["PERCENT",2];
glslparser.BinaryOperator.PERCENT.toString = $estr;
glslparser.BinaryOperator.PERCENT.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.PLUS = ["PLUS",3];
glslparser.BinaryOperator.PLUS.toString = $estr;
glslparser.BinaryOperator.PLUS.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.DASH = ["DASH",4];
glslparser.BinaryOperator.DASH.toString = $estr;
glslparser.BinaryOperator.DASH.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.LEFT_OP = ["LEFT_OP",5];
glslparser.BinaryOperator.LEFT_OP.toString = $estr;
glslparser.BinaryOperator.LEFT_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.RIGHT_OP = ["RIGHT_OP",6];
glslparser.BinaryOperator.RIGHT_OP.toString = $estr;
glslparser.BinaryOperator.RIGHT_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.LEFT_ANGLE = ["LEFT_ANGLE",7];
glslparser.BinaryOperator.LEFT_ANGLE.toString = $estr;
glslparser.BinaryOperator.LEFT_ANGLE.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.RIGHT_ANGLE = ["RIGHT_ANGLE",8];
glslparser.BinaryOperator.RIGHT_ANGLE.toString = $estr;
glslparser.BinaryOperator.RIGHT_ANGLE.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.LE_OP = ["LE_OP",9];
glslparser.BinaryOperator.LE_OP.toString = $estr;
glslparser.BinaryOperator.LE_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.GE_OP = ["GE_OP",10];
glslparser.BinaryOperator.GE_OP.toString = $estr;
glslparser.BinaryOperator.GE_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.EQ_OP = ["EQ_OP",11];
glslparser.BinaryOperator.EQ_OP.toString = $estr;
glslparser.BinaryOperator.EQ_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.NE_OP = ["NE_OP",12];
glslparser.BinaryOperator.NE_OP.toString = $estr;
glslparser.BinaryOperator.NE_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.AMPERSAND = ["AMPERSAND",13];
glslparser.BinaryOperator.AMPERSAND.toString = $estr;
glslparser.BinaryOperator.AMPERSAND.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.CARET = ["CARET",14];
glslparser.BinaryOperator.CARET.toString = $estr;
glslparser.BinaryOperator.CARET.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.VERTICAL_BAR = ["VERTICAL_BAR",15];
glslparser.BinaryOperator.VERTICAL_BAR.toString = $estr;
glslparser.BinaryOperator.VERTICAL_BAR.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.AND_OP = ["AND_OP",16];
glslparser.BinaryOperator.AND_OP.toString = $estr;
glslparser.BinaryOperator.AND_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.XOR_OP = ["XOR_OP",17];
glslparser.BinaryOperator.XOR_OP.toString = $estr;
glslparser.BinaryOperator.XOR_OP.__enum__ = glslparser.BinaryOperator;
glslparser.BinaryOperator.OR_OP = ["OR_OP",18];
glslparser.BinaryOperator.OR_OP.toString = $estr;
glslparser.BinaryOperator.OR_OP.__enum__ = glslparser.BinaryOperator;
glslparser.UnaryOperator = { __ename__ : true, __constructs__ : ["INC_OP","DEC_OP","PLUS","DASH","BANG","TILDE"] };
glslparser.UnaryOperator.INC_OP = ["INC_OP",0];
glslparser.UnaryOperator.INC_OP.toString = $estr;
glslparser.UnaryOperator.INC_OP.__enum__ = glslparser.UnaryOperator;
glslparser.UnaryOperator.DEC_OP = ["DEC_OP",1];
glslparser.UnaryOperator.DEC_OP.toString = $estr;
glslparser.UnaryOperator.DEC_OP.__enum__ = glslparser.UnaryOperator;
glslparser.UnaryOperator.PLUS = ["PLUS",2];
glslparser.UnaryOperator.PLUS.toString = $estr;
glslparser.UnaryOperator.PLUS.__enum__ = glslparser.UnaryOperator;
glslparser.UnaryOperator.DASH = ["DASH",3];
glslparser.UnaryOperator.DASH.toString = $estr;
glslparser.UnaryOperator.DASH.__enum__ = glslparser.UnaryOperator;
glslparser.UnaryOperator.BANG = ["BANG",4];
glslparser.UnaryOperator.BANG.toString = $estr;
glslparser.UnaryOperator.BANG.__enum__ = glslparser.UnaryOperator;
glslparser.UnaryOperator.TILDE = ["TILDE",5];
glslparser.UnaryOperator.TILDE.toString = $estr;
glslparser.UnaryOperator.TILDE.__enum__ = glslparser.UnaryOperator;
glslparser.AssignmentOperator = { __ename__ : true, __constructs__ : ["EQUAL","MUL_ASSIGN","DIV_ASSIGN","MOD_ASSIGN","ADD_ASSIGN","SUB_ASSIGN","LEFT_ASSIGN","RIGHT_ASSIGN","AND_ASSIGN","XOR_ASSIGN","OR_ASSIGN"] };
glslparser.AssignmentOperator.EQUAL = ["EQUAL",0];
glslparser.AssignmentOperator.EQUAL.toString = $estr;
glslparser.AssignmentOperator.EQUAL.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.MUL_ASSIGN = ["MUL_ASSIGN",1];
glslparser.AssignmentOperator.MUL_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.MUL_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.DIV_ASSIGN = ["DIV_ASSIGN",2];
glslparser.AssignmentOperator.DIV_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.DIV_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.MOD_ASSIGN = ["MOD_ASSIGN",3];
glslparser.AssignmentOperator.MOD_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.MOD_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.ADD_ASSIGN = ["ADD_ASSIGN",4];
glslparser.AssignmentOperator.ADD_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.ADD_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.SUB_ASSIGN = ["SUB_ASSIGN",5];
glslparser.AssignmentOperator.SUB_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.SUB_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.LEFT_ASSIGN = ["LEFT_ASSIGN",6];
glslparser.AssignmentOperator.LEFT_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.LEFT_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.RIGHT_ASSIGN = ["RIGHT_ASSIGN",7];
glslparser.AssignmentOperator.RIGHT_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.RIGHT_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.AND_ASSIGN = ["AND_ASSIGN",8];
glslparser.AssignmentOperator.AND_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.AND_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.XOR_ASSIGN = ["XOR_ASSIGN",9];
glslparser.AssignmentOperator.XOR_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.XOR_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.AssignmentOperator.OR_ASSIGN = ["OR_ASSIGN",10];
glslparser.AssignmentOperator.OR_ASSIGN.toString = $estr;
glslparser.AssignmentOperator.OR_ASSIGN.__enum__ = glslparser.AssignmentOperator;
glslparser.PrecisionQualifier = { __ename__ : true, __constructs__ : ["HIGH_PRECISION","MEDIUM_PRECISION","LOW_PRECISION"] };
glslparser.PrecisionQualifier.HIGH_PRECISION = ["HIGH_PRECISION",0];
glslparser.PrecisionQualifier.HIGH_PRECISION.toString = $estr;
glslparser.PrecisionQualifier.HIGH_PRECISION.__enum__ = glslparser.PrecisionQualifier;
glslparser.PrecisionQualifier.MEDIUM_PRECISION = ["MEDIUM_PRECISION",1];
glslparser.PrecisionQualifier.MEDIUM_PRECISION.toString = $estr;
glslparser.PrecisionQualifier.MEDIUM_PRECISION.__enum__ = glslparser.PrecisionQualifier;
glslparser.PrecisionQualifier.LOW_PRECISION = ["LOW_PRECISION",2];
glslparser.PrecisionQualifier.LOW_PRECISION.toString = $estr;
glslparser.PrecisionQualifier.LOW_PRECISION.__enum__ = glslparser.PrecisionQualifier;
glslparser.JumpMode = { __ename__ : true, __constructs__ : ["CONTINUE","BREAK","RETURN","DISCARD"] };
glslparser.JumpMode.CONTINUE = ["CONTINUE",0];
glslparser.JumpMode.CONTINUE.toString = $estr;
glslparser.JumpMode.CONTINUE.__enum__ = glslparser.JumpMode;
glslparser.JumpMode.BREAK = ["BREAK",1];
glslparser.JumpMode.BREAK.toString = $estr;
glslparser.JumpMode.BREAK.__enum__ = glslparser.JumpMode;
glslparser.JumpMode.RETURN = ["RETURN",2];
glslparser.JumpMode.RETURN.toString = $estr;
glslparser.JumpMode.RETURN.__enum__ = glslparser.JumpMode;
glslparser.JumpMode.DISCARD = ["DISCARD",3];
glslparser.JumpMode.DISCARD.toString = $estr;
glslparser.JumpMode.DISCARD.__enum__ = glslparser.JumpMode;
glslparser.TypeClass = { __ename__ : true, __constructs__ : ["VOID","FLOAT","INT","BOOL","VEC2","VEC3","VEC4","BVEC2","BVEC3","BVEC4","IVEC2","IVEC3","IVEC4","MAT2","MAT3","MAT4","SAMPLER2D","SAMPLERCUBE","STRUCT","TYPE_NAME"] };
glslparser.TypeClass.VOID = ["VOID",0];
glslparser.TypeClass.VOID.toString = $estr;
glslparser.TypeClass.VOID.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.FLOAT = ["FLOAT",1];
glslparser.TypeClass.FLOAT.toString = $estr;
glslparser.TypeClass.FLOAT.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.INT = ["INT",2];
glslparser.TypeClass.INT.toString = $estr;
glslparser.TypeClass.INT.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.BOOL = ["BOOL",3];
glslparser.TypeClass.BOOL.toString = $estr;
glslparser.TypeClass.BOOL.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.VEC2 = ["VEC2",4];
glslparser.TypeClass.VEC2.toString = $estr;
glslparser.TypeClass.VEC2.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.VEC3 = ["VEC3",5];
glslparser.TypeClass.VEC3.toString = $estr;
glslparser.TypeClass.VEC3.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.VEC4 = ["VEC4",6];
glslparser.TypeClass.VEC4.toString = $estr;
glslparser.TypeClass.VEC4.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.BVEC2 = ["BVEC2",7];
glslparser.TypeClass.BVEC2.toString = $estr;
glslparser.TypeClass.BVEC2.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.BVEC3 = ["BVEC3",8];
glslparser.TypeClass.BVEC3.toString = $estr;
glslparser.TypeClass.BVEC3.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.BVEC4 = ["BVEC4",9];
glslparser.TypeClass.BVEC4.toString = $estr;
glslparser.TypeClass.BVEC4.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.IVEC2 = ["IVEC2",10];
glslparser.TypeClass.IVEC2.toString = $estr;
glslparser.TypeClass.IVEC2.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.IVEC3 = ["IVEC3",11];
glslparser.TypeClass.IVEC3.toString = $estr;
glslparser.TypeClass.IVEC3.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.IVEC4 = ["IVEC4",12];
glslparser.TypeClass.IVEC4.toString = $estr;
glslparser.TypeClass.IVEC4.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.MAT2 = ["MAT2",13];
glslparser.TypeClass.MAT2.toString = $estr;
glslparser.TypeClass.MAT2.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.MAT3 = ["MAT3",14];
glslparser.TypeClass.MAT3.toString = $estr;
glslparser.TypeClass.MAT3.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.MAT4 = ["MAT4",15];
glslparser.TypeClass.MAT4.toString = $estr;
glslparser.TypeClass.MAT4.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.SAMPLER2D = ["SAMPLER2D",16];
glslparser.TypeClass.SAMPLER2D.toString = $estr;
glslparser.TypeClass.SAMPLER2D.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.SAMPLERCUBE = ["SAMPLERCUBE",17];
glslparser.TypeClass.SAMPLERCUBE.toString = $estr;
glslparser.TypeClass.SAMPLERCUBE.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.STRUCT = ["STRUCT",18];
glslparser.TypeClass.STRUCT.toString = $estr;
glslparser.TypeClass.STRUCT.__enum__ = glslparser.TypeClass;
glslparser.TypeClass.TYPE_NAME = ["TYPE_NAME",19];
glslparser.TypeClass.TYPE_NAME.toString = $estr;
glslparser.TypeClass.TYPE_NAME.__enum__ = glslparser.TypeClass;
glslparser.ParameterQualifier = { __ename__ : true, __constructs__ : ["IN","OUT","INOUT"] };
glslparser.ParameterQualifier.IN = ["IN",0];
glslparser.ParameterQualifier.IN.toString = $estr;
glslparser.ParameterQualifier.IN.__enum__ = glslparser.ParameterQualifier;
glslparser.ParameterQualifier.OUT = ["OUT",1];
glslparser.ParameterQualifier.OUT.toString = $estr;
glslparser.ParameterQualifier.OUT.__enum__ = glslparser.ParameterQualifier;
glslparser.ParameterQualifier.INOUT = ["INOUT",2];
glslparser.ParameterQualifier.INOUT.toString = $estr;
glslparser.ParameterQualifier.INOUT.__enum__ = glslparser.ParameterQualifier;
glslparser.TypeQualifier = { __ename__ : true, __constructs__ : ["CONST","ATTRIBUTE","VARYING","INVARIANT_VARYING","UNIFORM"] };
glslparser.TypeQualifier.CONST = ["CONST",0];
glslparser.TypeQualifier.CONST.toString = $estr;
glslparser.TypeQualifier.CONST.__enum__ = glslparser.TypeQualifier;
glslparser.TypeQualifier.ATTRIBUTE = ["ATTRIBUTE",1];
glslparser.TypeQualifier.ATTRIBUTE.toString = $estr;
glslparser.TypeQualifier.ATTRIBUTE.__enum__ = glslparser.TypeQualifier;
glslparser.TypeQualifier.VARYING = ["VARYING",2];
glslparser.TypeQualifier.VARYING.toString = $estr;
glslparser.TypeQualifier.VARYING.__enum__ = glslparser.TypeQualifier;
glslparser.TypeQualifier.INVARIANT_VARYING = ["INVARIANT_VARYING",3];
glslparser.TypeQualifier.INVARIANT_VARYING.toString = $estr;
glslparser.TypeQualifier.INVARIANT_VARYING.__enum__ = glslparser.TypeQualifier;
glslparser.TypeQualifier.UNIFORM = ["UNIFORM",4];
glslparser.TypeQualifier.UNIFORM.toString = $estr;
glslparser.TypeQualifier.UNIFORM.__enum__ = glslparser.TypeQualifier;
glslparser.Eval = function() { };
glslparser.Eval.__name__ = ["glslparser","Eval"];
glslparser.Eval.evaluateConstantExpressions = function(ast) {
	glslparser.Eval.variables = new haxe.ds.StringMap();
	glslparser.Eval.iterate(ast);
};
glslparser.Eval.iterate = function(node) {
	var _g = Type.getClass(node);
	switch(_g) {
	case Array:
		var _;
		_ = js.Boot.__cast(node , Array);
		var _g2 = 0;
		var _g1 = _.length;
		while(_g2 < _g1) {
			var i = _g2++;
			glslparser.Eval.iterate(_[i]);
		}
		break;
	case glslparser.VariableDeclaration:
		var _1;
		_1 = js.Boot.__cast(node , glslparser.VariableDeclaration);
		glslparser.Eval.iterate(_1.typeSpecifier);
		if(_1.typeSpecifier.qualifier == glslparser.TypeQualifier.CONST) {
			var _g21 = 0;
			var _g11 = _1.declarators.length;
			while(_g21 < _g11) {
				var i1 = _g21++;
				glslparser.Eval.defineConst(_1.declarators[i1]);
			}
		}
		break;
	case glslparser.StructSpecifier:
		var _2;
		_2 = js.Boot.__cast(node , glslparser.StructSpecifier);
		glslparser.Eval.defineType(_2);
		glslparser.Eval.iterate(_2.structDeclarations);
		break;
	case glslparser.StructDeclaration:
		var _3;
		_3 = js.Boot.__cast(node , glslparser.StructDeclaration);
		glslparser.Eval.iterate(_3.typeSpecifier);
		break;
	default:
		console.log("default case");
	}
};
glslparser.Eval.resolveExpression = function(expr) {
	var _g = Type.getClass(expr);
	switch(_g) {
	case glslparser.Literal:
		var _;
		_ = js.Boot.__cast(expr , glslparser.Literal);
		return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(_);
	case glslparser.FunctionCall:
		var _1;
		_1 = js.Boot.__cast(expr , glslparser.FunctionCall);
		return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(_1);
	case glslparser.Identifier:
		var _2;
		_2 = js.Boot.__cast(expr , glslparser.Identifier);
		var e = glslparser.Eval.variables.get(_2.name);
		if(e == null) glslparser.Eval.warn("" + _2.name + " has not been defined in this scope");
		return glslparser.Eval.resolveExpression(e);
	case glslparser.BinaryExpression:
		var _3;
		_3 = js.Boot.__cast(expr , glslparser.BinaryExpression);
		return glslparser.Eval.resolveBinaryExpression(_3);
	case glslparser.UnaryExpression:
		var _4;
		_4 = js.Boot.__cast(expr , glslparser.UnaryExpression);
		break;
	case glslparser.SequenceExpression:
		var _5;
		_5 = js.Boot.__cast(expr , glslparser.SequenceExpression);
		break;
	case glslparser.ConditionalExpression:
		var _6;
		_6 = js.Boot.__cast(expr , glslparser.ConditionalExpression);
		break;
	case glslparser.AssignmentExpression:
		var _7;
		_7 = js.Boot.__cast(expr , glslparser.AssignmentExpression);
		break;
	case glslparser.FieldSelectionExpression:
		var _8;
		_8 = js.Boot.__cast(expr , glslparser.FieldSelectionExpression);
		break;
	}
	glslparser.Eval.error("cannot resolve expression " + Std.string(expr));
	return null;
};
glslparser.Eval.resolveBinaryExpression = function(binExpr) {
	var left = glslparser.Eval.resolveExpression(binExpr.left);
	var right = glslparser.Eval.resolveExpression(binExpr.right);
	var op = binExpr.op;
	var leftType = glslparser._Eval.GLSLBasicExpr_Impl_.toGLSLBasicType(left);
	var rightType = glslparser._Eval.GLSLBasicExpr_Impl_.toGLSLBasicType(right);
	{
		var _g = glslparser.OpType.BinOp(leftType,rightType,op);
		switch(_g[1]) {
		case 0:
			switch(_g[2][1]) {
			case 0:
				switch(_g[2][2][1]) {
				case 2:
					switch(_g[3][1]) {
					case 0:
						switch(_g[3][2][1]) {
						case 2:
							switch(_g[4][1]) {
							case 0:
								var rv = _g[3][3];
								var lv = _g[2][3];
								var r = Math.floor(lv * rv);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r,glslparser.Eval.glslFloatInt(r),glslparser.TypeClass.INT));
							case 1:
								var rv1 = _g[3][3];
								var lv1 = _g[2][3];
								var r1 = Math.floor(lv1 / rv1);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r1,glslparser.Eval.glslFloatInt(r1),glslparser.TypeClass.INT));
							case 2:
								var rv2 = _g[3][3];
								var lv2 = _g[2][3];
								var r2 = Math.floor(lv2 % rv2);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r2,glslparser.Eval.glslFloatInt(r2),glslparser.TypeClass.INT));
							case 3:
								var rv3 = _g[3][3];
								var lv3 = _g[2][3];
								var r3 = Math.floor(lv3 + rv3);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r3,glslparser.Eval.glslFloatInt(r3),glslparser.TypeClass.INT));
							case 4:
								var rv4 = _g[3][3];
								var lv4 = _g[2][3];
								var r4 = Math.floor(lv4 - rv4);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r4,glslparser.Eval.glslFloatInt(r4),glslparser.TypeClass.INT));
							case 7:
								var rv5 = _g[3][3];
								var lv5 = _g[2][3];
								var r5 = lv5 < rv5;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r5,glslparser.Eval.glslBoolString(r5),glslparser.TypeClass.BOOL));
							case 8:
								var rv6 = _g[3][3];
								var lv6 = _g[2][3];
								var r6 = lv6 > rv6;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r6,glslparser.Eval.glslBoolString(r6),glslparser.TypeClass.BOOL));
							case 9:
								var rv7 = _g[3][3];
								var lv7 = _g[2][3];
								var r7 = lv7 <= rv7;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r7,glslparser.Eval.glslBoolString(r7),glslparser.TypeClass.BOOL));
							case 10:
								var rv8 = _g[3][3];
								var lv8 = _g[2][3];
								var r8 = lv8 >= rv8;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r8,glslparser.Eval.glslBoolString(r8),glslparser.TypeClass.BOOL));
							case 11:
								var rv9 = _g[3][3];
								var lv9 = _g[2][3];
								var r9 = lv9 == rv9;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r9,glslparser.Eval.glslBoolString(r9),glslparser.TypeClass.BOOL));
							case 12:
								var rv10 = _g[3][3];
								var lv10 = _g[2][3];
								var r10 = lv10 != rv10;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r10,glslparser.Eval.glslBoolString(r10),glslparser.TypeClass.BOOL));
							case 5:
								var rv11 = _g[3][3];
								var lv11 = _g[2][3];
								var r11 = Math.floor(lv11 << rv11);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r11,glslparser.Eval.glslFloatInt(r11),glslparser.TypeClass.INT));
							case 6:
								var rv12 = _g[3][3];
								var lv12 = _g[2][3];
								var r12 = Math.floor(lv12 >> rv12);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r12,glslparser.Eval.glslFloatInt(r12),glslparser.TypeClass.INT));
							case 13:
								var rv13 = _g[3][3];
								var lv13 = _g[2][3];
								var r13 = Math.floor(lv13 & rv13);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r13,glslparser.Eval.glslFloatInt(r13),glslparser.TypeClass.INT));
							case 14:
								var rv14 = _g[3][3];
								var lv14 = _g[2][3];
								var r14 = Math.floor(lv14 ^ rv14);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r14,glslparser.Eval.glslFloatInt(r14),glslparser.TypeClass.INT));
							case 15:
								var rv15 = _g[3][3];
								var lv15 = _g[2][3];
								var r15 = Math.floor(lv15 | rv15);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r15,glslparser.Eval.glslFloatInt(r15),glslparser.TypeClass.INT));
							default:
							}
							break;
						default:
						}
						break;
					default:
					}
					break;
				case 1:
					switch(_g[3][1]) {
					case 0:
						switch(_g[3][2][1]) {
						case 1:
							switch(_g[4][1]) {
							case 0:
								var rv16 = _g[3][3];
								var lv16 = _g[2][3];
								var r16 = lv16 * rv16;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r16,glslparser.Eval.glslFloatString(r16),glslparser.TypeClass.FLOAT));
							case 1:
								var rv17 = _g[3][3];
								var lv17 = _g[2][3];
								var r17 = lv17 / rv17;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r17,glslparser.Eval.glslFloatString(r17),glslparser.TypeClass.FLOAT));
							case 2:
								var rv18 = _g[3][3];
								var lv18 = _g[2][3];
								var r18 = Math.floor(lv18 % rv18);
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r18,glslparser.Eval.glslFloatString(r18),glslparser.TypeClass.FLOAT));
							case 3:
								var rv19 = _g[3][3];
								var lv19 = _g[2][3];
								var r19 = lv19 + rv19;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r19,glslparser.Eval.glslFloatString(r19),glslparser.TypeClass.FLOAT));
							case 4:
								var rv20 = _g[3][3];
								var lv20 = _g[2][3];
								var r20 = lv20 - rv20;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r20,glslparser.Eval.glslFloatString(r20),glslparser.TypeClass.FLOAT));
							case 7:
								var rv21 = _g[3][3];
								var lv21 = _g[2][3];
								var r21 = lv21 < rv21;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r21,glslparser.Eval.glslBoolString(r21),glslparser.TypeClass.BOOL));
							case 8:
								var rv22 = _g[3][3];
								var lv22 = _g[2][3];
								var r22 = lv22 > rv22;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r22,glslparser.Eval.glslBoolString(r22),glslparser.TypeClass.BOOL));
							case 9:
								var rv23 = _g[3][3];
								var lv23 = _g[2][3];
								var r23 = lv23 <= rv23;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r23,glslparser.Eval.glslBoolString(r23),glslparser.TypeClass.BOOL));
							case 10:
								var rv24 = _g[3][3];
								var lv24 = _g[2][3];
								var r24 = lv24 >= rv24;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r24,glslparser.Eval.glslBoolString(r24),glslparser.TypeClass.BOOL));
							case 11:
								var rv25 = _g[3][3];
								var lv25 = _g[2][3];
								var r25 = lv25 == rv25;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r25,glslparser.Eval.glslBoolString(r25),glslparser.TypeClass.BOOL));
							case 12:
								var rv26 = _g[3][3];
								var lv26 = _g[2][3];
								var r26 = lv26 != rv26;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r26,glslparser.Eval.glslBoolString(r26),glslparser.TypeClass.BOOL));
							default:
							}
							break;
						default:
						}
						break;
					default:
					}
					break;
				case 3:
					switch(_g[3][1]) {
					case 0:
						switch(_g[3][2][1]) {
						case 3:
							switch(_g[4][1]) {
							case 11:
								var rv27 = _g[3][3];
								var lv27 = _g[2][3];
								var r27 = lv27 == rv27;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r27,glslparser.Eval.glslBoolString(r27),glslparser.TypeClass.BOOL));
							case 16:
								var rv28 = _g[3][3];
								var lv28 = _g[2][3];
								var r28 = lv28 && rv28;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r28,glslparser.Eval.glslBoolString(r28),glslparser.TypeClass.BOOL));
							case 17:
								var rv29 = _g[3][3];
								var lv29 = _g[2][3];
								var r29 = !lv29 != !rv29;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r29,glslparser.Eval.glslBoolString(r29),glslparser.TypeClass.BOOL));
							case 18:
								var rv30 = _g[3][3];
								var lv30 = _g[2][3];
								var r30 = lv30 || rv30;
								return glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression(new glslparser.Literal(r30,glslparser.Eval.glslBoolString(r30),glslparser.TypeClass.BOOL));
							default:
							}
							break;
						default:
						}
						break;
					default:
					}
					break;
				default:
				}
				break;
			default:
			}
			break;
		default:
		}
	}
	glslparser.Eval.error("could not resolve binary expression " + Std.string(left) + " " + Std.string(op) + " " + Std.string(rightType));
	return null;
};
glslparser.Eval.resolveUnaryExpression = function(unExpr) {
	var arg = glslparser.Eval.resolveExpression(unExpr.arg);
	var op = unExpr.op;
	var argType = glslparser._Eval.GLSLBasicExpr_Impl_.toGLSLBasicType(arg);
	glslparser.Eval.error("could not resolve unary expression " + Std.string(unExpr));
	return null;
};
glslparser.Eval.defineType = function(specifier) {
	console.log("#! define type " + Std.string(specifier));
};
glslparser.Eval.defineConst = function(declarator) {
	console.log("define const " + declarator.name);
	var value = glslparser.Eval.resolveExpression(declarator.initializer);
	glslparser.Eval.variables.set(declarator.name,value);
	console.log(glslparser.Eval.variables.toString());
};
glslparser.Eval.glslFloatString = function(f) {
	var str;
	if(f == null) str = "null"; else str = "" + f;
	var rx = new EReg("\\.","g");
	if(!rx.match(str)) str += ".0";
	return str;
};
glslparser.Eval.glslFloatInt = function(i) {
	var str;
	if(i == null) str = "null"; else str = "" + i;
	var rx = new EReg("(\\d+)\\.","g");
	if(rx.match(str)) str = rx.matched(1);
	if(str == "") str = "0";
	return str;
};
glslparser.Eval.glslBoolString = function(b) {
	if(b == null) return "null"; else return "" + b;
};
glslparser.Eval.warn = function(msg) {
	console.log("Eval warning: " + msg);
};
glslparser.Eval.error = function(msg) {
	throw "Eval error: " + msg;
};
glslparser.OpType = { __ename__ : true, __constructs__ : ["BinOp","UnOp"] };
glslparser.OpType.BinOp = function(l,r,op) { var $x = ["BinOp",0,l,r,op]; $x.__enum__ = glslparser.OpType; $x.toString = $estr; return $x; };
glslparser.OpType.UnOp = function(arg,op,isPrefix) { var $x = ["UnOp",1,arg,op,isPrefix]; $x.__enum__ = glslparser.OpType; $x.toString = $estr; return $x; };
glslparser.GLSLBasicType = { __ename__ : true, __constructs__ : ["LiteralType","FunctionCallType"] };
glslparser.GLSLBasicType.LiteralType = function(t,v) { var $x = ["LiteralType",0,t,v]; $x.__enum__ = glslparser.GLSLBasicType; $x.toString = $estr; return $x; };
glslparser.GLSLBasicType.FunctionCallType = ["FunctionCallType",1];
glslparser.GLSLBasicType.FunctionCallType.toString = $estr;
glslparser.GLSLBasicType.FunctionCallType.__enum__ = glslparser.GLSLBasicType;
glslparser._Eval = {};
glslparser._Eval.GLSLBasicExpr_Impl_ = {};
glslparser._Eval.GLSLBasicExpr_Impl_.__name__ = ["glslparser","_Eval","GLSLBasicExpr_Impl_"];
glslparser._Eval.GLSLBasicExpr_Impl_._new = function(expr) {
	var this1;
	if(!glslparser._Eval.GLSLBasicExpr_Impl_.isFullyresolved(expr)) glslparser.Eval.error("cannot create GLSLBasicExpr; expression is not fully resolved. " + Std.string(expr));
	this1 = expr;
	return this1;
};
glslparser._Eval.GLSLBasicExpr_Impl_.isFullyresolved = function(expr) {
	var _g = Type.getClass(expr);
	switch(_g) {
	case glslparser.Literal:
		return true;
	case glslparser.FunctionCall:
		var _;
		_ = js.Boot.__cast(expr , glslparser.FunctionCall);
		return _.constructor;
	}
	return false;
};
glslparser._Eval.GLSLBasicExpr_Impl_.toGLSLBasicType = function(this1) {
	if(Type.getClass(this1) == glslparser.Literal) {
		var _;
		_ = js.Boot.__cast(this1 , glslparser.Literal);
		return glslparser.GLSLBasicType.LiteralType(_.typeClass,_.value);
	} else if(Type.getClass(this1) == glslparser.FunctionCall) {
		var _1;
		_1 = js.Boot.__cast(this1 , glslparser.FunctionCall);
		glslparser.Eval.error("FunctionCallType not supported yet");
		return glslparser.GLSLBasicType.FunctionCallType;
	}
	glslparser.Eval.error("unrecognized GLSLBasicExpr: " + Std.string(this1));
	return null;
};
glslparser._Eval.GLSLBasicExpr_Impl_.fromExpression = function(expr) {
	var this1;
	if(!glslparser._Eval.GLSLBasicExpr_Impl_.isFullyresolved(expr)) glslparser.Eval.error("cannot create GLSLBasicExpr; expression is not fully resolved. " + Std.string(expr));
	this1 = expr;
	return this1;
};
glslparser.TokenType = { __ename__ : true, __constructs__ : ["ATTRIBUTE","CONST","BOOL","FLOAT","INT","BREAK","CONTINUE","DO","ELSE","FOR","IF","DISCARD","RETURN","BVEC2","BVEC3","BVEC4","IVEC2","IVEC3","IVEC4","VEC2","VEC3","VEC4","MAT2","MAT3","MAT4","IN","OUT","INOUT","UNIFORM","VARYING","SAMPLER2D","SAMPLERCUBE","STRUCT","VOID","WHILE","INVARIANT","HIGH_PRECISION","MEDIUM_PRECISION","LOW_PRECISION","PRECISION","BOOLCONSTANT","RESERVED_KEYWORD","LEFT_OP","RIGHT_OP","INC_OP","DEC_OP","LE_OP","GE_OP","EQ_OP","NE_OP","AND_OP","OR_OP","XOR_OP","MUL_ASSIGN","DIV_ASSIGN","ADD_ASSIGN","MOD_ASSIGN","SUB_ASSIGN","LEFT_ASSIGN","RIGHT_ASSIGN","AND_ASSIGN","XOR_ASSIGN","OR_ASSIGN","LEFT_PAREN","RIGHT_PAREN","LEFT_BRACKET","RIGHT_BRACKET","LEFT_BRACE","RIGHT_BRACE","DOT","COMMA","COLON","EQUAL","SEMICOLON","BANG","DASH","TILDE","PLUS","STAR","SLASH","PERCENT","LEFT_ANGLE","RIGHT_ANGLE","VERTICAL_BAR","CARET","AMPERSAND","QUESTION","IDENTIFIER","TYPE_NAME","FIELD_SELECTION","INTCONSTANT","FLOATCONSTANT","BLOCK_COMMENT","LINE_COMMENT","PREPROCESSOR","WHITESPACE"] };
glslparser.TokenType.ATTRIBUTE = ["ATTRIBUTE",0];
glslparser.TokenType.ATTRIBUTE.toString = $estr;
glslparser.TokenType.ATTRIBUTE.__enum__ = glslparser.TokenType;
glslparser.TokenType.CONST = ["CONST",1];
glslparser.TokenType.CONST.toString = $estr;
glslparser.TokenType.CONST.__enum__ = glslparser.TokenType;
glslparser.TokenType.BOOL = ["BOOL",2];
glslparser.TokenType.BOOL.toString = $estr;
glslparser.TokenType.BOOL.__enum__ = glslparser.TokenType;
glslparser.TokenType.FLOAT = ["FLOAT",3];
glslparser.TokenType.FLOAT.toString = $estr;
glslparser.TokenType.FLOAT.__enum__ = glslparser.TokenType;
glslparser.TokenType.INT = ["INT",4];
glslparser.TokenType.INT.toString = $estr;
glslparser.TokenType.INT.__enum__ = glslparser.TokenType;
glslparser.TokenType.BREAK = ["BREAK",5];
glslparser.TokenType.BREAK.toString = $estr;
glslparser.TokenType.BREAK.__enum__ = glslparser.TokenType;
glslparser.TokenType.CONTINUE = ["CONTINUE",6];
glslparser.TokenType.CONTINUE.toString = $estr;
glslparser.TokenType.CONTINUE.__enum__ = glslparser.TokenType;
glslparser.TokenType.DO = ["DO",7];
glslparser.TokenType.DO.toString = $estr;
glslparser.TokenType.DO.__enum__ = glslparser.TokenType;
glslparser.TokenType.ELSE = ["ELSE",8];
glslparser.TokenType.ELSE.toString = $estr;
glslparser.TokenType.ELSE.__enum__ = glslparser.TokenType;
glslparser.TokenType.FOR = ["FOR",9];
glslparser.TokenType.FOR.toString = $estr;
glslparser.TokenType.FOR.__enum__ = glslparser.TokenType;
glslparser.TokenType.IF = ["IF",10];
glslparser.TokenType.IF.toString = $estr;
glslparser.TokenType.IF.__enum__ = glslparser.TokenType;
glslparser.TokenType.DISCARD = ["DISCARD",11];
glslparser.TokenType.DISCARD.toString = $estr;
glslparser.TokenType.DISCARD.__enum__ = glslparser.TokenType;
glslparser.TokenType.RETURN = ["RETURN",12];
glslparser.TokenType.RETURN.toString = $estr;
glslparser.TokenType.RETURN.__enum__ = glslparser.TokenType;
glslparser.TokenType.BVEC2 = ["BVEC2",13];
glslparser.TokenType.BVEC2.toString = $estr;
glslparser.TokenType.BVEC2.__enum__ = glslparser.TokenType;
glslparser.TokenType.BVEC3 = ["BVEC3",14];
glslparser.TokenType.BVEC3.toString = $estr;
glslparser.TokenType.BVEC3.__enum__ = glslparser.TokenType;
glslparser.TokenType.BVEC4 = ["BVEC4",15];
glslparser.TokenType.BVEC4.toString = $estr;
glslparser.TokenType.BVEC4.__enum__ = glslparser.TokenType;
glslparser.TokenType.IVEC2 = ["IVEC2",16];
glslparser.TokenType.IVEC2.toString = $estr;
glslparser.TokenType.IVEC2.__enum__ = glslparser.TokenType;
glslparser.TokenType.IVEC3 = ["IVEC3",17];
glslparser.TokenType.IVEC3.toString = $estr;
glslparser.TokenType.IVEC3.__enum__ = glslparser.TokenType;
glslparser.TokenType.IVEC4 = ["IVEC4",18];
glslparser.TokenType.IVEC4.toString = $estr;
glslparser.TokenType.IVEC4.__enum__ = glslparser.TokenType;
glslparser.TokenType.VEC2 = ["VEC2",19];
glslparser.TokenType.VEC2.toString = $estr;
glslparser.TokenType.VEC2.__enum__ = glslparser.TokenType;
glslparser.TokenType.VEC3 = ["VEC3",20];
glslparser.TokenType.VEC3.toString = $estr;
glslparser.TokenType.VEC3.__enum__ = glslparser.TokenType;
glslparser.TokenType.VEC4 = ["VEC4",21];
glslparser.TokenType.VEC4.toString = $estr;
glslparser.TokenType.VEC4.__enum__ = glslparser.TokenType;
glslparser.TokenType.MAT2 = ["MAT2",22];
glslparser.TokenType.MAT2.toString = $estr;
glslparser.TokenType.MAT2.__enum__ = glslparser.TokenType;
glslparser.TokenType.MAT3 = ["MAT3",23];
glslparser.TokenType.MAT3.toString = $estr;
glslparser.TokenType.MAT3.__enum__ = glslparser.TokenType;
glslparser.TokenType.MAT4 = ["MAT4",24];
glslparser.TokenType.MAT4.toString = $estr;
glslparser.TokenType.MAT4.__enum__ = glslparser.TokenType;
glslparser.TokenType.IN = ["IN",25];
glslparser.TokenType.IN.toString = $estr;
glslparser.TokenType.IN.__enum__ = glslparser.TokenType;
glslparser.TokenType.OUT = ["OUT",26];
glslparser.TokenType.OUT.toString = $estr;
glslparser.TokenType.OUT.__enum__ = glslparser.TokenType;
glslparser.TokenType.INOUT = ["INOUT",27];
glslparser.TokenType.INOUT.toString = $estr;
glslparser.TokenType.INOUT.__enum__ = glslparser.TokenType;
glslparser.TokenType.UNIFORM = ["UNIFORM",28];
glslparser.TokenType.UNIFORM.toString = $estr;
glslparser.TokenType.UNIFORM.__enum__ = glslparser.TokenType;
glslparser.TokenType.VARYING = ["VARYING",29];
glslparser.TokenType.VARYING.toString = $estr;
glslparser.TokenType.VARYING.__enum__ = glslparser.TokenType;
glslparser.TokenType.SAMPLER2D = ["SAMPLER2D",30];
glslparser.TokenType.SAMPLER2D.toString = $estr;
glslparser.TokenType.SAMPLER2D.__enum__ = glslparser.TokenType;
glslparser.TokenType.SAMPLERCUBE = ["SAMPLERCUBE",31];
glslparser.TokenType.SAMPLERCUBE.toString = $estr;
glslparser.TokenType.SAMPLERCUBE.__enum__ = glslparser.TokenType;
glslparser.TokenType.STRUCT = ["STRUCT",32];
glslparser.TokenType.STRUCT.toString = $estr;
glslparser.TokenType.STRUCT.__enum__ = glslparser.TokenType;
glslparser.TokenType.VOID = ["VOID",33];
glslparser.TokenType.VOID.toString = $estr;
glslparser.TokenType.VOID.__enum__ = glslparser.TokenType;
glslparser.TokenType.WHILE = ["WHILE",34];
glslparser.TokenType.WHILE.toString = $estr;
glslparser.TokenType.WHILE.__enum__ = glslparser.TokenType;
glslparser.TokenType.INVARIANT = ["INVARIANT",35];
glslparser.TokenType.INVARIANT.toString = $estr;
glslparser.TokenType.INVARIANT.__enum__ = glslparser.TokenType;
glslparser.TokenType.HIGH_PRECISION = ["HIGH_PRECISION",36];
glslparser.TokenType.HIGH_PRECISION.toString = $estr;
glslparser.TokenType.HIGH_PRECISION.__enum__ = glslparser.TokenType;
glslparser.TokenType.MEDIUM_PRECISION = ["MEDIUM_PRECISION",37];
glslparser.TokenType.MEDIUM_PRECISION.toString = $estr;
glslparser.TokenType.MEDIUM_PRECISION.__enum__ = glslparser.TokenType;
glslparser.TokenType.LOW_PRECISION = ["LOW_PRECISION",38];
glslparser.TokenType.LOW_PRECISION.toString = $estr;
glslparser.TokenType.LOW_PRECISION.__enum__ = glslparser.TokenType;
glslparser.TokenType.PRECISION = ["PRECISION",39];
glslparser.TokenType.PRECISION.toString = $estr;
glslparser.TokenType.PRECISION.__enum__ = glslparser.TokenType;
glslparser.TokenType.BOOLCONSTANT = ["BOOLCONSTANT",40];
glslparser.TokenType.BOOLCONSTANT.toString = $estr;
glslparser.TokenType.BOOLCONSTANT.__enum__ = glslparser.TokenType;
glslparser.TokenType.RESERVED_KEYWORD = ["RESERVED_KEYWORD",41];
glslparser.TokenType.RESERVED_KEYWORD.toString = $estr;
glslparser.TokenType.RESERVED_KEYWORD.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_OP = ["LEFT_OP",42];
glslparser.TokenType.LEFT_OP.toString = $estr;
glslparser.TokenType.LEFT_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_OP = ["RIGHT_OP",43];
glslparser.TokenType.RIGHT_OP.toString = $estr;
glslparser.TokenType.RIGHT_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.INC_OP = ["INC_OP",44];
glslparser.TokenType.INC_OP.toString = $estr;
glslparser.TokenType.INC_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.DEC_OP = ["DEC_OP",45];
glslparser.TokenType.DEC_OP.toString = $estr;
glslparser.TokenType.DEC_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.LE_OP = ["LE_OP",46];
glslparser.TokenType.LE_OP.toString = $estr;
glslparser.TokenType.LE_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.GE_OP = ["GE_OP",47];
glslparser.TokenType.GE_OP.toString = $estr;
glslparser.TokenType.GE_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.EQ_OP = ["EQ_OP",48];
glslparser.TokenType.EQ_OP.toString = $estr;
glslparser.TokenType.EQ_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.NE_OP = ["NE_OP",49];
glslparser.TokenType.NE_OP.toString = $estr;
glslparser.TokenType.NE_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.AND_OP = ["AND_OP",50];
glslparser.TokenType.AND_OP.toString = $estr;
glslparser.TokenType.AND_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.OR_OP = ["OR_OP",51];
glslparser.TokenType.OR_OP.toString = $estr;
glslparser.TokenType.OR_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.XOR_OP = ["XOR_OP",52];
glslparser.TokenType.XOR_OP.toString = $estr;
glslparser.TokenType.XOR_OP.__enum__ = glslparser.TokenType;
glslparser.TokenType.MUL_ASSIGN = ["MUL_ASSIGN",53];
glslparser.TokenType.MUL_ASSIGN.toString = $estr;
glslparser.TokenType.MUL_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.DIV_ASSIGN = ["DIV_ASSIGN",54];
glslparser.TokenType.DIV_ASSIGN.toString = $estr;
glslparser.TokenType.DIV_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.ADD_ASSIGN = ["ADD_ASSIGN",55];
glslparser.TokenType.ADD_ASSIGN.toString = $estr;
glslparser.TokenType.ADD_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.MOD_ASSIGN = ["MOD_ASSIGN",56];
glslparser.TokenType.MOD_ASSIGN.toString = $estr;
glslparser.TokenType.MOD_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.SUB_ASSIGN = ["SUB_ASSIGN",57];
glslparser.TokenType.SUB_ASSIGN.toString = $estr;
glslparser.TokenType.SUB_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_ASSIGN = ["LEFT_ASSIGN",58];
glslparser.TokenType.LEFT_ASSIGN.toString = $estr;
glslparser.TokenType.LEFT_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_ASSIGN = ["RIGHT_ASSIGN",59];
glslparser.TokenType.RIGHT_ASSIGN.toString = $estr;
glslparser.TokenType.RIGHT_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.AND_ASSIGN = ["AND_ASSIGN",60];
glslparser.TokenType.AND_ASSIGN.toString = $estr;
glslparser.TokenType.AND_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.XOR_ASSIGN = ["XOR_ASSIGN",61];
glslparser.TokenType.XOR_ASSIGN.toString = $estr;
glslparser.TokenType.XOR_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.OR_ASSIGN = ["OR_ASSIGN",62];
glslparser.TokenType.OR_ASSIGN.toString = $estr;
glslparser.TokenType.OR_ASSIGN.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_PAREN = ["LEFT_PAREN",63];
glslparser.TokenType.LEFT_PAREN.toString = $estr;
glslparser.TokenType.LEFT_PAREN.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_PAREN = ["RIGHT_PAREN",64];
glslparser.TokenType.RIGHT_PAREN.toString = $estr;
glslparser.TokenType.RIGHT_PAREN.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_BRACKET = ["LEFT_BRACKET",65];
glslparser.TokenType.LEFT_BRACKET.toString = $estr;
glslparser.TokenType.LEFT_BRACKET.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_BRACKET = ["RIGHT_BRACKET",66];
glslparser.TokenType.RIGHT_BRACKET.toString = $estr;
glslparser.TokenType.RIGHT_BRACKET.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_BRACE = ["LEFT_BRACE",67];
glslparser.TokenType.LEFT_BRACE.toString = $estr;
glslparser.TokenType.LEFT_BRACE.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_BRACE = ["RIGHT_BRACE",68];
glslparser.TokenType.RIGHT_BRACE.toString = $estr;
glslparser.TokenType.RIGHT_BRACE.__enum__ = glslparser.TokenType;
glslparser.TokenType.DOT = ["DOT",69];
glslparser.TokenType.DOT.toString = $estr;
glslparser.TokenType.DOT.__enum__ = glslparser.TokenType;
glslparser.TokenType.COMMA = ["COMMA",70];
glslparser.TokenType.COMMA.toString = $estr;
glslparser.TokenType.COMMA.__enum__ = glslparser.TokenType;
glslparser.TokenType.COLON = ["COLON",71];
glslparser.TokenType.COLON.toString = $estr;
glslparser.TokenType.COLON.__enum__ = glslparser.TokenType;
glslparser.TokenType.EQUAL = ["EQUAL",72];
glslparser.TokenType.EQUAL.toString = $estr;
glslparser.TokenType.EQUAL.__enum__ = glslparser.TokenType;
glslparser.TokenType.SEMICOLON = ["SEMICOLON",73];
glslparser.TokenType.SEMICOLON.toString = $estr;
glslparser.TokenType.SEMICOLON.__enum__ = glslparser.TokenType;
glslparser.TokenType.BANG = ["BANG",74];
glslparser.TokenType.BANG.toString = $estr;
glslparser.TokenType.BANG.__enum__ = glslparser.TokenType;
glslparser.TokenType.DASH = ["DASH",75];
glslparser.TokenType.DASH.toString = $estr;
glslparser.TokenType.DASH.__enum__ = glslparser.TokenType;
glslparser.TokenType.TILDE = ["TILDE",76];
glslparser.TokenType.TILDE.toString = $estr;
glslparser.TokenType.TILDE.__enum__ = glslparser.TokenType;
glslparser.TokenType.PLUS = ["PLUS",77];
glslparser.TokenType.PLUS.toString = $estr;
glslparser.TokenType.PLUS.__enum__ = glslparser.TokenType;
glslparser.TokenType.STAR = ["STAR",78];
glslparser.TokenType.STAR.toString = $estr;
glslparser.TokenType.STAR.__enum__ = glslparser.TokenType;
glslparser.TokenType.SLASH = ["SLASH",79];
glslparser.TokenType.SLASH.toString = $estr;
glslparser.TokenType.SLASH.__enum__ = glslparser.TokenType;
glslparser.TokenType.PERCENT = ["PERCENT",80];
glslparser.TokenType.PERCENT.toString = $estr;
glslparser.TokenType.PERCENT.__enum__ = glslparser.TokenType;
glslparser.TokenType.LEFT_ANGLE = ["LEFT_ANGLE",81];
glslparser.TokenType.LEFT_ANGLE.toString = $estr;
glslparser.TokenType.LEFT_ANGLE.__enum__ = glslparser.TokenType;
glslparser.TokenType.RIGHT_ANGLE = ["RIGHT_ANGLE",82];
glslparser.TokenType.RIGHT_ANGLE.toString = $estr;
glslparser.TokenType.RIGHT_ANGLE.__enum__ = glslparser.TokenType;
glslparser.TokenType.VERTICAL_BAR = ["VERTICAL_BAR",83];
glslparser.TokenType.VERTICAL_BAR.toString = $estr;
glslparser.TokenType.VERTICAL_BAR.__enum__ = glslparser.TokenType;
glslparser.TokenType.CARET = ["CARET",84];
glslparser.TokenType.CARET.toString = $estr;
glslparser.TokenType.CARET.__enum__ = glslparser.TokenType;
glslparser.TokenType.AMPERSAND = ["AMPERSAND",85];
glslparser.TokenType.AMPERSAND.toString = $estr;
glslparser.TokenType.AMPERSAND.__enum__ = glslparser.TokenType;
glslparser.TokenType.QUESTION = ["QUESTION",86];
glslparser.TokenType.QUESTION.toString = $estr;
glslparser.TokenType.QUESTION.__enum__ = glslparser.TokenType;
glslparser.TokenType.IDENTIFIER = ["IDENTIFIER",87];
glslparser.TokenType.IDENTIFIER.toString = $estr;
glslparser.TokenType.IDENTIFIER.__enum__ = glslparser.TokenType;
glslparser.TokenType.TYPE_NAME = ["TYPE_NAME",88];
glslparser.TokenType.TYPE_NAME.toString = $estr;
glslparser.TokenType.TYPE_NAME.__enum__ = glslparser.TokenType;
glslparser.TokenType.FIELD_SELECTION = ["FIELD_SELECTION",89];
glslparser.TokenType.FIELD_SELECTION.toString = $estr;
glslparser.TokenType.FIELD_SELECTION.__enum__ = glslparser.TokenType;
glslparser.TokenType.INTCONSTANT = ["INTCONSTANT",90];
glslparser.TokenType.INTCONSTANT.toString = $estr;
glslparser.TokenType.INTCONSTANT.__enum__ = glslparser.TokenType;
glslparser.TokenType.FLOATCONSTANT = ["FLOATCONSTANT",91];
glslparser.TokenType.FLOATCONSTANT.toString = $estr;
glslparser.TokenType.FLOATCONSTANT.__enum__ = glslparser.TokenType;
glslparser.TokenType.BLOCK_COMMENT = ["BLOCK_COMMENT",92];
glslparser.TokenType.BLOCK_COMMENT.toString = $estr;
glslparser.TokenType.BLOCK_COMMENT.__enum__ = glslparser.TokenType;
glslparser.TokenType.LINE_COMMENT = ["LINE_COMMENT",93];
glslparser.TokenType.LINE_COMMENT.toString = $estr;
glslparser.TokenType.LINE_COMMENT.__enum__ = glslparser.TokenType;
glslparser.TokenType.PREPROCESSOR = ["PREPROCESSOR",94];
glslparser.TokenType.PREPROCESSOR.toString = $estr;
glslparser.TokenType.PREPROCESSOR.__enum__ = glslparser.TokenType;
glslparser.TokenType.WHITESPACE = ["WHITESPACE",95];
glslparser.TokenType.WHITESPACE.toString = $estr;
glslparser.TokenType.WHITESPACE.__enum__ = glslparser.TokenType;
glslparser.ParserData = function() { };
glslparser.ParserData.__name__ = ["glslparser","ParserData"];
glslparser.Parser = function() { };
glslparser.Parser.__name__ = ["glslparser","Parser"];
glslparser.Parser.parse = function(input) {
	return glslparser.Parser.parseTokens(glslparser.Tokenizer.tokenize(input));
};
glslparser.Parser.parseTokens = function(tokens) {
	glslparser.Parser.i = 0;
	glslparser.Parser.errorCount = 0;
	glslparser.Parser.stack = [{ stateno : 0, major : 0, minor : null}];
	glslparser.Parser.warnings = [];
	glslparser.ParserReducer.reset();
	var lastToken = null;
	var _g = 0;
	while(_g < tokens.length) {
		var t = tokens[_g];
		++_g;
		if(HxOverrides.indexOf(glslparser.Parser.ignoredTokens,t.type,0) != -1) continue;
		glslparser.Parser.parseStep(glslparser.Parser.tokenIdMap.get(t.type),(function($this) {
			var $r;
			var e = glslparser.EMinorType.Token(t);
			$r = e;
			return $r;
		}(this)));
		lastToken = t;
	}
	glslparser.Parser.parseStep(0,(function($this) {
		var $r;
		var e1 = glslparser.EMinorType.Token(lastToken);
		$r = e1;
		return $r;
	}(this)));
	return glslparser.ParserReducer.result;
};
glslparser.Parser.parseStep = function(major,minor) {
	var act;
	var atEOF = major == 0;
	var errorHit = false;
	do {
		act = glslparser.Parser.findShiftAction(major);
		if(act < 332) {
			glslparser.Parser.assert(!atEOF,{ fileName : "Parser.hx", lineNumber : 61, className : "glslparser.Parser", methodName : "parseStep"});
			glslparser.Parser.shift(act,major,minor);
			glslparser.Parser.errorCount--;
			major = 165;
		} else if(act < 542) glslparser.Parser.reduce(act - 332); else {
			glslparser.Parser.assert(act == 542,{ fileName : "Parser.hx", lineNumber : 69, className : "glslparser.Parser", methodName : "parseStep"});
			if(glslparser.Parser.errorCount <= 0) glslparser.Parser.syntaxError(major,minor);
			glslparser.Parser.errorCount = 3;
			if(atEOF) glslparser.Parser.parseFailed(minor);
			major = 165;
		}
	} while(major != 165 && glslparser.Parser.i >= 0);
	return;
};
glslparser.Parser.popStack = function() {
	if(glslparser.Parser.i < 0) return 0;
	var major = glslparser.Parser.stack.pop().major;
	glslparser.Parser.i--;
	return major;
};
glslparser.Parser.findShiftAction = function(iLookAhead) {
	var stateno = glslparser.Parser.stack[glslparser.Parser.i].stateno;
	var j = glslparser.Parser.shiftOffset[stateno];
	if(stateno > 168 || j == -36) return glslparser.Parser.defaultAction[stateno];
	glslparser.Parser.assert(iLookAhead != 165,{ fileName : "Parser.hx", lineNumber : 106, className : "glslparser.Parser", methodName : "findShiftAction"});
	j += iLookAhead;
	if(j < 0 || j >= glslparser.Parser.actionCount || glslparser.Parser.lookahead[j] != iLookAhead) return glslparser.Parser.defaultAction[stateno];
	return glslparser.Parser.action[j];
};
glslparser.Parser.findReduceAction = function(stateno,iLookAhead) {
	var j;
	glslparser.Parser.assert(stateno <= 72,{ fileName : "Parser.hx", lineNumber : 125, className : "glslparser.Parser", methodName : "findReduceAction"});
	j = glslparser.Parser.reduceOffset[stateno];
	glslparser.Parser.assert(j != -62,{ fileName : "Parser.hx", lineNumber : 130, className : "glslparser.Parser", methodName : "findReduceAction"});
	glslparser.Parser.assert(iLookAhead != 165,{ fileName : "Parser.hx", lineNumber : 131, className : "glslparser.Parser", methodName : "findReduceAction"});
	j += iLookAhead;
	glslparser.Parser.assert(j >= 0 && j < glslparser.Parser.actionCount,{ fileName : "Parser.hx", lineNumber : 139, className : "glslparser.Parser", methodName : "findReduceAction"});
	glslparser.Parser.assert(glslparser.Parser.lookahead[j] == iLookAhead,{ fileName : "Parser.hx", lineNumber : 140, className : "glslparser.Parser", methodName : "findReduceAction"});
	return glslparser.Parser.action[j];
};
glslparser.Parser.shift = function(newState,major,minor) {
	glslparser.Parser.i++;
	glslparser.Parser.stack[glslparser.Parser.i] = { stateno : newState, major : major, minor : minor};
};
glslparser.Parser.reduce = function(ruleno) {
	var $goto;
	var act;
	var size;
	var newNode = glslparser.ParserReducer.reduce(ruleno);
	$goto = glslparser._Parser.RuleInfoEntry_Impl_.get_lhs(glslparser.Parser.ruleInfo[ruleno]);
	size = glslparser._Parser.RuleInfoEntry_Impl_.get_nrhs(glslparser.Parser.ruleInfo[ruleno]);
	glslparser.Parser.i -= size;
	act = glslparser.Parser.findReduceAction(glslparser.Parser.stack[glslparser.Parser.i].stateno,$goto);
	if(act < 332) glslparser.Parser.shift(act,$goto,newNode); else {
		glslparser.Parser.assert(act == 543,{ fileName : "Parser.hx", lineNumber : 172, className : "glslparser.Parser", methodName : "reduce"});
		glslparser.Parser.accept();
	}
};
glslparser.Parser.accept = function() {
	while(glslparser.Parser.i >= 0) glslparser.Parser.popStack();
};
glslparser.Parser.syntaxError = function(major,minor) {
	glslparser.Parser.warn("syntax error, " + Std.string(minor));
};
glslparser.Parser.parseFailed = function(minor) {
	glslparser.Parser.error("parse failed, " + Std.string(minor));
};
glslparser.Parser.assert = function(cond,pos) {
	if(!cond) glslparser.Parser.warn("assert failed in " + pos.className + "::" + pos.methodName + " line " + pos.lineNumber);
};
glslparser.Parser.warn = function(msg) {
	glslparser.Parser.warnings.push("Parser warning: " + msg);
};
glslparser.Parser.error = function(msg) {
	throw "Parser error: " + msg;
};
glslparser._Parser = {};
glslparser._Parser.RuleInfoEntry_Impl_ = {};
glslparser._Parser.RuleInfoEntry_Impl_.__name__ = ["glslparser","_Parser","RuleInfoEntry_Impl_"];
glslparser._Parser.RuleInfoEntry_Impl_.get_lhs = function(this1) {
	return this1[0];
};
glslparser._Parser.RuleInfoEntry_Impl_.set_lhs = function(this1,v) {
	return this1[0] = v;
};
glslparser._Parser.RuleInfoEntry_Impl_.get_nrhs = function(this1) {
	return this1[1];
};
glslparser._Parser.RuleInfoEntry_Impl_.set_nrhs = function(this1,v) {
	return this1[1] = v;
};
glslparser.ParserDebugData = function() { };
glslparser.ParserDebugData.__name__ = ["glslparser","ParserDebugData"];
glslparser.ParserDebugData.ruleString = function(ruleno) {
	return glslparser.ParserDebugData.ruleMap.get(ruleno);
};
glslparser.ParserDebugData.ruleName = function(ruleno) {
	var ruleNameReg = new EReg("^\\w+","");
	ruleNameReg.match(glslparser.ParserDebugData.ruleString(ruleno));
	return ruleNameReg.matched(0);
};
glslparser.EMinorType = { __ename__ : true, __constructs__ : ["Token","Node","EnumValue","NodeArray"] };
glslparser.EMinorType.Token = function(t) { var $x = ["Token",0,t]; $x.__enum__ = glslparser.EMinorType; $x.toString = $estr; return $x; };
glslparser.EMinorType.Node = function(n) { var $x = ["Node",1,n]; $x.__enum__ = glslparser.EMinorType; $x.toString = $estr; return $x; };
glslparser.EMinorType.EnumValue = function(e) { var $x = ["EnumValue",2,e]; $x.__enum__ = glslparser.EMinorType; $x.toString = $estr; return $x; };
glslparser.EMinorType.NodeArray = function(a) { var $x = ["NodeArray",3,a]; $x.__enum__ = glslparser.EMinorType; $x.toString = $estr; return $x; };
glslparser._ParserReducer = {};
glslparser._ParserReducer.MinorType_Impl_ = {};
glslparser._ParserReducer.MinorType_Impl_.__name__ = ["glslparser","_ParserReducer","MinorType_Impl_"];
glslparser._ParserReducer.MinorType_Impl_._new = function(e) {
	return e;
};
glslparser._ParserReducer.MinorType_Impl_.get_v = function(this1) {
	return this1.slice(2)[0];
};
glslparser._ParserReducer.MinorType_Impl_.get_type = function(this1) {
	return this1;
};
glslparser._ParserReducer.MinorType_Impl_.fromToken = function(t) {
	var e = glslparser.EMinorType.Token(t);
	return e;
};
glslparser._ParserReducer.MinorType_Impl_.fromNode = function(n) {
	var e = glslparser.EMinorType.Node(n);
	return e;
};
glslparser._ParserReducer.MinorType_Impl_.fromEnumValue = function(e) {
	var e1 = glslparser.EMinorType.EnumValue(e);
	return e1;
};
glslparser._ParserReducer.MinorType_Impl_.fromNodeArray = function(a) {
	var e = glslparser.EMinorType.NodeArray(a);
	return e;
};
glslparser.ParserReducer = function() { };
glslparser.ParserReducer.__name__ = ["glslparser","ParserReducer"];
glslparser.ParserReducer.reduce = function(ruleno) {
	glslparser.ParserReducer.ruleno = ruleno;
	switch(ruleno) {
	case 0:
		glslparser.ParserReducer.result = glslparser.ParserReducer.n(1);
		return glslparser.ParserReducer.s(1);
	case 1:
		var n = new glslparser.Identifier(glslparser.ParserReducer.t(1).data);
		var e = glslparser.EMinorType.Node(n);
		return e;
	case 2:
		return glslparser.ParserReducer.s(1);
	case 3:
		var n1 = new glslparser.Literal(Std.parseInt(glslparser.ParserReducer.t(1).data),glslparser.ParserReducer.t(1).data,glslparser.TypeClass.INT);
		var e1 = glslparser.EMinorType.Node(n1);
		return e1;
	case 4:
		var n2 = new glslparser.Literal(Std.parseFloat(glslparser.ParserReducer.t(1).data),glslparser.ParserReducer.t(1).data,glslparser.TypeClass.FLOAT);
		var e2 = glslparser.EMinorType.Node(n2);
		return e2;
	case 5:
		var n3 = new glslparser.Literal(glslparser.ParserReducer.t(1).data == "true",glslparser.ParserReducer.t(1).data,glslparser.TypeClass.BOOL);
		var e3 = glslparser.EMinorType.Node(n3);
		return e3;
	case 6:
		glslparser.ParserReducer.e(2).parenWrap = true;
		return glslparser.ParserReducer.s(2);
	case 7:
		return glslparser.ParserReducer.s(1);
	case 8:
		var n4 = new glslparser.ArrayElementSelectionExpression(glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e4 = glslparser.EMinorType.Node(n4);
		return e4;
	case 9:
		return glslparser.ParserReducer.s(1);
	case 10:
		var n5 = new glslparser.FieldSelectionExpression(glslparser.ParserReducer.e(1),new glslparser.Identifier(glslparser.ParserReducer.t(3).data));
		var e5 = glslparser.EMinorType.Node(n5);
		return e5;
	case 11:
		var n6 = new glslparser.UnaryExpression(glslparser.UnaryOperator.INC_OP,glslparser.ParserReducer.e(1),false);
		var e6 = glslparser.EMinorType.Node(n6);
		return e6;
	case 12:
		var n7 = new glslparser.UnaryExpression(glslparser.UnaryOperator.DEC_OP,glslparser.ParserReducer.e(1),false);
		var e7 = glslparser.EMinorType.Node(n7);
		return e7;
	case 13:
		return glslparser.ParserReducer.s(1);
	case 14:
		return glslparser.ParserReducer.s(1);
	case 15:
		return glslparser.ParserReducer.s(1);
	case 16:
		return glslparser.ParserReducer.s(1);
	case 17:
		return glslparser.ParserReducer.s(1);
	case 18:
		return glslparser.ParserReducer.s(1);
	case 19:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.FunctionCall)).parameters.push(glslparser.ParserReducer.n(2));
		return glslparser.ParserReducer.s(1);
	case 20:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.FunctionCall)).parameters.push(glslparser.ParserReducer.n(3));
		return glslparser.ParserReducer.s(1);
	case 21:
		return glslparser.ParserReducer.s(1);
	case 22:
		var n8 = new glslparser.FunctionCall(glslparser.ParserReducer.t(1).data,null,true);
		var e8 = glslparser.EMinorType.Node(n8);
		return e8;
	case 23:
		var n9 = new glslparser.FunctionCall(glslparser.ParserReducer.t(1).data,null,false);
		var e9 = glslparser.EMinorType.Node(n9);
		return e9;
	case 24:
		return glslparser.ParserReducer.s(1);
	case 25:
		return glslparser.ParserReducer.s(1);
	case 26:
		return glslparser.ParserReducer.s(1);
	case 27:
		return glslparser.ParserReducer.s(1);
	case 28:
		return glslparser.ParserReducer.s(1);
	case 29:
		return glslparser.ParserReducer.s(1);
	case 30:
		return glslparser.ParserReducer.s(1);
	case 31:
		return glslparser.ParserReducer.s(1);
	case 32:
		return glslparser.ParserReducer.s(1);
	case 33:
		return glslparser.ParserReducer.s(1);
	case 34:
		return glslparser.ParserReducer.s(1);
	case 35:
		return glslparser.ParserReducer.s(1);
	case 36:
		return glslparser.ParserReducer.s(1);
	case 37:
		return glslparser.ParserReducer.s(1);
	case 38:
		return glslparser.ParserReducer.s(1);
	case 39:
		return glslparser.ParserReducer.s(1);
	case 40:
		return glslparser.ParserReducer.s(1);
	case 41:
		var n10 = new glslparser.UnaryExpression(glslparser.UnaryOperator.INC_OP,glslparser.ParserReducer.e(2),true);
		var e10 = glslparser.EMinorType.Node(n10);
		return e10;
	case 42:
		var n11 = new glslparser.UnaryExpression(glslparser.UnaryOperator.DEC_OP,glslparser.ParserReducer.e(2),true);
		var e11 = glslparser.EMinorType.Node(n11);
		return e11;
	case 43:
		var n12 = new glslparser.UnaryExpression(glslparser.ParserReducer.ev(1),glslparser.ParserReducer.e(2),true);
		var e12 = glslparser.EMinorType.Node(n12);
		return e12;
	case 44:
		var e13 = glslparser.EMinorType.EnumValue(glslparser.UnaryOperator.PLUS);
		return e13;
	case 45:
		var e14 = glslparser.EMinorType.EnumValue(glslparser.UnaryOperator.DASH);
		return e14;
	case 46:
		var e15 = glslparser.EMinorType.EnumValue(glslparser.UnaryOperator.BANG);
		return e15;
	case 47:
		var e16 = glslparser.EMinorType.EnumValue(glslparser.UnaryOperator.TILDE);
		return e16;
	case 48:
		return glslparser.ParserReducer.s(1);
	case 49:
		var n13 = new glslparser.BinaryExpression(glslparser.BinaryOperator.STAR,glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e17 = glslparser.EMinorType.Node(n13);
		return e17;
	case 50:
		var n14 = new glslparser.BinaryExpression(glslparser.BinaryOperator.SLASH,glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e18 = glslparser.EMinorType.Node(n14);
		return e18;
	case 51:
		var n15 = new glslparser.BinaryExpression(glslparser.BinaryOperator.PERCENT,glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e19 = glslparser.EMinorType.Node(n15);
		return e19;
	case 52:
		return glslparser.ParserReducer.s(1);
	case 53:
		var n16 = new glslparser.BinaryExpression(glslparser.BinaryOperator.PLUS,glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e20 = glslparser.EMinorType.Node(n16);
		return e20;
	case 54:
		var n17 = new glslparser.BinaryExpression(glslparser.BinaryOperator.DASH,glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3));
		var e21 = glslparser.EMinorType.Node(n17);
		return e21;
	case 55:
		return glslparser.ParserReducer.s(1);
	case 56:
		var n18 = new glslparser.BinaryExpression(glslparser.BinaryOperator.LEFT_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e22 = glslparser.EMinorType.Node(n18);
		return e22;
	case 57:
		var n19 = new glslparser.BinaryExpression(glslparser.BinaryOperator.RIGHT_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e23 = glslparser.EMinorType.Node(n19);
		return e23;
	case 58:
		return glslparser.ParserReducer.s(1);
	case 59:
		var n20 = new glslparser.BinaryExpression(glslparser.BinaryOperator.LEFT_ANGLE,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e24 = glslparser.EMinorType.Node(n20);
		return e24;
	case 60:
		var n21 = new glslparser.BinaryExpression(glslparser.BinaryOperator.RIGHT_ANGLE,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e25 = glslparser.EMinorType.Node(n21);
		return e25;
	case 61:
		var n22 = new glslparser.BinaryExpression(glslparser.BinaryOperator.LE_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e26 = glslparser.EMinorType.Node(n22);
		return e26;
	case 62:
		var n23 = new glslparser.BinaryExpression(glslparser.BinaryOperator.GE_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e27 = glslparser.EMinorType.Node(n23);
		return e27;
	case 63:
		return glslparser.ParserReducer.s(1);
	case 64:
		var n24 = new glslparser.BinaryExpression(glslparser.BinaryOperator.EQ_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e28 = glslparser.EMinorType.Node(n24);
		return e28;
	case 65:
		var n25 = new glslparser.BinaryExpression(glslparser.BinaryOperator.NE_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e29 = glslparser.EMinorType.Node(n25);
		return e29;
	case 66:
		return glslparser.ParserReducer.s(1);
	case 67:
		var n26 = new glslparser.BinaryExpression(glslparser.BinaryOperator.AMPERSAND,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e30 = glslparser.EMinorType.Node(n26);
		return e30;
	case 68:
		return glslparser.ParserReducer.s(1);
	case 69:
		var n27 = new glslparser.BinaryExpression(glslparser.BinaryOperator.CARET,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e31 = glslparser.EMinorType.Node(n27);
		return e31;
	case 70:
		return glslparser.ParserReducer.s(1);
	case 71:
		var n28 = new glslparser.BinaryExpression(glslparser.BinaryOperator.VERTICAL_BAR,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e32 = glslparser.EMinorType.Node(n28);
		return e32;
	case 72:
		return glslparser.ParserReducer.s(1);
	case 73:
		var n29 = new glslparser.BinaryExpression(glslparser.BinaryOperator.AND_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e33 = glslparser.EMinorType.Node(n29);
		return e33;
	case 74:
		return glslparser.ParserReducer.s(1);
	case 75:
		var n30 = new glslparser.BinaryExpression(glslparser.BinaryOperator.XOR_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e34 = glslparser.EMinorType.Node(n30);
		return e34;
	case 76:
		return glslparser.ParserReducer.s(1);
	case 77:
		var n31 = new glslparser.BinaryExpression(glslparser.BinaryOperator.OR_OP,glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e35 = glslparser.EMinorType.Node(n31);
		return e35;
	case 78:
		return glslparser.ParserReducer.s(1);
	case 79:
		var n32 = new glslparser.ConditionalExpression(glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(2),glslparser.ParserReducer.n(3));
		var e36 = glslparser.EMinorType.Node(n32);
		return e36;
	case 80:
		return glslparser.ParserReducer.s(1);
	case 81:
		var n33 = new glslparser.AssignmentExpression(glslparser.ParserReducer.ev(2),glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3));
		var e37 = glslparser.EMinorType.Node(n33);
		return e37;
	case 82:
		var e38 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.EQUAL);
		return e38;
	case 83:
		var e39 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.MUL_ASSIGN);
		return e39;
	case 84:
		var e40 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.DIV_ASSIGN);
		return e40;
	case 85:
		var e41 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.MOD_ASSIGN);
		return e41;
	case 86:
		var e42 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.ADD_ASSIGN);
		return e42;
	case 87:
		var e43 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.SUB_ASSIGN);
		return e43;
	case 88:
		var e44 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.LEFT_ASSIGN);
		return e44;
	case 89:
		var e45 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.RIGHT_ASSIGN);
		return e45;
	case 90:
		var e46 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.AND_ASSIGN);
		return e46;
	case 91:
		var e47 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.XOR_ASSIGN);
		return e47;
	case 92:
		var e48 = glslparser.EMinorType.EnumValue(glslparser.AssignmentOperator.OR_ASSIGN);
		return e48;
	case 93:
		return glslparser.ParserReducer.s(1);
	case 94:
		if(Std["is"](glslparser.ParserReducer.e(1),glslparser.SequenceExpression)) {
			(js.Boot.__cast(glslparser.ParserReducer.e(1) , glslparser.SequenceExpression)).expressions.push(glslparser.ParserReducer.e(3));
			return glslparser.ParserReducer.s(1);
		} else {
			var n34 = new glslparser.SequenceExpression([glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3)]);
			var e49 = glslparser.EMinorType.Node(n34);
			return e49;
		}
		break;
	case 95:
		return glslparser.ParserReducer.s(1);
	case 96:
		var n35 = new glslparser.FunctionPrototype(glslparser.ParserReducer.s(1));
		var e50 = glslparser.EMinorType.Node(n35);
		return e50;
	case 97:
		return glslparser.ParserReducer.s(1);
	case 98:
		var n36 = new glslparser.PrecisionDeclaration(glslparser.ParserReducer.ev(2),glslparser.ParserReducer.n(3));
		var e51 = glslparser.EMinorType.Node(n36);
		return e51;
	case 99:
		return glslparser.ParserReducer.s(1);
	case 100:
		return glslparser.ParserReducer.s(1);
	case 101:
		return glslparser.ParserReducer.s(1);
	case 102:
		var fh;
		fh = js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.FunctionHeader);
		fh.parameters.push(glslparser.ParserReducer.n(2));
		var e52 = glslparser.EMinorType.Node(fh);
		return e52;
	case 103:
		var fh1;
		fh1 = js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.FunctionHeader);
		fh1.parameters.push(glslparser.ParserReducer.n(3));
		var e53 = glslparser.EMinorType.Node(fh1);
		return e53;
	case 104:
		var n37 = new glslparser.FunctionHeader(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.n(1));
		var e54 = glslparser.EMinorType.Node(n37);
		return e54;
	case 105:
		var n38 = new glslparser.ParameterDeclaration(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.n(1));
		var e55 = glslparser.EMinorType.Node(n38);
		return e55;
	case 106:
		var n39 = new glslparser.ParameterDeclaration(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.n(1),null,null,glslparser.ParserReducer.e(3));
		var e56 = glslparser.EMinorType.Node(n39);
		return e56;
	case 107:
		var pd;
		pd = js.Boot.__cast(glslparser.ParserReducer.n(3) , glslparser.ParameterDeclaration);
		pd.typeQualifier = glslparser.ParserReducer.ev(1);
		pd.parameterQualifier = glslparser.ParserReducer.ev(2);
		var e57 = glslparser.EMinorType.Node(pd);
		return e57;
	case 108:
		var pd1;
		pd1 = js.Boot.__cast(glslparser.ParserReducer.n(2) , glslparser.ParameterDeclaration);
		pd1.parameterQualifier = glslparser.ParserReducer.ev(1);
		var e58 = glslparser.EMinorType.Node(pd1);
		return e58;
	case 109:
		var pd2;
		pd2 = js.Boot.__cast(glslparser.ParserReducer.n(3) , glslparser.ParameterDeclaration);
		pd2.typeQualifier = glslparser.ParserReducer.ev(1);
		pd2.parameterQualifier = glslparser.ParserReducer.ev(2);
		var e59 = glslparser.EMinorType.Node(pd2);
		return e59;
	case 110:
		var pd3;
		pd3 = js.Boot.__cast(glslparser.ParserReducer.n(2) , glslparser.ParameterDeclaration);
		pd3.parameterQualifier = glslparser.ParserReducer.ev(1);
		var e60 = glslparser.EMinorType.Node(pd3);
		return e60;
	case 111:
		return null;
	case 112:
		var e61 = glslparser.EMinorType.EnumValue(glslparser.ParameterQualifier.IN);
		return e61;
	case 113:
		var e62 = glslparser.EMinorType.EnumValue(glslparser.ParameterQualifier.OUT);
		return e62;
	case 114:
		var e63 = glslparser.EMinorType.EnumValue(glslparser.ParameterQualifier.INOUT);
		return e63;
	case 115:
		var n40 = new glslparser.ParameterDeclaration(null,glslparser.ParserReducer.n(1));
		var e64 = glslparser.EMinorType.Node(n40);
		return e64;
	case 116:
		var n41 = new glslparser.ParameterDeclaration(null,glslparser.ParserReducer.n(1),null,null,glslparser.ParserReducer.e(3));
		var e65 = glslparser.EMinorType.Node(n41);
		return e65;
	case 117:
		return glslparser.ParserReducer.s(1);
	case 118:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.VariableDeclaration)).declarators.push(new glslparser.Declarator(glslparser.ParserReducer.t(3).data,null,false));
		return glslparser.ParserReducer.s(1);
	case 119:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.VariableDeclaration)).declarators.push(new glslparser.ArrayDeclarator(glslparser.ParserReducer.t(3).data,glslparser.ParserReducer.e(5)));
		return glslparser.ParserReducer.s(1);
	case 120:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.VariableDeclaration)).declarators.push(new glslparser.Declarator(glslparser.ParserReducer.t(3).data,glslparser.ParserReducer.e(5),false));
		return glslparser.ParserReducer.s(1);
	case 121:
		var n42 = new glslparser.VariableDeclaration(glslparser.ParserReducer.n(1),[new glslparser.Declarator("",null,false)]);
		var e66 = glslparser.EMinorType.Node(n42);
		return e66;
	case 122:
		var n43 = new glslparser.VariableDeclaration(glslparser.ParserReducer.n(1),[new glslparser.Declarator(glslparser.ParserReducer.t(2).data,null,false)]);
		var e67 = glslparser.EMinorType.Node(n43);
		return e67;
	case 123:
		var n44 = new glslparser.VariableDeclaration(glslparser.ParserReducer.n(1),[new glslparser.ArrayDeclarator(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.e(4))]);
		var e68 = glslparser.EMinorType.Node(n44);
		return e68;
	case 124:
		var n45 = new glslparser.VariableDeclaration(glslparser.ParserReducer.n(1),[new glslparser.Declarator(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.e(4),false)]);
		var e69 = glslparser.EMinorType.Node(n45);
		return e69;
	case 125:
		var n46 = new glslparser.VariableDeclaration(null,[new glslparser.Declarator(glslparser.ParserReducer.t(2).data,null,true)]);
		var e70 = glslparser.EMinorType.Node(n46);
		return e70;
	case 126:
		return glslparser.ParserReducer.s(1);
	case 127:
		(js.Boot.__cast(glslparser.ParserReducer.n(2) , glslparser.TypeSpecifier)).qualifier = glslparser.ParserReducer.ev(1);
		return glslparser.ParserReducer.s(2);
	case 128:
		var e71 = glslparser.EMinorType.EnumValue(glslparser.TypeQualifier.CONST);
		return e71;
	case 129:
		var e72 = glslparser.EMinorType.EnumValue(glslparser.TypeQualifier.ATTRIBUTE);
		return e72;
	case 130:
		var e73 = glslparser.EMinorType.EnumValue(glslparser.TypeQualifier.VARYING);
		return e73;
	case 131:
		var e74 = glslparser.EMinorType.EnumValue(glslparser.TypeQualifier.INVARIANT_VARYING);
		return e74;
	case 132:
		var e75 = glslparser.EMinorType.EnumValue(glslparser.TypeQualifier.UNIFORM);
		return e75;
	case 133:
		return glslparser.ParserReducer.s(1);
	case 134:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.TypeSpecifier)).precision = glslparser.ParserReducer.ev(1);
		return glslparser.ParserReducer.s(1);
	case 135:
		var n47 = new glslparser.TypeSpecifier(glslparser.TypeClass.VOID,glslparser.ParserReducer.t(1).data);
		var e76 = glslparser.EMinorType.Node(n47);
		return e76;
	case 136:
		var n48 = new glslparser.TypeSpecifier(glslparser.TypeClass.FLOAT,glslparser.ParserReducer.t(1).data);
		var e77 = glslparser.EMinorType.Node(n48);
		return e77;
	case 137:
		var n49 = new glslparser.TypeSpecifier(glslparser.TypeClass.INT,glslparser.ParserReducer.t(1).data);
		var e78 = glslparser.EMinorType.Node(n49);
		return e78;
	case 138:
		var n50 = new glslparser.TypeSpecifier(glslparser.TypeClass.BOOL,glslparser.ParserReducer.t(1).data);
		var e79 = glslparser.EMinorType.Node(n50);
		return e79;
	case 139:
		var n51 = new glslparser.TypeSpecifier(glslparser.TypeClass.VEC2,glslparser.ParserReducer.t(1).data);
		var e80 = glslparser.EMinorType.Node(n51);
		return e80;
	case 140:
		var n52 = new glslparser.TypeSpecifier(glslparser.TypeClass.VEC3,glslparser.ParserReducer.t(1).data);
		var e81 = glslparser.EMinorType.Node(n52);
		return e81;
	case 141:
		var n53 = new glslparser.TypeSpecifier(glslparser.TypeClass.VEC4,glslparser.ParserReducer.t(1).data);
		var e82 = glslparser.EMinorType.Node(n53);
		return e82;
	case 142:
		var n54 = new glslparser.TypeSpecifier(glslparser.TypeClass.BVEC2,glslparser.ParserReducer.t(1).data);
		var e83 = glslparser.EMinorType.Node(n54);
		return e83;
	case 143:
		var n55 = new glslparser.TypeSpecifier(glslparser.TypeClass.BVEC3,glslparser.ParserReducer.t(1).data);
		var e84 = glslparser.EMinorType.Node(n55);
		return e84;
	case 144:
		var n56 = new glslparser.TypeSpecifier(glslparser.TypeClass.BVEC4,glslparser.ParserReducer.t(1).data);
		var e85 = glslparser.EMinorType.Node(n56);
		return e85;
	case 145:
		var n57 = new glslparser.TypeSpecifier(glslparser.TypeClass.IVEC2,glslparser.ParserReducer.t(1).data);
		var e86 = glslparser.EMinorType.Node(n57);
		return e86;
	case 146:
		var n58 = new glslparser.TypeSpecifier(glslparser.TypeClass.IVEC3,glslparser.ParserReducer.t(1).data);
		var e87 = glslparser.EMinorType.Node(n58);
		return e87;
	case 147:
		var n59 = new glslparser.TypeSpecifier(glslparser.TypeClass.IVEC4,glslparser.ParserReducer.t(1).data);
		var e88 = glslparser.EMinorType.Node(n59);
		return e88;
	case 148:
		var n60 = new glslparser.TypeSpecifier(glslparser.TypeClass.MAT2,glslparser.ParserReducer.t(1).data);
		var e89 = glslparser.EMinorType.Node(n60);
		return e89;
	case 149:
		var n61 = new glslparser.TypeSpecifier(glslparser.TypeClass.MAT3,glslparser.ParserReducer.t(1).data);
		var e90 = glslparser.EMinorType.Node(n61);
		return e90;
	case 150:
		var n62 = new glslparser.TypeSpecifier(glslparser.TypeClass.MAT4,glslparser.ParserReducer.t(1).data);
		var e91 = glslparser.EMinorType.Node(n62);
		return e91;
	case 151:
		var n63 = new glslparser.TypeSpecifier(glslparser.TypeClass.SAMPLER2D,glslparser.ParserReducer.t(1).data);
		var e92 = glslparser.EMinorType.Node(n63);
		return e92;
	case 152:
		var n64 = new glslparser.TypeSpecifier(glslparser.TypeClass.SAMPLERCUBE,glslparser.ParserReducer.t(1).data);
		var e93 = glslparser.EMinorType.Node(n64);
		return e93;
	case 153:
		return glslparser.ParserReducer.s(1);
	case 154:
		var n65 = new glslparser.TypeSpecifier(glslparser.TypeClass.TYPE_NAME,glslparser.ParserReducer.t(1).data);
		var e94 = glslparser.EMinorType.Node(n65);
		return e94;
	case 155:
		var e95 = glslparser.EMinorType.EnumValue(glslparser.PrecisionQualifier.HIGH_PRECISION);
		return e95;
	case 156:
		var e96 = glslparser.EMinorType.EnumValue(glslparser.PrecisionQualifier.MEDIUM_PRECISION);
		return e96;
	case 157:
		var e97 = glslparser.EMinorType.EnumValue(glslparser.PrecisionQualifier.LOW_PRECISION);
		return e97;
	case 158:
		var n66 = new glslparser.StructSpecifier(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.a(4));
		var e98 = glslparser.EMinorType.Node(n66);
		return e98;
	case 159:
		var n67 = new glslparser.StructSpecifier("",glslparser.ParserReducer.a(3));
		var e99 = glslparser.EMinorType.Node(n67);
		return e99;
	case 160:
		var a = [glslparser.ParserReducer.n(1)];
		var e100 = glslparser.EMinorType.NodeArray(a);
		return e100;
	case 161:
		glslparser.ParserReducer.a(1).push(glslparser.ParserReducer.n(2));
		return glslparser.ParserReducer.s(1);
	case 162:
		var n68 = new glslparser.StructDeclaration(glslparser.ParserReducer.n(1),glslparser.ParserReducer.a(2));
		var e101 = glslparser.EMinorType.Node(n68);
		return e101;
	case 163:
		var a1 = [glslparser.ParserReducer.n(1)];
		var e102 = glslparser.EMinorType.NodeArray(a1);
		return e102;
	case 164:
		glslparser.ParserReducer.a(1).push(glslparser.ParserReducer.n(3));
		return glslparser.ParserReducer.s(1);
	case 165:
		var n69 = new glslparser.StructDeclarator(glslparser.ParserReducer.t(1).data);
		var e103 = glslparser.EMinorType.Node(n69);
		return e103;
	case 166:
		var n70 = new glslparser.StructArrayDeclarator(glslparser.ParserReducer.t(1).data,glslparser.ParserReducer.e(3));
		var e104 = glslparser.EMinorType.Node(n70);
		return e104;
	case 167:
		return glslparser.ParserReducer.s(1);
	case 168:
		var n71 = new glslparser.DeclarationStatement(glslparser.ParserReducer.n(1));
		var e105 = glslparser.EMinorType.Node(n71);
		return e105;
	case 169:
		return glslparser.ParserReducer.s(1);
	case 170:
		return glslparser.ParserReducer.s(1);
	case 171:
		return glslparser.ParserReducer.s(1);
	case 172:
		return glslparser.ParserReducer.s(1);
	case 173:
		return glslparser.ParserReducer.s(1);
	case 174:
		return glslparser.ParserReducer.s(1);
	case 175:
		return glslparser.ParserReducer.s(1);
	case 176:
		var n72 = new glslparser.CompoundStatement([],true);
		var e106 = glslparser.EMinorType.Node(n72);
		return e106;
	case 177:
		var n73 = new glslparser.CompoundStatement(glslparser.ParserReducer.a(2),true);
		var e107 = glslparser.EMinorType.Node(n73);
		return e107;
	case 178:
		return glslparser.ParserReducer.s(1);
	case 179:
		return glslparser.ParserReducer.s(1);
	case 180:
		var n74 = new glslparser.CompoundStatement([],false);
		var e108 = glslparser.EMinorType.Node(n74);
		return e108;
	case 181:
		var n75 = new glslparser.CompoundStatement(glslparser.ParserReducer.a(2),false);
		var e109 = glslparser.EMinorType.Node(n75);
		return e109;
	case 182:
		var a2 = [glslparser.ParserReducer.n(1)];
		var e110 = glslparser.EMinorType.NodeArray(a2);
		return e110;
	case 183:
		glslparser.ParserReducer.a(1).push(glslparser.ParserReducer.n(2));
		return glslparser.ParserReducer.s(1);
	case 184:
		var n76 = new glslparser.ExpressionStatement(null);
		var e111 = glslparser.EMinorType.Node(n76);
		return e111;
	case 185:
		var n77 = new glslparser.ExpressionStatement(glslparser.ParserReducer.e(1));
		var e112 = glslparser.EMinorType.Node(n77);
		return e112;
	case 186:
		var n78 = new glslparser.IfStatement(glslparser.ParserReducer.e(3),glslparser.ParserReducer.a(5)[0],glslparser.ParserReducer.a(5)[1]);
		var e113 = glslparser.EMinorType.Node(n78);
		return e113;
	case 187:
		var a3 = [glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(3)];
		var e114 = glslparser.EMinorType.NodeArray(a3);
		return e114;
	case 188:
		var a4 = [glslparser.ParserReducer.n(1),null];
		var e115 = glslparser.EMinorType.NodeArray(a4);
		return e115;
	case 189:
		return glslparser.ParserReducer.s(1);
	case 190:
		var n79 = new glslparser.VariableDeclaration(glslparser.ParserReducer.n(1),[new glslparser.Declarator(glslparser.ParserReducer.t(2).data,glslparser.ParserReducer.e(4),false)]);
		var e116 = glslparser.EMinorType.Node(n79);
		return e116;
	case 191:
		var n80 = new glslparser.WhileStatement(glslparser.ParserReducer.e(3),glslparser.ParserReducer.n(5));
		var e117 = glslparser.EMinorType.Node(n80);
		return e117;
	case 192:
		var n81 = new glslparser.DoWhileStatement(glslparser.ParserReducer.e(5),glslparser.ParserReducer.n(2));
		var e118 = glslparser.EMinorType.Node(n81);
		return e118;
	case 193:
		var n82 = new glslparser.ForStatement(glslparser.ParserReducer.n(3),glslparser.ParserReducer.a(4)[0],glslparser.ParserReducer.a(4)[1],glslparser.ParserReducer.n(6));
		var e119 = glslparser.EMinorType.Node(n82);
		return e119;
	case 194:
		return glslparser.ParserReducer.s(1);
	case 195:
		return glslparser.ParserReducer.s(1);
	case 196:
		return glslparser.ParserReducer.s(1);
	case 197:
		return null;
	case 198:
		var a5 = [glslparser.ParserReducer.e(1),null];
		var e120 = glslparser.EMinorType.NodeArray(a5);
		return e120;
	case 199:
		var a6 = [glslparser.ParserReducer.e(1),glslparser.ParserReducer.e(3)];
		var e121 = glslparser.EMinorType.NodeArray(a6);
		return e121;
	case 200:
		var n83 = new glslparser.JumpStatement(glslparser.JumpMode.CONTINUE);
		var e122 = glslparser.EMinorType.Node(n83);
		return e122;
	case 201:
		var n84 = new glslparser.JumpStatement(glslparser.JumpMode.BREAK);
		var e123 = glslparser.EMinorType.Node(n84);
		return e123;
	case 202:
		var n85 = new glslparser.JumpStatement(glslparser.JumpMode.RETURN);
		var e124 = glslparser.EMinorType.Node(n85);
		return e124;
	case 203:
		var n86 = new glslparser.ReturnStatement(glslparser.ParserReducer.n(2));
		var e125 = glslparser.EMinorType.Node(n86);
		return e125;
	case 204:
		var n87 = new glslparser.JumpStatement(glslparser.JumpMode.DISCARD);
		var e126 = glslparser.EMinorType.Node(n87);
		return e126;
	case 205:
		var a7 = [glslparser.ParserReducer.n(1)];
		var e127 = glslparser.EMinorType.NodeArray(a7);
		return e127;
	case 206:
		glslparser.ParserReducer.a(1).push(glslparser.ParserReducer.n(2));
		return glslparser.ParserReducer.s(1);
	case 207:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.Declaration)).global = true;
		return glslparser.ParserReducer.s(1);
	case 208:
		(js.Boot.__cast(glslparser.ParserReducer.n(1) , glslparser.Declaration)).global = true;
		return glslparser.ParserReducer.s(1);
	case 209:
		var n88 = new glslparser.FunctionDefinition(glslparser.ParserReducer.n(1),glslparser.ParserReducer.n(2));
		var e128 = glslparser.EMinorType.Node(n88);
		return e128;
	}
	glslparser.Parser.warn("unhandled reduce rule, (" + ruleno + ", " + glslparser.ParserDebugData.ruleName(ruleno) + ")");
	return null;
};
glslparser.ParserReducer.reset = function() {
	glslparser.ParserReducer.result = null;
	glslparser.ParserReducer.ruleno = -1;
};
glslparser.ParserReducer.s = function(n) {
	if(n <= 0) return null;
	var j = glslparser._Parser.RuleInfoEntry_Impl_.get_nrhs(glslparser.Parser.ruleInfo[glslparser.ParserReducer.ruleno]) - n;
	return glslparser.Parser.stack[glslparser.Parser.i - j].minor;
};
glslparser.ParserReducer.n = function(m) {
	var this1 = glslparser.ParserReducer.s(m);
	return this1.slice(2)[0];
};
glslparser.ParserReducer.t = function(m) {
	var this1 = glslparser.ParserReducer.s(m);
	return this1.slice(2)[0];
};
glslparser.ParserReducer.e = function(m) {
	return js.Boot.__cast((function($this) {
		var $r;
		var this1 = glslparser.ParserReducer.s(m);
		$r = this1.slice(2)[0];
		return $r;
	}(this)) , glslparser.Expression);
};
glslparser.ParserReducer.ev = function(m) {
	if(glslparser.ParserReducer.s(m) != null) {
		var this1 = glslparser.ParserReducer.s(m);
		return this1.slice(2)[0];
	} else return null;
};
glslparser.ParserReducer.a = function(m) {
	var this1 = glslparser.ParserReducer.s(m);
	return this1.slice(2)[0];
};
glslparser.ParserReducer.get_i = function() {
	return glslparser.Parser.i;
};
glslparser.ParserReducer.get_stack = function() {
	return glslparser.Parser.stack;
};
glslparser.ScanMode = { __ename__ : true, __constructs__ : ["UNDETERMINED","BLOCK_COMMENT","LINE_COMMENT","PREPROCESSOR","WHITESPACE","OPERATOR","LITERAL","INTEGER_CONSTANT","DECIMAL_CONSTANT","HEX_CONSTANT","OCTAL_CONSTANT","FLOATING_CONSTANT","FRACTIONAL_CONSTANT","EXPONENT_PART"] };
glslparser.ScanMode.UNDETERMINED = ["UNDETERMINED",0];
glslparser.ScanMode.UNDETERMINED.toString = $estr;
glslparser.ScanMode.UNDETERMINED.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.BLOCK_COMMENT = ["BLOCK_COMMENT",1];
glslparser.ScanMode.BLOCK_COMMENT.toString = $estr;
glslparser.ScanMode.BLOCK_COMMENT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.LINE_COMMENT = ["LINE_COMMENT",2];
glslparser.ScanMode.LINE_COMMENT.toString = $estr;
glslparser.ScanMode.LINE_COMMENT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.PREPROCESSOR = ["PREPROCESSOR",3];
glslparser.ScanMode.PREPROCESSOR.toString = $estr;
glslparser.ScanMode.PREPROCESSOR.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.WHITESPACE = ["WHITESPACE",4];
glslparser.ScanMode.WHITESPACE.toString = $estr;
glslparser.ScanMode.WHITESPACE.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.OPERATOR = ["OPERATOR",5];
glslparser.ScanMode.OPERATOR.toString = $estr;
glslparser.ScanMode.OPERATOR.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.LITERAL = ["LITERAL",6];
glslparser.ScanMode.LITERAL.toString = $estr;
glslparser.ScanMode.LITERAL.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.INTEGER_CONSTANT = ["INTEGER_CONSTANT",7];
glslparser.ScanMode.INTEGER_CONSTANT.toString = $estr;
glslparser.ScanMode.INTEGER_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.DECIMAL_CONSTANT = ["DECIMAL_CONSTANT",8];
glslparser.ScanMode.DECIMAL_CONSTANT.toString = $estr;
glslparser.ScanMode.DECIMAL_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.HEX_CONSTANT = ["HEX_CONSTANT",9];
glslparser.ScanMode.HEX_CONSTANT.toString = $estr;
glslparser.ScanMode.HEX_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.OCTAL_CONSTANT = ["OCTAL_CONSTANT",10];
glslparser.ScanMode.OCTAL_CONSTANT.toString = $estr;
glslparser.ScanMode.OCTAL_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.FLOATING_CONSTANT = ["FLOATING_CONSTANT",11];
glslparser.ScanMode.FLOATING_CONSTANT.toString = $estr;
glslparser.ScanMode.FLOATING_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.FRACTIONAL_CONSTANT = ["FRACTIONAL_CONSTANT",12];
glslparser.ScanMode.FRACTIONAL_CONSTANT.toString = $estr;
glslparser.ScanMode.FRACTIONAL_CONSTANT.__enum__ = glslparser.ScanMode;
glslparser.ScanMode.EXPONENT_PART = ["EXPONENT_PART",13];
glslparser.ScanMode.EXPONENT_PART.toString = $estr;
glslparser.ScanMode.EXPONENT_PART.__enum__ = glslparser.ScanMode;
glslparser.Tokenizer = function() { };
glslparser.Tokenizer.__name__ = ["glslparser","Tokenizer"];
glslparser.Tokenizer.tokenize = function(source) {
	glslparser.Tokenizer.source = source;
	glslparser.Tokenizer.tokens = [];
	glslparser.Tokenizer.i = 0;
	glslparser.Tokenizer.line = 1;
	glslparser.Tokenizer.col = 1;
	glslparser.Tokenizer.userDefinedTypes = [];
	glslparser.Tokenizer.warnings = [];
	glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
	var lastMode;
	while(glslparser.Tokenizer.i < source.length || glslparser.Tokenizer.mode != glslparser.ScanMode.UNDETERMINED) {
		lastMode = glslparser.Tokenizer.mode;
		var _g = glslparser.Tokenizer.mode;
		switch(_g[1]) {
		case 0:
			glslparser.Tokenizer.determineMode();
			break;
		case 3:
			glslparser.Tokenizer.preprocessorMode();
			break;
		case 1:
			glslparser.Tokenizer.blockCommentMode();
			break;
		case 2:
			glslparser.Tokenizer.lineCommentMode();
			break;
		case 4:
			glslparser.Tokenizer.whitespaceMode();
			break;
		case 5:
			glslparser.Tokenizer.operatorMode();
			break;
		case 6:
			glslparser.Tokenizer.literalMode();
			break;
		case 11:
			glslparser.Tokenizer.floatingConstantMode();
			break;
		case 12:
			glslparser.Tokenizer.fractionalConstantMode();
			break;
		case 13:
			glslparser.Tokenizer.exponentPartMode();
			break;
		case 9:case 10:case 8:
			glslparser.Tokenizer.integerConstantMode();
			break;
		default:
			glslparser.Tokenizer.error("unhandled mode " + Std.string(glslparser.Tokenizer.mode));
		}
		if(glslparser.Tokenizer.mode == lastMode && glslparser.Tokenizer.i == glslparser.Tokenizer.last_i) {
			glslparser.Tokenizer.error("unclosed mode " + Std.string(glslparser.Tokenizer.mode));
			break;
		}
	}
	return glslparser.Tokenizer.tokens;
};
glslparser.Tokenizer.startLen = function(m) {
	return (glslparser.Tokenizer.startConditionsMap.get(m))();
};
glslparser.Tokenizer.isStart = function(m) {
	return glslparser.Tokenizer.startLen(m) != null;
};
glslparser.Tokenizer.isEnd = function(m) {
	return (glslparser.Tokenizer.endConditionsMap.get(m))();
};
glslparser.Tokenizer.tryMode = function(m) {
	var n = (glslparser.Tokenizer.startConditionsMap.get(m))();
	if(n != null) {
		glslparser.Tokenizer.mode = m;
		glslparser.Tokenizer.advance(n);
		return true;
	}
	return false;
};
glslparser.Tokenizer.advance = function(n) {
	if(n == null) n = 1;
	glslparser.Tokenizer.last_i = glslparser.Tokenizer.i;
	while(n-- > 0 && glslparser.Tokenizer.i < glslparser.Tokenizer.source.length) {
		glslparser.Tokenizer.buf += glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i);
		glslparser.Tokenizer.i++;
	}
	var splitByLines = new EReg("\n","gm").split(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.last_i,glslparser.Tokenizer.i));
	var nl = splitByLines.length - 1;
	if(nl > 0) {
		glslparser.Tokenizer.line += nl;
		glslparser.Tokenizer.col = splitByLines[nl].length + 1;
	} else glslparser.Tokenizer.col += glslparser.Tokenizer.i - glslparser.Tokenizer.last_i;
};
glslparser.Tokenizer.determineMode = function() {
	glslparser.Tokenizer.buf = "";
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.BLOCK_COMMENT)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.LINE_COMMENT)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.PREPROCESSOR)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.WHITESPACE)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.LITERAL)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.FLOATING_CONSTANT)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.OPERATOR)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.HEX_CONSTANT)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.OCTAL_CONSTANT)) return;
	if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.DECIMAL_CONSTANT)) return;
	glslparser.Tokenizer.warn("unrecognized token " + glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
	glslparser.Tokenizer.advance();
	return;
};
glslparser.Tokenizer.preprocessorMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.PREPROCESSOR);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.blockCommentMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.BLOCK_COMMENT);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.lineCommentMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.LINE_COMMENT);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.whitespaceMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.WHITESPACE);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.operatorMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.Tokenizer.operatorMap.get(glslparser.Tokenizer.buf));
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.literalMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		var tt = null;
		tt = glslparser.Tokenizer.literalKeywordMap.get(glslparser.Tokenizer.buf);
		if(tt == null && glslparser.Tokenizer.previousTokenType() == glslparser.TokenType.DOT) tt = glslparser.TokenType.FIELD_SELECTION;
		if(tt == null && HxOverrides.indexOf(glslparser.Tokenizer.userDefinedTypes,glslparser.Tokenizer.buf,0) != -1) tt = glslparser.TokenType.TYPE_NAME;
		if(tt == null) {
			tt = glslparser.TokenType.IDENTIFIER;
			if(glslparser.Tokenizer.previousTokenType(0,true) == glslparser.TokenType.STRUCT) glslparser.Tokenizer.userDefinedTypes.push(glslparser.Tokenizer.buf);
		}
		glslparser.Tokenizer.buildToken(tt);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.floatingConstantMode = function() {
	var _g = glslparser.Tokenizer.floatMode;
	switch(_g) {
	case 0:
		if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.FRACTIONAL_CONSTANT)) {
			glslparser.Tokenizer.floatMode = 1;
			return;
		}
		var j = glslparser.Tokenizer.i;
		while(new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i))) glslparser.Tokenizer.advance();
		if(glslparser.Tokenizer.i > j) {
			glslparser.Tokenizer.floatMode = 2;
			return;
		}
		glslparser.Tokenizer.error("error parsing float, could not determine floatMode");
		break;
	case 1:
		glslparser.Tokenizer.floatMode = 3;
		if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.EXPONENT_PART)) return;
		break;
	case 2:
		if(glslparser.Tokenizer.tryMode(glslparser.ScanMode.EXPONENT_PART)) {
			glslparser.Tokenizer.floatMode = 3;
			return;
		} else glslparser.Tokenizer.error("float in floatMode 2 must have exponent part - none found");
		break;
	}
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.FLOATCONSTANT);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		glslparser.Tokenizer.floatMode = 0;
		return;
	}
	glslparser.Tokenizer.error("error parsing float");
};
glslparser.Tokenizer.fractionalConstantMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.mode = glslparser.ScanMode.FLOATING_CONSTANT;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.exponentPartMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.mode = glslparser.ScanMode.FLOATING_CONSTANT;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.integerConstantMode = function() {
	if((glslparser.Tokenizer.endConditionsMap.get(glslparser.Tokenizer.mode))()) {
		glslparser.Tokenizer.buildToken(glslparser.TokenType.INTCONSTANT);
		glslparser.Tokenizer.mode = glslparser.ScanMode.UNDETERMINED;
		return;
	}
	glslparser.Tokenizer.advance();
};
glslparser.Tokenizer.buildToken = function(type) {
	if(type == null) glslparser.Tokenizer.error("cannot have null token type");
	if(glslparser.Tokenizer.buf == "") glslparser.Tokenizer.error("cannot have empty token data");
	var token = { type : type, data : glslparser.Tokenizer.buf, line : glslparser.Tokenizer.line, column : glslparser.Tokenizer.col, position : glslparser.Tokenizer.i - glslparser.Tokenizer.buf.length};
	if(glslparser.Tokenizer.verbose) console.log("building token " + Std.string(type) + " (" + glslparser.Tokenizer.buf + ")");
	glslparser.Tokenizer.tokens.push(token);
};
glslparser.Tokenizer.c = function(j) {
	return glslparser.Tokenizer.source.charAt(j);
};
glslparser.Tokenizer.previousToken = function(n,ignoreWhitespaceAndComments) {
	if(ignoreWhitespaceAndComments == null) ignoreWhitespaceAndComments = false;
	if(n == null) n = 0;
	if(!ignoreWhitespaceAndComments) return glslparser.Tokenizer.tokens[-n + glslparser.Tokenizer.tokens.length - 1]; else {
		var t = null;
		var i = 0;
		while(n >= 0 && i < glslparser.Tokenizer.tokens.length) {
			t = glslparser.Tokenizer.tokens[-i + glslparser.Tokenizer.tokens.length - 1];
			if(t.type != glslparser.TokenType.WHITESPACE && t.type != glslparser.TokenType.BLOCK_COMMENT && t.type != glslparser.TokenType.LINE_COMMENT) n--;
			i++;
		}
		return t;
	}
};
glslparser.Tokenizer.previousTokenType = function(n,ignoreWhitespaceAndComments) {
	if(n == null) n = 0;
	var pt = glslparser.Tokenizer.previousToken(n,ignoreWhitespaceAndComments);
	if(pt != null) return pt.type; else return null;
};
glslparser.Tokenizer.warn = function(msg) {
	glslparser.Tokenizer.warnings.push("Tokenizer Warning: " + msg + ", line " + glslparser.Tokenizer.line + ", column " + glslparser.Tokenizer.col);
};
glslparser.Tokenizer.error = function(msg) {
	throw "Tokenizer Error: " + msg + ", line " + glslparser.Tokenizer.line + ", column " + glslparser.Tokenizer.col;
};
var haxe = {};
haxe.IMap = function() { };
haxe.IMap.__name__ = ["haxe","IMap"];
haxe.Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.prototype = {
	run: function() {
	}
	,__class__: haxe.Timer
};
haxe.ds = {};
haxe.ds.BalancedTree = function() {
};
haxe.ds.BalancedTree.__name__ = ["haxe","ds","BalancedTree"];
haxe.ds.BalancedTree.prototype = {
	set: function(key,value) {
		this.root = this.setLoop(key,value,this.root);
	}
	,get: function(key) {
		var node = this.root;
		while(node != null) {
			var c = this.compare(key,node.key);
			if(c == 0) return node.value;
			if(c < 0) node = node.left; else node = node.right;
		}
		return null;
	}
	,setLoop: function(k,v,node) {
		if(node == null) return new haxe.ds.TreeNode(null,k,v,null);
		var c = this.compare(k,node.key);
		if(c == 0) return new haxe.ds.TreeNode(node.left,k,v,node.right,node == null?0:node._height); else if(c < 0) {
			var nl = this.setLoop(k,v,node.left);
			return this.balance(nl,node.key,node.value,node.right);
		} else {
			var nr = this.setLoop(k,v,node.right);
			return this.balance(node.left,node.key,node.value,nr);
		}
	}
	,balance: function(l,k,v,r) {
		var hl;
		if(l == null) hl = 0; else hl = l._height;
		var hr;
		if(r == null) hr = 0; else hr = r._height;
		if(hl > hr + 2) {
			if((function($this) {
				var $r;
				var _this = l.left;
				$r = _this == null?0:_this._height;
				return $r;
			}(this)) >= (function($this) {
				var $r;
				var _this1 = l.right;
				$r = _this1 == null?0:_this1._height;
				return $r;
			}(this))) return new haxe.ds.TreeNode(l.left,l.key,l.value,new haxe.ds.TreeNode(l.right,k,v,r)); else return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l.left,l.key,l.value,l.right.left),l.right.key,l.right.value,new haxe.ds.TreeNode(l.right.right,k,v,r));
		} else if(hr > hl + 2) {
			if((function($this) {
				var $r;
				var _this2 = r.right;
				$r = _this2 == null?0:_this2._height;
				return $r;
			}(this)) > (function($this) {
				var $r;
				var _this3 = r.left;
				$r = _this3 == null?0:_this3._height;
				return $r;
			}(this))) return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l,k,v,r.left),r.key,r.value,r.right); else return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l,k,v,r.left.left),r.left.key,r.left.value,new haxe.ds.TreeNode(r.left.right,r.key,r.value,r.right));
		} else return new haxe.ds.TreeNode(l,k,v,r,(hl > hr?hl:hr) + 1);
	}
	,compare: function(k1,k2) {
		return Reflect.compare(k1,k2);
	}
	,__class__: haxe.ds.BalancedTree
};
haxe.ds.TreeNode = function(l,k,v,r,h) {
	if(h == null) h = -1;
	this.left = l;
	this.key = k;
	this.value = v;
	this.right = r;
	if(h == -1) this._height = ((function($this) {
		var $r;
		var _this = $this.left;
		$r = _this == null?0:_this._height;
		return $r;
	}(this)) > (function($this) {
		var $r;
		var _this1 = $this.right;
		$r = _this1 == null?0:_this1._height;
		return $r;
	}(this))?(function($this) {
		var $r;
		var _this2 = $this.left;
		$r = _this2 == null?0:_this2._height;
		return $r;
	}(this)):(function($this) {
		var $r;
		var _this3 = $this.right;
		$r = _this3 == null?0:_this3._height;
		return $r;
	}(this))) + 1; else this._height = h;
};
haxe.ds.TreeNode.__name__ = ["haxe","ds","TreeNode"];
haxe.ds.TreeNode.prototype = {
	__class__: haxe.ds.TreeNode
};
haxe.ds.EnumValueMap = function() {
	haxe.ds.BalancedTree.call(this);
};
haxe.ds.EnumValueMap.__name__ = ["haxe","ds","EnumValueMap"];
haxe.ds.EnumValueMap.__interfaces__ = [haxe.IMap];
haxe.ds.EnumValueMap.__super__ = haxe.ds.BalancedTree;
haxe.ds.EnumValueMap.prototype = $extend(haxe.ds.BalancedTree.prototype,{
	compare: function(k1,k2) {
		var d = k1[1] - k2[1];
		if(d != 0) return d;
		var p1 = k1.slice(2);
		var p2 = k2.slice(2);
		if(p1.length == 0 && p2.length == 0) return 0;
		return this.compareArgs(p1,p2);
	}
	,compareArgs: function(a1,a2) {
		var ld = a1.length - a2.length;
		if(ld != 0) return ld;
		var _g1 = 0;
		var _g = a1.length;
		while(_g1 < _g) {
			var i = _g1++;
			var d = this.compareArg(a1[i],a2[i]);
			if(d != 0) return d;
		}
		return 0;
	}
	,compareArg: function(v1,v2) {
		if(Reflect.isEnumValue(v1) && Reflect.isEnumValue(v2)) return this.compare(v1,v2); else if((v1 instanceof Array) && v1.__enum__ == null && ((v2 instanceof Array) && v2.__enum__ == null)) return this.compareArgs(v1,v2); else return Reflect.compare(v1,v2);
	}
	,__class__: haxe.ds.EnumValueMap
});
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = ["haxe","ds","IntMap"];
haxe.ds.IntMap.__interfaces__ = [haxe.IMap];
haxe.ds.IntMap.prototype = {
	set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,__class__: haxe.ds.IntMap
};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.__interfaces__ = [haxe.IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,toString: function() {
		var s = new StringBuf();
		s.b += "{";
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			if(i == null) s.b += "null"; else s.b += "" + i;
			s.b += " => ";
			s.add(Std.string(this.get(i)));
			if(it.hasNext()) s.b += ", ";
		}
		s.b += "}";
		return s.b;
	}
	,__class__: haxe.ds.StringMap
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = ["js","Boot"];
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js.Boot.__nativeClassName(o);
		if(name != null) return js.Boot.__resolveNativeClass(name);
		return null;
	}
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js.Boot.__string_rec(o[i1],s); else str2 += js.Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js.Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
};
js.Boot.__nativeClassName = function(o) {
	var name = js.Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js.Boot.__isNativeObj = function(o) {
	return js.Boot.__nativeClassName(o) != null;
};
js.Boot.__resolveNativeClass = function(name) {
	if(typeof window != "undefined") return window[name]; else return global[name];
};
js.Browser = function() { };
js.Browser.__name__ = ["js","Browser"];
js.Browser.getLocalStorage = function() {
	try {
		var s = window.localStorage;
		s.getItem("");
		return s;
	} catch( e ) {
		return null;
	}
};
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
glslparser.ParserData.ignoredTokens = [glslparser.TokenType.WHITESPACE,glslparser.TokenType.LINE_COMMENT,glslparser.TokenType.BLOCK_COMMENT,glslparser.TokenType.PREPROCESSOR];
glslparser.ParserData.errorsSymbol = false;
glslparser.ParserData.illegalSymbolNumber = 165;
glslparser.ParserData.nStates = 332;
glslparser.ParserData.nRules = 210;
glslparser.ParserData.actionCount = 2483;
glslparser.ParserData.action = [168,329,328,327,22,45,44,43,42,355,55,54,261,324,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,330,325,166,76,167,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,52,51,50,193,70,239,238,237,84,217,216,215,213,245,244,239,238,237,87,1,195,121,32,119,7,111,109,108,14,107,168,329,328,327,22,222,221,220,49,48,55,54,261,320,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,330,325,104,76,317,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,32,212,38,193,70,69,56,36,84,217,216,215,213,245,244,239,238,237,87,1,174,121,37,119,7,111,109,108,14,107,168,329,328,327,22,47,46,40,39,29,55,54,261,35,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,330,325,91,76,34,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,272,227,356,193,70,69,56,357,84,217,216,215,213,245,244,239,238,237,87,1,175,121,331,119,7,111,109,108,14,107,168,329,328,327,22,33,21,128,2,358,55,54,261,25,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,330,325,83,76,359,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,86,231,360,193,70,361,362,363,84,217,216,215,213,245,244,239,238,237,87,1,196,121,133,119,7,111,109,108,14,107,168,329,328,327,22,243,364,365,366,367,55,54,261,368,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,369,370,330,325,371,76,331,323,322,103,165,23,263,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,88,193,70,265,59,27,84,217,216,215,213,245,244,239,238,237,87,2,264,121,240,119,7,111,109,108,14,107,168,329,328,327,22,243,232,228,262,26,55,54,261,226,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,225,214,330,325,64,76,77,323,322,103,165,23,263,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,132,193,70,210,32,135,84,217,216,215,213,245,244,239,238,237,87,1,209,121,28,119,7,111,109,108,14,107,330,325,90,76,18,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,268,267,204,136,89,65,241,129,63,124,9,123,20,206,62,12,13,208,153,243,271,270,116,17,201,58,8,191,200,199,198,197,3,120,192,190,211,113,24,72,32,16,330,325,90,76,186,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,207,10,204,136,89,65,241,129,63,124,326,123,321,206,62,112,19,208,32,243,31,234,6,32,201,176,203,202,200,199,198,197,4,330,325,90,76,184,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,183,233,204,136,89,65,241,129,63,124,32,123,214,206,62,180,15,208,131,243,173,66,57,30,201,176,203,202,200,199,198,197,5,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,182,204,136,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,544,544,201,544,544,191,200,199,198,197,544,189,192,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,204,136,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,544,544,201,187,203,202,200,199,198,197,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,204,136,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,544,544,201,544,544,191,200,199,198,197,544,114,192,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,204,136,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,544,544,201,185,203,202,200,199,198,197,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,204,136,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,544,544,201,194,203,202,200,199,198,197,330,325,90,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,204,136,89,65,241,129,63,124,544,123,544,206,62,65,241,208,544,243,544,544,224,85,177,544,223,544,178,243,168,329,328,327,22,544,544,11,544,544,55,54,261,544,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,330,325,82,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,544,193,70,544,544,544,84,217,216,215,213,245,244,239,238,237,87,168,329,328,327,22,544,544,544,544,544,55,54,261,544,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,296,295,294,293,168,329,328,327,22,544,544,544,544,544,55,54,319,544,315,314,313,312,311,310,309,308,307,306,305,304,303,302,301,300,296,295,294,293,544,125,217,216,215,213,245,244,239,238,237,87,330,325,118,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,544,544,544,65,241,544,544,544,544,117,544,206,62,330,325,544,76,243,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,161,179,544,110,106,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,98,330,325,118,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,65,241,544,544,65,241,544,219,85,544,117,218,206,62,243,544,330,325,243,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,74,115,332,284,283,282,281,280,279,278,277,276,275,274,544,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,100,70,544,544,544,84,217,216,215,213,245,244,239,238,237,87,544,544,544,70,544,544,544,84,217,216,215,213,245,244,239,238,237,87,168,329,328,327,22,544,544,544,544,544,55,54,544,544,315,314,313,312,311,310,309,308,307,306,305,304,303,302,301,300,296,295,294,293,330,325,544,76,544,323,322,103,165,23,263,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,544,544,544,181,544,168,329,328,327,22,544,544,544,544,544,55,54,544,188,315,314,313,312,311,310,309,308,307,306,305,304,303,302,301,300,296,295,294,293,330,325,105,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,81,76,544,323,322,103,165,23,286,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,544,76,544,323,322,103,165,23,269,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,544,76,544,323,322,103,165,23,273,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,544,76,544,323,322,103,165,23,285,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,544,76,544,323,322,103,165,23,288,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,156,92,266,544,134,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,156,92,266,544,130,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,156,92,266,544,127,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,156,92,266,544,126,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,156,92,266,544,122,330,325,544,76,544,323,322,103,165,23,318,164,316,68,53,80,102,101,75,94,163,162,160,158,156,92,287,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,544,544,544,544,544,544,544,544,245,244,239,238,237,87,544,236,222,221,220,125,217,216,215,213,65,241,245,244,239,238,237,87,67,229,544,544,544,544,243,61,230,544,544,544,245,244,239,238,237,87,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,158,154,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,162,160,155,544,261,544,260,259,258,257,256,255,254,253,252,251,250,249,248,247,246,242,65,241,544,544,330,325,544,76,205,323,322,103,165,23,243,164,316,289,53,80,102,101,75,94,163,162,157,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,99,245,244,544,330,325,87,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,94,163,159,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,75,93,543,41,544,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,101,73,544,544,544,544,544,544,544,544,544,170,71,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,544,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,97,169,171,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,96,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,80,102,95,544,170,71,89,65,241,129,63,124,544,123,544,206,62,544,544,208,544,243,544,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,79,544,544,544,172,171,330,325,544,76,544,323,322,103,165,23,544,164,316,289,53,78,330,325,544,76,544,323,322,103,165,23,544,164,316,299,53,330,325,544,76,544,323,322,103,165,23,544,164,316,298,53,330,325,544,76,432,323,322,103,165,23,544,164,316,297,53,330,325,544,76,544,323,322,103,165,23,544,164,316,292,53,330,325,544,76,544,323,322,103,165,23,544,164,316,291,53,544,544,544,330,325,544,76,544,323,322,103,165,23,544,164,316,290,53,544,544,222,221,220,125,217,216,215,213,65,241,544,65,241,544,544,544,67,544,544,67,544,544,243,60,230,243,544,235];
glslparser.ParserData.lookahead = [1,2,3,4,5,40,41,42,43,5,11,12,13,8,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,35,36,37,65,66,77,78,79,70,71,72,73,74,75,76,77,78,79,80,81,82,83,14,85,86,87,88,89,90,91,1,2,3,4,5,67,68,69,31,32,11,12,13,6,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,5,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,14,132,46,65,66,136,137,48,70,71,72,73,74,75,76,77,78,79,80,81,82,83,47,85,86,87,88,89,90,91,1,2,3,4,5,38,39,44,45,53,11,12,13,49,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,50,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,10,132,5,65,66,136,137,5,70,71,72,73,74,75,76,77,78,79,80,81,82,83,65,85,86,87,88,89,90,91,1,2,3,4,5,51,52,1,81,5,11,12,13,7,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,5,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,144,145,5,65,66,5,5,5,70,71,72,73,74,75,76,77,78,79,80,81,82,83,128,85,86,87,88,89,90,91,1,2,3,4,5,141,5,5,5,5,11,12,13,5,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,5,5,95,96,5,98,65,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,1,65,66,8,81,7,70,71,72,73,74,75,76,77,78,79,80,81,140,83,128,85,86,87,88,89,90,91,1,2,3,4,5,141,8,6,65,7,11,12,13,8,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,8,73,95,96,14,98,1,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,1,65,66,8,14,14,70,71,72,73,74,75,76,77,78,79,80,81,140,83,7,85,86,87,88,89,90,91,95,96,97,98,5,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,65,65,124,125,126,127,128,129,130,131,84,133,54,135,136,5,7,139,9,141,11,12,1,54,146,81,6,149,150,151,152,153,6,155,156,157,5,85,7,14,14,5,95,96,97,98,65,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,1,5,124,125,126,127,128,129,130,131,6,133,6,135,136,6,54,139,14,141,14,65,6,14,146,147,148,149,150,151,152,153,154,95,96,97,98,65,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,65,145,124,125,126,127,128,129,130,131,14,133,73,135,136,65,65,139,1,141,156,127,137,122,146,147,148,149,150,151,152,153,154,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,65,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,164,164,146,164,164,149,150,151,152,153,164,155,156,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,164,164,146,147,148,149,150,151,152,153,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,164,164,146,164,164,149,150,151,152,153,164,155,156,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,164,164,146,147,148,149,150,151,152,153,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,164,164,146,147,148,149,150,151,152,153,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,127,128,139,164,141,164,164,134,135,146,164,138,164,150,141,1,2,3,4,5,164,164,159,164,164,11,12,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,164,65,66,164,164,164,70,71,72,73,74,75,76,77,78,79,80,1,2,3,4,5,164,164,164,164,164,11,12,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,1,2,3,4,5,164,164,164,164,164,11,12,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,164,70,71,72,73,74,75,76,77,78,79,80,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,164,164,164,127,128,164,164,164,164,133,164,135,136,95,96,164,98,141,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,158,164,160,161,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,127,128,164,164,127,128,164,134,135,164,133,138,135,136,141,164,95,96,141,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,158,0,54,55,56,57,58,59,60,61,62,63,64,164,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,66,164,164,164,70,71,72,73,74,75,76,77,78,79,80,164,164,164,66,164,164,164,70,71,72,73,74,75,76,77,78,79,80,1,2,3,4,5,164,164,164,164,164,11,12,164,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,164,164,65,164,1,2,3,4,5,164,164,164,164,164,11,12,164,140,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,97,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,123,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,123,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,123,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,123,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,164,123,95,96,164,98,164,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,164,164,164,164,164,164,164,164,75,76,77,78,79,80,164,82,67,68,69,70,71,72,73,74,127,128,75,76,77,78,79,80,135,82,164,164,164,164,141,142,143,164,164,164,75,76,77,78,79,80,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,119,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,117,118,164,13,164,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,127,128,164,164,95,96,164,98,135,100,101,102,103,104,141,106,107,108,109,110,111,112,113,114,115,116,117,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,75,76,164,95,96,80,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,115,116,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,114,93,94,164,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,113,164,164,164,164,164,164,164,164,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,164,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,162,163,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,111,112,164,124,125,126,127,128,129,130,131,164,133,164,135,136,164,164,139,164,141,164,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,164,164,164,162,163,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,110,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,95,96,164,98,6,100,101,102,103,104,164,106,107,108,109,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,164,164,164,95,96,164,98,164,100,101,102,103,104,164,106,107,108,109,164,164,67,68,69,70,71,72,73,74,127,128,164,127,128,164,164,164,135,164,164,135,164,164,141,142,143,141,164,143];
glslparser.ParserData.shiftUseDefault = -36;
glslparser.ParserData.shiftCount = 168;
glslparser.ParserData.shiftOffsetMin = -35;
glslparser.ParserData.shiftOffsetMax = 2388;
glslparser.ParserData.shiftOffset = [1420,272,181,363,90,-1,454,363,454,363,1092,1172,1172,1566,1500,1566,1566,1566,1566,1566,1566,1566,1566,1206,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1402,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1566,1958,1958,1958,1958,1940,1922,1958,2388,1938,2076,2076,719,1349,29,-11,200,719,-35,-35,-35,582,604,26,26,26,698,651,599,641,279,598,517,531,509,508,138,227,145,145,149,149,149,149,68,68,149,68,648,646,69,653,652,637,614,658,638,554,609,525,593,542,594,69,583,499,545,513,494,479,417,481,460,457,456,453,425,350,398,422,426,339,397,394,393,372,368,367,366,365,336,335,334,331,306,277,245,240,233,170,146,170,111,146,127,111,108,127,108,124,98,69,5,4];
glslparser.ParserData.reduceUseDefault = -62;
glslparser.ParserData.reduceCount = 72;
glslparser.ParserData.reduceMin = -61;
glslparser.ParserData.reduceMax = 2343;
glslparser.ParserData.reduceOffset = [2103,580,520,451,882,882,823,761,702,640,941,1158,1243,-61,1533,1506,1032,1440,212,396,305,121,30,1813,1784,1755,1726,1697,1668,1641,1614,1587,1560,1944,1969,2016,2059,1200,2081,2104,1287,2180,2190,2172,2152,1225,2039,1356,2249,2228,2343,2325,2310,2295,2280,2265,1239,951,2336,1886,2339,2339,1980,112,21,319,228,190,603,587,596,566,558];
glslparser.ParserData.defaultAction = [542,542,542,542,542,542,542,542,542,542,542,529,542,542,542,530,542,542,542,542,542,542,542,350,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,542,443,443,542,542,542,380,443,542,542,542,397,396,395,372,454,386,385,384,542,542,542,542,447,542,542,450,542,542,542,410,399,398,394,393,392,391,389,388,390,387,542,542,531,542,542,542,542,542,542,542,542,542,542,542,542,521,542,520,542,542,453,433,542,542,542,437,542,542,497,542,542,542,542,542,486,482,481,480,479,478,477,476,475,474,473,472,471,470,469,468,542,409,407,408,405,406,403,404,401,402,400,542,542,345,542,333,537,540,539,538,541,513,512,514,527,526,528,536,534,535,533,532,525,524,523,522,519,518,511,510,516,515,509,508,507,506,505,504,503,502,501,500,459,458,457,449,456,455,436,435,464,463,462,461,460,442,440,446,445,444,441,439,448,438,434,431,491,492,495,498,496,494,493,490,489,488,487,466,465,486,485,484,483,482,481,480,479,478,477,476,475,474,473,472,471,470,469,468,467,430,499,452,451,427,429,517,426,344,343,342,352,424,423,422,421,420,419,418,417,416,415,414,413,425,412,411,380,383,382,381,379,378,377,376,375,374,373,371,370,369,368,367,366,365,364,363,362,361,360,359,358,357,356,354,353,351,349,348,347,346,341,340,339,338,337,336,335,334,428];
glslparser.ParserData.ruleInfo = [[93,1],[95,1],[96,1],[96,1],[96,1],[96,1],[96,3],[98,1],[98,4],[98,1],[98,3],[98,2],[98,2],[99,1],[100,1],[101,2],[101,2],[103,2],[103,1],[102,2],[102,3],[104,2],[106,1],[106,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[107,1],[108,1],[108,2],[108,2],[108,2],[109,1],[109,1],[109,1],[109,1],[110,1],[110,3],[110,3],[110,3],[111,1],[111,3],[111,3],[112,1],[112,3],[112,3],[113,1],[113,3],[113,3],[113,3],[113,3],[114,1],[114,3],[114,3],[115,1],[115,3],[116,1],[116,3],[117,1],[117,3],[118,1],[118,3],[119,1],[119,3],[120,1],[120,3],[121,1],[121,5],[105,1],[105,3],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[122,1],[97,1],[97,3],[123,1],[124,2],[124,2],[124,4],[125,2],[129,1],[129,1],[131,2],[131,3],[130,3],[134,2],[134,5],[132,3],[132,2],[132,3],[132,2],[137,0],[137,1],[137,1],[137,1],[138,1],[138,4],[126,1],[126,3],[126,6],[126,5],[139,1],[139,2],[139,5],[139,4],[139,2],[133,1],[133,2],[136,1],[136,1],[136,1],[136,2],[136,1],[135,1],[135,2],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[128,1],[127,1],[127,1],[127,1],[141,5],[141,4],[142,1],[142,2],[143,3],[144,1],[144,3],[145,1],[145,4],[140,1],[146,1],[147,1],[147,1],[149,1],[149,1],[149,1],[149,1],[149,1],[148,2],[148,3],[155,1],[155,1],[156,2],[156,3],[154,1],[154,2],[150,1],[150,2],[151,5],[157,3],[157,1],[158,1],[158,4],[152,5],[152,7],[152,6],[159,1],[159,1],[161,1],[161,0],[160,2],[160,3],[153,2],[153,2],[153,2],[153,3],[153,2],[94,1],[94,2],[162,1],[162,1],[163,2]];
glslparser.ParserData.tokenIdMap = (function($this) {
	var $r;
	var _g = new haxe.ds.EnumValueMap();
	_g.set(glslparser.TokenType.IDENTIFIER,1);
	_g.set(glslparser.TokenType.INTCONSTANT,2);
	_g.set(glslparser.TokenType.FLOATCONSTANT,3);
	_g.set(glslparser.TokenType.BOOLCONSTANT,4);
	_g.set(glslparser.TokenType.LEFT_PAREN,5);
	_g.set(glslparser.TokenType.RIGHT_PAREN,6);
	_g.set(glslparser.TokenType.LEFT_BRACKET,7);
	_g.set(glslparser.TokenType.RIGHT_BRACKET,8);
	_g.set(glslparser.TokenType.DOT,9);
	_g.set(glslparser.TokenType.FIELD_SELECTION,10);
	_g.set(glslparser.TokenType.INC_OP,11);
	_g.set(glslparser.TokenType.DEC_OP,12);
	_g.set(glslparser.TokenType.VOID,13);
	_g.set(glslparser.TokenType.COMMA,14);
	_g.set(glslparser.TokenType.FLOAT,15);
	_g.set(glslparser.TokenType.INT,16);
	_g.set(glslparser.TokenType.BOOL,17);
	_g.set(glslparser.TokenType.VEC2,18);
	_g.set(glslparser.TokenType.VEC3,19);
	_g.set(glslparser.TokenType.VEC4,20);
	_g.set(glslparser.TokenType.BVEC2,21);
	_g.set(glslparser.TokenType.BVEC3,22);
	_g.set(glslparser.TokenType.BVEC4,23);
	_g.set(glslparser.TokenType.IVEC2,24);
	_g.set(glslparser.TokenType.IVEC3,25);
	_g.set(glslparser.TokenType.IVEC4,26);
	_g.set(glslparser.TokenType.MAT2,27);
	_g.set(glslparser.TokenType.MAT3,28);
	_g.set(glslparser.TokenType.MAT4,29);
	_g.set(glslparser.TokenType.TYPE_NAME,30);
	_g.set(glslparser.TokenType.PLUS,31);
	_g.set(glslparser.TokenType.DASH,32);
	_g.set(glslparser.TokenType.BANG,33);
	_g.set(glslparser.TokenType.TILDE,34);
	_g.set(glslparser.TokenType.STAR,35);
	_g.set(glslparser.TokenType.SLASH,36);
	_g.set(glslparser.TokenType.PERCENT,37);
	_g.set(glslparser.TokenType.LEFT_OP,38);
	_g.set(glslparser.TokenType.RIGHT_OP,39);
	_g.set(glslparser.TokenType.LEFT_ANGLE,40);
	_g.set(glslparser.TokenType.RIGHT_ANGLE,41);
	_g.set(glslparser.TokenType.LE_OP,42);
	_g.set(glslparser.TokenType.GE_OP,43);
	_g.set(glslparser.TokenType.EQ_OP,44);
	_g.set(glslparser.TokenType.NE_OP,45);
	_g.set(glslparser.TokenType.AMPERSAND,46);
	_g.set(glslparser.TokenType.CARET,47);
	_g.set(glslparser.TokenType.VERTICAL_BAR,48);
	_g.set(glslparser.TokenType.AND_OP,49);
	_g.set(glslparser.TokenType.XOR_OP,50);
	_g.set(glslparser.TokenType.OR_OP,51);
	_g.set(glslparser.TokenType.QUESTION,52);
	_g.set(glslparser.TokenType.COLON,53);
	_g.set(glslparser.TokenType.EQUAL,54);
	_g.set(glslparser.TokenType.MUL_ASSIGN,55);
	_g.set(glslparser.TokenType.DIV_ASSIGN,56);
	_g.set(glslparser.TokenType.MOD_ASSIGN,57);
	_g.set(glslparser.TokenType.ADD_ASSIGN,58);
	_g.set(glslparser.TokenType.SUB_ASSIGN,59);
	_g.set(glslparser.TokenType.LEFT_ASSIGN,60);
	_g.set(glslparser.TokenType.RIGHT_ASSIGN,61);
	_g.set(glslparser.TokenType.AND_ASSIGN,62);
	_g.set(glslparser.TokenType.XOR_ASSIGN,63);
	_g.set(glslparser.TokenType.OR_ASSIGN,64);
	_g.set(glslparser.TokenType.SEMICOLON,65);
	_g.set(glslparser.TokenType.PRECISION,66);
	_g.set(glslparser.TokenType.IN,67);
	_g.set(glslparser.TokenType.OUT,68);
	_g.set(glslparser.TokenType.INOUT,69);
	_g.set(glslparser.TokenType.INVARIANT,70);
	_g.set(glslparser.TokenType.CONST,71);
	_g.set(glslparser.TokenType.ATTRIBUTE,72);
	_g.set(glslparser.TokenType.VARYING,73);
	_g.set(glslparser.TokenType.UNIFORM,74);
	_g.set(glslparser.TokenType.SAMPLER2D,75);
	_g.set(glslparser.TokenType.SAMPLERCUBE,76);
	_g.set(glslparser.TokenType.HIGH_PRECISION,77);
	_g.set(glslparser.TokenType.MEDIUM_PRECISION,78);
	_g.set(glslparser.TokenType.LOW_PRECISION,79);
	_g.set(glslparser.TokenType.STRUCT,80);
	_g.set(glslparser.TokenType.LEFT_BRACE,81);
	_g.set(glslparser.TokenType.RIGHT_BRACE,82);
	_g.set(glslparser.TokenType.IF,83);
	_g.set(glslparser.TokenType.ELSE,84);
	_g.set(glslparser.TokenType.WHILE,85);
	_g.set(glslparser.TokenType.DO,86);
	_g.set(glslparser.TokenType.FOR,87);
	_g.set(glslparser.TokenType.CONTINUE,88);
	_g.set(glslparser.TokenType.BREAK,89);
	_g.set(glslparser.TokenType.RETURN,90);
	_g.set(glslparser.TokenType.DISCARD,91);
	$r = _g;
	return $r;
}(this));
glslparser.Parser.errorsSymbol = false;
glslparser.Parser.illegalSymbolNumber = 165;
glslparser.Parser.nStates = 332;
glslparser.Parser.nRules = 210;
glslparser.Parser.noAction = 544;
glslparser.Parser.acceptAction = 543;
glslparser.Parser.errorAction = 542;
glslparser.Parser.actionCount = 2483;
glslparser.Parser.action = glslparser.ParserData.action;
glslparser.Parser.lookahead = glslparser.ParserData.lookahead;
glslparser.Parser.shiftUseDefault = -36;
glslparser.Parser.shiftCount = 168;
glslparser.Parser.shiftOffsetMin = -35;
glslparser.Parser.shiftOffsetMax = 2388;
glslparser.Parser.shiftOffset = glslparser.ParserData.shiftOffset;
glslparser.Parser.reduceUseDefault = -62;
glslparser.Parser.reduceCount = 72;
glslparser.Parser.reduceMin = -61;
glslparser.Parser.reduceMax = 2343;
glslparser.Parser.reduceOffset = glslparser.ParserData.reduceOffset;
glslparser.Parser.defaultAction = glslparser.ParserData.defaultAction;
glslparser.Parser.ruleInfo = glslparser.ParserData.ruleInfo;
glslparser.Parser.tokenIdMap = glslparser.ParserData.tokenIdMap;
glslparser.Parser.ignoredTokens = glslparser.ParserData.ignoredTokens;
glslparser.ParserDebugData.ruleMap = (function($this) {
	var $r;
	var _g = new haxe.ds.IntMap();
	_g.set(0,"root ::= translation_unit");
	_g.set(1,"variable_identifier ::= IDENTIFIER");
	_g.set(2,"primary_expression ::= variable_identifier");
	_g.set(3,"primary_expression ::= INTCONSTANT");
	_g.set(4,"primary_expression ::= FLOATCONSTANT");
	_g.set(5,"primary_expression ::= BOOLCONSTANT");
	_g.set(6,"primary_expression ::= LEFT_PAREN expression RIGHT_PAREN");
	_g.set(7,"postfix_expression ::= primary_expression");
	_g.set(8,"postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET");
	_g.set(9,"postfix_expression ::= function_call");
	_g.set(10,"postfix_expression ::= postfix_expression DOT FIELD_SELECTION");
	_g.set(11,"postfix_expression ::= postfix_expression INC_OP");
	_g.set(12,"postfix_expression ::= postfix_expression DEC_OP");
	_g.set(13,"integer_expression ::= expression");
	_g.set(14,"function_call ::= function_call_generic");
	_g.set(15,"function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN");
	_g.set(16,"function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN");
	_g.set(17,"function_call_header_no_parameters ::= function_call_header VOID");
	_g.set(18,"function_call_header_no_parameters ::= function_call_header");
	_g.set(19,"function_call_header_with_parameters ::= function_call_header assignment_expression");
	_g.set(20,"function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression");
	_g.set(21,"function_call_header ::= function_identifier LEFT_PAREN");
	_g.set(22,"function_identifier ::= constructor_identifier");
	_g.set(23,"function_identifier ::= IDENTIFIER");
	_g.set(24,"constructor_identifier ::= FLOAT");
	_g.set(25,"constructor_identifier ::= INT");
	_g.set(26,"constructor_identifier ::= BOOL");
	_g.set(27,"constructor_identifier ::= VEC2");
	_g.set(28,"constructor_identifier ::= VEC3");
	_g.set(29,"constructor_identifier ::= VEC4");
	_g.set(30,"constructor_identifier ::= BVEC2");
	_g.set(31,"constructor_identifier ::= BVEC3");
	_g.set(32,"constructor_identifier ::= BVEC4");
	_g.set(33,"constructor_identifier ::= IVEC2");
	_g.set(34,"constructor_identifier ::= IVEC3");
	_g.set(35,"constructor_identifier ::= IVEC4");
	_g.set(36,"constructor_identifier ::= MAT2");
	_g.set(37,"constructor_identifier ::= MAT3");
	_g.set(38,"constructor_identifier ::= MAT4");
	_g.set(39,"constructor_identifier ::= TYPE_NAME");
	_g.set(40,"unary_expression ::= postfix_expression");
	_g.set(41,"unary_expression ::= INC_OP unary_expression");
	_g.set(42,"unary_expression ::= DEC_OP unary_expression");
	_g.set(43,"unary_expression ::= unary_operator unary_expression");
	_g.set(44,"unary_operator ::= PLUS");
	_g.set(45,"unary_operator ::= DASH");
	_g.set(46,"unary_operator ::= BANG");
	_g.set(47,"unary_operator ::= TILDE");
	_g.set(48,"multiplicative_expression ::= unary_expression");
	_g.set(49,"multiplicative_expression ::= multiplicative_expression STAR unary_expression");
	_g.set(50,"multiplicative_expression ::= multiplicative_expression SLASH unary_expression");
	_g.set(51,"multiplicative_expression ::= multiplicative_expression PERCENT unary_expression");
	_g.set(52,"additive_expression ::= multiplicative_expression");
	_g.set(53,"additive_expression ::= additive_expression PLUS multiplicative_expression");
	_g.set(54,"additive_expression ::= additive_expression DASH multiplicative_expression");
	_g.set(55,"shift_expression ::= additive_expression");
	_g.set(56,"shift_expression ::= shift_expression LEFT_OP additive_expression");
	_g.set(57,"shift_expression ::= shift_expression RIGHT_OP additive_expression");
	_g.set(58,"relational_expression ::= shift_expression");
	_g.set(59,"relational_expression ::= relational_expression LEFT_ANGLE shift_expression");
	_g.set(60,"relational_expression ::= relational_expression RIGHT_ANGLE shift_expression");
	_g.set(61,"relational_expression ::= relational_expression LE_OP shift_expression");
	_g.set(62,"relational_expression ::= relational_expression GE_OP shift_expression");
	_g.set(63,"equality_expression ::= relational_expression");
	_g.set(64,"equality_expression ::= equality_expression EQ_OP relational_expression");
	_g.set(65,"equality_expression ::= equality_expression NE_OP relational_expression");
	_g.set(66,"and_expression ::= equality_expression");
	_g.set(67,"and_expression ::= and_expression AMPERSAND equality_expression");
	_g.set(68,"exclusive_or_expression ::= and_expression");
	_g.set(69,"exclusive_or_expression ::= exclusive_or_expression CARET and_expression");
	_g.set(70,"inclusive_or_expression ::= exclusive_or_expression");
	_g.set(71,"inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression");
	_g.set(72,"logical_and_expression ::= inclusive_or_expression");
	_g.set(73,"logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression");
	_g.set(74,"logical_xor_expression ::= logical_and_expression");
	_g.set(75,"logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression");
	_g.set(76,"logical_or_expression ::= logical_xor_expression");
	_g.set(77,"logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression");
	_g.set(78,"conditional_expression ::= logical_or_expression");
	_g.set(79,"conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression");
	_g.set(80,"assignment_expression ::= conditional_expression");
	_g.set(81,"assignment_expression ::= unary_expression assignment_operator assignment_expression");
	_g.set(82,"assignment_operator ::= EQUAL");
	_g.set(83,"assignment_operator ::= MUL_ASSIGN");
	_g.set(84,"assignment_operator ::= DIV_ASSIGN");
	_g.set(85,"assignment_operator ::= MOD_ASSIGN");
	_g.set(86,"assignment_operator ::= ADD_ASSIGN");
	_g.set(87,"assignment_operator ::= SUB_ASSIGN");
	_g.set(88,"assignment_operator ::= LEFT_ASSIGN");
	_g.set(89,"assignment_operator ::= RIGHT_ASSIGN");
	_g.set(90,"assignment_operator ::= AND_ASSIGN");
	_g.set(91,"assignment_operator ::= XOR_ASSIGN");
	_g.set(92,"assignment_operator ::= OR_ASSIGN");
	_g.set(93,"expression ::= assignment_expression");
	_g.set(94,"expression ::= expression COMMA assignment_expression");
	_g.set(95,"constant_expression ::= conditional_expression");
	_g.set(96,"declaration ::= function_prototype SEMICOLON");
	_g.set(97,"declaration ::= init_declarator_list SEMICOLON");
	_g.set(98,"declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON");
	_g.set(99,"function_prototype ::= function_declarator RIGHT_PAREN");
	_g.set(100,"function_declarator ::= function_header");
	_g.set(101,"function_declarator ::= function_header_with_parameters");
	_g.set(102,"function_header_with_parameters ::= function_header parameter_declaration");
	_g.set(103,"function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration");
	_g.set(104,"function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN");
	_g.set(105,"parameter_declarator ::= type_specifier IDENTIFIER");
	_g.set(106,"parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET");
	_g.set(107,"parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator");
	_g.set(108,"parameter_declaration ::= parameter_qualifier parameter_declarator");
	_g.set(109,"parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier");
	_g.set(110,"parameter_declaration ::= parameter_qualifier parameter_type_specifier");
	_g.set(111,"parameter_qualifier ::=");
	_g.set(112,"parameter_qualifier ::= IN");
	_g.set(113,"parameter_qualifier ::= OUT");
	_g.set(114,"parameter_qualifier ::= INOUT");
	_g.set(115,"parameter_type_specifier ::= type_specifier");
	_g.set(116,"parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET");
	_g.set(117,"init_declarator_list ::= single_declaration");
	_g.set(118,"init_declarator_list ::= init_declarator_list COMMA IDENTIFIER");
	_g.set(119,"init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET");
	_g.set(120,"init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer");
	_g.set(121,"single_declaration ::= fully_specified_type");
	_g.set(122,"single_declaration ::= fully_specified_type IDENTIFIER");
	_g.set(123,"single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET");
	_g.set(124,"single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer");
	_g.set(125,"single_declaration ::= INVARIANT IDENTIFIER");
	_g.set(126,"fully_specified_type ::= type_specifier");
	_g.set(127,"fully_specified_type ::= type_qualifier type_specifier");
	_g.set(128,"type_qualifier ::= CONST");
	_g.set(129,"type_qualifier ::= ATTRIBUTE");
	_g.set(130,"type_qualifier ::= VARYING");
	_g.set(131,"type_qualifier ::= INVARIANT VARYING");
	_g.set(132,"type_qualifier ::= UNIFORM");
	_g.set(133,"type_specifier ::= type_specifier_no_prec");
	_g.set(134,"type_specifier ::= precision_qualifier type_specifier_no_prec");
	_g.set(135,"type_specifier_no_prec ::= VOID");
	_g.set(136,"type_specifier_no_prec ::= FLOAT");
	_g.set(137,"type_specifier_no_prec ::= INT");
	_g.set(138,"type_specifier_no_prec ::= BOOL");
	_g.set(139,"type_specifier_no_prec ::= VEC2");
	_g.set(140,"type_specifier_no_prec ::= VEC3");
	_g.set(141,"type_specifier_no_prec ::= VEC4");
	_g.set(142,"type_specifier_no_prec ::= BVEC2");
	_g.set(143,"type_specifier_no_prec ::= BVEC3");
	_g.set(144,"type_specifier_no_prec ::= BVEC4");
	_g.set(145,"type_specifier_no_prec ::= IVEC2");
	_g.set(146,"type_specifier_no_prec ::= IVEC3");
	_g.set(147,"type_specifier_no_prec ::= IVEC4");
	_g.set(148,"type_specifier_no_prec ::= MAT2");
	_g.set(149,"type_specifier_no_prec ::= MAT3");
	_g.set(150,"type_specifier_no_prec ::= MAT4");
	_g.set(151,"type_specifier_no_prec ::= SAMPLER2D");
	_g.set(152,"type_specifier_no_prec ::= SAMPLERCUBE");
	_g.set(153,"type_specifier_no_prec ::= struct_specifier");
	_g.set(154,"type_specifier_no_prec ::= TYPE_NAME");
	_g.set(155,"precision_qualifier ::= HIGH_PRECISION");
	_g.set(156,"precision_qualifier ::= MEDIUM_PRECISION");
	_g.set(157,"precision_qualifier ::= LOW_PRECISION");
	_g.set(158,"struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE");
	_g.set(159,"struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE");
	_g.set(160,"struct_declaration_list ::= struct_declaration");
	_g.set(161,"struct_declaration_list ::= struct_declaration_list struct_declaration");
	_g.set(162,"struct_declaration ::= type_specifier struct_declarator_list SEMICOLON");
	_g.set(163,"struct_declarator_list ::= struct_declarator");
	_g.set(164,"struct_declarator_list ::= struct_declarator_list COMMA struct_declarator");
	_g.set(165,"struct_declarator ::= IDENTIFIER");
	_g.set(166,"struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET");
	_g.set(167,"initializer ::= assignment_expression");
	_g.set(168,"declaration_statement ::= declaration");
	_g.set(169,"statement_no_new_scope ::= compound_statement_with_scope");
	_g.set(170,"statement_no_new_scope ::= simple_statement");
	_g.set(171,"simple_statement ::= declaration_statement");
	_g.set(172,"simple_statement ::= expression_statement");
	_g.set(173,"simple_statement ::= selection_statement");
	_g.set(174,"simple_statement ::= iteration_statement");
	_g.set(175,"simple_statement ::= jump_statement");
	_g.set(176,"compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE");
	_g.set(177,"compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE");
	_g.set(178,"statement_with_scope ::= compound_statement_no_new_scope");
	_g.set(179,"statement_with_scope ::= simple_statement");
	_g.set(180,"compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE");
	_g.set(181,"compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE");
	_g.set(182,"statement_list ::= statement_no_new_scope");
	_g.set(183,"statement_list ::= statement_list statement_no_new_scope");
	_g.set(184,"expression_statement ::= SEMICOLON");
	_g.set(185,"expression_statement ::= expression SEMICOLON");
	_g.set(186,"selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement");
	_g.set(187,"selection_rest_statement ::= statement_with_scope ELSE statement_with_scope");
	_g.set(188,"selection_rest_statement ::= statement_with_scope");
	_g.set(189,"condition ::= expression");
	_g.set(190,"condition ::= fully_specified_type IDENTIFIER EQUAL initializer");
	_g.set(191,"iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope");
	_g.set(192,"iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON");
	_g.set(193,"iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope");
	_g.set(194,"for_init_statement ::= expression_statement");
	_g.set(195,"for_init_statement ::= declaration_statement");
	_g.set(196,"conditionopt ::= condition");
	_g.set(197,"conditionopt ::=");
	_g.set(198,"for_rest_statement ::= conditionopt SEMICOLON");
	_g.set(199,"for_rest_statement ::= conditionopt SEMICOLON expression");
	_g.set(200,"jump_statement ::= CONTINUE SEMICOLON");
	_g.set(201,"jump_statement ::= BREAK SEMICOLON");
	_g.set(202,"jump_statement ::= RETURN SEMICOLON");
	_g.set(203,"jump_statement ::= RETURN expression SEMICOLON");
	_g.set(204,"jump_statement ::= DISCARD SEMICOLON");
	_g.set(205,"translation_unit ::= external_declaration");
	_g.set(206,"translation_unit ::= translation_unit external_declaration");
	_g.set(207,"external_declaration ::= function_definition");
	_g.set(208,"external_declaration ::= declaration");
	_g.set(209,"function_definition ::= function_prototype compound_statement_no_new_scope");
	$r = _g;
	return $r;
}(this));
glslparser.Tokenizer.verbose = false;
glslparser.Tokenizer.floatMode = 0;
glslparser.Tokenizer.operatorRegex = new EReg("[&<=>|*?!+%(){}.~:,;/\\-\\^\\[\\]]","");
glslparser.Tokenizer.startConditionsMap = (function($this) {
	var $r;
	var _g = new haxe.ds.EnumValueMap();
	_g.set(glslparser.ScanMode.BLOCK_COMMENT,function() {
		if(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 2) == "/*") return 2; else return null;
	});
	_g.set(glslparser.ScanMode.LINE_COMMENT,function() {
		if(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 2) == "//") return 2; else return null;
	});
	_g.set(glslparser.ScanMode.PREPROCESSOR,function() {
		if(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "#") return 1; else return null;
	});
	_g.set(glslparser.ScanMode.WHITESPACE,function() {
		if(new EReg("\\s","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i))) return 1; else return null;
	});
	_g.set(glslparser.ScanMode.OPERATOR,function() {
		if(glslparser.Tokenizer.operatorRegex.match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i))) return 1; else return null;
	});
	_g.set(glslparser.ScanMode.LITERAL,function() {
		if(new EReg("[a-z_]","i").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i))) return 1; else return null;
	});
	_g.set(glslparser.ScanMode.HEX_CONSTANT,function() {
		if(new EReg("0x[a-f0-9]","i").match(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 3))) return 3; else return null;
	});
	_g.set(glslparser.ScanMode.OCTAL_CONSTANT,function() {
		if(new EReg("0[0-7]","").match(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 2))) return 2; else return null;
	});
	_g.set(glslparser.ScanMode.DECIMAL_CONSTANT,function() {
		if(new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i))) return 1; else return null;
	});
	_g.set(glslparser.ScanMode.FLOATING_CONSTANT,function() {
		if(glslparser.Tokenizer.startLen(glslparser.ScanMode.FRACTIONAL_CONSTANT) != null) return 0;
		var j = glslparser.Tokenizer.i;
		while(new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(j))) j++;
		var _i = glslparser.Tokenizer.i;
		glslparser.Tokenizer.i = j;
		var exponentFollows = glslparser.Tokenizer.startLen(glslparser.ScanMode.EXPONENT_PART) != null;
		glslparser.Tokenizer.i = _i;
		if(j > glslparser.Tokenizer.i && exponentFollows) return 0;
		return null;
	});
	_g.set(glslparser.ScanMode.FRACTIONAL_CONSTANT,function() {
		var j1 = glslparser.Tokenizer.i;
		while(new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(j1))) j1++;
		if(j1 > glslparser.Tokenizer.i && glslparser.Tokenizer.source.charAt(j1) == ".") return ++j1 - glslparser.Tokenizer.i;
		if(new EReg("\\.\\d","").match(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 2))) return 2; else return null;
	});
	_g.set(glslparser.ScanMode.EXPONENT_PART,function() {
		var r = new EReg("^[e][+-]?\\d","i");
		if(r.match(glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i,glslparser.Tokenizer.i + 3))) return r.matched(0).length; else return null;
	});
	$r = _g;
	return $r;
}(this));
glslparser.Tokenizer.endConditionsMap = (function($this) {
	var $r;
	var _g = new haxe.ds.EnumValueMap();
	_g.set(glslparser.ScanMode.BLOCK_COMMENT,function() {
		return glslparser.Tokenizer.source.substring(glslparser.Tokenizer.i - 2,glslparser.Tokenizer.i) == "*/";
	});
	_g.set(glslparser.ScanMode.LINE_COMMENT,function() {
		return glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "\n" || glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "";
	});
	_g.set(glslparser.ScanMode.PREPROCESSOR,function() {
		return glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "\n" && glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i - 1) != "\\" || glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "";
	});
	_g.set(glslparser.ScanMode.WHITESPACE,function() {
		return !new EReg("\\s","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.OPERATOR,function() {
		return !(function($this) {
			var $r;
			var key = glslparser.Tokenizer.buf + glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i);
			$r = glslparser.Tokenizer.operatorMap.exists(key);
			return $r;
		}(this)) || glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i) == "";
	});
	_g.set(glslparser.ScanMode.LITERAL,function() {
		return !new EReg("[a-z0-9_]","i").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.HEX_CONSTANT,function() {
		return !new EReg("[a-f0-9]","i").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.OCTAL_CONSTANT,function() {
		return !new EReg("[0-7]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.DECIMAL_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.FLOATING_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.FRACTIONAL_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	_g.set(glslparser.ScanMode.EXPONENT_PART,function() {
		return !new EReg("[0-9]","").match(glslparser.Tokenizer.source.charAt(glslparser.Tokenizer.i));
	});
	$r = _g;
	return $r;
}(this));
glslparser.Tokenizer.operatorMap = (function($this) {
	var $r;
	var _g = new haxe.ds.StringMap();
	_g.set("<<",glslparser.TokenType.LEFT_OP);
	_g.set(">>",glslparser.TokenType.RIGHT_OP);
	_g.set("++",glslparser.TokenType.INC_OP);
	_g.set("--",glslparser.TokenType.DEC_OP);
	_g.set("<=",glslparser.TokenType.LE_OP);
	_g.set(">=",glslparser.TokenType.GE_OP);
	_g.set("==",glslparser.TokenType.EQ_OP);
	_g.set("!=",glslparser.TokenType.NE_OP);
	_g.set("&&",glslparser.TokenType.AND_OP);
	_g.set("||",glslparser.TokenType.OR_OP);
	_g.set("^^",glslparser.TokenType.XOR_OP);
	_g.set("*=",glslparser.TokenType.MUL_ASSIGN);
	_g.set("/=",glslparser.TokenType.DIV_ASSIGN);
	_g.set("+=",glslparser.TokenType.ADD_ASSIGN);
	_g.set("%=",glslparser.TokenType.MOD_ASSIGN);
	_g.set("-=",glslparser.TokenType.SUB_ASSIGN);
	_g.set("<<=",glslparser.TokenType.LEFT_ASSIGN);
	_g.set(">>=",glslparser.TokenType.RIGHT_ASSIGN);
	_g.set("&=",glslparser.TokenType.AND_ASSIGN);
	_g.set("^=",glslparser.TokenType.XOR_ASSIGN);
	_g.set("|=",glslparser.TokenType.OR_ASSIGN);
	_g.set("(",glslparser.TokenType.LEFT_PAREN);
	_g.set(")",glslparser.TokenType.RIGHT_PAREN);
	_g.set("[",glslparser.TokenType.LEFT_BRACKET);
	_g.set("]",glslparser.TokenType.RIGHT_BRACKET);
	_g.set("{",glslparser.TokenType.LEFT_BRACE);
	_g.set("}",glslparser.TokenType.RIGHT_BRACE);
	_g.set(".",glslparser.TokenType.DOT);
	_g.set(",",glslparser.TokenType.COMMA);
	_g.set(":",glslparser.TokenType.COLON);
	_g.set("=",glslparser.TokenType.EQUAL);
	_g.set(";",glslparser.TokenType.SEMICOLON);
	_g.set("!",glslparser.TokenType.BANG);
	_g.set("-",glslparser.TokenType.DASH);
	_g.set("~",glslparser.TokenType.TILDE);
	_g.set("+",glslparser.TokenType.PLUS);
	_g.set("*",glslparser.TokenType.STAR);
	_g.set("/",glslparser.TokenType.SLASH);
	_g.set("%",glslparser.TokenType.PERCENT);
	_g.set("<",glslparser.TokenType.LEFT_ANGLE);
	_g.set(">",glslparser.TokenType.RIGHT_ANGLE);
	_g.set("|",glslparser.TokenType.VERTICAL_BAR);
	_g.set("^",glslparser.TokenType.CARET);
	_g.set("&",glslparser.TokenType.AMPERSAND);
	_g.set("?",glslparser.TokenType.QUESTION);
	$r = _g;
	return $r;
}(this));
glslparser.Tokenizer.literalKeywordMap = (function($this) {
	var $r;
	var _g = new haxe.ds.StringMap();
	_g.set("attribute",glslparser.TokenType.ATTRIBUTE);
	_g.set("uniform",glslparser.TokenType.UNIFORM);
	_g.set("varying",glslparser.TokenType.VARYING);
	_g.set("const",glslparser.TokenType.CONST);
	_g.set("void",glslparser.TokenType.VOID);
	_g.set("int",glslparser.TokenType.INT);
	_g.set("float",glslparser.TokenType.FLOAT);
	_g.set("bool",glslparser.TokenType.BOOL);
	_g.set("vec2",glslparser.TokenType.VEC2);
	_g.set("vec3",glslparser.TokenType.VEC3);
	_g.set("vec4",glslparser.TokenType.VEC4);
	_g.set("bvec2",glslparser.TokenType.BVEC2);
	_g.set("bvec3",glslparser.TokenType.BVEC3);
	_g.set("bvec4",glslparser.TokenType.BVEC4);
	_g.set("ivec2",glslparser.TokenType.IVEC2);
	_g.set("ivec3",glslparser.TokenType.IVEC3);
	_g.set("ivec4",glslparser.TokenType.IVEC4);
	_g.set("mat2",glslparser.TokenType.MAT2);
	_g.set("mat3",glslparser.TokenType.MAT3);
	_g.set("mat4",glslparser.TokenType.MAT4);
	_g.set("sampler2D",glslparser.TokenType.SAMPLER2D);
	_g.set("samplerCube",glslparser.TokenType.SAMPLERCUBE);
	_g.set("break",glslparser.TokenType.BREAK);
	_g.set("continue",glslparser.TokenType.CONTINUE);
	_g.set("while",glslparser.TokenType.WHILE);
	_g.set("do",glslparser.TokenType.DO);
	_g.set("for",glslparser.TokenType.FOR);
	_g.set("if",glslparser.TokenType.IF);
	_g.set("else",glslparser.TokenType.ELSE);
	_g.set("return",glslparser.TokenType.RETURN);
	_g.set("discard",glslparser.TokenType.DISCARD);
	_g.set("struct",glslparser.TokenType.STRUCT);
	_g.set("in",glslparser.TokenType.IN);
	_g.set("out",glslparser.TokenType.OUT);
	_g.set("inout",glslparser.TokenType.INOUT);
	_g.set("invariant",glslparser.TokenType.INVARIANT);
	_g.set("precision",glslparser.TokenType.PRECISION);
	_g.set("highp",glslparser.TokenType.HIGH_PRECISION);
	_g.set("mediump",glslparser.TokenType.MEDIUM_PRECISION);
	_g.set("lowp",glslparser.TokenType.LOW_PRECISION);
	_g.set("true",glslparser.TokenType.BOOLCONSTANT);
	_g.set("false",glslparser.TokenType.BOOLCONSTANT);
	_g.set("asm",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("class",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("union",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("enum",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("typedef",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("template",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("this",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("packed",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("goto",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("switch",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("default",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("inline",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("noinline",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("volatile",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("public",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("static",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("extern",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("external",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("interface",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("long",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("short",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("double",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("half",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("fixed",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("unsigned",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("input",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("output",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("hvec2",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("hvec3",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("hvec4",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("dvec2",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("dvec3",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("dvec4",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("fvec2",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("fvec3",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("fvec4",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sampler1DShadow",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sampler2DShadow",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sampler2DRect",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sampler3DRect",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sampler2DRectShadow",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("sizeof",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("cast",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("namespace",glslparser.TokenType.RESERVED_KEYWORD);
	_g.set("using",glslparser.TokenType.RESERVED_KEYWORD);
	$r = _g;
	return $r;
}(this));
js.Boot.__toStr = {}.toString;
Main.main();
})();
