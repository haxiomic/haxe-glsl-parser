(function (console) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
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
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		var tmp;
		if(this.r.m != null && n >= 0 && n < this.r.m.length) tmp = this.r.m[n]; else throw new js__$Boot_HaxeError("EReg::matched");
		return tmp;
	}
	,matchedRight: function() {
		if(this.r.m == null) throw new js__$Boot_HaxeError("No string matched");
		var sz = this.r.m.index + this.r.m[0].length;
		return HxOverrides.substr(this.r.s,sz,this.r.s.length - sz);
	}
	,split: function(s) {
		var d = "#__delim__#";
		return s.replace(this.r,d).split(d);
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
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
var Main = function() {
	this.warnings = [];
	this.inputChanged = false;
	var _g = this;
	this.jsonContainer = window.document.getElementById("json-container");
	this.messagesElement = window.document.getElementById("messages");
	this.warningsElement = window.document.getElementById("warnings");
	this.successElement = window.document.getElementById("success");
	var savedInput = this.loadInput();
	if(savedInput != null) Editor.setValue(savedInput,1); else Editor.setValue("uniform float time;\n\nvoid main( void ){\n\tgl_FragColor = vec4(sin(time), 0.4, 0.8, 1.0);\n}",1);
	Editor.on("change",function(e) {
		_g.inputChanged = true;
	});
	var reparseTimer = new haxe_Timer(500);
	reparseTimer.run = function() {
		if(_g.inputChanged) _g.parseAndEvaluate();
	};
	this.parseAndEvaluate();
};
Main.__name__ = true;
Main.main = function() {
	new Main();
};
Main.prototype = {
	parseAndEvaluate: function() {
		var input = Editor.getValue();
		try {
			this.warnings = [];
			var ast = this.parse(input);
			this.displayAST(ast);
			var pretty = glsl_printer_NodePrinter.print(ast,"\t");
			var plain = glsl_printer_NodePrinter.print(ast,null);
			console.log("-- Pretty --");
			console.log(pretty);
			console.log("-- Plain --");
			console.log(plain);
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			this.warnings = this.warnings.concat([e]);
			this.jsonContainer.innerHTML = "";
		}
		this.saveInput(input);
		this.showErrors(this.warnings);
		this.inputChanged = false;
	}
	,parse: function(input) {
		var tokens = glsl_parser_Tokenizer.tokenize(input);
		this.warnings = this.warnings.concat(glsl_parser_Tokenizer.warnings);
		tokens = glsl_parser_Preprocessor.process(tokens);
		this.warnings = this.warnings.concat(glsl_parser_Preprocessor.warnings);
		var ast = glsl_parser_Parser.parseTokens(tokens);
		this.warnings = this.warnings.concat(glsl_parser_Parser.warnings);
		return ast;
	}
	,displayAST: function(ast) {
		this.jsonContainer.innerHTML = "";
		this.jsonContainer.appendChild((renderjson.set_show_to_level(3).set_sort_objects(true).set_icons("","-"))(ast));
	}
	,showErrors: function(warnings) {
		if(warnings.length > 0) {
			var ul = window.document.createElement("ul");
			var _g = 0;
			while(_g < warnings.length) {
				var w = warnings[_g];
				++_g;
				var li = window.document.createElement("li");
				li.innerHTML = w;
				ul.appendChild(li);
			}
			this.warningsElement.innerHTML = "";
			this.warningsElement.appendChild(ul);
			this.warningsElement.style.width = "100%";
			this.warningsElement.style.display = "";
			this.successElement.innerHTML = "";
			this.successElement.style.display = "none";
			this.messagesElement.className = "error";
		} else {
			this.successElement.innerHTML = "GLSL parsed without error";
			this.successElement.style.width = "100%";
			this.successElement.style.display = "";
			this.warningsElement.innerHTML = "";
			this.warningsElement.style.display = "none";
			this.messagesElement.className = "success";
		}
		window.fitMessageContent();
	}
	,saveInput: function(input) {
		js_Browser.getLocalStorage().setItem("glsl-input",input);
	}
	,loadInput: function() {
		return js_Browser.getLocalStorage().getItem("glsl-input");
	}
	,__class__: Main
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
};
Reflect.isEnumValue = function(v) {
	return v != null && v.__enum__ != null;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { };
Type.__name__ = true;
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = js_Boot.getClass(v);
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2;
		var _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e1 ) {
		if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
		return false;
	}
	return true;
};
var glsl_Node = function() { };
glsl_Node.__name__ = true;
glsl_Node.prototype = {
	__class__: glsl_Node
};
var glsl_Root = function(declarations) {
	this.declarations = declarations;
	this.nodeName = "Root";
};
glsl_Root.__name__ = true;
glsl_Root.__interfaces__ = [glsl_Node];
glsl_Root.prototype = {
	__class__: glsl_Root
};
var glsl_TypeSpecifier = function(dataType,storage,precision,invariant) {
	if(invariant == null) invariant = false;
	this.dataType = dataType;
	this.storage = storage;
	this.precision = precision;
	this.invariant = invariant;
	this.nodeName = "TypeSpecifier";
};
glsl_TypeSpecifier.__name__ = true;
glsl_TypeSpecifier.__interfaces__ = [glsl_Node];
glsl_TypeSpecifier.prototype = {
	__class__: glsl_TypeSpecifier
};
var glsl_StructSpecifier = function(name,fieldDeclarations) {
	this.name = name;
	this.fieldDeclarations = fieldDeclarations;
	glsl_TypeSpecifier.call(this,glsl_DataType.USER_TYPE(name));
	this.nodeName = "StructSpecifier";
};
glsl_StructSpecifier.__name__ = true;
glsl_StructSpecifier.__super__ = glsl_TypeSpecifier;
glsl_StructSpecifier.prototype = $extend(glsl_TypeSpecifier.prototype,{
	__class__: glsl_StructSpecifier
});
var glsl_StructFieldDeclaration = function(typeSpecifier,declarators) {
	this.typeSpecifier = typeSpecifier;
	this.declarators = declarators;
	this.nodeName = "StructFieldDeclaration";
};
glsl_StructFieldDeclaration.__name__ = true;
glsl_StructFieldDeclaration.__interfaces__ = [glsl_Node];
glsl_StructFieldDeclaration.prototype = {
	__class__: glsl_StructFieldDeclaration
};
var glsl_StructDeclarator = function(name,arraySizeExpression) {
	this.name = name;
	this.arraySizeExpression = arraySizeExpression;
	this.nodeName = "StructDeclarator";
};
glsl_StructDeclarator.__name__ = true;
glsl_StructDeclarator.__interfaces__ = [glsl_Node];
glsl_StructDeclarator.prototype = {
	__class__: glsl_StructDeclarator
};
var glsl_Expression = function() { };
glsl_Expression.__name__ = true;
glsl_Expression.__interfaces__ = [glsl_Node];
glsl_Expression.prototype = {
	__class__: glsl_Expression
};
var glsl_TypedExpression = function() { };
glsl_TypedExpression.__name__ = true;
glsl_TypedExpression.prototype = {
	__class__: glsl_TypedExpression
};
var glsl_Identifier = function(name) {
	this.parenWrap = false;
	this.name = name;
	this.nodeName = "Identifier";
};
glsl_Identifier.__name__ = true;
glsl_Identifier.__interfaces__ = [glsl_Expression];
glsl_Identifier.prototype = {
	__class__: glsl_Identifier
};
var glsl_Primitive = function(value,dataType) {
	this.parenWrap = false;
	this.dataType = dataType;
	this.set_value(value);
	this.nodeName = "Primitive";
};
glsl_Primitive.__name__ = true;
glsl_Primitive.__interfaces__ = [glsl_TypedExpression,glsl_Expression];
glsl_Primitive.prototype = {
	set_value: function(v) {
		var _g = this.dataType;
		switch(_g[1]) {
		case 2:
			this.raw = glsl_printer_Utils.glslIntString(v);
			break;
		case 1:
			this.raw = glsl_printer_Utils.glslFloatString(v);
			break;
		case 3:
			this.raw = glsl_printer_Utils.glslBoolString(v);
			break;
		default:
			this.raw = "";
		}
		return this.value = v;
	}
	,__class__: glsl_Primitive
};
var glsl_BinaryExpression = function(op,left,right) {
	this.parenWrap = false;
	this.op = op;
	this.left = left;
	this.right = right;
	this.nodeName = "BinaryExpression";
};
glsl_BinaryExpression.__name__ = true;
glsl_BinaryExpression.__interfaces__ = [glsl_Expression];
glsl_BinaryExpression.prototype = {
	__class__: glsl_BinaryExpression
};
var glsl_UnaryExpression = function(op,arg,isPrefix) {
	this.parenWrap = false;
	this.op = op;
	this.arg = arg;
	this.isPrefix = isPrefix;
	this.nodeName = "UnaryExpression";
};
glsl_UnaryExpression.__name__ = true;
glsl_UnaryExpression.__interfaces__ = [glsl_Expression];
glsl_UnaryExpression.prototype = {
	__class__: glsl_UnaryExpression
};
var glsl_SequenceExpression = function(expressions) {
	this.parenWrap = false;
	this.expressions = expressions;
	this.nodeName = "SequenceExpression";
};
glsl_SequenceExpression.__name__ = true;
glsl_SequenceExpression.__interfaces__ = [glsl_Expression];
glsl_SequenceExpression.prototype = {
	__class__: glsl_SequenceExpression
};
var glsl_ConditionalExpression = function(test,consequent,alternate) {
	this.parenWrap = false;
	this.test = test;
	this.consequent = consequent;
	this.alternate = alternate;
	this.nodeName = "ConditionalExpression";
};
glsl_ConditionalExpression.__name__ = true;
glsl_ConditionalExpression.__interfaces__ = [glsl_Expression];
glsl_ConditionalExpression.prototype = {
	__class__: glsl_ConditionalExpression
};
var glsl_AssignmentExpression = function(op,left,right) {
	this.parenWrap = false;
	this.op = op;
	this.left = left;
	this.right = right;
	this.nodeName = "AssignmentExpression";
};
glsl_AssignmentExpression.__name__ = true;
glsl_AssignmentExpression.__interfaces__ = [glsl_Expression];
glsl_AssignmentExpression.prototype = {
	__class__: glsl_AssignmentExpression
};
var glsl_FieldSelectionExpression = function(left,field) {
	this.parenWrap = false;
	this.left = left;
	this.field = field;
	this.nodeName = "FieldSelectionExpression";
};
glsl_FieldSelectionExpression.__name__ = true;
glsl_FieldSelectionExpression.__interfaces__ = [glsl_Expression];
glsl_FieldSelectionExpression.prototype = {
	__class__: glsl_FieldSelectionExpression
};
var glsl_ArrayElementSelectionExpression = function(left,arrayIndexExpression) {
	this.parenWrap = false;
	this.left = left;
	this.arrayIndexExpression = arrayIndexExpression;
	this.nodeName = "ArrayElementSelectionExpression";
};
glsl_ArrayElementSelectionExpression.__name__ = true;
glsl_ArrayElementSelectionExpression.__interfaces__ = [glsl_Expression];
glsl_ArrayElementSelectionExpression.prototype = {
	__class__: glsl_ArrayElementSelectionExpression
};
var glsl_ExpressionParameters = function() { };
glsl_ExpressionParameters.__name__ = true;
glsl_ExpressionParameters.prototype = {
	__class__: glsl_ExpressionParameters
};
var glsl_FunctionCall = function(name,parameters) {
	this.parenWrap = false;
	this.name = name;
	this.parameters = parameters != null?parameters:[];
	this.nodeName = "FunctionCall";
};
glsl_FunctionCall.__name__ = true;
glsl_FunctionCall.__interfaces__ = [glsl_ExpressionParameters,glsl_Expression];
glsl_FunctionCall.prototype = {
	__class__: glsl_FunctionCall
};
var glsl_Constructor = function(dataType,parameters) {
	this.parenWrap = false;
	this.dataType = dataType;
	this.parameters = parameters != null?parameters:[];
	this.nodeName = "Constructor";
};
glsl_Constructor.__name__ = true;
glsl_Constructor.__interfaces__ = [glsl_TypedExpression,glsl_ExpressionParameters,glsl_Expression];
glsl_Constructor.prototype = {
	__class__: glsl_Constructor
};
var glsl_Declaration = function() { };
glsl_Declaration.__name__ = true;
glsl_Declaration.__interfaces__ = [glsl_Node];
glsl_Declaration.prototype = {
	__class__: glsl_Declaration
};
var glsl_PrecisionDeclaration = function(precision,dataType) {
	this.external = false;
	this.precision = precision;
	this.dataType = dataType;
	this.nodeName = "PrecisionDeclaration";
};
glsl_PrecisionDeclaration.__name__ = true;
glsl_PrecisionDeclaration.__interfaces__ = [glsl_Declaration];
glsl_PrecisionDeclaration.prototype = {
	__class__: glsl_PrecisionDeclaration
};
var glsl_FunctionPrototype = function(header) {
	this.external = false;
	this.header = header;
	this.nodeName = "FunctionPrototype";
};
glsl_FunctionPrototype.__name__ = true;
glsl_FunctionPrototype.__interfaces__ = [glsl_Declaration];
glsl_FunctionPrototype.prototype = {
	__class__: glsl_FunctionPrototype
};
var glsl_VariableDeclaration = function(typeSpecifier,declarators) {
	this.external = false;
	this.typeSpecifier = typeSpecifier;
	this.declarators = declarators;
	this.nodeName = "VariableDeclaration";
};
glsl_VariableDeclaration.__name__ = true;
glsl_VariableDeclaration.__interfaces__ = [glsl_Declaration];
glsl_VariableDeclaration.prototype = {
	__class__: glsl_VariableDeclaration
};
var glsl_Declarator = function(name,initializer,arraySizeExpression) {
	this.name = name;
	this.initializer = initializer;
	this.arraySizeExpression = arraySizeExpression;
	this.nodeName = "Declarator";
};
glsl_Declarator.__name__ = true;
glsl_Declarator.__interfaces__ = [glsl_Node];
glsl_Declarator.prototype = {
	__class__: glsl_Declarator
};
var glsl_ParameterDeclaration = function(name,typeSpecifier,parameterQualifier,arraySizeExpression) {
	this.name = name;
	this.typeSpecifier = typeSpecifier;
	this.parameterQualifier = parameterQualifier;
	this.arraySizeExpression = arraySizeExpression;
	this.nodeName = "ParameterDeclaration";
};
glsl_ParameterDeclaration.__name__ = true;
glsl_ParameterDeclaration.__interfaces__ = [glsl_Node];
glsl_ParameterDeclaration.prototype = {
	__class__: glsl_ParameterDeclaration
};
var glsl_FunctionDefinition = function(header,body) {
	this.external = true;
	this.header = header;
	this.body = body;
	this.nodeName = "FunctionDefinition";
};
glsl_FunctionDefinition.__name__ = true;
glsl_FunctionDefinition.__interfaces__ = [glsl_Declaration];
glsl_FunctionDefinition.prototype = {
	__class__: glsl_FunctionDefinition
};
var glsl_FunctionHeader = function(name,returnType,parameters) {
	this.name = name;
	this.returnType = returnType;
	this.parameters = parameters != null?parameters:[];
	this.nodeName = "FunctionHeader";
};
glsl_FunctionHeader.__name__ = true;
glsl_FunctionHeader.__interfaces__ = [glsl_Node];
glsl_FunctionHeader.prototype = {
	__class__: glsl_FunctionHeader
};
var glsl_Statement = function() { };
glsl_Statement.__name__ = true;
glsl_Statement.__interfaces__ = [glsl_Node];
glsl_Statement.prototype = {
	__class__: glsl_Statement
};
var glsl_CompoundStatement = function(statementList,newScope) {
	this.statementList = statementList;
	this.newScope = newScope;
	this.nodeName = "CompoundStatement";
};
glsl_CompoundStatement.__name__ = true;
glsl_CompoundStatement.__interfaces__ = [glsl_Statement];
glsl_CompoundStatement.prototype = {
	__class__: glsl_CompoundStatement
};
var glsl_DeclarationStatement = function(declaration) {
	this.newScope = false;
	this.declaration = declaration;
	this.nodeName = "DeclarationStatement";
};
glsl_DeclarationStatement.__name__ = true;
glsl_DeclarationStatement.__interfaces__ = [glsl_Statement];
glsl_DeclarationStatement.prototype = {
	__class__: glsl_DeclarationStatement
};
var glsl_ExpressionStatement = function(expression) {
	this.newScope = false;
	this.expression = expression;
	this.nodeName = "ExpressionStatement";
};
glsl_ExpressionStatement.__name__ = true;
glsl_ExpressionStatement.__interfaces__ = [glsl_Statement];
glsl_ExpressionStatement.prototype = {
	__class__: glsl_ExpressionStatement
};
var glsl_IfStatement = function(test,consequent,alternate) {
	this.newScope = false;
	this.test = test;
	this.consequent = consequent;
	this.alternate = alternate;
	this.nodeName = "IfStatement";
};
glsl_IfStatement.__name__ = true;
glsl_IfStatement.__interfaces__ = [glsl_Statement];
glsl_IfStatement.prototype = {
	__class__: glsl_IfStatement
};
var glsl_JumpStatement = function(mode) {
	this.newScope = false;
	this.mode = mode;
	this.nodeName = "JumpStatement";
};
glsl_JumpStatement.__name__ = true;
glsl_JumpStatement.__interfaces__ = [glsl_Statement];
glsl_JumpStatement.prototype = {
	__class__: glsl_JumpStatement
};
var glsl_ReturnStatement = function(returnExpression) {
	this.returnExpression = returnExpression;
	glsl_JumpStatement.call(this,glsl_JumpMode.RETURN);
	this.nodeName = "ReturnStatement";
};
glsl_ReturnStatement.__name__ = true;
glsl_ReturnStatement.__super__ = glsl_JumpStatement;
glsl_ReturnStatement.prototype = $extend(glsl_JumpStatement.prototype,{
	__class__: glsl_ReturnStatement
});
var glsl_IterationStatement = function() { };
glsl_IterationStatement.__name__ = true;
glsl_IterationStatement.__interfaces__ = [glsl_Statement];
glsl_IterationStatement.prototype = {
	__class__: glsl_IterationStatement
};
var glsl_WhileStatement = function(test,body) {
	this.newScope = false;
	this.test = test;
	this.body = body;
	this.nodeName = "WhileStatement";
};
glsl_WhileStatement.__name__ = true;
glsl_WhileStatement.__interfaces__ = [glsl_IterationStatement];
glsl_WhileStatement.prototype = {
	__class__: glsl_WhileStatement
};
var glsl_DoWhileStatement = function(test,body) {
	this.newScope = false;
	this.test = test;
	this.body = body;
	this.nodeName = "DoWhileStatement";
};
glsl_DoWhileStatement.__name__ = true;
glsl_DoWhileStatement.__interfaces__ = [glsl_IterationStatement];
glsl_DoWhileStatement.prototype = {
	__class__: glsl_DoWhileStatement
};
var glsl_ForStatement = function(init,test,update,body) {
	this.newScope = false;
	this.init = init;
	this.test = test;
	this.update = update;
	this.body = body;
	this.nodeName = "ForStatement";
};
glsl_ForStatement.__name__ = true;
glsl_ForStatement.__interfaces__ = [glsl_IterationStatement];
glsl_ForStatement.prototype = {
	__class__: glsl_ForStatement
};
var glsl_PreprocessorDirective = function(content) {
	this.newScope = false;
	this.external = true;
	this.content = content;
	this.nodeName = "PreprocessorDirective";
};
glsl_PreprocessorDirective.__name__ = true;
glsl_PreprocessorDirective.__interfaces__ = [glsl_Statement,glsl_Declaration];
glsl_PreprocessorDirective.prototype = {
	__class__: glsl_PreprocessorDirective
};
var glsl_BinaryOperator = { __ename__ : true, __constructs__ : ["STAR","SLASH","PERCENT","PLUS","DASH","LEFT_OP","RIGHT_OP","LEFT_ANGLE","RIGHT_ANGLE","LE_OP","GE_OP","EQ_OP","NE_OP","AMPERSAND","CARET","VERTICAL_BAR","AND_OP","XOR_OP","OR_OP"] };
glsl_BinaryOperator.STAR = ["STAR",0];
glsl_BinaryOperator.STAR.toString = $estr;
glsl_BinaryOperator.STAR.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.SLASH = ["SLASH",1];
glsl_BinaryOperator.SLASH.toString = $estr;
glsl_BinaryOperator.SLASH.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.PERCENT = ["PERCENT",2];
glsl_BinaryOperator.PERCENT.toString = $estr;
glsl_BinaryOperator.PERCENT.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.PLUS = ["PLUS",3];
glsl_BinaryOperator.PLUS.toString = $estr;
glsl_BinaryOperator.PLUS.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.DASH = ["DASH",4];
glsl_BinaryOperator.DASH.toString = $estr;
glsl_BinaryOperator.DASH.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.LEFT_OP = ["LEFT_OP",5];
glsl_BinaryOperator.LEFT_OP.toString = $estr;
glsl_BinaryOperator.LEFT_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.RIGHT_OP = ["RIGHT_OP",6];
glsl_BinaryOperator.RIGHT_OP.toString = $estr;
glsl_BinaryOperator.RIGHT_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.LEFT_ANGLE = ["LEFT_ANGLE",7];
glsl_BinaryOperator.LEFT_ANGLE.toString = $estr;
glsl_BinaryOperator.LEFT_ANGLE.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.RIGHT_ANGLE = ["RIGHT_ANGLE",8];
glsl_BinaryOperator.RIGHT_ANGLE.toString = $estr;
glsl_BinaryOperator.RIGHT_ANGLE.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.LE_OP = ["LE_OP",9];
glsl_BinaryOperator.LE_OP.toString = $estr;
glsl_BinaryOperator.LE_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.GE_OP = ["GE_OP",10];
glsl_BinaryOperator.GE_OP.toString = $estr;
glsl_BinaryOperator.GE_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.EQ_OP = ["EQ_OP",11];
glsl_BinaryOperator.EQ_OP.toString = $estr;
glsl_BinaryOperator.EQ_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.NE_OP = ["NE_OP",12];
glsl_BinaryOperator.NE_OP.toString = $estr;
glsl_BinaryOperator.NE_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.AMPERSAND = ["AMPERSAND",13];
glsl_BinaryOperator.AMPERSAND.toString = $estr;
glsl_BinaryOperator.AMPERSAND.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.CARET = ["CARET",14];
glsl_BinaryOperator.CARET.toString = $estr;
glsl_BinaryOperator.CARET.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.VERTICAL_BAR = ["VERTICAL_BAR",15];
glsl_BinaryOperator.VERTICAL_BAR.toString = $estr;
glsl_BinaryOperator.VERTICAL_BAR.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.AND_OP = ["AND_OP",16];
glsl_BinaryOperator.AND_OP.toString = $estr;
glsl_BinaryOperator.AND_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.XOR_OP = ["XOR_OP",17];
glsl_BinaryOperator.XOR_OP.toString = $estr;
glsl_BinaryOperator.XOR_OP.__enum__ = glsl_BinaryOperator;
glsl_BinaryOperator.OR_OP = ["OR_OP",18];
glsl_BinaryOperator.OR_OP.toString = $estr;
glsl_BinaryOperator.OR_OP.__enum__ = glsl_BinaryOperator;
var glsl_UnaryOperator = { __ename__ : true, __constructs__ : ["INC_OP","DEC_OP","PLUS","DASH","BANG","TILDE"] };
glsl_UnaryOperator.INC_OP = ["INC_OP",0];
glsl_UnaryOperator.INC_OP.toString = $estr;
glsl_UnaryOperator.INC_OP.__enum__ = glsl_UnaryOperator;
glsl_UnaryOperator.DEC_OP = ["DEC_OP",1];
glsl_UnaryOperator.DEC_OP.toString = $estr;
glsl_UnaryOperator.DEC_OP.__enum__ = glsl_UnaryOperator;
glsl_UnaryOperator.PLUS = ["PLUS",2];
glsl_UnaryOperator.PLUS.toString = $estr;
glsl_UnaryOperator.PLUS.__enum__ = glsl_UnaryOperator;
glsl_UnaryOperator.DASH = ["DASH",3];
glsl_UnaryOperator.DASH.toString = $estr;
glsl_UnaryOperator.DASH.__enum__ = glsl_UnaryOperator;
glsl_UnaryOperator.BANG = ["BANG",4];
glsl_UnaryOperator.BANG.toString = $estr;
glsl_UnaryOperator.BANG.__enum__ = glsl_UnaryOperator;
glsl_UnaryOperator.TILDE = ["TILDE",5];
glsl_UnaryOperator.TILDE.toString = $estr;
glsl_UnaryOperator.TILDE.__enum__ = glsl_UnaryOperator;
var glsl_AssignmentOperator = { __ename__ : true, __constructs__ : ["EQUAL","MUL_ASSIGN","DIV_ASSIGN","MOD_ASSIGN","ADD_ASSIGN","SUB_ASSIGN","LEFT_ASSIGN","RIGHT_ASSIGN","AND_ASSIGN","XOR_ASSIGN","OR_ASSIGN"] };
glsl_AssignmentOperator.EQUAL = ["EQUAL",0];
glsl_AssignmentOperator.EQUAL.toString = $estr;
glsl_AssignmentOperator.EQUAL.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.MUL_ASSIGN = ["MUL_ASSIGN",1];
glsl_AssignmentOperator.MUL_ASSIGN.toString = $estr;
glsl_AssignmentOperator.MUL_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.DIV_ASSIGN = ["DIV_ASSIGN",2];
glsl_AssignmentOperator.DIV_ASSIGN.toString = $estr;
glsl_AssignmentOperator.DIV_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.MOD_ASSIGN = ["MOD_ASSIGN",3];
glsl_AssignmentOperator.MOD_ASSIGN.toString = $estr;
glsl_AssignmentOperator.MOD_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.ADD_ASSIGN = ["ADD_ASSIGN",4];
glsl_AssignmentOperator.ADD_ASSIGN.toString = $estr;
glsl_AssignmentOperator.ADD_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.SUB_ASSIGN = ["SUB_ASSIGN",5];
glsl_AssignmentOperator.SUB_ASSIGN.toString = $estr;
glsl_AssignmentOperator.SUB_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.LEFT_ASSIGN = ["LEFT_ASSIGN",6];
glsl_AssignmentOperator.LEFT_ASSIGN.toString = $estr;
glsl_AssignmentOperator.LEFT_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.RIGHT_ASSIGN = ["RIGHT_ASSIGN",7];
glsl_AssignmentOperator.RIGHT_ASSIGN.toString = $estr;
glsl_AssignmentOperator.RIGHT_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.AND_ASSIGN = ["AND_ASSIGN",8];
glsl_AssignmentOperator.AND_ASSIGN.toString = $estr;
glsl_AssignmentOperator.AND_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.XOR_ASSIGN = ["XOR_ASSIGN",9];
glsl_AssignmentOperator.XOR_ASSIGN.toString = $estr;
glsl_AssignmentOperator.XOR_ASSIGN.__enum__ = glsl_AssignmentOperator;
glsl_AssignmentOperator.OR_ASSIGN = ["OR_ASSIGN",10];
glsl_AssignmentOperator.OR_ASSIGN.toString = $estr;
glsl_AssignmentOperator.OR_ASSIGN.__enum__ = glsl_AssignmentOperator;
var glsl_PrecisionQualifier = { __ename__ : true, __constructs__ : ["HIGH_PRECISION","MEDIUM_PRECISION","LOW_PRECISION"] };
glsl_PrecisionQualifier.HIGH_PRECISION = ["HIGH_PRECISION",0];
glsl_PrecisionQualifier.HIGH_PRECISION.toString = $estr;
glsl_PrecisionQualifier.HIGH_PRECISION.__enum__ = glsl_PrecisionQualifier;
glsl_PrecisionQualifier.MEDIUM_PRECISION = ["MEDIUM_PRECISION",1];
glsl_PrecisionQualifier.MEDIUM_PRECISION.toString = $estr;
glsl_PrecisionQualifier.MEDIUM_PRECISION.__enum__ = glsl_PrecisionQualifier;
glsl_PrecisionQualifier.LOW_PRECISION = ["LOW_PRECISION",2];
glsl_PrecisionQualifier.LOW_PRECISION.toString = $estr;
glsl_PrecisionQualifier.LOW_PRECISION.__enum__ = glsl_PrecisionQualifier;
var glsl_JumpMode = { __ename__ : true, __constructs__ : ["CONTINUE","BREAK","RETURN","DISCARD"] };
glsl_JumpMode.CONTINUE = ["CONTINUE",0];
glsl_JumpMode.CONTINUE.toString = $estr;
glsl_JumpMode.CONTINUE.__enum__ = glsl_JumpMode;
glsl_JumpMode.BREAK = ["BREAK",1];
glsl_JumpMode.BREAK.toString = $estr;
glsl_JumpMode.BREAK.__enum__ = glsl_JumpMode;
glsl_JumpMode.RETURN = ["RETURN",2];
glsl_JumpMode.RETURN.toString = $estr;
glsl_JumpMode.RETURN.__enum__ = glsl_JumpMode;
glsl_JumpMode.DISCARD = ["DISCARD",3];
glsl_JumpMode.DISCARD.toString = $estr;
glsl_JumpMode.DISCARD.__enum__ = glsl_JumpMode;
var glsl_DataType = { __ename__ : true, __constructs__ : ["VOID","FLOAT","INT","BOOL","VEC2","VEC3","VEC4","BVEC2","BVEC3","BVEC4","IVEC2","IVEC3","IVEC4","MAT2","MAT3","MAT4","SAMPLER2D","SAMPLERCUBE","USER_TYPE"] };
glsl_DataType.VOID = ["VOID",0];
glsl_DataType.VOID.toString = $estr;
glsl_DataType.VOID.__enum__ = glsl_DataType;
glsl_DataType.FLOAT = ["FLOAT",1];
glsl_DataType.FLOAT.toString = $estr;
glsl_DataType.FLOAT.__enum__ = glsl_DataType;
glsl_DataType.INT = ["INT",2];
glsl_DataType.INT.toString = $estr;
glsl_DataType.INT.__enum__ = glsl_DataType;
glsl_DataType.BOOL = ["BOOL",3];
glsl_DataType.BOOL.toString = $estr;
glsl_DataType.BOOL.__enum__ = glsl_DataType;
glsl_DataType.VEC2 = ["VEC2",4];
glsl_DataType.VEC2.toString = $estr;
glsl_DataType.VEC2.__enum__ = glsl_DataType;
glsl_DataType.VEC3 = ["VEC3",5];
glsl_DataType.VEC3.toString = $estr;
glsl_DataType.VEC3.__enum__ = glsl_DataType;
glsl_DataType.VEC4 = ["VEC4",6];
glsl_DataType.VEC4.toString = $estr;
glsl_DataType.VEC4.__enum__ = glsl_DataType;
glsl_DataType.BVEC2 = ["BVEC2",7];
glsl_DataType.BVEC2.toString = $estr;
glsl_DataType.BVEC2.__enum__ = glsl_DataType;
glsl_DataType.BVEC3 = ["BVEC3",8];
glsl_DataType.BVEC3.toString = $estr;
glsl_DataType.BVEC3.__enum__ = glsl_DataType;
glsl_DataType.BVEC4 = ["BVEC4",9];
glsl_DataType.BVEC4.toString = $estr;
glsl_DataType.BVEC4.__enum__ = glsl_DataType;
glsl_DataType.IVEC2 = ["IVEC2",10];
glsl_DataType.IVEC2.toString = $estr;
glsl_DataType.IVEC2.__enum__ = glsl_DataType;
glsl_DataType.IVEC3 = ["IVEC3",11];
glsl_DataType.IVEC3.toString = $estr;
glsl_DataType.IVEC3.__enum__ = glsl_DataType;
glsl_DataType.IVEC4 = ["IVEC4",12];
glsl_DataType.IVEC4.toString = $estr;
glsl_DataType.IVEC4.__enum__ = glsl_DataType;
glsl_DataType.MAT2 = ["MAT2",13];
glsl_DataType.MAT2.toString = $estr;
glsl_DataType.MAT2.__enum__ = glsl_DataType;
glsl_DataType.MAT3 = ["MAT3",14];
glsl_DataType.MAT3.toString = $estr;
glsl_DataType.MAT3.__enum__ = glsl_DataType;
glsl_DataType.MAT4 = ["MAT4",15];
glsl_DataType.MAT4.toString = $estr;
glsl_DataType.MAT4.__enum__ = glsl_DataType;
glsl_DataType.SAMPLER2D = ["SAMPLER2D",16];
glsl_DataType.SAMPLER2D.toString = $estr;
glsl_DataType.SAMPLER2D.__enum__ = glsl_DataType;
glsl_DataType.SAMPLERCUBE = ["SAMPLERCUBE",17];
glsl_DataType.SAMPLERCUBE.toString = $estr;
glsl_DataType.SAMPLERCUBE.__enum__ = glsl_DataType;
glsl_DataType.USER_TYPE = function(name) { var $x = ["USER_TYPE",18,name]; $x.__enum__ = glsl_DataType; $x.toString = $estr; return $x; };
var glsl_ParameterQualifier = { __ename__ : true, __constructs__ : ["IN","OUT","INOUT"] };
glsl_ParameterQualifier.IN = ["IN",0];
glsl_ParameterQualifier.IN.toString = $estr;
glsl_ParameterQualifier.IN.__enum__ = glsl_ParameterQualifier;
glsl_ParameterQualifier.OUT = ["OUT",1];
glsl_ParameterQualifier.OUT.toString = $estr;
glsl_ParameterQualifier.OUT.__enum__ = glsl_ParameterQualifier;
glsl_ParameterQualifier.INOUT = ["INOUT",2];
glsl_ParameterQualifier.INOUT.toString = $estr;
glsl_ParameterQualifier.INOUT.__enum__ = glsl_ParameterQualifier;
var glsl_StorageQualifier = { __ename__ : true, __constructs__ : ["CONST","ATTRIBUTE","VARYING","UNIFORM"] };
glsl_StorageQualifier.CONST = ["CONST",0];
glsl_StorageQualifier.CONST.toString = $estr;
glsl_StorageQualifier.CONST.__enum__ = glsl_StorageQualifier;
glsl_StorageQualifier.ATTRIBUTE = ["ATTRIBUTE",1];
glsl_StorageQualifier.ATTRIBUTE.toString = $estr;
glsl_StorageQualifier.ATTRIBUTE.__enum__ = glsl_StorageQualifier;
glsl_StorageQualifier.VARYING = ["VARYING",2];
glsl_StorageQualifier.VARYING.toString = $estr;
glsl_StorageQualifier.VARYING.__enum__ = glsl_StorageQualifier;
glsl_StorageQualifier.UNIFORM = ["UNIFORM",3];
glsl_StorageQualifier.UNIFORM.toString = $estr;
glsl_StorageQualifier.UNIFORM.__enum__ = glsl_StorageQualifier;
var glsl_NodeEnum = { __ename__ : true, __constructs__ : ["RootNode","TypeSpecifierNode","StructSpecifierNode","StructFieldDeclarationNode","StructDeclaratorNode","ExpressionNode","IdentifierNode","PrimitiveNode","BinaryExpressionNode","UnaryExpressionNode","SequenceExpressionNode","ConditionalExpressionNode","AssignmentExpressionNode","FieldSelectionExpressionNode","ArrayElementSelectionExpressionNode","FunctionCallNode","ConstructorNode","DeclarationNode","PrecisionDeclarationNode","VariableDeclarationNode","DeclaratorNode","ParameterDeclarationNode","FunctionDefinitionNode","FunctionPrototypeNode","FunctionHeaderNode","StatementNode","CompoundStatementNode","DeclarationStatementNode","ExpressionStatementNode","IterationStatementNode","WhileStatementNode","DoWhileStatementNode","ForStatementNode","IfStatementNode","JumpStatementNode","ReturnStatementNode","PreprocessorDirectiveNode"] };
glsl_NodeEnum.RootNode = function(n) { var $x = ["RootNode",0,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.TypeSpecifierNode = function(n) { var $x = ["TypeSpecifierNode",1,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.StructSpecifierNode = function(n) { var $x = ["StructSpecifierNode",2,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.StructFieldDeclarationNode = function(n) { var $x = ["StructFieldDeclarationNode",3,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.StructDeclaratorNode = function(n) { var $x = ["StructDeclaratorNode",4,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ExpressionNode = function(n) { var $x = ["ExpressionNode",5,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.IdentifierNode = function(n) { var $x = ["IdentifierNode",6,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.PrimitiveNode = function(n) { var $x = ["PrimitiveNode",7,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.BinaryExpressionNode = function(n) { var $x = ["BinaryExpressionNode",8,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.UnaryExpressionNode = function(n) { var $x = ["UnaryExpressionNode",9,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.SequenceExpressionNode = function(n) { var $x = ["SequenceExpressionNode",10,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ConditionalExpressionNode = function(n) { var $x = ["ConditionalExpressionNode",11,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.AssignmentExpressionNode = function(n) { var $x = ["AssignmentExpressionNode",12,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.FieldSelectionExpressionNode = function(n) { var $x = ["FieldSelectionExpressionNode",13,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ArrayElementSelectionExpressionNode = function(n) { var $x = ["ArrayElementSelectionExpressionNode",14,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.FunctionCallNode = function(n) { var $x = ["FunctionCallNode",15,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ConstructorNode = function(n) { var $x = ["ConstructorNode",16,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.DeclarationNode = function(n) { var $x = ["DeclarationNode",17,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.PrecisionDeclarationNode = function(n) { var $x = ["PrecisionDeclarationNode",18,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.VariableDeclarationNode = function(n) { var $x = ["VariableDeclarationNode",19,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.DeclaratorNode = function(n) { var $x = ["DeclaratorNode",20,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ParameterDeclarationNode = function(n) { var $x = ["ParameterDeclarationNode",21,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.FunctionDefinitionNode = function(n) { var $x = ["FunctionDefinitionNode",22,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.FunctionPrototypeNode = function(n) { var $x = ["FunctionPrototypeNode",23,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.FunctionHeaderNode = function(n) { var $x = ["FunctionHeaderNode",24,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.StatementNode = function(n) { var $x = ["StatementNode",25,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.CompoundStatementNode = function(n) { var $x = ["CompoundStatementNode",26,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.DeclarationStatementNode = function(n) { var $x = ["DeclarationStatementNode",27,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ExpressionStatementNode = function(n) { var $x = ["ExpressionStatementNode",28,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.IterationStatementNode = function(n) { var $x = ["IterationStatementNode",29,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.WhileStatementNode = function(n) { var $x = ["WhileStatementNode",30,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.DoWhileStatementNode = function(n) { var $x = ["DoWhileStatementNode",31,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ForStatementNode = function(n) { var $x = ["ForStatementNode",32,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.IfStatementNode = function(n) { var $x = ["IfStatementNode",33,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.JumpStatementNode = function(n) { var $x = ["JumpStatementNode",34,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.ReturnStatementNode = function(n) { var $x = ["ReturnStatementNode",35,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
glsl_NodeEnum.PreprocessorDirectiveNode = function(n) { var $x = ["PreprocessorDirectiveNode",36,n]; $x.__enum__ = glsl_NodeEnum; $x.toString = $estr; return $x; };
var glsl_NodeEnumHelper = function() { };
glsl_NodeEnumHelper.__name__ = true;
glsl_NodeEnumHelper.toEnum = function(n) {
	return (function($this) {
		var $r;
		var _g = Type["typeof"](n);
		$r = _g == null?null:(function($this) {
			var $r;
			switch(_g[1]) {
			case 6:
				$r = (function($this) {
					var $r;
					switch(_g[2]) {
					case glsl_Root:
						$r = glsl_NodeEnum.RootNode(n);
						break;
					case glsl_TypeSpecifier:
						$r = glsl_NodeEnum.TypeSpecifierNode(n);
						break;
					case glsl_StructSpecifier:
						$r = glsl_NodeEnum.StructSpecifierNode(n);
						break;
					case glsl_StructFieldDeclaration:
						$r = glsl_NodeEnum.StructFieldDeclarationNode(n);
						break;
					case glsl_StructDeclarator:
						$r = glsl_NodeEnum.StructDeclaratorNode(n);
						break;
					case glsl_Expression:
						$r = glsl_NodeEnum.ExpressionNode(n);
						break;
					case glsl_Identifier:
						$r = glsl_NodeEnum.IdentifierNode(n);
						break;
					case glsl_Primitive:
						$r = glsl_NodeEnum.PrimitiveNode(n);
						break;
					case glsl_BinaryExpression:
						$r = glsl_NodeEnum.BinaryExpressionNode(n);
						break;
					case glsl_UnaryExpression:
						$r = glsl_NodeEnum.UnaryExpressionNode(n);
						break;
					case glsl_SequenceExpression:
						$r = glsl_NodeEnum.SequenceExpressionNode(n);
						break;
					case glsl_ConditionalExpression:
						$r = glsl_NodeEnum.ConditionalExpressionNode(n);
						break;
					case glsl_AssignmentExpression:
						$r = glsl_NodeEnum.AssignmentExpressionNode(n);
						break;
					case glsl_FieldSelectionExpression:
						$r = glsl_NodeEnum.FieldSelectionExpressionNode(n);
						break;
					case glsl_ArrayElementSelectionExpression:
						$r = glsl_NodeEnum.ArrayElementSelectionExpressionNode(n);
						break;
					case glsl_FunctionCall:
						$r = glsl_NodeEnum.FunctionCallNode(n);
						break;
					case glsl_Constructor:
						$r = glsl_NodeEnum.ConstructorNode(n);
						break;
					case glsl_Declaration:
						$r = glsl_NodeEnum.DeclarationNode(n);
						break;
					case glsl_PrecisionDeclaration:
						$r = glsl_NodeEnum.PrecisionDeclarationNode(n);
						break;
					case glsl_VariableDeclaration:
						$r = glsl_NodeEnum.VariableDeclarationNode(n);
						break;
					case glsl_Declarator:
						$r = glsl_NodeEnum.DeclaratorNode(n);
						break;
					case glsl_ParameterDeclaration:
						$r = glsl_NodeEnum.ParameterDeclarationNode(n);
						break;
					case glsl_FunctionDefinition:
						$r = glsl_NodeEnum.FunctionDefinitionNode(n);
						break;
					case glsl_FunctionPrototype:
						$r = glsl_NodeEnum.FunctionPrototypeNode(n);
						break;
					case glsl_FunctionHeader:
						$r = glsl_NodeEnum.FunctionHeaderNode(n);
						break;
					case glsl_Statement:
						$r = glsl_NodeEnum.StatementNode(n);
						break;
					case glsl_CompoundStatement:
						$r = glsl_NodeEnum.CompoundStatementNode(n);
						break;
					case glsl_DeclarationStatement:
						$r = glsl_NodeEnum.DeclarationStatementNode(n);
						break;
					case glsl_ExpressionStatement:
						$r = glsl_NodeEnum.ExpressionStatementNode(n);
						break;
					case glsl_IterationStatement:
						$r = glsl_NodeEnum.IterationStatementNode(n);
						break;
					case glsl_WhileStatement:
						$r = glsl_NodeEnum.WhileStatementNode(n);
						break;
					case glsl_DoWhileStatement:
						$r = glsl_NodeEnum.DoWhileStatementNode(n);
						break;
					case glsl_ForStatement:
						$r = glsl_NodeEnum.ForStatementNode(n);
						break;
					case glsl_IfStatement:
						$r = glsl_NodeEnum.IfStatementNode(n);
						break;
					case glsl_JumpStatement:
						$r = glsl_NodeEnum.JumpStatementNode(n);
						break;
					case glsl_ReturnStatement:
						$r = glsl_NodeEnum.ReturnStatementNode(n);
						break;
					case glsl_PreprocessorDirective:
						$r = glsl_NodeEnum.PreprocessorDirectiveNode(n);
						break;
					default:
						$r = null;
					}
					return $r;
				}($this));
				break;
			default:
				$r = null;
			}
			return $r;
		}($this));
		return $r;
	}(this));
};
var glsl_parser_TokenType = { __ename__ : true, __constructs__ : ["ATTRIBUTE","CONST","BOOL","FLOAT","INT","BREAK","CONTINUE","DO","ELSE","FOR","IF","DISCARD","RETURN","BVEC2","BVEC3","BVEC4","IVEC2","IVEC3","IVEC4","VEC2","VEC3","VEC4","MAT2","MAT3","MAT4","IN","OUT","INOUT","UNIFORM","VARYING","SAMPLER2D","SAMPLERCUBE","STRUCT","VOID","WHILE","INVARIANT","HIGH_PRECISION","MEDIUM_PRECISION","LOW_PRECISION","PRECISION","BOOLCONSTANT","IDENTIFIER","TYPE_NAME","FIELD_SELECTION","LEFT_OP","RIGHT_OP","INC_OP","DEC_OP","LE_OP","GE_OP","EQ_OP","NE_OP","AND_OP","OR_OP","XOR_OP","MUL_ASSIGN","DIV_ASSIGN","ADD_ASSIGN","MOD_ASSIGN","SUB_ASSIGN","LEFT_ASSIGN","RIGHT_ASSIGN","AND_ASSIGN","XOR_ASSIGN","OR_ASSIGN","LEFT_PAREN","RIGHT_PAREN","LEFT_BRACKET","RIGHT_BRACKET","LEFT_BRACE","RIGHT_BRACE","DOT","COMMA","COLON","EQUAL","SEMICOLON","BANG","DASH","TILDE","PLUS","STAR","SLASH","PERCENT","LEFT_ANGLE","RIGHT_ANGLE","VERTICAL_BAR","CARET","AMPERSAND","QUESTION","INTCONSTANT","FLOATCONSTANT","WHITESPACE","BLOCK_COMMENT","LINE_COMMENT","PREPROCESSOR_DIRECTIVE","RESERVED_KEYWORD"] };
glsl_parser_TokenType.ATTRIBUTE = ["ATTRIBUTE",0];
glsl_parser_TokenType.ATTRIBUTE.toString = $estr;
glsl_parser_TokenType.ATTRIBUTE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.CONST = ["CONST",1];
glsl_parser_TokenType.CONST.toString = $estr;
glsl_parser_TokenType.CONST.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BOOL = ["BOOL",2];
glsl_parser_TokenType.BOOL.toString = $estr;
glsl_parser_TokenType.BOOL.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.FLOAT = ["FLOAT",3];
glsl_parser_TokenType.FLOAT.toString = $estr;
glsl_parser_TokenType.FLOAT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.INT = ["INT",4];
glsl_parser_TokenType.INT.toString = $estr;
glsl_parser_TokenType.INT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BREAK = ["BREAK",5];
glsl_parser_TokenType.BREAK.toString = $estr;
glsl_parser_TokenType.BREAK.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.CONTINUE = ["CONTINUE",6];
glsl_parser_TokenType.CONTINUE.toString = $estr;
glsl_parser_TokenType.CONTINUE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DO = ["DO",7];
glsl_parser_TokenType.DO.toString = $estr;
glsl_parser_TokenType.DO.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.ELSE = ["ELSE",8];
glsl_parser_TokenType.ELSE.toString = $estr;
glsl_parser_TokenType.ELSE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.FOR = ["FOR",9];
glsl_parser_TokenType.FOR.toString = $estr;
glsl_parser_TokenType.FOR.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IF = ["IF",10];
glsl_parser_TokenType.IF.toString = $estr;
glsl_parser_TokenType.IF.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DISCARD = ["DISCARD",11];
glsl_parser_TokenType.DISCARD.toString = $estr;
glsl_parser_TokenType.DISCARD.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RETURN = ["RETURN",12];
glsl_parser_TokenType.RETURN.toString = $estr;
glsl_parser_TokenType.RETURN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BVEC2 = ["BVEC2",13];
glsl_parser_TokenType.BVEC2.toString = $estr;
glsl_parser_TokenType.BVEC2.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BVEC3 = ["BVEC3",14];
glsl_parser_TokenType.BVEC3.toString = $estr;
glsl_parser_TokenType.BVEC3.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BVEC4 = ["BVEC4",15];
glsl_parser_TokenType.BVEC4.toString = $estr;
glsl_parser_TokenType.BVEC4.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IVEC2 = ["IVEC2",16];
glsl_parser_TokenType.IVEC2.toString = $estr;
glsl_parser_TokenType.IVEC2.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IVEC3 = ["IVEC3",17];
glsl_parser_TokenType.IVEC3.toString = $estr;
glsl_parser_TokenType.IVEC3.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IVEC4 = ["IVEC4",18];
glsl_parser_TokenType.IVEC4.toString = $estr;
glsl_parser_TokenType.IVEC4.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VEC2 = ["VEC2",19];
glsl_parser_TokenType.VEC2.toString = $estr;
glsl_parser_TokenType.VEC2.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VEC3 = ["VEC3",20];
glsl_parser_TokenType.VEC3.toString = $estr;
glsl_parser_TokenType.VEC3.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VEC4 = ["VEC4",21];
glsl_parser_TokenType.VEC4.toString = $estr;
glsl_parser_TokenType.VEC4.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MAT2 = ["MAT2",22];
glsl_parser_TokenType.MAT2.toString = $estr;
glsl_parser_TokenType.MAT2.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MAT3 = ["MAT3",23];
glsl_parser_TokenType.MAT3.toString = $estr;
glsl_parser_TokenType.MAT3.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MAT4 = ["MAT4",24];
glsl_parser_TokenType.MAT4.toString = $estr;
glsl_parser_TokenType.MAT4.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IN = ["IN",25];
glsl_parser_TokenType.IN.toString = $estr;
glsl_parser_TokenType.IN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.OUT = ["OUT",26];
glsl_parser_TokenType.OUT.toString = $estr;
glsl_parser_TokenType.OUT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.INOUT = ["INOUT",27];
glsl_parser_TokenType.INOUT.toString = $estr;
glsl_parser_TokenType.INOUT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.UNIFORM = ["UNIFORM",28];
glsl_parser_TokenType.UNIFORM.toString = $estr;
glsl_parser_TokenType.UNIFORM.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VARYING = ["VARYING",29];
glsl_parser_TokenType.VARYING.toString = $estr;
glsl_parser_TokenType.VARYING.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.SAMPLER2D = ["SAMPLER2D",30];
glsl_parser_TokenType.SAMPLER2D.toString = $estr;
glsl_parser_TokenType.SAMPLER2D.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.SAMPLERCUBE = ["SAMPLERCUBE",31];
glsl_parser_TokenType.SAMPLERCUBE.toString = $estr;
glsl_parser_TokenType.SAMPLERCUBE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.STRUCT = ["STRUCT",32];
glsl_parser_TokenType.STRUCT.toString = $estr;
glsl_parser_TokenType.STRUCT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VOID = ["VOID",33];
glsl_parser_TokenType.VOID.toString = $estr;
glsl_parser_TokenType.VOID.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.WHILE = ["WHILE",34];
glsl_parser_TokenType.WHILE.toString = $estr;
glsl_parser_TokenType.WHILE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.INVARIANT = ["INVARIANT",35];
glsl_parser_TokenType.INVARIANT.toString = $estr;
glsl_parser_TokenType.INVARIANT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.HIGH_PRECISION = ["HIGH_PRECISION",36];
glsl_parser_TokenType.HIGH_PRECISION.toString = $estr;
glsl_parser_TokenType.HIGH_PRECISION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MEDIUM_PRECISION = ["MEDIUM_PRECISION",37];
glsl_parser_TokenType.MEDIUM_PRECISION.toString = $estr;
glsl_parser_TokenType.MEDIUM_PRECISION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LOW_PRECISION = ["LOW_PRECISION",38];
glsl_parser_TokenType.LOW_PRECISION.toString = $estr;
glsl_parser_TokenType.LOW_PRECISION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.PRECISION = ["PRECISION",39];
glsl_parser_TokenType.PRECISION.toString = $estr;
glsl_parser_TokenType.PRECISION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BOOLCONSTANT = ["BOOLCONSTANT",40];
glsl_parser_TokenType.BOOLCONSTANT.toString = $estr;
glsl_parser_TokenType.BOOLCONSTANT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.IDENTIFIER = ["IDENTIFIER",41];
glsl_parser_TokenType.IDENTIFIER.toString = $estr;
glsl_parser_TokenType.IDENTIFIER.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.TYPE_NAME = ["TYPE_NAME",42];
glsl_parser_TokenType.TYPE_NAME.toString = $estr;
glsl_parser_TokenType.TYPE_NAME.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.FIELD_SELECTION = ["FIELD_SELECTION",43];
glsl_parser_TokenType.FIELD_SELECTION.toString = $estr;
glsl_parser_TokenType.FIELD_SELECTION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_OP = ["LEFT_OP",44];
glsl_parser_TokenType.LEFT_OP.toString = $estr;
glsl_parser_TokenType.LEFT_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_OP = ["RIGHT_OP",45];
glsl_parser_TokenType.RIGHT_OP.toString = $estr;
glsl_parser_TokenType.RIGHT_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.INC_OP = ["INC_OP",46];
glsl_parser_TokenType.INC_OP.toString = $estr;
glsl_parser_TokenType.INC_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DEC_OP = ["DEC_OP",47];
glsl_parser_TokenType.DEC_OP.toString = $estr;
glsl_parser_TokenType.DEC_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LE_OP = ["LE_OP",48];
glsl_parser_TokenType.LE_OP.toString = $estr;
glsl_parser_TokenType.LE_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.GE_OP = ["GE_OP",49];
glsl_parser_TokenType.GE_OP.toString = $estr;
glsl_parser_TokenType.GE_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.EQ_OP = ["EQ_OP",50];
glsl_parser_TokenType.EQ_OP.toString = $estr;
glsl_parser_TokenType.EQ_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.NE_OP = ["NE_OP",51];
glsl_parser_TokenType.NE_OP.toString = $estr;
glsl_parser_TokenType.NE_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.AND_OP = ["AND_OP",52];
glsl_parser_TokenType.AND_OP.toString = $estr;
glsl_parser_TokenType.AND_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.OR_OP = ["OR_OP",53];
glsl_parser_TokenType.OR_OP.toString = $estr;
glsl_parser_TokenType.OR_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.XOR_OP = ["XOR_OP",54];
glsl_parser_TokenType.XOR_OP.toString = $estr;
glsl_parser_TokenType.XOR_OP.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MUL_ASSIGN = ["MUL_ASSIGN",55];
glsl_parser_TokenType.MUL_ASSIGN.toString = $estr;
glsl_parser_TokenType.MUL_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DIV_ASSIGN = ["DIV_ASSIGN",56];
glsl_parser_TokenType.DIV_ASSIGN.toString = $estr;
glsl_parser_TokenType.DIV_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.ADD_ASSIGN = ["ADD_ASSIGN",57];
glsl_parser_TokenType.ADD_ASSIGN.toString = $estr;
glsl_parser_TokenType.ADD_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.MOD_ASSIGN = ["MOD_ASSIGN",58];
glsl_parser_TokenType.MOD_ASSIGN.toString = $estr;
glsl_parser_TokenType.MOD_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.SUB_ASSIGN = ["SUB_ASSIGN",59];
glsl_parser_TokenType.SUB_ASSIGN.toString = $estr;
glsl_parser_TokenType.SUB_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_ASSIGN = ["LEFT_ASSIGN",60];
glsl_parser_TokenType.LEFT_ASSIGN.toString = $estr;
glsl_parser_TokenType.LEFT_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_ASSIGN = ["RIGHT_ASSIGN",61];
glsl_parser_TokenType.RIGHT_ASSIGN.toString = $estr;
glsl_parser_TokenType.RIGHT_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.AND_ASSIGN = ["AND_ASSIGN",62];
glsl_parser_TokenType.AND_ASSIGN.toString = $estr;
glsl_parser_TokenType.AND_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.XOR_ASSIGN = ["XOR_ASSIGN",63];
glsl_parser_TokenType.XOR_ASSIGN.toString = $estr;
glsl_parser_TokenType.XOR_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.OR_ASSIGN = ["OR_ASSIGN",64];
glsl_parser_TokenType.OR_ASSIGN.toString = $estr;
glsl_parser_TokenType.OR_ASSIGN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_PAREN = ["LEFT_PAREN",65];
glsl_parser_TokenType.LEFT_PAREN.toString = $estr;
glsl_parser_TokenType.LEFT_PAREN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_PAREN = ["RIGHT_PAREN",66];
glsl_parser_TokenType.RIGHT_PAREN.toString = $estr;
glsl_parser_TokenType.RIGHT_PAREN.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_BRACKET = ["LEFT_BRACKET",67];
glsl_parser_TokenType.LEFT_BRACKET.toString = $estr;
glsl_parser_TokenType.LEFT_BRACKET.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_BRACKET = ["RIGHT_BRACKET",68];
glsl_parser_TokenType.RIGHT_BRACKET.toString = $estr;
glsl_parser_TokenType.RIGHT_BRACKET.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_BRACE = ["LEFT_BRACE",69];
glsl_parser_TokenType.LEFT_BRACE.toString = $estr;
glsl_parser_TokenType.LEFT_BRACE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_BRACE = ["RIGHT_BRACE",70];
glsl_parser_TokenType.RIGHT_BRACE.toString = $estr;
glsl_parser_TokenType.RIGHT_BRACE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DOT = ["DOT",71];
glsl_parser_TokenType.DOT.toString = $estr;
glsl_parser_TokenType.DOT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.COMMA = ["COMMA",72];
glsl_parser_TokenType.COMMA.toString = $estr;
glsl_parser_TokenType.COMMA.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.COLON = ["COLON",73];
glsl_parser_TokenType.COLON.toString = $estr;
glsl_parser_TokenType.COLON.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.EQUAL = ["EQUAL",74];
glsl_parser_TokenType.EQUAL.toString = $estr;
glsl_parser_TokenType.EQUAL.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.SEMICOLON = ["SEMICOLON",75];
glsl_parser_TokenType.SEMICOLON.toString = $estr;
glsl_parser_TokenType.SEMICOLON.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BANG = ["BANG",76];
glsl_parser_TokenType.BANG.toString = $estr;
glsl_parser_TokenType.BANG.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.DASH = ["DASH",77];
glsl_parser_TokenType.DASH.toString = $estr;
glsl_parser_TokenType.DASH.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.TILDE = ["TILDE",78];
glsl_parser_TokenType.TILDE.toString = $estr;
glsl_parser_TokenType.TILDE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.PLUS = ["PLUS",79];
glsl_parser_TokenType.PLUS.toString = $estr;
glsl_parser_TokenType.PLUS.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.STAR = ["STAR",80];
glsl_parser_TokenType.STAR.toString = $estr;
glsl_parser_TokenType.STAR.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.SLASH = ["SLASH",81];
glsl_parser_TokenType.SLASH.toString = $estr;
glsl_parser_TokenType.SLASH.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.PERCENT = ["PERCENT",82];
glsl_parser_TokenType.PERCENT.toString = $estr;
glsl_parser_TokenType.PERCENT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LEFT_ANGLE = ["LEFT_ANGLE",83];
glsl_parser_TokenType.LEFT_ANGLE.toString = $estr;
glsl_parser_TokenType.LEFT_ANGLE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RIGHT_ANGLE = ["RIGHT_ANGLE",84];
glsl_parser_TokenType.RIGHT_ANGLE.toString = $estr;
glsl_parser_TokenType.RIGHT_ANGLE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.VERTICAL_BAR = ["VERTICAL_BAR",85];
glsl_parser_TokenType.VERTICAL_BAR.toString = $estr;
glsl_parser_TokenType.VERTICAL_BAR.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.CARET = ["CARET",86];
glsl_parser_TokenType.CARET.toString = $estr;
glsl_parser_TokenType.CARET.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.AMPERSAND = ["AMPERSAND",87];
glsl_parser_TokenType.AMPERSAND.toString = $estr;
glsl_parser_TokenType.AMPERSAND.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.QUESTION = ["QUESTION",88];
glsl_parser_TokenType.QUESTION.toString = $estr;
glsl_parser_TokenType.QUESTION.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.INTCONSTANT = ["INTCONSTANT",89];
glsl_parser_TokenType.INTCONSTANT.toString = $estr;
glsl_parser_TokenType.INTCONSTANT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.FLOATCONSTANT = ["FLOATCONSTANT",90];
glsl_parser_TokenType.FLOATCONSTANT.toString = $estr;
glsl_parser_TokenType.FLOATCONSTANT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.WHITESPACE = ["WHITESPACE",91];
glsl_parser_TokenType.WHITESPACE.toString = $estr;
glsl_parser_TokenType.WHITESPACE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.BLOCK_COMMENT = ["BLOCK_COMMENT",92];
glsl_parser_TokenType.BLOCK_COMMENT.toString = $estr;
glsl_parser_TokenType.BLOCK_COMMENT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.LINE_COMMENT = ["LINE_COMMENT",93];
glsl_parser_TokenType.LINE_COMMENT.toString = $estr;
glsl_parser_TokenType.LINE_COMMENT.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE = ["PREPROCESSOR_DIRECTIVE",94];
glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE.toString = $estr;
glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE.__enum__ = glsl_parser_TokenType;
glsl_parser_TokenType.RESERVED_KEYWORD = ["RESERVED_KEYWORD",95];
glsl_parser_TokenType.RESERVED_KEYWORD.toString = $estr;
glsl_parser_TokenType.RESERVED_KEYWORD.__enum__ = glsl_parser_TokenType;
var glsl_parser_ParserTables = function() { };
glsl_parser_ParserTables.__name__ = true;
var glsl_parser_Parser = function() { };
glsl_parser_Parser.__name__ = true;
glsl_parser_Parser.init = function() {
	glsl_parser_Parser.i = 0;
	glsl_parser_Parser.stack = [{ stateno : 0, major : 0, minor : null}];
	glsl_parser_Parser.errorCount = 0;
	glsl_parser_Parser.currentNode = null;
	glsl_parser_Parser.warnings = [];
	glsl_parser_TreeBuilder.reset();
};
glsl_parser_Parser.parse = function(input) {
	glsl_parser_Parser.init();
	var tokens = glsl_parser_Tokenizer.tokenize(input);
	return glsl_parser_Parser.parseTokens(tokens);
};
glsl_parser_Parser.parseTokens = function(tokens) {
	glsl_parser_Parser.init();
	var lastToken = null;
	var _g = 0;
	while(_g < tokens.length) {
		var t = tokens[_g];
		++_g;
		if(HxOverrides.indexOf(glsl_parser_Parser.ignoredTokens,t.type,0) != -1) continue;
		glsl_parser_Parser.parseStep(glsl_parser_Parser.tokenIdMap.get(t.type),t);
		lastToken = t;
	}
	glsl_parser_Parser.parseStep(0,lastToken);
	return glsl_parser_Parser.currentNode;
};
glsl_parser_Parser.parseStep = function(major,minor) {
	var act;
	var atEOF = major == 0;
	while(true) {
		act = glsl_parser_Parser.findShiftAction(major);
		if(act < 335) {
			glsl_parser_Parser.assert(!atEOF,{ fileName : "Parser.hx", lineNumber : 77, className : "glsl.parser.Parser", methodName : "parseStep"});
			glsl_parser_Parser.shift(act,major,minor);
			glsl_parser_Parser.errorCount--;
			major = 167;
		} else if(act < 548) glsl_parser_Parser.reduce(act - 335); else {
			glsl_parser_Parser.assert(act == 548,{ fileName : "Parser.hx", lineNumber : 85, className : "glsl.parser.Parser", methodName : "parseStep"});
			if(glsl_parser_Parser.errorCount <= 0) {
				var minor1 = minor;
				var msg = "syntax error";
				var data = Reflect.field(minor1,"data");
				if(data != null) msg += ", '" + data + "'";
				glsl_parser_Parser.warn(msg,minor1);
			}
			glsl_parser_Parser.errorCount = 3;
			if(atEOF) {
				var minor2 = minor;
				var msg1 = "parse failed";
				var data1 = Reflect.field(minor2,"data");
				if(data1 != null) msg1 += ", '" + data1 + "'";
				glsl_parser_Parser.error(msg1,minor2);
			}
			major = 167;
		}
		if(!(major != 167 && glsl_parser_Parser.i >= 0)) break;
	}
	return;
};
glsl_parser_Parser.popStack = function() {
	if(glsl_parser_Parser.i < 0) return 0;
	var major = glsl_parser_Parser.stack.pop().major;
	glsl_parser_Parser.i--;
	return major;
};
glsl_parser_Parser.findShiftAction = function(iLookAhead) {
	var stateno = glsl_parser_Parser.stack[glsl_parser_Parser.i].stateno;
	var j = glsl_parser_Parser.shiftOffset[stateno];
	if(stateno > 168 || j == -36) return glsl_parser_Parser.defaultAction[stateno];
	glsl_parser_Parser.assert(iLookAhead != 167,{ fileName : "Parser.hx", lineNumber : 121, className : "glsl.parser.Parser", methodName : "findShiftAction"});
	j += iLookAhead;
	if(j < 0 || j >= glsl_parser_Parser.actionCount || glsl_parser_Parser.lookahead[j] != iLookAhead) return glsl_parser_Parser.defaultAction[stateno];
	return glsl_parser_Parser.action[j];
};
glsl_parser_Parser.findReduceAction = function(stateno,iLookAhead) {
	var j;
	glsl_parser_Parser.assert(stateno <= 72,{ fileName : "Parser.hx", lineNumber : 140, className : "glsl.parser.Parser", methodName : "findReduceAction"});
	j = glsl_parser_Parser.reduceOffset[stateno];
	glsl_parser_Parser.assert(j != -63,{ fileName : "Parser.hx", lineNumber : 145, className : "glsl.parser.Parser", methodName : "findReduceAction"});
	glsl_parser_Parser.assert(iLookAhead != 167,{ fileName : "Parser.hx", lineNumber : 146, className : "glsl.parser.Parser", methodName : "findReduceAction"});
	j += iLookAhead;
	glsl_parser_Parser.assert(j >= 0 && j < glsl_parser_Parser.actionCount,{ fileName : "Parser.hx", lineNumber : 154, className : "glsl.parser.Parser", methodName : "findReduceAction"});
	glsl_parser_Parser.assert(glsl_parser_Parser.lookahead[j] == iLookAhead,{ fileName : "Parser.hx", lineNumber : 155, className : "glsl.parser.Parser", methodName : "findReduceAction"});
	return glsl_parser_Parser.action[j];
};
glsl_parser_Parser.shift = function(newState,major,minor) {
	glsl_parser_Parser.i++;
	glsl_parser_Parser.stack[glsl_parser_Parser.i] = { stateno : newState, major : major, minor : minor};
};
glsl_parser_Parser.reduce = function(ruleno) {
	var $goto;
	var act;
	var size;
	var newNode = glsl_parser_TreeBuilder.buildRule(ruleno);
	glsl_parser_Parser.currentNode = newNode;
	$goto = glsl_parser__$Parser_RuleInfoEntry_$Impl_$.get_lhs(glsl_parser_Parser.ruleInfo[ruleno]);
	size = glsl_parser__$Parser_RuleInfoEntry_$Impl_$.get_nrhs(glsl_parser_Parser.ruleInfo[ruleno]);
	glsl_parser_Parser.i -= size;
	act = glsl_parser_Parser.findReduceAction(glsl_parser_Parser.stack[glsl_parser_Parser.i].stateno,$goto);
	if(act < 335) glsl_parser_Parser.shift(act,$goto,newNode); else {
		glsl_parser_Parser.assert(act == 549,{ fileName : "Parser.hx", lineNumber : 188, className : "glsl.parser.Parser", methodName : "reduce"});
		glsl_parser_Parser.accept();
	}
};
glsl_parser_Parser.accept = function() {
	while(glsl_parser_Parser.i >= 0) glsl_parser_Parser.popStack();
};
glsl_parser_Parser.syntaxError = function(major,minor) {
	var msg = "syntax error";
	var data = Reflect.field(minor,"data");
	if(data != null) msg += ", '" + data + "'";
	glsl_parser_Parser.warn(msg,minor);
};
glsl_parser_Parser.parseFailed = function(minor) {
	var msg = "parse failed";
	var data = Reflect.field(minor,"data");
	if(data != null) msg += ", '" + data + "'";
	glsl_parser_Parser.error(msg,minor);
};
glsl_parser_Parser.assert = function(cond,pos) {
	if(!cond) glsl_parser_Parser.warn("assert failed in " + pos.className + "::" + pos.methodName + " line " + pos.lineNumber);
};
glsl_parser_Parser.warn = function(msg,info) {
	var str = "Parser Warning: " + msg;
	var line = Reflect.field(info,"line");
	var col = Reflect.field(info,"column");
	var tmp;
	var a = Type["typeof"](line);
	tmp = Type.enumEq(a,ValueType.TInt);
	if(tmp) {
		str += ", line " + line;
		var tmp1;
		var a1 = Type["typeof"](col);
		tmp1 = Type.enumEq(a1,ValueType.TInt);
		if(tmp1) str += ", column " + col;
	}
	glsl_parser_Parser.warnings.push(str);
};
glsl_parser_Parser.error = function(msg,info) {
	var str = "Parser Error: " + msg;
	var line = Reflect.field(info,"line");
	var col = Reflect.field(info,"column");
	var tmp;
	var a = Type["typeof"](line);
	tmp = Type.enumEq(a,ValueType.TInt);
	if(tmp) {
		str += ", line " + line;
		var tmp1;
		var a1 = Type["typeof"](col);
		tmp1 = Type.enumEq(a1,ValueType.TInt);
		if(tmp1) str += ", column " + col;
	}
	throw new js__$Boot_HaxeError(str);
};
var glsl_parser__$Parser_RuleInfoEntry_$Impl_$ = {};
glsl_parser__$Parser_RuleInfoEntry_$Impl_$.__name__ = true;
glsl_parser__$Parser_RuleInfoEntry_$Impl_$.get_lhs = function(this1) {
	return this1[0];
};
glsl_parser__$Parser_RuleInfoEntry_$Impl_$.set_lhs = function(this1,v) {
	return this1[0] = v;
};
glsl_parser__$Parser_RuleInfoEntry_$Impl_$.get_nrhs = function(this1) {
	return this1[1];
};
glsl_parser__$Parser_RuleInfoEntry_$Impl_$.set_nrhs = function(this1,v) {
	return this1[1] = v;
};
var glsl_parser_PPMacro = { __ename__ : true, __constructs__ : ["UserMacroObject","UserMacroFunction","BuiltinMacroObject","BuiltinMacroFunction","UnresolveableMacro"] };
glsl_parser_PPMacro.UserMacroObject = function(content) { var $x = ["UserMacroObject",0,content]; $x.__enum__ = glsl_parser_PPMacro; $x.toString = $estr; return $x; };
glsl_parser_PPMacro.UserMacroFunction = function(content,parameters) { var $x = ["UserMacroFunction",1,content,parameters]; $x.__enum__ = glsl_parser_PPMacro; $x.toString = $estr; return $x; };
glsl_parser_PPMacro.BuiltinMacroObject = function(func) { var $x = ["BuiltinMacroObject",2,func]; $x.__enum__ = glsl_parser_PPMacro; $x.toString = $estr; return $x; };
glsl_parser_PPMacro.BuiltinMacroFunction = function(func,parameterCount) { var $x = ["BuiltinMacroFunction",3,func,parameterCount]; $x.__enum__ = glsl_parser_PPMacro; $x.toString = $estr; return $x; };
glsl_parser_PPMacro.UnresolveableMacro = function(ppMacro) { var $x = ["UnresolveableMacro",4,ppMacro]; $x.__enum__ = glsl_parser_PPMacro; $x.toString = $estr; return $x; };
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
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
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
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
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
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
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
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
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
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
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__cast = function(o,t) {
	if(js_Boot.__instanceof(o,t)) return o; else throw new js__$Boot_HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	if(typeof window != "undefined") return window[name]; else return global[name];
};
var glsl_parser_Preprocessor = function() { };
glsl_parser_Preprocessor.__name__ = true;
glsl_parser_Preprocessor.process = function(inputTokens,force) {
	if(force == null) force = false;
	glsl_parser_Preprocessor.tokens = inputTokens;
	glsl_parser_Preprocessor.i = 0;
	glsl_parser_Preprocessor.force = force;
	glsl_parser_Preprocessor.userDefinedMacros = new haxe_ds_StringMap();
	glsl_parser_Preprocessor.warnings = [];
	glsl_parser_Preprocessor.version = 100;
	glsl_parser_Preprocessor.pragmas = [];
	while(glsl_parser_Preprocessor.i < glsl_parser_Preprocessor.tokens.length) {
		var _g = glsl_parser_Preprocessor.tokens[glsl_parser_Preprocessor.i].type;
		switch(_g[1]) {
		case 94:
			try {
				glsl_parser_Preprocessor.processDirective();
			} catch( $e0 ) {
				if ($e0 instanceof js__$Boot_HaxeError) $e0 = $e0.val;
				if( js_Boot.__instanceof($e0,glsl_parser_PPError) ) {
					var e = $e0;
					switch(e[1]) {
					case 0:
						var info = e[3];
						glsl_parser_Preprocessor.warn(e[2],info);
						break;
					case 1:
						var info1 = e[3];
						glsl_parser_Preprocessor.error(e[2],info1);
						break;
					}
				} else if( js_Boot.__instanceof($e0,String) ) {
					var msg = $e0;
					glsl_parser_Preprocessor.warn(msg,glsl_parser_Preprocessor.tokens[glsl_parser_Preprocessor.i]);
				} else throw($e0);
			}
			break;
		default:
			{
				var _g1 = HxOverrides.indexOf(glsl_parser_PPTokensHelper.identifierTokens,_g,0) >= 0;
				switch(_g1) {
				case true:
					try {
						glsl_parser_Preprocessor.processIdentifier();
					} catch( $e1 ) {
						if ($e1 instanceof js__$Boot_HaxeError) $e1 = $e1.val;
						if( js_Boot.__instanceof($e1,glsl_parser_PPError) ) {
							var e1 = $e1;
							switch(e1[1]) {
							case 0:
								var info2 = e1[3];
								glsl_parser_Preprocessor.warn(e1[2],info2);
								break;
							case 1:
								var info3 = e1[3];
								glsl_parser_Preprocessor.error(e1[2],info3);
								break;
							}
						} else if( js_Boot.__instanceof($e1,String) ) {
							var msg1 = $e1;
							glsl_parser_Preprocessor.warn(msg1,glsl_parser_Preprocessor.tokens[glsl_parser_Preprocessor.i]);
						} else throw($e1);
					}
					break;
				default:
				}
			}
		}
		glsl_parser_Preprocessor.i++;
	}
	return glsl_parser_Preprocessor.tokens;
};
glsl_parser_Preprocessor.processDirective = function() {
	var t = glsl_parser_Preprocessor.tokens[glsl_parser_Preprocessor.i];
	var directive = glsl_parser_Preprocessor.readDirectiveData(t.data);
	var _g = directive.title;
	switch(_g) {
	case "":
		break;
	case "define":
		var definition = glsl_parser_Preprocessor.evaluateMacroDefinition(directive.content);
		glsl_parser_Preprocessor.defineMacro(definition.name,definition.ppMacro);
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		break;
	case "undef":
		var tmp;
		if(!glsl_parser_Preprocessor.macroNameReg.match(directive.content)) throw new js__$Boot_HaxeError("invalid macro name");
		tmp = glsl_parser_Preprocessor.macroNameReg.matched(1);
		var macroName = tmp;
		glsl_parser_Preprocessor.undefineMacro(macroName);
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		break;
	case "if":case "ifdef":case "ifndef":
		glsl_parser_Preprocessor.processIfSwitch();
		break;
	case "else":case "elif":case "endif":
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		throw new js__$Boot_HaxeError("unexpected #" + directive.title);
		break;
	case "error":
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		throw new js__$Boot_HaxeError(glsl_parser_PPError.Error("" + directive.content,t));
		break;
	case "pragma":
		if(new EReg("^\\s*STDGL(\\s+|$)","").match(directive.content)) throw new js__$Boot_HaxeError("pragmas beginning with STDGL are reserved");
		glsl_parser_Preprocessor.pragmas.push(directive.content);
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		break;
	case "extension":
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		throw new js__$Boot_HaxeError("directive #extension is not yet supported");
		break;
	case "version":
		if(glsl_parser_PPTokensHelper.nextNonSkipToken(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i,-1) == null) {
			var versionNumRegex = new EReg("^(\\d+)$","");
			var matched = versionNumRegex.match(directive.content);
			if(matched) {
				versionNumRegex.matched(1);
				glsl_parser_Preprocessor.version = Std.parseInt(versionNumRegex.matched(1));
				if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
			} else {
				var _g1 = directive.content;
				switch(_g1) {
				case "":
					throw new js__$Boot_HaxeError("version number required");
					break;
				default:
					throw new js__$Boot_HaxeError("invalid version number '" + directive.content + "'");
				}
			}
		} else throw new js__$Boot_HaxeError("#version directive must occur before anything else, except for comments and whitespace");
		break;
	case "line":
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		throw new js__$Boot_HaxeError("directive #line is not yet supported");
		break;
	default:
		if(glsl_parser_Preprocessor.force) glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
		throw new js__$Boot_HaxeError("unknown directive #'" + directive.title + "'");
	}
};
glsl_parser_Preprocessor.processIfSwitch = function() {
	var newTokens = [];
	var start = glsl_parser_Preprocessor.i;
	var end = null;
	var j = glsl_parser_Preprocessor.i;
	var t;
	var level = 0;
	var directive;
	var lastTitle;
	var testBlocks = [];
	try {
		t = glsl_parser_Preprocessor.tokens[j];
		try {
			{
				var _g = directive = glsl_parser_Preprocessor.readDirectiveData(t.data);
				switch(_g.title) {
				case "if":
					level++;
					throw new js__$Boot_HaxeError("#if directive is not yet supported");
					break;
				case "ifdef":
					var content = _g.content;
					level++;
					var tmp;
					if(!glsl_parser_Preprocessor.macroNameReg.match(content)) throw new js__$Boot_HaxeError("invalid macro name");
					tmp = glsl_parser_Preprocessor.macroNameReg.matched(1);
					var macroName = tmp;
					testBlocks.push({ testFunc : function() {
						return glsl_parser_Preprocessor.isMacroDefined(macroName);
					}, start : j + 1, end : null});
					break;
				case "ifndef":
					var content1 = _g.content;
					level++;
					var tmp1;
					if(!glsl_parser_Preprocessor.macroNameReg.match(content1)) throw new js__$Boot_HaxeError("invalid macro name");
					tmp1 = glsl_parser_Preprocessor.macroNameReg.matched(1);
					var macroName1 = tmp1;
					testBlocks.push({ testFunc : function() {
						return !glsl_parser_Preprocessor.isMacroDefined(macroName1);
					}, start : j + 1, end : null});
					break;
				default:
					throw new js__$Boot_HaxeError("expected if-switch directive, got #" + _g.title);
				}
			}
			lastTitle = directive.title;
			while(level > 0) {
				j = glsl_parser_PPTokensHelper.nextNonSkipTokenIndex(glsl_parser_Preprocessor.tokens,j,1,glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE);
				t = glsl_parser_Preprocessor.tokens[j];
				if(t == null) throw new js__$Boot_HaxeError("expecting #endif but reached end of file");
				{
					var _g1 = directive = glsl_parser_Preprocessor.readDirectiveData(t.data);
					switch(_g1.title) {
					case "if":case "ifdef":case "ifndef":
						level++;
						break;
					case "else":
						if(level == 1) {
							if(lastTitle == "else") throw new js__$Boot_HaxeError("#" + directive.title + " cannot follow #else");
							testBlocks[testBlocks.length - 1].end = j - 1;
							testBlocks.push({ testFunc : function() {
								return true;
							}, start : j + 1, end : null});
						}
						break;
					case "elif":
						if(level == 1) throw new js__$Boot_HaxeError("#elif directive is not yet supported");
						break;
					case "endif":
						level--;
						break;
					default:
					}
				}
				lastTitle = directive.title;
			}
			testBlocks[testBlocks.length - 1].end = j - 1;
		} catch( msg ) {
			if (msg instanceof js__$Boot_HaxeError) msg = msg.val;
			if( js_Boot.__instanceof(msg,String) ) {
				throw new js__$Boot_HaxeError(glsl_parser_PPError.Warn(msg,t));
			} else throw(msg);
		}
		end = j;
		var _g2 = 0;
		while(_g2 < testBlocks.length) {
			var b = testBlocks[_g2];
			++_g2;
			try {
				if(b.testFunc()) {
					newTokens = glsl_parser_Preprocessor.tokens.slice(b.start,b.end);
					break;
				}
			} catch( msg1 ) {
				if (msg1 instanceof js__$Boot_HaxeError) msg1 = msg1.val;
				if( js_Boot.__instanceof(msg1,String) ) {
					throw new js__$Boot_HaxeError(glsl_parser_PPError.Warn(msg1,glsl_parser_Preprocessor.tokens[b.start - 1]));
				} else throw(msg1);
			}
		}
		glsl_parser_PPTokensHelper.deleteTokens(glsl_parser_Preprocessor.tokens,start,end - start + 1);
		glsl_parser_PPTokensHelper.insertTokens(glsl_parser_Preprocessor.tokens,start,newTokens);
		glsl_parser_Preprocessor.i = start - 1;
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		while(level > 0) {
			j = glsl_parser_PPTokensHelper.nextNonSkipTokenIndex(glsl_parser_Preprocessor.tokens,j,1,glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE);
			t = glsl_parser_Preprocessor.tokens[j];
			if(t == null) throw new js__$Boot_HaxeError(glsl_parser_PPError.Warn("expecting #endif but reached end of file",glsl_parser_Preprocessor.tokens[start]));
			var _g3 = glsl_parser_Preprocessor.readDirectiveData(t.data).title;
			switch(_g3) {
			case "if":case "ifdef":case "ifndef":
				level++;
				break;
			case "endif":
				level--;
				break;
			}
		}
		glsl_parser_Preprocessor.i = j;
		throw new js__$Boot_HaxeError(e);
	}
};
glsl_parser_Preprocessor.processIdentifier = function() {
	var expanded = glsl_parser_PPTokensHelper.expandIdentifier(glsl_parser_Preprocessor.tokens,glsl_parser_Preprocessor.i);
	if(expanded != null) glsl_parser_Preprocessor.i += expanded.length;
};
glsl_parser_Preprocessor.getMacro = function(id) {
	var ppMacro;
	var tmp;
	var _this = glsl_parser_Preprocessor.builtinMacros;
	if(__map_reserved[id] != null) tmp = _this.getReserved(id); else tmp = _this.h[id];
	if((ppMacro = tmp) != null) return ppMacro;
	var tmp1;
	var _this1 = glsl_parser_Preprocessor.userDefinedMacros;
	if(__map_reserved[id] != null) tmp1 = _this1.getReserved(id); else tmp1 = _this1.h[id];
	if((ppMacro = tmp1) != null) return ppMacro;
	return null;
};
glsl_parser_Preprocessor.defineMacro = function(id,ppMacro) {
	var existingMacro = glsl_parser_Preprocessor.getMacro(id);
	if(existingMacro == null) {
	} else switch(existingMacro[1]) {
	case 2:case 3:case 4:
		throw new js__$Boot_HaxeError("redefinition of predefined macro");
		break;
	case 0:case 1:
		throw new js__$Boot_HaxeError("macro redefinition");
		break;
	}
	if(new EReg("^__","").match(id)) throw new js__$Boot_HaxeError("macro name is reserved");
	if(ppMacro == null) throw new js__$Boot_HaxeError("null macro definitions are not allowed");
	var _this = glsl_parser_Preprocessor.userDefinedMacros;
	if(__map_reserved[id] != null) _this.setReserved(id,ppMacro); else _this.h[id] = ppMacro;
};
glsl_parser_Preprocessor.undefineMacro = function(id) {
	var existingMacro = glsl_parser_Preprocessor.getMacro(id);
	if(existingMacro == null) {
	} else switch(existingMacro[1]) {
	case 2:case 3:case 4:
		throw new js__$Boot_HaxeError("cannot undefine predefined macro");
		break;
	case 0:case 1:
		glsl_parser_Preprocessor.userDefinedMacros.remove(id);
		break;
	}
};
glsl_parser_Preprocessor.isMacroDefined = function(id) {
	var m = glsl_parser_Preprocessor.getMacro(id);
	if(m == null) return false; else switch(m[1]) {
	case 4:
		if(glsl_parser_Preprocessor.force && m[2] != null) return true; else throw new js__$Boot_HaxeError("cannot resolve macro definition '" + id + "'");
		break;
	default:
		return true;
	}
};
glsl_parser_Preprocessor.readDirectiveData = function(data) {
	if(!glsl_parser_Preprocessor.directiveTitleReg.match(data)) throw new js__$Boot_HaxeError("invalid directive title");
	var title = glsl_parser_Preprocessor.directiveTitleReg.matched(1);
	var content = StringTools.trim(glsl_parser_Preprocessor.directiveTitleReg.matchedRight());
	content = StringTools.replace(content,"\\\n","\n");
	return { title : title, content : content};
};
glsl_parser_Preprocessor.readMacroName = function(data) {
	if(!glsl_parser_Preprocessor.macroNameReg.match(data)) throw new js__$Boot_HaxeError("invalid macro name");
	return glsl_parser_Preprocessor.macroNameReg.matched(1);
};
glsl_parser_Preprocessor.evaluateMacroDefinition = function(definitionString) {
	if(glsl_parser_Preprocessor.macroNameReg.match(definitionString)) {
		var macroName = glsl_parser_Preprocessor.macroNameReg.matched(1);
		var macroContent = "";
		var macroParameters = [];
		var nextChar = glsl_parser_Preprocessor.macroNameReg.matched(2);
		var userMacro;
		switch(nextChar) {
		case "(":
			var parametersReg = new EReg("([^\\)]*)\\)","");
			var parameterReg = new EReg("^\\s*(([a-z_]\\w*)?)\\s*(,|$)","i");
			var matchedRightParen = parametersReg.match(glsl_parser_Preprocessor.macroNameReg.matchedRight());
			if(matchedRightParen) {
				var parameterString = parametersReg.matched(1);
				macroContent = parametersReg.matchedRight();
				var reachedLast = false;
				while(!reachedLast) if(parameterReg.match(parameterString)) {
					var parameterName = parameterReg.matched(1);
					var parameterNextChar = parameterReg.matched(3);
					macroParameters.push(parameterName);
					parameterString = parameterReg.matchedRight();
					reachedLast = parameterNextChar != ",";
				} else throw new js__$Boot_HaxeError("invalid macro parameter");
			} else throw new js__$Boot_HaxeError("unmatched parentheses");
			userMacro = glsl_parser_PPMacro.UserMacroFunction(StringTools.trim(macroContent),macroParameters);
			break;
		default:
			macroContent = nextChar + glsl_parser_Preprocessor.macroNameReg.matchedRight();
			macroContent = StringTools.trim(macroContent);
			userMacro = glsl_parser_PPMacro.UserMacroObject(StringTools.trim(macroContent));
		}
		return { name : macroName, ppMacro : userMacro};
	} else throw new js__$Boot_HaxeError("invalid macro definition");
	return null;
};
glsl_parser_Preprocessor.evaluateExpr = function(expr) {
};
glsl_parser_Preprocessor.warn = function(msg,info) {
	var str = "Preprocessor Warning: " + msg;
	var line = Reflect.field(info,"line");
	var col = Reflect.field(info,"column");
	var tmp;
	var a = Type["typeof"](line);
	tmp = Type.enumEq(a,ValueType.TInt);
	if(tmp) {
		str += ", line " + line;
		var tmp1;
		var a1 = Type["typeof"](col);
		tmp1 = Type.enumEq(a1,ValueType.TInt);
		if(tmp1) str += ", column " + col;
	}
	glsl_parser_Preprocessor.warnings.push(str);
};
glsl_parser_Preprocessor.error = function(msg,info) {
	var str = "Preprocessor Error: " + msg;
	var line = Reflect.field(info,"line");
	var col = Reflect.field(info,"column");
	var tmp;
	var a = Type["typeof"](line);
	tmp = Type.enumEq(a,ValueType.TInt);
	if(tmp) {
		str += ", line " + line;
		var tmp1;
		var a1 = Type["typeof"](col);
		tmp1 = Type.enumEq(a1,ValueType.TInt);
		if(tmp1) str += ", column " + col;
	}
	throw new js__$Boot_HaxeError(str);
};
var glsl_parser_PPError = { __ename__ : true, __constructs__ : ["Warn","Error"] };
glsl_parser_PPError.Warn = function(msg,info) { var $x = ["Warn",0,msg,info]; $x.__enum__ = glsl_parser_PPError; $x.toString = $estr; return $x; };
glsl_parser_PPError.Error = function(msg,info) { var $x = ["Error",1,msg,info]; $x.__enum__ = glsl_parser_PPError; $x.toString = $estr; return $x; };
var glsl_parser_PPTokensHelper = function() { };
glsl_parser_PPTokensHelper.__name__ = true;
glsl_parser_PPTokensHelper.expandIdentifiers = function(tokens,overrideMap,ignore) {
	var len = tokens.length;
	var _g = 0;
	while(_g < len) {
		var j = _g++;
		if(HxOverrides.indexOf(glsl_parser_PPTokensHelper.identifierTokens,tokens[j].type,0) >= 0) {
			glsl_parser_PPTokensHelper.expandIdentifier(tokens,j,overrideMap,ignore);
			len = tokens.length;
		}
	}
	return tokens;
};
glsl_parser_PPTokensHelper.expandIdentifier = function(tokens,i,overrideMap,ignore) {
	var token = tokens[i];
	var id = token.data;
	if(ignore != null && HxOverrides.indexOf(ignore,id,0) != -1) return null;
	var ppMacro = overrideMap == null?glsl_parser_Preprocessor.getMacro(id):__map_reserved[id] != null?overrideMap.getReserved(id):overrideMap.h[id];
	if(ppMacro == null) return null;
	var tmp;
	var resolveMacro1 = null;
	resolveMacro1 = function(ppMacro1) {
		switch(ppMacro1[1]) {
		case 0:
			var content = ppMacro1[2];
			var tmp1;
			var newTokens1 = glsl_parser_Tokenizer.tokenize(content,function(warning) {
				throw new js__$Boot_HaxeError("" + warning);
			},function(error) {
				throw new js__$Boot_HaxeError("" + error);
			});
			var _g = 0;
			while(_g < newTokens1.length) {
				var t = newTokens1[_g];
				++_g;
				t.line = token.line;
				t.column = token.column;
			}
			tmp1 = newTokens1;
			var newTokens = tmp1;
			if(ignore == null) ignore = [id]; else ignore.push(id);
			glsl_parser_PPTokensHelper.expandIdentifiers(newTokens,overrideMap,ignore);
			glsl_parser_PPTokensHelper.deleteTokens(tokens,i,1);
			glsl_parser_PPTokensHelper.insertTokens(tokens,i,newTokens);
			return newTokens;
		case 1:
			var parameters = ppMacro1[3];
			var content1 = ppMacro1[2];
			try {
				var functionCall = glsl_parser_PPTokensHelper.readFunctionCall(tokens,i);
				if(functionCall.args.length != parameters.length) {
					var _g1 = functionCall.args.length > parameters.length;
					switch(_g1) {
					case true:
						throw new js__$Boot_HaxeError("too many arguments for macro");
						break;
					case false:
						throw new js__$Boot_HaxeError("not enough arguments for macro");
						break;
					}
				}
				var tmp2;
				var newTokens3 = glsl_parser_Tokenizer.tokenize(content1,function(warning1) {
					throw new js__$Boot_HaxeError("" + warning1);
				},function(error1) {
					throw new js__$Boot_HaxeError("" + error1);
				});
				var _g2 = 0;
				while(_g2 < newTokens3.length) {
					var t1 = newTokens3[_g2];
					++_g2;
					t1.line = token.line;
					t1.column = token.column;
				}
				tmp2 = newTokens3;
				var newTokens2 = tmp2;
				var parameterMap = new haxe_ds_StringMap();
				var _g11 = 0;
				var _g3 = parameters.length;
				while(_g11 < _g3) {
					var i1 = _g11++;
					var tmp3;
					var key = parameters[i1];
					if(__map_reserved[key] != null) tmp3 = parameterMap.existsReserved(key); else tmp3 = parameterMap.h.hasOwnProperty(key);
					if(!tmp3) {
						var value = glsl_parser_PPMacro.UserMacroObject(glsl_printer_TokenArrayPrinter.print(functionCall.args[i1]));
						var key1 = parameters[i1];
						if(__map_reserved[key1] != null) parameterMap.setReserved(key1,value); else parameterMap.h[key1] = value;
					}
				}
				glsl_parser_PPTokensHelper.expandIdentifiers(newTokens2,parameterMap);
				if(ignore == null) ignore = [id]; else ignore.push(id);
				glsl_parser_PPTokensHelper.expandIdentifiers(newTokens2,overrideMap,ignore);
				glsl_parser_PPTokensHelper.deleteTokens(tokens,i,functionCall.len);
				glsl_parser_PPTokensHelper.insertTokens(tokens,i,newTokens2);
				return newTokens2;
			} catch( e ) {
				if (e instanceof js__$Boot_HaxeError) e = e.val;
			}
			break;
		case 2:
			var func = ppMacro1[2];
			var tmp4;
			var content2 = func();
			var newTokens5 = glsl_parser_Tokenizer.tokenize(content2,function(warning2) {
				throw new js__$Boot_HaxeError("" + warning2);
			},function(error2) {
				throw new js__$Boot_HaxeError("" + error2);
			});
			var _g4 = 0;
			while(_g4 < newTokens5.length) {
				var t2 = newTokens5[_g4];
				++_g4;
				t2.line = token.line;
				t2.column = token.column;
			}
			tmp4 = newTokens5;
			var newTokens4 = tmp4;
			glsl_parser_PPTokensHelper.deleteTokens(tokens,i,1);
			glsl_parser_PPTokensHelper.insertTokens(tokens,i,newTokens4);
			return newTokens4;
		case 3:
			var requiredParameterCount = ppMacro1[3];
			var func1 = ppMacro1[2];
			try {
				var functionCall1 = glsl_parser_PPTokensHelper.readFunctionCall(tokens,i);
				if(functionCall1.args.length != requiredParameterCount) {
					var _g5 = functionCall1.args.length > requiredParameterCount;
					switch(_g5) {
					case true:
						throw new js__$Boot_HaxeError("too many arguments for macro");
						break;
					case false:
						throw new js__$Boot_HaxeError("not enough arguments for macro");
						break;
					}
				}
				var tmp5;
				var content3 = func1(functionCall1.args);
				var newTokens7 = glsl_parser_Tokenizer.tokenize(content3,function(warning3) {
					throw new js__$Boot_HaxeError("" + warning3);
				},function(error3) {
					throw new js__$Boot_HaxeError("" + error3);
				});
				var _g6 = 0;
				while(_g6 < newTokens7.length) {
					var t3 = newTokens7[_g6];
					++_g6;
					t3.line = token.line;
					t3.column = token.column;
				}
				tmp5 = newTokens7;
				var newTokens6 = tmp5;
				glsl_parser_PPTokensHelper.deleteTokens(tokens,i,functionCall1.len);
				glsl_parser_PPTokensHelper.insertTokens(tokens,i,newTokens6);
				return newTokens6;
			} catch( e1 ) {
				if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
			}
			break;
		case 4:
			var forceMacro = ppMacro1[2];
			if(glsl_parser_Preprocessor.force && forceMacro != null) return resolveMacro1(forceMacro); else throw new js__$Boot_HaxeError("cannot resolve macro");
			break;
		}
		return null;
	};
	tmp = resolveMacro1;
	var resolveMacro = tmp;
	return resolveMacro(ppMacro);
};
glsl_parser_PPTokensHelper.readFunctionCall = function(tokens,start) {
	var ident = tokens[start];
	if(ident == null || !(HxOverrides.indexOf(glsl_parser_PPTokensHelper.identifierTokens,ident.type,0) >= 0)) throw new js__$Boot_HaxeError("invalid function call");
	var args = [];
	var j = glsl_parser_PPTokensHelper.nextNonSkipTokenIndex(tokens,start);
	if(j == -1) throw new js__$Boot_HaxeError("invalid function call");
	var t = tokens[j];
	if(Type.enumEq(t.type,glsl_parser_TokenType.LEFT_PAREN)) {
		var argBuffer = [];
		var level = 1;
		do {
			t = tokens[++j];
			if(t == null) throw new js__$Boot_HaxeError("expecting ')'");
			if(HxOverrides.indexOf(glsl_parser_Tokenizer.skippableTypes,t.type,0) != -1) continue;
			var _g = t.type;
			if(_g == null) throw new js__$Boot_HaxeError("" + Std.string(t) + " has no token type"); else switch(_g[1]) {
			case 65:
				level++;
				break;
			case 66:
				level--;
				break;
			case 72:
				if(level == 1) {
					args.push(argBuffer);
					argBuffer = [];
				} else argBuffer.push(t);
				break;
			default:
				argBuffer.push(t);
			}
			if(level <= 0) {
				args.push(argBuffer);
				argBuffer = [];
				break;
			}
		} while(true);
		return { ident : ident, args : args, start : start, len : j - start + 1};
	}
	throw new js__$Boot_HaxeError("expecting '('");
};
glsl_parser_PPTokensHelper.nextNonSkipToken = function(tokens,start,n,requiredType) {
	if(n == null) n = 1;
	var j = glsl_parser_PPTokensHelper.nextNonSkipTokenIndex(tokens,start,n,requiredType);
	return j != -1?tokens[j]:null;
};
glsl_parser_PPTokensHelper.nextNonSkipTokenIndex = function(tokens,start,n,requiredType) {
	if(n == null) n = 1;
	var direction = n >= 0?1:-1;
	var j = start;
	var m = Math.abs(n);
	var t;
	while(m > 0) {
		j += direction;
		t = tokens[j];
		if(t == null) return -1;
		if(requiredType != null && !Type.enumEq(t.type,requiredType)) continue;
		if(HxOverrides.indexOf(glsl_parser_Tokenizer.skippableTypes,t.type,0) != -1) continue;
		m--;
	}
	return j;
};
glsl_parser_PPTokensHelper.deleteTokens = function(tokens,start,count) {
	if(count == null) count = 1;
	return tokens.splice(start,count);
};
glsl_parser_PPTokensHelper.insertTokens = function(tokens,start,newTokens) {
	var j = newTokens.length;
	while(--j >= 0) tokens.splice(start,0,newTokens[j]);
	return tokens;
};
glsl_parser_PPTokensHelper.isIdentifierType = function(type) {
	return HxOverrides.indexOf(glsl_parser_PPTokensHelper.identifierTokens,type,0) >= 0;
};
var glsl_parser__$Tokenizer_ScanMode = { __ename__ : true, __constructs__ : ["UNDETERMINED","BLOCK_COMMENT","LINE_COMMENT","PREPROCESSOR_DIRECTIVE","WHITESPACE","OPERATOR","LITERAL","INTEGER_CONSTANT","DECIMAL_CONSTANT","HEX_CONSTANT","OCTAL_CONSTANT","FLOATING_CONSTANT","FRACTIONAL_CONSTANT","EXPONENT_PART"] };
glsl_parser__$Tokenizer_ScanMode.UNDETERMINED = ["UNDETERMINED",0];
glsl_parser__$Tokenizer_ScanMode.UNDETERMINED.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.UNDETERMINED.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT = ["BLOCK_COMMENT",1];
glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT = ["LINE_COMMENT",2];
glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE = ["PREPROCESSOR_DIRECTIVE",3];
glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.WHITESPACE = ["WHITESPACE",4];
glsl_parser__$Tokenizer_ScanMode.WHITESPACE.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.WHITESPACE.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.OPERATOR = ["OPERATOR",5];
glsl_parser__$Tokenizer_ScanMode.OPERATOR.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.OPERATOR.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.LITERAL = ["LITERAL",6];
glsl_parser__$Tokenizer_ScanMode.LITERAL.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.LITERAL.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.INTEGER_CONSTANT = ["INTEGER_CONSTANT",7];
glsl_parser__$Tokenizer_ScanMode.INTEGER_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.INTEGER_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT = ["DECIMAL_CONSTANT",8];
glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT = ["HEX_CONSTANT",9];
glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT = ["OCTAL_CONSTANT",10];
glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT = ["FLOATING_CONSTANT",11];
glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT = ["FRACTIONAL_CONSTANT",12];
glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT.__enum__ = glsl_parser__$Tokenizer_ScanMode;
glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART = ["EXPONENT_PART",13];
glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART.toString = $estr;
glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART.__enum__ = glsl_parser__$Tokenizer_ScanMode;
var glsl_parser_Tokenizer = function() { };
glsl_parser_Tokenizer.__name__ = true;
glsl_parser_Tokenizer.tokenize = function(source,onWarn,onError) {
	glsl_parser_Tokenizer.source = source;
	glsl_parser_Tokenizer.onWarn = onWarn;
	glsl_parser_Tokenizer.onError = onError;
	glsl_parser_Tokenizer.tokens = [];
	glsl_parser_Tokenizer.i = 0;
	glsl_parser_Tokenizer.line = 1;
	glsl_parser_Tokenizer.col = 1;
	glsl_parser_Tokenizer.userDefinedTypes = [];
	glsl_parser_Tokenizer.warnings = [];
	glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
	var lastMode;
	while(glsl_parser_Tokenizer.i < source.length || glsl_parser_Tokenizer.mode != glsl_parser__$Tokenizer_ScanMode.UNDETERMINED) {
		lastMode = glsl_parser_Tokenizer.mode;
		var _g = glsl_parser_Tokenizer.mode;
		switch(_g[1]) {
		case 0:
			glsl_parser_Tokenizer.determineMode();
			break;
		case 3:
			glsl_parser_Tokenizer.preprocessorMode();
			break;
		case 1:
			glsl_parser_Tokenizer.blockCommentMode();
			break;
		case 2:
			glsl_parser_Tokenizer.lineCommentMode();
			break;
		case 4:
			glsl_parser_Tokenizer.whitespaceMode();
			break;
		case 5:
			glsl_parser_Tokenizer.operatorMode();
			break;
		case 6:
			glsl_parser_Tokenizer.literalMode();
			break;
		case 11:
			glsl_parser_Tokenizer.floatingConstantMode();
			break;
		case 12:
			glsl_parser_Tokenizer.fractionalConstantMode();
			break;
		case 13:
			glsl_parser_Tokenizer.exponentPartMode();
			break;
		case 9:case 10:case 8:
			glsl_parser_Tokenizer.integerConstantMode();
			break;
		default:
			glsl_parser_Tokenizer.error("unhandled mode " + Std.string(glsl_parser_Tokenizer.mode));
		}
		if(glsl_parser_Tokenizer.mode == lastMode && glsl_parser_Tokenizer.i == glsl_parser_Tokenizer.last_i) {
			glsl_parser_Tokenizer.error("unclosed mode " + Std.string(glsl_parser_Tokenizer.mode));
			break;
		}
	}
	var _g1 = 0;
	var _g2 = glsl_parser_Tokenizer.tokens.length;
	while(_g1 < _g2) {
		var j = _g1++;
		var t = glsl_parser_Tokenizer.tokens[j];
		if(t.type != glsl_parser_TokenType.IDENTIFIER) continue;
		var previousTokenType = null;
		var k = j - 1;
		while(k >= 0 && previousTokenType == null) {
			var tt = glsl_parser_Tokenizer.tokens[k--].type;
			if(HxOverrides.indexOf(glsl_parser_Tokenizer.skippableTypes,tt,0) == -1) previousTokenType = tt;
		}
		if(previousTokenType == glsl_parser_TokenType.STRUCT) {
			glsl_parser_Tokenizer.userDefinedTypes.push(t.data);
			continue;
		}
		if(HxOverrides.indexOf(glsl_parser_Tokenizer.userDefinedTypes,t.data,0) != -1) {
			var nextTokenType = null;
			var k1 = j + 1;
			while(k1 < glsl_parser_Tokenizer.tokens.length && nextTokenType == null) {
				var tt1 = glsl_parser_Tokenizer.tokens[k1++].type;
				if(HxOverrides.indexOf(glsl_parser_Tokenizer.skippableTypes,tt1,0) == -1) nextTokenType = tt1;
			}
			if(nextTokenType == glsl_parser_TokenType.IDENTIFIER || nextTokenType == glsl_parser_TokenType.LEFT_PAREN || nextTokenType == glsl_parser_TokenType.LEFT_BRACKET) t.type = glsl_parser_TokenType.TYPE_NAME;
		}
	}
	return glsl_parser_Tokenizer.tokens;
};
glsl_parser_Tokenizer.startLen = function(m) {
	return glsl_parser_Tokenizer.startConditionsMap.get(m)();
};
glsl_parser_Tokenizer.isStart = function(m) {
	return glsl_parser_Tokenizer.startLen(m) != null;
};
glsl_parser_Tokenizer.isEnd = function(m) {
	return glsl_parser_Tokenizer.endConditionsMap.get(m)();
};
glsl_parser_Tokenizer.tryMode = function(m) {
	var n = glsl_parser_Tokenizer.startConditionsMap.get(m)();
	if(n != null) {
		glsl_parser_Tokenizer.mode = m;
		glsl_parser_Tokenizer.advance(n);
		return true;
	}
	return false;
};
glsl_parser_Tokenizer.advance = function(n) {
	if(n == null) n = 1;
	glsl_parser_Tokenizer.last_i = glsl_parser_Tokenizer.i;
	while(n-- > 0 && glsl_parser_Tokenizer.i < glsl_parser_Tokenizer.source.length) {
		glsl_parser_Tokenizer.buf += glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i);
		glsl_parser_Tokenizer.i++;
	}
	var splitByLines = new EReg("\n","gm").split(glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.last_i,glsl_parser_Tokenizer.i));
	var nl = splitByLines.length - 1;
	if(nl > 0) {
		glsl_parser_Tokenizer.line += nl;
		glsl_parser_Tokenizer.col = splitByLines[nl].length + 1;
	} else glsl_parser_Tokenizer.col += glsl_parser_Tokenizer.i - glsl_parser_Tokenizer.last_i;
};
glsl_parser_Tokenizer.determineMode = function() {
	glsl_parser_Tokenizer.buf = "";
	glsl_parser_Tokenizer.lineStart = glsl_parser_Tokenizer.line;
	glsl_parser_Tokenizer.colStart = glsl_parser_Tokenizer.col;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.WHITESPACE)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.LITERAL)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.OPERATOR)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT)) return;
	if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT)) return;
	glsl_parser_Tokenizer.warn("unrecognized token " + glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
	glsl_parser_Tokenizer.advance();
	return;
};
glsl_parser_Tokenizer.preprocessorMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.blockCommentMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.BLOCK_COMMENT);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.lineCommentMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.LINE_COMMENT);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.whitespaceMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.WHITESPACE);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.operatorMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		var tmp;
		var _this = glsl_parser_Tokenizer.operatorMap;
		var key = glsl_parser_Tokenizer.buf;
		if(__map_reserved[key] != null) tmp = _this.getReserved(key); else tmp = _this.h[key];
		glsl_parser_Tokenizer.buildToken(tmp);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.literalMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		var tt = null;
		var tmp;
		var _this = glsl_parser_Tokenizer.keywordMap;
		var key = glsl_parser_Tokenizer.buf;
		if(__map_reserved[key] != null) tmp = _this.getReserved(key); else tmp = _this.h[key];
		tt = tmp;
		if(tt == null && glsl_parser_Tokenizer.previousTokenType() == glsl_parser_TokenType.DOT) tt = glsl_parser_TokenType.FIELD_SELECTION;
		if(tt == null) tt = glsl_parser_TokenType.IDENTIFIER;
		glsl_parser_Tokenizer.buildToken(tt);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.floatingConstantMode = function() {
	var _g = glsl_parser_Tokenizer.floatMode;
	switch(_g) {
	case 0:
		if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT)) {
			glsl_parser_Tokenizer.floatMode = 1;
			return;
		}
		var j = glsl_parser_Tokenizer.i;
		while(new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i))) glsl_parser_Tokenizer.advance();
		if(glsl_parser_Tokenizer.i > j) {
			glsl_parser_Tokenizer.floatMode = 2;
			return;
		}
		glsl_parser_Tokenizer.error("error parsing float, could not determine floatMode");
		break;
	case 1:
		glsl_parser_Tokenizer.floatMode = 3;
		if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART)) return;
		break;
	case 2:
		if(glsl_parser_Tokenizer.tryMode(glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART)) {
			glsl_parser_Tokenizer.floatMode = 3;
			return;
		} else glsl_parser_Tokenizer.error("float in floatMode 2 must have exponent part - none found");
		break;
	}
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.FLOATCONSTANT);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		glsl_parser_Tokenizer.floatMode = 0;
		return;
	}
	glsl_parser_Tokenizer.error("error parsing float");
};
glsl_parser_Tokenizer.fractionalConstantMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.exponentPartMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.integerConstantMode = function() {
	if(glsl_parser_Tokenizer.endConditionsMap.get(glsl_parser_Tokenizer.mode)()) {
		glsl_parser_Tokenizer.buildToken(glsl_parser_TokenType.INTCONSTANT);
		glsl_parser_Tokenizer.mode = glsl_parser__$Tokenizer_ScanMode.UNDETERMINED;
		return;
	}
	glsl_parser_Tokenizer.advance();
};
glsl_parser_Tokenizer.buildToken = function(type) {
	if(type == null) glsl_parser_Tokenizer.error("cannot have null token type");
	if(glsl_parser_Tokenizer.buf == "") glsl_parser_Tokenizer.error("cannot have empty token data");
	var token = { type : type, data : glsl_parser_Tokenizer.buf, line : glsl_parser_Tokenizer.lineStart, column : glsl_parser_Tokenizer.colStart, position : glsl_parser_Tokenizer.i - glsl_parser_Tokenizer.buf.length};
	if(glsl_parser_Tokenizer.verbose) console.log("building token " + Std.string(type) + " (" + glsl_parser_Tokenizer.buf + ")");
	glsl_parser_Tokenizer.tokens.push(token);
	if(type == glsl_parser_TokenType.RESERVED_KEYWORD) glsl_parser_Tokenizer.warn("using reserved keyword " + glsl_parser_Tokenizer.buf);
};
glsl_parser_Tokenizer.c = function(j) {
	return glsl_parser_Tokenizer.source.charAt(j);
};
glsl_parser_Tokenizer.previousToken = function(n,ignoreSkippable) {
	if(ignoreSkippable == null) ignoreSkippable = false;
	if(n == null) n = 0;
	if(!ignoreSkippable) return glsl_parser_Tokenizer.tokens[-n + glsl_parser_Tokenizer.tokens.length - 1]; else {
		var t = null;
		var i = 0;
		while(n >= 0 && i < glsl_parser_Tokenizer.tokens.length) {
			t = glsl_parser_Tokenizer.tokens[-i + glsl_parser_Tokenizer.tokens.length - 1];
			if(HxOverrides.indexOf(glsl_parser_Tokenizer.skippableTypes,t.type,0) == -1) n--;
			i++;
		}
		return t;
	}
};
glsl_parser_Tokenizer.previousTokenType = function(n,ignoreSkippable) {
	if(n == null) n = 0;
	var pt = glsl_parser_Tokenizer.previousToken(n,ignoreSkippable);
	return pt != null?pt.type:null;
};
glsl_parser_Tokenizer.warn = function(msg) {
	if(glsl_parser_Tokenizer.onWarn != null) glsl_parser_Tokenizer.onWarn(msg); else glsl_parser_Tokenizer.warnings.push("Tokenizer Warning: " + msg + ", line " + glsl_parser_Tokenizer.line + ", column " + glsl_parser_Tokenizer.col);
};
glsl_parser_Tokenizer.error = function(msg) {
	if(glsl_parser_Tokenizer.onError != null) glsl_parser_Tokenizer.onError(msg); else throw new js__$Boot_HaxeError("Tokenizer Error: " + msg + ", line " + glsl_parser_Tokenizer.line + ", column " + glsl_parser_Tokenizer.col);
};
var glsl_parser_TreeBuilder = function() { };
glsl_parser_TreeBuilder.__name__ = true;
glsl_parser_TreeBuilder.buildRule = function(ruleno) {
	glsl_parser_TreeBuilder.ruleno = ruleno;
	switch(ruleno) {
	case 0:
		return new glsl_Root(glsl_parser_TreeBuilder.s(1));
	case 1:
		return new glsl_Identifier(glsl_parser_TreeBuilder.s(1).data);
	case 2:
		return glsl_parser_TreeBuilder.s(1);
	case 3:
		var l = new glsl_Primitive(Std.parseInt(glsl_parser_TreeBuilder.s(1).data),glsl_DataType.INT);
		l.raw = glsl_parser_TreeBuilder.s(1).data;
		return l;
	case 4:
		var tmp;
		var x = glsl_parser_TreeBuilder.s(1).data;
		tmp = parseFloat(x);
		var l1 = new glsl_Primitive(tmp,glsl_DataType.FLOAT);
		l1.raw = glsl_parser_TreeBuilder.s(1).data;
		return l1;
	case 5:
		var l2 = new glsl_Primitive(glsl_parser_TreeBuilder.s(1).data == "true",glsl_DataType.BOOL);
		l2.raw = glsl_parser_TreeBuilder.s(1).data;
		return l2;
	case 6:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_Expression)).parenWrap = true;
		return glsl_parser_TreeBuilder.s(2);
	case 7:
		return glsl_parser_TreeBuilder.s(1);
	case 8:
		return new glsl_ArrayElementSelectionExpression(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 9:
		return glsl_parser_TreeBuilder.s(1);
	case 10:
		return new glsl_FieldSelectionExpression(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),new glsl_Identifier(glsl_parser_TreeBuilder.s(3).data));
	case 11:
		return new glsl_UnaryExpression(glsl_UnaryOperator.INC_OP,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),false);
	case 12:
		return new glsl_UnaryExpression(glsl_UnaryOperator.DEC_OP,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),false);
	case 13:
		return glsl_parser_TreeBuilder.s(1);
	case 14:
		return glsl_parser_TreeBuilder.s(1);
	case 15:
		return glsl_parser_TreeBuilder.s(1);
	case 16:
		return glsl_parser_TreeBuilder.s(1);
	case 17:
		return glsl_parser_TreeBuilder.s(1);
	case 18:
		return glsl_parser_TreeBuilder.s(1);
	case 19:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_ExpressionParameters)).parameters.push(glsl_parser_TreeBuilder.s(2));
		return glsl_parser_TreeBuilder.s(1);
	case 20:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_ExpressionParameters)).parameters.push(glsl_parser_TreeBuilder.s(3));
		return glsl_parser_TreeBuilder.s(1);
	case 21:
		return glsl_parser_TreeBuilder.s(1);
	case 22:
		return new glsl_Constructor(glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null);
	case 23:
		return new glsl_FunctionCall(glsl_parser_TreeBuilder.s(1).data);
	case 24:
		return glsl_DataType.FLOAT;
	case 25:
		return glsl_DataType.INT;
	case 26:
		return glsl_DataType.BOOL;
	case 27:
		return glsl_DataType.VEC2;
	case 28:
		return glsl_DataType.VEC3;
	case 29:
		return glsl_DataType.VEC4;
	case 30:
		return glsl_DataType.BVEC2;
	case 31:
		return glsl_DataType.BVEC3;
	case 32:
		return glsl_DataType.BVEC4;
	case 33:
		return glsl_DataType.IVEC2;
	case 34:
		return glsl_DataType.IVEC3;
	case 35:
		return glsl_DataType.IVEC4;
	case 36:
		return glsl_DataType.MAT2;
	case 37:
		return glsl_DataType.MAT3;
	case 38:
		return glsl_DataType.MAT4;
	case 39:
		return glsl_DataType.USER_TYPE(glsl_parser_TreeBuilder.s(1).data);
	case 40:
		return glsl_parser_TreeBuilder.s(1);
	case 41:
		return new glsl_UnaryExpression(glsl_UnaryOperator.INC_OP,js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_Expression),true);
	case 42:
		return new glsl_UnaryExpression(glsl_UnaryOperator.DEC_OP,js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_Expression),true);
	case 43:
		return new glsl_UnaryExpression(glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null,js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_Expression),true);
	case 44:
		return glsl_UnaryOperator.PLUS;
	case 45:
		return glsl_UnaryOperator.DASH;
	case 46:
		return glsl_UnaryOperator.BANG;
	case 47:
		return glsl_UnaryOperator.TILDE;
	case 48:
		return glsl_parser_TreeBuilder.s(1);
	case 49:
		return new glsl_BinaryExpression(glsl_BinaryOperator.STAR,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 50:
		return new glsl_BinaryExpression(glsl_BinaryOperator.SLASH,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 51:
		return new glsl_BinaryExpression(glsl_BinaryOperator.PERCENT,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 52:
		return glsl_parser_TreeBuilder.s(1);
	case 53:
		return new glsl_BinaryExpression(glsl_BinaryOperator.PLUS,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 54:
		return new glsl_BinaryExpression(glsl_BinaryOperator.DASH,js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 55:
		return glsl_parser_TreeBuilder.s(1);
	case 56:
		return new glsl_BinaryExpression(glsl_BinaryOperator.LEFT_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 57:
		return new glsl_BinaryExpression(glsl_BinaryOperator.RIGHT_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 58:
		return glsl_parser_TreeBuilder.s(1);
	case 59:
		return new glsl_BinaryExpression(glsl_BinaryOperator.LEFT_ANGLE,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 60:
		return new glsl_BinaryExpression(glsl_BinaryOperator.RIGHT_ANGLE,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 61:
		return new glsl_BinaryExpression(glsl_BinaryOperator.LE_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 62:
		return new glsl_BinaryExpression(glsl_BinaryOperator.GE_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 63:
		return glsl_parser_TreeBuilder.s(1);
	case 64:
		return new glsl_BinaryExpression(glsl_BinaryOperator.EQ_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 65:
		return new glsl_BinaryExpression(glsl_BinaryOperator.NE_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 66:
		return glsl_parser_TreeBuilder.s(1);
	case 67:
		return new glsl_BinaryExpression(glsl_BinaryOperator.AMPERSAND,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 68:
		return glsl_parser_TreeBuilder.s(1);
	case 69:
		return new glsl_BinaryExpression(glsl_BinaryOperator.CARET,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 70:
		return glsl_parser_TreeBuilder.s(1);
	case 71:
		return new glsl_BinaryExpression(glsl_BinaryOperator.VERTICAL_BAR,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 72:
		return glsl_parser_TreeBuilder.s(1);
	case 73:
		return new glsl_BinaryExpression(glsl_BinaryOperator.AND_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 74:
		return glsl_parser_TreeBuilder.s(1);
	case 75:
		return new glsl_BinaryExpression(glsl_BinaryOperator.XOR_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 76:
		return glsl_parser_TreeBuilder.s(1);
	case 77:
		return new glsl_BinaryExpression(glsl_BinaryOperator.OR_OP,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 78:
		return glsl_parser_TreeBuilder.s(1);
	case 79:
		return new glsl_ConditionalExpression(glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3),glsl_parser_TreeBuilder.s(5));
	case 80:
		return glsl_parser_TreeBuilder.s(1);
	case 81:
		return new glsl_AssignmentExpression(glsl_parser_TreeBuilder.s(2) != null?glsl_parser_TreeBuilder.s(2):null,glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3));
	case 82:
		return glsl_AssignmentOperator.EQUAL;
	case 83:
		return glsl_AssignmentOperator.MUL_ASSIGN;
	case 84:
		return glsl_AssignmentOperator.DIV_ASSIGN;
	case 85:
		return glsl_AssignmentOperator.MOD_ASSIGN;
	case 86:
		return glsl_AssignmentOperator.ADD_ASSIGN;
	case 87:
		return glsl_AssignmentOperator.SUB_ASSIGN;
	case 88:
		return glsl_AssignmentOperator.LEFT_ASSIGN;
	case 89:
		return glsl_AssignmentOperator.RIGHT_ASSIGN;
	case 90:
		return glsl_AssignmentOperator.AND_ASSIGN;
	case 91:
		return glsl_AssignmentOperator.XOR_ASSIGN;
	case 92:
		return glsl_AssignmentOperator.OR_ASSIGN;
	case 93:
		return glsl_parser_TreeBuilder.s(1);
	case 94:
		var tmp1;
		var v = js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression);
		tmp1 = js_Boot.__instanceof(v,glsl_SequenceExpression);
		if(tmp1) {
			(js_Boot.__cast(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression) , glsl_SequenceExpression)).expressions.push(js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
			return glsl_parser_TreeBuilder.s(1);
		} else return new glsl_SequenceExpression([js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression)]);
		break;
	case 95:
		return glsl_parser_TreeBuilder.s(1);
	case 96:
		return new glsl_FunctionPrototype(glsl_parser_TreeBuilder.s(1));
	case 97:
		return glsl_parser_TreeBuilder.s(1);
	case 98:
		return new glsl_PrecisionDeclaration(glsl_parser_TreeBuilder.s(2) != null?glsl_parser_TreeBuilder.s(2):null,(js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_TypeSpecifier)).dataType);
	case 99:
		return glsl_parser_TreeBuilder.s(1);
	case 100:
		return glsl_parser_TreeBuilder.s(1);
	case 101:
		return glsl_parser_TreeBuilder.s(1);
	case 102:
		var fh = js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_FunctionHeader);
		fh.parameters.push(glsl_parser_TreeBuilder.s(2));
		return fh;
	case 103:
		var fh1 = js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_FunctionHeader);
		fh1.parameters.push(glsl_parser_TreeBuilder.s(3));
		return fh1;
	case 104:
		return new glsl_FunctionHeader(glsl_parser_TreeBuilder.s(2).data,glsl_parser_TreeBuilder.s(1));
	case 105:
		return new glsl_ParameterDeclaration(glsl_parser_TreeBuilder.s(2).data,glsl_parser_TreeBuilder.s(1));
	case 106:
		return new glsl_ParameterDeclaration(glsl_parser_TreeBuilder.s(2).data,glsl_parser_TreeBuilder.s(1),null,js_Boot.__cast(glsl_parser_TreeBuilder.s(4) , glsl_Expression));
	case 107:
		var pd = js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_ParameterDeclaration);
		pd.parameterQualifier = glsl_parser_TreeBuilder.s(2) != null?glsl_parser_TreeBuilder.s(2):null;
		var tmp2;
		var a = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		tmp2 = Type.enumEq(a,glsl_parser_Instructions.SET_INVARIANT_VARYING);
		if(tmp2) {
			pd.typeSpecifier.storage = glsl_StorageQualifier.VARYING;
			pd.typeSpecifier.invariant = true;
		} else pd.typeSpecifier.storage = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return pd;
	case 108:
		var pd1 = js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_ParameterDeclaration);
		pd1.parameterQualifier = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return pd1;
	case 109:
		var pd2 = js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_ParameterDeclaration);
		pd2.parameterQualifier = glsl_parser_TreeBuilder.s(2) != null?glsl_parser_TreeBuilder.s(2):null;
		var tmp3;
		var a1 = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		tmp3 = Type.enumEq(a1,glsl_parser_Instructions.SET_INVARIANT_VARYING);
		if(tmp3) {
			pd2.typeSpecifier.storage = glsl_StorageQualifier.VARYING;
			pd2.typeSpecifier.invariant = true;
		} else pd2.typeSpecifier.storage = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return pd2;
	case 110:
		var pd3 = js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_ParameterDeclaration);
		pd3.parameterQualifier = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return pd3;
	case 111:
		return null;
	case 112:
		return glsl_ParameterQualifier.IN;
	case 113:
		return glsl_ParameterQualifier.OUT;
	case 114:
		return glsl_ParameterQualifier.INOUT;
	case 115:
		return new glsl_ParameterDeclaration(null,glsl_parser_TreeBuilder.s(1));
	case 116:
		return new glsl_ParameterDeclaration(null,glsl_parser_TreeBuilder.s(1),null,js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 117:
		return glsl_parser_TreeBuilder.s(1);
	case 118:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_VariableDeclaration)).declarators.push(new glsl_Declarator(glsl_parser_TreeBuilder.s(3).data,null,null));
		return glsl_parser_TreeBuilder.s(1);
	case 119:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_VariableDeclaration)).declarators.push(new glsl_Declarator(glsl_parser_TreeBuilder.s(3).data,null,js_Boot.__cast(glsl_parser_TreeBuilder.s(5) , glsl_Expression)));
		return glsl_parser_TreeBuilder.s(1);
	case 120:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_VariableDeclaration)).declarators.push(new glsl_Declarator(glsl_parser_TreeBuilder.s(3).data,js_Boot.__cast(glsl_parser_TreeBuilder.s(5) , glsl_Expression),null));
		return glsl_parser_TreeBuilder.s(1);
	case 121:
		return new glsl_VariableDeclaration(glsl_parser_TreeBuilder.s(1),[]);
	case 122:
		return new glsl_VariableDeclaration(glsl_parser_TreeBuilder.s(1),[new glsl_Declarator(glsl_parser_TreeBuilder.s(2).data,null,null)]);
	case 123:
		return new glsl_VariableDeclaration(glsl_parser_TreeBuilder.s(1),[new glsl_Declarator(glsl_parser_TreeBuilder.s(2).data,null,js_Boot.__cast(glsl_parser_TreeBuilder.s(4) , glsl_Expression))]);
	case 124:
		return new glsl_VariableDeclaration(glsl_parser_TreeBuilder.s(1),[new glsl_Declarator(glsl_parser_TreeBuilder.s(2).data,js_Boot.__cast(glsl_parser_TreeBuilder.s(4) , glsl_Expression),null)]);
	case 125:
		return new glsl_VariableDeclaration(new glsl_TypeSpecifier(null,null,null,true),[new glsl_Declarator(glsl_parser_TreeBuilder.s(2).data,null,null)]);
	case 126:
		return glsl_parser_TreeBuilder.s(1);
	case 127:
		var ts = js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_TypeSpecifier);
		var tmp4;
		var a2 = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		tmp4 = Type.enumEq(a2,glsl_parser_Instructions.SET_INVARIANT_VARYING);
		if(tmp4) {
			ts.storage = glsl_StorageQualifier.VARYING;
			ts.invariant = true;
		} else ts.storage = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return glsl_parser_TreeBuilder.s(2);
	case 128:
		return glsl_StorageQualifier.CONST;
	case 129:
		return glsl_StorageQualifier.ATTRIBUTE;
	case 130:
		return glsl_StorageQualifier.VARYING;
	case 131:
		return glsl_parser_Instructions.SET_INVARIANT_VARYING;
	case 132:
		return glsl_StorageQualifier.UNIFORM;
	case 133:
		return glsl_parser_TreeBuilder.s(1);
	case 134:
		var ts1 = js_Boot.__cast(glsl_parser_TreeBuilder.s(2) , glsl_TypeSpecifier);
		ts1.precision = glsl_parser_TreeBuilder.s(1) != null?glsl_parser_TreeBuilder.s(1):null;
		return ts1;
	case 135:
		return new glsl_TypeSpecifier(glsl_DataType.VOID);
	case 136:
		return new glsl_TypeSpecifier(glsl_DataType.FLOAT);
	case 137:
		return new glsl_TypeSpecifier(glsl_DataType.INT);
	case 138:
		return new glsl_TypeSpecifier(glsl_DataType.BOOL);
	case 139:
		return new glsl_TypeSpecifier(glsl_DataType.VEC2);
	case 140:
		return new glsl_TypeSpecifier(glsl_DataType.VEC3);
	case 141:
		return new glsl_TypeSpecifier(glsl_DataType.VEC4);
	case 142:
		return new glsl_TypeSpecifier(glsl_DataType.BVEC2);
	case 143:
		return new glsl_TypeSpecifier(glsl_DataType.BVEC3);
	case 144:
		return new glsl_TypeSpecifier(glsl_DataType.BVEC4);
	case 145:
		return new glsl_TypeSpecifier(glsl_DataType.IVEC2);
	case 146:
		return new glsl_TypeSpecifier(glsl_DataType.IVEC3);
	case 147:
		return new glsl_TypeSpecifier(glsl_DataType.IVEC4);
	case 148:
		return new glsl_TypeSpecifier(glsl_DataType.MAT2);
	case 149:
		return new glsl_TypeSpecifier(glsl_DataType.MAT3);
	case 150:
		return new glsl_TypeSpecifier(glsl_DataType.MAT4);
	case 151:
		return new glsl_TypeSpecifier(glsl_DataType.SAMPLER2D);
	case 152:
		return new glsl_TypeSpecifier(glsl_DataType.SAMPLERCUBE);
	case 153:
		return glsl_parser_TreeBuilder.s(1);
	case 154:
		return new glsl_TypeSpecifier(glsl_DataType.USER_TYPE(glsl_parser_TreeBuilder.s(1).data));
	case 155:
		return glsl_PrecisionQualifier.HIGH_PRECISION;
	case 156:
		return glsl_PrecisionQualifier.MEDIUM_PRECISION;
	case 157:
		return glsl_PrecisionQualifier.LOW_PRECISION;
	case 158:
		return new glsl_StructSpecifier(glsl_parser_TreeBuilder.s(2).data,glsl_parser_TreeBuilder.s(4));
	case 159:
		return new glsl_StructSpecifier(null,glsl_parser_TreeBuilder.s(3));
	case 160:
		return [glsl_parser_TreeBuilder.s(1)];
	case 161:
		glsl_parser_TreeBuilder.s(1).push(glsl_parser_TreeBuilder.s(2));
		return glsl_parser_TreeBuilder.s(1);
	case 162:
		return new glsl_StructFieldDeclaration(glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(2));
	case 163:
		return [glsl_parser_TreeBuilder.s(1)];
	case 164:
		glsl_parser_TreeBuilder.s(1).push(glsl_parser_TreeBuilder.s(3));
		return glsl_parser_TreeBuilder.s(1);
	case 165:
		return new glsl_StructDeclarator(glsl_parser_TreeBuilder.s(1).data);
	case 166:
		return new glsl_StructDeclarator(glsl_parser_TreeBuilder.s(1).data,js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression));
	case 167:
		return glsl_parser_TreeBuilder.s(1);
	case 168:
		return new glsl_DeclarationStatement(glsl_parser_TreeBuilder.s(1));
	case 169:
		return glsl_parser_TreeBuilder.s(1);
	case 170:
		return glsl_parser_TreeBuilder.s(1);
	case 171:
		return glsl_parser_TreeBuilder.s(1);
	case 172:
		return glsl_parser_TreeBuilder.s(1);
	case 173:
		return glsl_parser_TreeBuilder.s(1);
	case 174:
		return glsl_parser_TreeBuilder.s(1);
	case 175:
		return glsl_parser_TreeBuilder.s(1);
	case 176:
		return glsl_parser_TreeBuilder.s(1);
	case 177:
		return new glsl_CompoundStatement([],true);
	case 178:
		return new glsl_CompoundStatement(glsl_parser_TreeBuilder.s(2),true);
	case 179:
		return glsl_parser_TreeBuilder.s(1);
	case 180:
		return glsl_parser_TreeBuilder.s(1);
	case 181:
		return new glsl_CompoundStatement([],false);
	case 182:
		return new glsl_CompoundStatement(glsl_parser_TreeBuilder.s(2),false);
	case 183:
		return [glsl_parser_TreeBuilder.s(1)];
	case 184:
		glsl_parser_TreeBuilder.s(1).push(glsl_parser_TreeBuilder.s(2));
		return glsl_parser_TreeBuilder.s(1);
	case 185:
		return new glsl_ExpressionStatement(null);
	case 186:
		return new glsl_ExpressionStatement(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression));
	case 187:
		return new glsl_IfStatement(js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression),glsl_parser_TreeBuilder.s(5)[0],glsl_parser_TreeBuilder.s(5)[1]);
	case 188:
		return [glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(3)];
	case 189:
		return [glsl_parser_TreeBuilder.s(1),null];
	case 190:
		return glsl_parser_TreeBuilder.s(1);
	case 191:
		return new glsl_VariableDeclaration(glsl_parser_TreeBuilder.s(1),[new glsl_Declarator(glsl_parser_TreeBuilder.s(2).data,js_Boot.__cast(glsl_parser_TreeBuilder.s(4) , glsl_Expression),null)]);
	case 192:
		return new glsl_WhileStatement(js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression),glsl_parser_TreeBuilder.s(5));
	case 193:
		return new glsl_DoWhileStatement(js_Boot.__cast(glsl_parser_TreeBuilder.s(5) , glsl_Expression),glsl_parser_TreeBuilder.s(2));
	case 194:
		return new glsl_ForStatement(glsl_parser_TreeBuilder.s(3),glsl_parser_TreeBuilder.s(4)[0],glsl_parser_TreeBuilder.s(4)[1],glsl_parser_TreeBuilder.s(6));
	case 195:
		return glsl_parser_TreeBuilder.s(1);
	case 196:
		return glsl_parser_TreeBuilder.s(1);
	case 197:
		return glsl_parser_TreeBuilder.s(1);
	case 198:
		return null;
	case 199:
		return [js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),null];
	case 200:
		return [js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Expression),js_Boot.__cast(glsl_parser_TreeBuilder.s(3) , glsl_Expression)];
	case 201:
		return new glsl_JumpStatement(glsl_JumpMode.CONTINUE);
	case 202:
		return new glsl_JumpStatement(glsl_JumpMode.BREAK);
	case 203:
		return new glsl_ReturnStatement(null);
	case 204:
		return new glsl_ReturnStatement(glsl_parser_TreeBuilder.s(2));
	case 205:
		return new glsl_JumpStatement(glsl_JumpMode.DISCARD);
	case 206:
		return [glsl_parser_TreeBuilder.s(1)];
	case 207:
		glsl_parser_TreeBuilder.s(1).push(glsl_parser_TreeBuilder.s(2));
		return glsl_parser_TreeBuilder.s(1);
	case 208:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Declaration)).external = true;
		return glsl_parser_TreeBuilder.s(1);
	case 209:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Declaration)).external = true;
		return glsl_parser_TreeBuilder.s(1);
	case 210:
		(js_Boot.__cast(glsl_parser_TreeBuilder.s(1) , glsl_Declaration)).external = true;
		return glsl_parser_TreeBuilder.s(1);
	case 211:
		return new glsl_FunctionDefinition(glsl_parser_TreeBuilder.s(1),glsl_parser_TreeBuilder.s(2));
	case 212:
		return new glsl_PreprocessorDirective(glsl_parser_TreeBuilder.s(1).data);
	}
	glsl_parser_Parser.warn("unhandled reduce rule number " + ruleno);
	return null;
};
glsl_parser_TreeBuilder.reset = function() {
	glsl_parser_TreeBuilder.ruleno = -1;
};
glsl_parser_TreeBuilder.s = function(n) {
	if(n <= 0) return null;
	var j = glsl_parser__$Parser_RuleInfoEntry_$Impl_$.get_nrhs(glsl_parser_Parser.ruleInfo[glsl_parser_TreeBuilder.ruleno]) - n;
	return glsl_parser_Parser.stack[glsl_parser_Parser.i - j].minor;
};
glsl_parser_TreeBuilder.n = function(m) {
	return glsl_parser_TreeBuilder.s(m);
};
glsl_parser_TreeBuilder.t = function(m) {
	return glsl_parser_TreeBuilder.s(m);
};
glsl_parser_TreeBuilder.e = function(m) {
	return js_Boot.__cast(glsl_parser_TreeBuilder.s(m) , glsl_Expression);
};
glsl_parser_TreeBuilder.ev = function(m) {
	return glsl_parser_TreeBuilder.s(m) != null?glsl_parser_TreeBuilder.s(m):null;
};
glsl_parser_TreeBuilder.a = function(m) {
	return glsl_parser_TreeBuilder.s(m);
};
glsl_parser_TreeBuilder.get_i = function() {
	return glsl_parser_Parser.i;
};
glsl_parser_TreeBuilder.get_stack = function() {
	return glsl_parser_Parser.stack;
};
var glsl_parser_Instructions = { __ename__ : true, __constructs__ : ["SET_INVARIANT_VARYING"] };
glsl_parser_Instructions.SET_INVARIANT_VARYING = ["SET_INVARIANT_VARYING",0];
glsl_parser_Instructions.SET_INVARIANT_VARYING.toString = $estr;
glsl_parser_Instructions.SET_INVARIANT_VARYING.__enum__ = glsl_parser_Instructions;
var glsl_printer_NodePrinter = function() { };
glsl_printer_NodePrinter.__name__ = true;
glsl_printer_NodePrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n);
	if(_g == null) throw new js__$Boot_HaxeError("Node cannot be printed: " + Std.string(n)); else switch(_g[1]) {
	case 0:
		tmp = glsl_printer_RootPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 1:
		tmp = glsl_printer_TypeSpecifierPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 2:
		tmp = glsl_printer_StructSpecifierPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 3:
		tmp = glsl_printer_StructFieldDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 4:
		tmp = glsl_printer_StructDeclaratorPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 5:
		tmp = glsl_printer_ExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 6:
		tmp = glsl_printer_IdentifierPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 7:
		tmp = glsl_printer_PrimitivePrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 8:
		tmp = glsl_printer_BinaryExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 9:
		tmp = glsl_printer_UnaryExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 10:
		tmp = glsl_printer_SequenceExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 11:
		tmp = glsl_printer_ConditionalExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 12:
		tmp = glsl_printer_AssignmentExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 13:
		tmp = glsl_printer_FieldSelectionExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 14:
		tmp = glsl_printer_ArrayElementSelectionExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 15:
		tmp = glsl_printer_FunctionCallPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 16:
		tmp = glsl_printer_ConstructorPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 17:
		tmp = glsl_printer_DeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 18:
		tmp = glsl_printer_PrecisionDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 19:
		tmp = glsl_printer_VariableDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 20:
		tmp = glsl_printer_DeclaratorPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 21:
		tmp = glsl_printer_ParameterDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 22:
		tmp = glsl_printer_FunctionDefinitionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 23:
		tmp = glsl_printer_FunctionPrototypePrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 24:
		tmp = glsl_printer_FunctionHeaderPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 25:
		tmp = glsl_printer_StatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 26:
		tmp = glsl_printer_CompoundStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 27:
		tmp = glsl_printer_DeclarationStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 28:
		tmp = glsl_printer_ExpressionStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 29:
		tmp = glsl_printer_IterationStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 30:
		tmp = glsl_printer_WhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 31:
		tmp = glsl_printer_DoWhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 32:
		tmp = glsl_printer_ForStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 33:
		tmp = glsl_printer_IfStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 34:
		tmp = glsl_printer_JumpStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 35:
		tmp = glsl_printer_ReturnStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	default:
		throw new js__$Boot_HaxeError("Node cannot be printed: " + Std.string(n));
	}
	return tmp;
};
var glsl_printer_RootPrinter = function() { };
glsl_printer_RootPrinter.__name__ = true;
glsl_printer_RootPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	var _g1 = 0;
	var _g = n.declarations.length;
	while(_g1 < _g) {
		var i = _g1++;
		var d = n.declarations[i];
		var unit = glsl_printer_DeclarationPrinter.print(d,indentWith,0);
		var currentNodeEnum = glsl_NodeEnumHelper.toEnum(d);
		var nextNodeEnum = glsl_NodeEnumHelper.toEnum(n.declarations[i + 1]);
		if(pretty) {
			if(nextNodeEnum != null) {
				unit = unit + "\n";
				var tmp;
				if(!(currentNodeEnum[1] != nextNodeEnum[1])) switch(currentNodeEnum[1]) {
				case 22:
					tmp = true;
					break;
				default:
					tmp = false;
				} else tmp = true;
				if(tmp) unit = unit + "\n";
			}
		} else {
			var tmp1;
			switch(currentNodeEnum[1]) {
			case 36:
				tmp1 = true;
				break;
			default:
				tmp1 = false;
			}
			if(tmp1) unit = unit + "\n"; else {
				var tmp2;
				if(nextNodeEnum != null) switch(nextNodeEnum[1]) {
				case 36:
					tmp2 = true;
					break;
				default:
					tmp2 = false;
				} else tmp2 = false;
				if(tmp2) unit = unit + "\n";
			}
		}
		str += unit;
	}
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_TypeSpecifierPrinter = function() { };
glsl_printer_TypeSpecifierPrinter.__name__ = true;
glsl_printer_TypeSpecifierPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	{
		var _g = glsl_NodeEnumHelper.toEnum(n);
		switch(_g[1]) {
		case 2:
			return glsl_printer_StructSpecifierPrinter.print(_g[2],indentWith,indentLevel);
		default:
		}
	}
	var str = "";
	var qualifiers = [];
	if(n.invariant) qualifiers.push("invariant");
	if(n.storage != null) qualifiers.push(glsl_printer_StorageQualifierPrinter.print(n.storage));
	if(n.precision != null) qualifiers.push(glsl_printer_PrecisionQualifierPrinter.print(n.precision));
	if(n.dataType != null) qualifiers.push(glsl_printer_DataTypePrinter.print(n.dataType));
	str += qualifiers.join(" ");
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_StructSpecifierPrinter = function() { };
glsl_printer_StructSpecifierPrinter.__name__ = true;
glsl_printer_StructSpecifierPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	var qualifiers = [];
	if(n.invariant) qualifiers.push("invariant");
	if(n.storage != null) qualifiers.push(glsl_printer_StorageQualifierPrinter.print(n.storage));
	if(n.precision != null) qualifiers.push(glsl_printer_PrecisionQualifierPrinter.print(n.precision));
	str += qualifiers.join(" ") + (qualifiers.length > 0?" ":"");
	var name = n.name != null?n.name:"";
	str += "struct " + name + "{" + (pretty?"\n":"");
	str += n.fieldDeclarations.map(function(fd) {
		return glsl_printer_StructFieldDeclarationPrinter.print(fd,indentWith,1);
	}).join(pretty?"\n":"");
	str += (pretty?"\n":"") + "}";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_StructFieldDeclarationPrinter = function() { };
glsl_printer_StructFieldDeclarationPrinter.__name__ = true;
glsl_printer_StructFieldDeclarationPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = glsl_printer_TypeSpecifierPrinter.print(n.typeSpecifier,indentWith,0) + " ";
	str += n.declarators.map(function(dr) {
		return glsl_printer_StructDeclaratorPrinter.print(dr,indentWith);
	}).join(pretty?", ":",");
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_StructDeclaratorPrinter = function() { };
glsl_printer_StructDeclaratorPrinter.__name__ = true;
glsl_printer_StructDeclaratorPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = n.name + (n.arraySizeExpression != null?"[" + glsl_printer_ExpressionPrinter.print(n.arraySizeExpression,indentWith,0) + "]":"");
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ExpressionPrinter = function() { };
glsl_printer_ExpressionPrinter.__name__ = true;
glsl_printer_ExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n);
	if(_g == null) throw new js__$Boot_HaxeError("Expression cannot be printed: " + Std.string(n)); else switch(_g[1]) {
	case 6:
		tmp = glsl_printer_IdentifierPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 7:
		tmp = glsl_printer_PrimitivePrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 8:
		tmp = glsl_printer_BinaryExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 9:
		tmp = glsl_printer_UnaryExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 10:
		tmp = glsl_printer_SequenceExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 11:
		tmp = glsl_printer_ConditionalExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 12:
		tmp = glsl_printer_AssignmentExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 13:
		tmp = glsl_printer_FieldSelectionExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 14:
		tmp = glsl_printer_ArrayElementSelectionExpressionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 15:
		tmp = glsl_printer_FunctionCallPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 16:
		tmp = glsl_printer_ConstructorPrinter.print(_g[2],indentWith,indentLevel);
		break;
	default:
		throw new js__$Boot_HaxeError("Expression cannot be printed: " + Std.string(n));
	}
	return tmp;
};
var glsl_printer_IdentifierPrinter = function() { };
glsl_printer_IdentifierPrinter.__name__ = true;
glsl_printer_IdentifierPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = n.name;
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_PrimitivePrinter = function() { };
glsl_printer_PrimitivePrinter.__name__ = true;
glsl_printer_PrimitivePrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = n.raw;
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_BinaryExpressionPrinter = function() { };
glsl_printer_BinaryExpressionPrinter.__name__ = true;
glsl_printer_BinaryExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	str += glsl_printer_ExpressionPrinter.print(n.left,indentWith);
	str += pretty?" " + glsl_printer_BinaryOperatorPrinter.print(n.op) + " ":glsl_printer_BinaryOperatorPrinter.print(n.op);
	str += glsl_printer_ExpressionPrinter.print(n.right,indentWith);
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_UnaryExpressionPrinter = function() { };
glsl_printer_UnaryExpressionPrinter.__name__ = true;
glsl_printer_UnaryExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = "";
	if(n.isPrefix) str += glsl_printer_UnaryOperatorPrinter.print(n.op) + glsl_printer_ExpressionPrinter.print(n.arg,indentWith); else str += glsl_printer_ExpressionPrinter.print(n.arg,indentWith) + glsl_printer_UnaryOperatorPrinter.print(n.op);
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_SequenceExpressionPrinter = function() { };
glsl_printer_SequenceExpressionPrinter.__name__ = true;
glsl_printer_SequenceExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = n.expressions.map(function(e) {
		return glsl_printer_ExpressionPrinter.print(e,indentWith);
	}).join(pretty?", ":",");
	str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ConditionalExpressionPrinter = function() { };
glsl_printer_ConditionalExpressionPrinter.__name__ = true;
glsl_printer_ConditionalExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = glsl_printer_ExpressionPrinter.print(n.test,indentWith) + (pretty?" ? ":"?") + glsl_printer_ExpressionPrinter.print(n.consequent,indentWith) + (pretty?" : ":":") + glsl_printer_ExpressionPrinter.print(n.alternate,indentWith);
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_AssignmentExpressionPrinter = function() { };
glsl_printer_AssignmentExpressionPrinter.__name__ = true;
glsl_printer_AssignmentExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	str += glsl_printer_ExpressionPrinter.print(n.left,indentWith);
	str += pretty?" " + glsl_printer_AssignmentOperatorPrinter.print(n.op) + " ":glsl_printer_AssignmentOperatorPrinter.print(n.op);
	str += glsl_printer_ExpressionPrinter.print(n.right,indentWith);
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_FieldSelectionExpressionPrinter = function() { };
glsl_printer_FieldSelectionExpressionPrinter.__name__ = true;
glsl_printer_FieldSelectionExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_ExpressionPrinter.print(n.left,indentWith) + "." + glsl_printer_IdentifierPrinter.print(n.field,indentWith);
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ArrayElementSelectionExpressionPrinter = function() { };
glsl_printer_ArrayElementSelectionExpressionPrinter.__name__ = true;
glsl_printer_ArrayElementSelectionExpressionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_ExpressionPrinter.print(n.left,indentWith) + "[" + glsl_printer_ExpressionPrinter.print(n.arrayIndexExpression,indentWith) + "]";
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_FunctionCallPrinter = function() { };
glsl_printer_FunctionCallPrinter.__name__ = true;
glsl_printer_FunctionCallPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	{
		var _g = glsl_NodeEnumHelper.toEnum(n);
		switch(_g[1]) {
		case 16:
			return glsl_printer_ConstructorPrinter.print(_g[2],indentWith,indentLevel);
		default:
		}
	}
	var pretty = indentWith != null;
	var str = n.name + "(";
	str += n.parameters.map(function(e) {
		return glsl_printer_ExpressionPrinter.print(e,indentWith);
	}).join(pretty?", ":",");
	str += ")";
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ConstructorPrinter = function() { };
glsl_printer_ConstructorPrinter.__name__ = true;
glsl_printer_ConstructorPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = glsl_printer_DataTypePrinter.print(n.dataType) + "(";
	str += n.parameters.map(function(e) {
		return glsl_printer_ExpressionPrinter.print(e,indentWith);
	}).join(pretty?", ":",");
	str += ")";
	if(n.parenWrap) str = "(" + str + ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_DeclarationPrinter = function() { };
glsl_printer_DeclarationPrinter.__name__ = true;
glsl_printer_DeclarationPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n);
	if(_g == null) throw new js__$Boot_HaxeError("Declaration cannot be printed: " + Std.string(n)); else switch(_g[1]) {
	case 18:
		tmp = glsl_printer_PrecisionDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 19:
		tmp = glsl_printer_VariableDeclarationPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 23:
		tmp = glsl_printer_FunctionPrototypePrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 22:
		tmp = glsl_printer_FunctionDefinitionPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 36:
		tmp = glsl_printer_PreprocessorDirectivePrinter.print(_g[2],indentWith,indentLevel);
		break;
	default:
		throw new js__$Boot_HaxeError("Declaration cannot be printed: " + Std.string(n));
	}
	return tmp;
};
var glsl_printer_PrecisionDeclarationPrinter = function() { };
glsl_printer_PrecisionDeclarationPrinter.__name__ = true;
glsl_printer_PrecisionDeclarationPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = "precision " + glsl_printer_PrecisionQualifierPrinter.print(n.precision) + " " + glsl_printer_DataTypePrinter.print(n.dataType) + ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_VariableDeclarationPrinter = function() { };
glsl_printer_VariableDeclarationPrinter.__name__ = true;
glsl_printer_VariableDeclarationPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = glsl_printer_TypeSpecifierPrinter.print(n.typeSpecifier,indentWith,0) + (n.declarators.length > 0?" ":"");
	str += n.declarators.map(function(dr) {
		return glsl_printer_DeclaratorPrinter.print(dr,indentWith);
	}).join(pretty?", ":",");
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_DeclaratorPrinter = function() { };
glsl_printer_DeclaratorPrinter.__name__ = true;
glsl_printer_DeclaratorPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	str += (n.name != null?n.name:"") + (n.arraySizeExpression != null?"[" + glsl_printer_ExpressionPrinter.print(n.arraySizeExpression,indentWith,0) + "]":"") + (n.initializer != null?(pretty?" = ":"=") + glsl_printer_ExpressionPrinter.print(n.initializer,indentWith,0):"");
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ParameterDeclarationPrinter = function() { };
glsl_printer_ParameterDeclarationPrinter.__name__ = true;
glsl_printer_ParameterDeclarationPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var parts = [];
	if(n.parameterQualifier != null) parts.push(glsl_printer_ParameterQualifierPrinter.print(n.parameterQualifier));
	if(n.typeSpecifier != null) parts.push(glsl_printer_TypeSpecifierPrinter.print(n.typeSpecifier,indentWith));
	if(n.name != null) parts.push(n.name);
	if(n.arraySizeExpression != null) parts.push("[" + glsl_printer_ExpressionPrinter.print(n.arraySizeExpression,indentWith) + "]");
	var str = parts.join(" ");
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_FunctionDefinitionPrinter = function() { };
glsl_printer_FunctionDefinitionPrinter.__name__ = true;
glsl_printer_FunctionDefinitionPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_FunctionHeaderPrinter.print(n.header,indentWith);
	str += glsl_printer_CompoundStatementPrinter.print(n.body,indentWith);
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_FunctionPrototypePrinter = function() { };
glsl_printer_FunctionPrototypePrinter.__name__ = true;
glsl_printer_FunctionPrototypePrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_FunctionHeaderPrinter.print(n.header,indentWith) + ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_FunctionHeaderPrinter = function() { };
glsl_printer_FunctionHeaderPrinter.__name__ = true;
glsl_printer_FunctionHeaderPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = glsl_printer_TypeSpecifierPrinter.print(n.returnType,indentWith) + " " + n.name + "(";
	str += n.parameters.map(function(p) {
		return glsl_printer_ParameterDeclarationPrinter.print(p,indentWith);
	}).join(pretty?", ":",");
	str += ")";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_StatementPrinter = function() { };
glsl_printer_StatementPrinter.__name__ = true;
glsl_printer_StatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n);
	if(_g == null) throw new js__$Boot_HaxeError("Statement cannot be printed: " + Std.string(n)); else switch(_g[1]) {
	case 26:
		tmp = glsl_printer_CompoundStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 27:
		tmp = glsl_printer_DeclarationStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 28:
		tmp = glsl_printer_ExpressionStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 29:
		tmp = glsl_printer_IterationStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 30:
		tmp = glsl_printer_WhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 31:
		tmp = glsl_printer_DoWhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 32:
		tmp = glsl_printer_ForStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 33:
		tmp = glsl_printer_IfStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 34:
		tmp = glsl_printer_JumpStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 35:
		tmp = glsl_printer_ReturnStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 36:
		tmp = glsl_printer_PreprocessorDirectivePrinter.print(_g[2],indentWith,indentLevel);
		break;
	default:
		throw new js__$Boot_HaxeError("Statement cannot be printed: " + Std.string(n));
	}
	return tmp;
};
var glsl_printer_CompoundStatementPrinter = function() { };
glsl_printer_CompoundStatementPrinter.__name__ = true;
glsl_printer_CompoundStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "";
	str += "{" + (pretty?"\n":"");
	var _g1 = 0;
	var _g = n.statementList.length;
	while(_g1 < _g) {
		var i = _g1++;
		var smt = n.statementList[i];
		var smtStr = glsl_printer_StatementPrinter.print(smt,indentWith,1);
		var currentNodeEnum = glsl_NodeEnumHelper.toEnum(smt);
		var nextNodeEnum = glsl_NodeEnumHelper.toEnum(n.statementList[i + 1]);
		if(pretty) {
			if(nextNodeEnum != null) {
				smtStr = smtStr + "\n";
				if(currentNodeEnum[1] != nextNodeEnum[1] || js_Boot.__instanceof(smt,glsl_IterationStatement)) smtStr = smtStr + "\n";
			}
		} else {
			var previousNodeEnum = glsl_NodeEnumHelper.toEnum(n.statementList[i - 1]);
			var tmp;
			switch(currentNodeEnum[1]) {
			case 36:
				tmp = true;
				break;
			default:
				tmp = false;
			}
			if(tmp) {
				smtStr = smtStr + "\n";
				if(previousNodeEnum == null) smtStr = "\n" + smtStr;
			} else {
				var tmp1;
				if(nextNodeEnum != null) switch(nextNodeEnum[1]) {
				case 36:
					tmp1 = true;
					break;
				default:
					tmp1 = false;
				} else tmp1 = false;
				if(tmp1) smtStr = smtStr + "\n";
			}
		}
		str += smtStr;
	}
	str += (pretty?"\n":"") + "}";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_DeclarationStatementPrinter = function() { };
glsl_printer_DeclarationStatementPrinter.__name__ = true;
glsl_printer_DeclarationStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_DeclarationPrinter.print(n.declaration,indentWith);
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ExpressionStatementPrinter = function() { };
glsl_printer_ExpressionStatementPrinter.__name__ = true;
glsl_printer_ExpressionStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = n.expression != null?glsl_printer_ExpressionPrinter.print(n.expression,indentWith):"";
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_IfStatementPrinter = function() { };
glsl_printer_IfStatementPrinter.__name__ = true;
glsl_printer_IfStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n.consequent);
	switch(_g[1]) {
	case 26:
		tmp = true;
		break;
	default:
		tmp = false;
	}
	var compoundConsequent = tmp;
	var str = "if(" + glsl_printer_ExpressionPrinter.print(n.test,indentWith) + ")";
	str += pretty && !compoundConsequent?" ":"";
	str += glsl_printer_StatementPrinter.print(n.consequent,indentWith);
	if(n.alternate != null) {
		str += pretty && !compoundConsequent?"\n":"";
		var tmp1;
		var _g1 = glsl_NodeEnumHelper.toEnum(n.alternate);
		switch(_g1[1]) {
		case 26:
			tmp1 = true;
			break;
		default:
			tmp1 = false;
		}
		var compoundAlternate = tmp1;
		str += "else";
		str += !compoundAlternate?" ":"";
		str += glsl_printer_StatementPrinter.print(n.alternate,indentWith);
	}
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_JumpStatementPrinter = function() { };
glsl_printer_JumpStatementPrinter.__name__ = true;
glsl_printer_JumpStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	{
		var _g = glsl_NodeEnumHelper.toEnum(n);
		switch(_g[1]) {
		case 35:
			glsl_printer_ReturnStatementPrinter.print(_g[2],indentWith,indentLevel);
			break;
		default:
		}
	}
	var str = glsl_printer_JumpModePrinter.print(n.mode);
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ReturnStatementPrinter = function() { };
glsl_printer_ReturnStatementPrinter.__name__ = true;
glsl_printer_ReturnStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = glsl_printer_JumpModePrinter.print(n.mode);
	if(n.returnExpression != null) str += " " + glsl_printer_ExpressionPrinter.print(n.returnExpression,indentWith);
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_IterationStatementPrinter = function() { };
glsl_printer_IterationStatementPrinter.__name__ = true;
glsl_printer_IterationStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n);
	if(_g == null) throw new js__$Boot_HaxeError("IterationStatement cannot be printed: " + Std.string(n)); else switch(_g[1]) {
	case 30:
		tmp = glsl_printer_WhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 31:
		tmp = glsl_printer_DoWhileStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	case 32:
		tmp = glsl_printer_ForStatementPrinter.print(_g[2],indentWith,indentLevel);
		break;
	default:
		throw new js__$Boot_HaxeError("IterationStatement cannot be printed: " + Std.string(n));
	}
	return tmp;
};
var glsl_printer_WhileStatementPrinter = function() { };
glsl_printer_WhileStatementPrinter.__name__ = true;
glsl_printer_WhileStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = "while(" + glsl_printer_ExpressionPrinter.print(n.test,indentWith) + ")";
	str += glsl_printer_StatementPrinter.print(n.body,indentWith);
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_DoWhileStatementPrinter = function() { };
glsl_printer_DoWhileStatementPrinter.__name__ = true;
glsl_printer_DoWhileStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var tmp;
	var _g = glsl_NodeEnumHelper.toEnum(n.body);
	switch(_g[1]) {
	case 26:
		tmp = true;
		break;
	default:
		tmp = false;
	}
	var compoundBody = tmp;
	var str = "do";
	str += !compoundBody?" ":"";
	str += glsl_printer_StatementPrinter.print(n.body,indentWith);
	str += !compoundBody && pretty?"\n":"";
	str += "while(" + glsl_printer_ExpressionPrinter.print(n.test,indentWith) + ")";
	str += ";";
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_ForStatementPrinter = function() { };
glsl_printer_ForStatementPrinter.__name__ = true;
glsl_printer_ForStatementPrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var pretty = indentWith != null;
	var str = "for";
	str += "(" + glsl_printer_StatementPrinter.print(n.init,indentWith) + (pretty?" ":"") + glsl_printer_ExpressionPrinter.print(n.test,indentWith) + (pretty?"; ":";") + glsl_printer_ExpressionPrinter.print(n.update,indentWith) + ")";
	str += glsl_printer_StatementPrinter.print(n.body,indentWith);
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_PreprocessorDirectivePrinter = function() { };
glsl_printer_PreprocessorDirectivePrinter.__name__ = true;
glsl_printer_PreprocessorDirectivePrinter.print = function(n,indentWith,indentLevel) {
	if(indentLevel == null) indentLevel = 0;
	var str = n.content;
	return glsl_printer_Utils.indent(str,indentWith,indentLevel);
};
var glsl_printer_BinaryOperatorPrinter = function() { };
glsl_printer_BinaryOperatorPrinter.__name__ = true;
glsl_printer_BinaryOperatorPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 5:
		tmp = "<<";
		break;
	case 6:
		tmp = ">>";
		break;
	case 9:
		tmp = "<=";
		break;
	case 10:
		tmp = ">=";
		break;
	case 11:
		tmp = "==";
		break;
	case 12:
		tmp = "!=";
		break;
	case 16:
		tmp = "&&";
		break;
	case 18:
		tmp = "||";
		break;
	case 17:
		tmp = "^^";
		break;
	case 4:
		tmp = "-";
		break;
	case 3:
		tmp = "+";
		break;
	case 0:
		tmp = "*";
		break;
	case 1:
		tmp = "/";
		break;
	case 2:
		tmp = "%";
		break;
	case 7:
		tmp = "<";
		break;
	case 8:
		tmp = ">";
		break;
	case 15:
		tmp = "|";
		break;
	case 14:
		tmp = "^";
		break;
	case 13:
		tmp = "&";
		break;
	}
	return tmp;
};
var glsl_printer_UnaryOperatorPrinter = function() { };
glsl_printer_UnaryOperatorPrinter.__name__ = true;
glsl_printer_UnaryOperatorPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 0:
		tmp = "++";
		break;
	case 1:
		tmp = "--";
		break;
	case 4:
		tmp = "!";
		break;
	case 3:
		tmp = "-";
		break;
	case 5:
		tmp = "~";
		break;
	case 2:
		tmp = "+";
		break;
	}
	return tmp;
};
var glsl_printer_AssignmentOperatorPrinter = function() { };
glsl_printer_AssignmentOperatorPrinter.__name__ = true;
glsl_printer_AssignmentOperatorPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 1:
		tmp = "*=";
		break;
	case 2:
		tmp = "/=";
		break;
	case 4:
		tmp = "+=";
		break;
	case 3:
		tmp = "%=";
		break;
	case 5:
		tmp = "-=";
		break;
	case 6:
		tmp = "<<=";
		break;
	case 7:
		tmp = ">>=";
		break;
	case 8:
		tmp = "&=";
		break;
	case 9:
		tmp = "^=";
		break;
	case 10:
		tmp = "|=";
		break;
	case 0:
		tmp = "=";
		break;
	}
	return tmp;
};
var glsl_printer_PrecisionQualifierPrinter = function() { };
glsl_printer_PrecisionQualifierPrinter.__name__ = true;
glsl_printer_PrecisionQualifierPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 0:
		tmp = "highp";
		break;
	case 1:
		tmp = "mediump";
		break;
	case 2:
		tmp = "lowp";
		break;
	}
	return tmp;
};
var glsl_printer_JumpModePrinter = function() { };
glsl_printer_JumpModePrinter.__name__ = true;
glsl_printer_JumpModePrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 1:
		tmp = "break";
		break;
	case 0:
		tmp = "continue";
		break;
	case 2:
		tmp = "return";
		break;
	case 3:
		tmp = "discard";
		break;
	}
	return tmp;
};
var glsl_printer_DataTypePrinter = function() { };
glsl_printer_DataTypePrinter.__name__ = true;
glsl_printer_DataTypePrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 0:
		tmp = "void";
		break;
	case 2:
		tmp = "int";
		break;
	case 1:
		tmp = "float";
		break;
	case 3:
		tmp = "bool";
		break;
	case 4:
		tmp = "vec2";
		break;
	case 5:
		tmp = "vec3";
		break;
	case 6:
		tmp = "vec4";
		break;
	case 7:
		tmp = "bvec2";
		break;
	case 8:
		tmp = "bvec3";
		break;
	case 9:
		tmp = "bvec4";
		break;
	case 10:
		tmp = "ivec2";
		break;
	case 11:
		tmp = "ivec3";
		break;
	case 12:
		tmp = "ivec4";
		break;
	case 13:
		tmp = "mat2";
		break;
	case 14:
		tmp = "mat3";
		break;
	case 15:
		tmp = "mat4";
		break;
	case 16:
		tmp = "sampler2D";
		break;
	case 17:
		tmp = "samplerCube";
		break;
	case 18:
		tmp = e[2];
		break;
	}
	return tmp;
};
var glsl_printer_ParameterQualifierPrinter = function() { };
glsl_printer_ParameterQualifierPrinter.__name__ = true;
glsl_printer_ParameterQualifierPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 0:
		tmp = "in";
		break;
	case 1:
		tmp = "out";
		break;
	case 2:
		tmp = "inout";
		break;
	}
	return tmp;
};
var glsl_printer_StorageQualifierPrinter = function() { };
glsl_printer_StorageQualifierPrinter.__name__ = true;
glsl_printer_StorageQualifierPrinter.print = function(e) {
	var tmp;
	if(e == null) tmp = ""; else switch(e[1]) {
	case 1:
		tmp = "attribute";
		break;
	case 3:
		tmp = "uniform";
		break;
	case 2:
		tmp = "varying";
		break;
	case 0:
		tmp = "const";
		break;
	}
	return tmp;
};
var glsl_printer_TokenArrayPrinter = function() { };
glsl_printer_TokenArrayPrinter.__name__ = true;
glsl_printer_TokenArrayPrinter.print = function(tokens) {
	var str = "";
	var _g = 0;
	while(_g < tokens.length) {
		var t = tokens[_g];
		++_g;
		str += glsl_printer_TokenPrinter.print(t);
	}
	return str;
};
var glsl_printer_TokenPrinter = function() { };
glsl_printer_TokenPrinter.__name__ = true;
glsl_printer_TokenPrinter.print = function(token) {
	return token.data;
};
var glsl_printer_Utils = function() { };
glsl_printer_Utils.__name__ = true;
glsl_printer_Utils.indent = function(str,chars,level) {
	if(level == null) level = 1;
	if(chars == null || level == 0) return str;
	var result = "";
	var tmp;
	var _g = [];
	var _g1 = 0;
	while(_g1 < level) {
		_g1++;
		_g.push(chars);
	}
	tmp = _g;
	var identStr = tmp.join("");
	var lines = str.split("\n");
	var _g2 = 0;
	var _g11 = lines.length;
	while(_g2 < _g11) {
		var i = _g2++;
		var line = lines[i];
		result += identStr + line + (i < lines.length - 1?"\n":"");
	}
	return result;
};
glsl_printer_Utils.glslIntString = function(i) {
	var str = i == null?"null":"" + i;
	var rx = new EReg("(\\d+)\\.","g");
	if(rx.match(str)) str = rx.matched(1);
	return str == ""?"0":str;
};
glsl_printer_Utils.glslFloatString = function(f) {
	var str = f == null?"null":"" + f;
	var rx = new EReg("\\.","g");
	if(!rx.match(str)) str += ".0";
	return str;
};
glsl_printer_Utils.glslBoolString = function(b) {
	return b == null?"null":"" + b;
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.__name__ = true;
haxe_Timer.prototype = {
	run: function() {
	}
	,__class__: haxe_Timer
};
var haxe_ds_BalancedTree = function() {
};
haxe_ds_BalancedTree.__name__ = true;
haxe_ds_BalancedTree.prototype = {
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
		if(node == null) return new haxe_ds_TreeNode(null,k,v,null);
		var c = this.compare(k,node.key);
		var tmp;
		if(c == 0) tmp = new haxe_ds_TreeNode(node.left,k,v,node.right,node == null?0:node._height); else if(c < 0) {
			var nl = this.setLoop(k,v,node.left);
			tmp = this.balance(nl,node.key,node.value,node.right);
		} else {
			var nr = this.setLoop(k,v,node.right);
			tmp = this.balance(node.left,node.key,node.value,nr);
		}
		return tmp;
	}
	,balance: function(l,k,v,r) {
		var hl = l == null?0:l._height;
		var hr = r == null?0:r._height;
		var tmp;
		if(hl > hr + 2) {
			var tmp1;
			var _this = l.left;
			if(_this == null) tmp1 = 0; else tmp1 = _this._height;
			var tmp2;
			var _this1 = l.right;
			if(_this1 == null) tmp2 = 0; else tmp2 = _this1._height;
			if(tmp1 >= tmp2) tmp = new haxe_ds_TreeNode(l.left,l.key,l.value,new haxe_ds_TreeNode(l.right,k,v,r)); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l.left,l.key,l.value,l.right.left),l.right.key,l.right.value,new haxe_ds_TreeNode(l.right.right,k,v,r));
		} else if(hr > hl + 2) {
			var tmp3;
			var _this2 = r.right;
			if(_this2 == null) tmp3 = 0; else tmp3 = _this2._height;
			var tmp4;
			var _this3 = r.left;
			if(_this3 == null) tmp4 = 0; else tmp4 = _this3._height;
			if(tmp3 > tmp4) tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left),r.key,r.value,r.right); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left.left),r.left.key,r.left.value,new haxe_ds_TreeNode(r.left.right,r.key,r.value,r.right));
		} else tmp = new haxe_ds_TreeNode(l,k,v,r,(hl > hr?hl:hr) + 1);
		return tmp;
	}
	,compare: function(k1,k2) {
		return Reflect.compare(k1,k2);
	}
	,__class__: haxe_ds_BalancedTree
};
var haxe_ds_TreeNode = function(l,k,v,r,h) {
	if(h == null) h = -1;
	this.left = l;
	this.key = k;
	this.value = v;
	this.right = r;
	if(h == -1) {
		var tmp;
		var _this = this.left;
		if(_this == null) tmp = 0; else tmp = _this._height;
		var tmp1;
		var _this1 = this.right;
		if(_this1 == null) tmp1 = 0; else tmp1 = _this1._height;
		var tmp2;
		if(tmp > tmp1) {
			var _this2 = this.left;
			if(_this2 == null) tmp2 = 0; else tmp2 = _this2._height;
		} else {
			var _this3 = this.right;
			if(_this3 == null) tmp2 = 0; else tmp2 = _this3._height;
		}
		this._height = tmp2 + 1;
	} else this._height = h;
};
haxe_ds_TreeNode.__name__ = true;
haxe_ds_TreeNode.prototype = {
	__class__: haxe_ds_TreeNode
};
var haxe_ds_EnumValueMap = function() {
	haxe_ds_BalancedTree.call(this);
};
haxe_ds_EnumValueMap.__name__ = true;
haxe_ds_EnumValueMap.__interfaces__ = [haxe_IMap];
haxe_ds_EnumValueMap.__super__ = haxe_ds_BalancedTree;
haxe_ds_EnumValueMap.prototype = $extend(haxe_ds_BalancedTree.prototype,{
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
		return Reflect.isEnumValue(v1) && Reflect.isEnumValue(v2)?this.compare(v1,v2):(v1 instanceof Array) && v1.__enum__ == null && ((v2 instanceof Array) && v2.__enum__ == null)?this.compareArgs(v1,v2):Reflect.compare(v1,v2);
	}
	,__class__: haxe_ds_EnumValueMap
});
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		return this.rh == null?null:this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		if(__map_reserved[key] != null) {
			key = "$" + key;
			if(this.rh == null || !this.rh.hasOwnProperty(key)) return false;
			delete(this.rh[key]);
			return true;
		} else {
			if(!this.h.hasOwnProperty(key)) return false;
			delete(this.h[key]);
			return true;
		}
	}
	,__class__: haxe_ds_StringMap
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Browser = function() { };
js_Browser.__name__ = true;
js_Browser.getLocalStorage = function() {
	try {
		var s = window.localStorage;
		s.getItem("");
		return s;
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
if(Array.prototype.map == null) Array.prototype.map = function(f) {
	var a = [];
	var _g1 = 0;
	var _g = this.length;
	while(_g1 < _g) {
		var i = _g1++;
		a[i] = f(this[i]);
	}
	return a;
};
var __map_reserved = {}
glsl_parser_ParserTables.ignoredTokens = [glsl_parser_TokenType.WHITESPACE,glsl_parser_TokenType.LINE_COMMENT,glsl_parser_TokenType.BLOCK_COMMENT];
glsl_parser_ParserTables.errorsSymbol = false;
glsl_parser_ParserTables.illegalSymbolNumber = 167;
glsl_parser_ParserTables.nStates = 335;
glsl_parser_ParserTables.nRules = 213;
glsl_parser_ParserTables.actionCount = 2550;
glsl_parser_ParserTables.action = [168,332,331,330,22,45,44,43,42,358,55,54,264,327,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,333,328,166,76,167,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,52,51,50,195,70,242,241,240,84,220,219,218,216,248,247,242,241,240,87,1,197,121,28,119,7,111,109,108,14,107,181,168,332,331,330,22,32,225,224,223,323,55,54,264,320,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,333,328,104,76,20,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,38,215,37,195,70,69,56,36,84,220,219,218,216,248,247,242,241,240,87,1,175,121,210,119,7,111,109,108,14,107,181,168,332,331,330,22,49,48,47,46,35,55,54,264,34,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,333,328,91,76,275,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,359,230,217,195,70,69,56,360,84,220,219,218,216,248,247,242,241,240,87,1,176,121,361,119,7,111,109,108,14,107,181,168,332,331,330,22,41,40,33,21,362,55,54,264,363,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,333,328,83,76,364,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,32,128,365,195,70,334,334,25,84,220,219,218,216,248,247,242,241,240,87,1,198,121,2,119,7,111,109,108,14,107,181,168,332,331,330,22,86,234,366,29,367,55,54,264,368,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,369,370,333,328,371,76,372,326,325,103,165,23,266,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,373,195,70,374,88,268,84,220,219,218,216,248,247,242,241,240,87,2,267,121,265,119,7,111,109,108,14,107,181,168,332,331,330,22,59,235,217,27,231,55,54,264,26,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,229,228,333,328,64,76,77,326,325,103,165,23,266,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,213,195,70,18,9,32,84,220,219,218,216,248,247,242,241,240,87,1,212,121,135,119,7,111,109,108,14,107,181,333,328,90,76,12,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,271,132,207,136,89,65,244,129,63,124,133,123,116,209,62,270,13,211,153,246,274,273,17,246,204,65,244,193,203,202,201,200,199,67,120,194,192,8,329,246,61,233,333,328,90,76,32,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,113,16,207,136,89,65,244,129,63,124,324,123,58,209,62,3,188,211,31,246,72,10,186,32,204,177,206,205,203,202,201,200,199,4,333,328,90,76,6,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,131,185,207,136,89,65,244,129,63,124,237,123,112,209,62,182,15,211,236,246,32,174,32,66,204,177,206,205,203,202,201,200,199,5,333,328,90,76,57,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,30,207,136,89,65,244,129,63,124,243,123,184,209,62,550,550,211,550,246,550,550,550,246,204,550,550,193,203,202,201,200,199,550,191,194,550,550,333,328,90,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,207,136,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,550,550,550,204,189,206,205,203,202,201,200,199,550,333,328,90,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,207,136,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,550,550,550,204,550,550,193,203,202,201,200,199,550,114,194,550,550,333,328,90,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,207,136,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,550,550,550,204,187,206,205,203,202,201,200,199,550,333,328,90,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,207,136,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,550,550,550,204,196,206,205,203,202,201,200,199,333,328,90,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,207,136,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,65,244,550,178,550,550,550,179,67,168,332,331,330,22,246,60,233,11,550,55,54,264,550,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,333,328,82,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,550,195,70,550,550,550,84,220,219,218,216,248,247,242,241,240,87,168,332,331,330,22,550,550,550,550,550,55,54,264,550,152,151,150,149,148,147,146,145,144,143,142,141,140,139,138,137,299,298,297,296,168,332,331,330,22,550,550,550,550,550,55,54,322,550,318,317,316,315,314,313,312,311,310,309,308,307,306,305,304,303,299,298,297,296,550,125,220,219,218,216,248,247,242,241,240,87,550,333,328,118,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,550,214,550,24,65,244,550,550,550,550,117,550,209,62,333,328,550,76,246,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,159,180,550,110,106,333,328,550,76,550,326,325,103,165,23,19,164,319,292,53,80,100,333,328,118,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,550,65,244,550,550,65,244,550,227,85,550,117,226,209,62,246,550,333,328,246,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,93,115,335,287,286,285,284,283,282,281,280,279,278,277,550,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,550,550,550,550,550,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,225,224,223,125,220,219,218,216,550,550,550,550,70,550,550,550,84,220,219,218,216,248,247,242,241,240,87,550,550,550,550,550,550,550,550,70,550,550,181,84,220,219,218,216,248,247,242,241,240,87,550,550,550,550,550,435,550,550,550,550,550,181,550,168,332,331,330,22,550,550,550,550,550,55,54,550,550,318,317,316,315,314,313,312,311,310,309,308,307,306,305,304,303,299,298,297,296,550,171,71,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,225,224,223,125,220,219,218,216,550,550,550,183,170,168,332,331,330,22,550,550,550,173,172,55,54,550,550,318,317,316,315,314,313,312,311,310,309,308,307,306,305,304,303,299,298,297,296,333,328,550,76,550,326,325,103,165,23,266,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,98,190,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,79,333,328,105,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,81,76,550,326,325,103,165,23,289,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,272,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,78,333,328,550,76,550,326,325,103,165,23,276,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,288,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,291,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,333,328,550,76,550,326,325,103,165,23,550,164,319,302,53,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,158,156,92,269,550,134,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,158,156,92,269,550,130,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,158,156,92,269,550,127,550,550,550,550,550,65,244,550,550,333,328,550,76,208,326,325,103,165,23,246,164,319,292,53,80,102,101,75,94,163,162,160,158,156,92,269,550,126,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,158,156,92,269,550,122,333,328,550,76,550,326,325,103,165,23,321,164,319,68,53,80,102,101,75,94,163,162,160,158,156,92,290,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,550,550,550,550,550,550,65,244,248,247,242,241,240,87,67,239,550,550,550,550,246,550,238,550,550,550,248,247,242,241,240,87,550,232,550,550,550,550,550,550,550,550,550,550,248,247,242,241,240,87,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,158,154,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,160,155,550,264,550,263,262,261,260,259,258,257,256,255,254,253,252,251,250,249,245,550,550,550,550,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,163,162,157,550,550,550,550,550,550,550,550,550,550,549,39,550,550,550,550,248,247,550,333,328,87,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,75,94,161,550,171,71,89,65,244,129,63,124,550,123,550,209,62,550,550,211,550,246,550,550,333,328,550,76,550,326,325,103,165,23,170,164,319,292,53,80,102,101,74,169,172,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,101,73,550,550,550,550,550,550,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,97,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,96,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,102,95,333,328,550,76,550,326,325,103,165,23,550,164,319,292,53,80,99,333,328,550,76,550,326,325,103,165,23,550,164,319,301,53,333,328,550,76,550,326,325,103,165,23,550,164,319,300,53,550,333,328,550,76,550,326,325,103,165,23,550,164,319,295,53,550,333,328,550,76,550,326,325,103,165,23,550,164,319,294,53,333,328,550,76,550,326,325,103,165,23,550,164,319,293,53,65,244,550,550,550,550,550,222,85,550,550,221,550,550,246];
glsl_parser_ParserTables.lookahead = [1,2,3,4,5,40,41,42,43,5,11,12,13,8,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,35,36,37,65,66,77,78,79,70,71,72,73,74,75,76,77,78,79,80,81,82,83,7,85,86,87,88,89,90,91,92,1,2,3,4,5,14,67,68,69,6,11,12,13,5,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,98,99,54,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,46,133,47,65,66,137,138,48,70,71,72,73,74,75,76,77,78,79,80,81,82,83,1,85,86,87,88,89,90,91,92,1,2,3,4,5,31,32,38,39,49,11,12,13,50,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,98,99,10,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,5,133,73,65,66,137,138,5,70,71,72,73,74,75,76,77,78,79,80,81,82,83,5,85,86,87,88,89,90,91,92,1,2,3,4,5,44,45,51,52,5,11,12,13,5,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,98,99,5,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,14,1,5,65,66,65,65,7,70,71,72,73,74,75,76,77,78,79,80,81,82,83,81,85,86,87,88,89,90,91,92,1,2,3,4,5,145,146,5,53,5,11,12,13,5,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,5,5,96,97,5,99,5,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,5,65,66,5,1,8,70,71,72,73,74,75,76,77,78,79,80,81,141,83,65,85,86,87,88,89,90,91,92,1,2,3,4,5,81,8,73,7,6,11,12,13,7,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,8,8,96,97,14,99,1,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,8,65,66,5,84,14,70,71,72,73,74,75,76,77,78,79,80,81,141,83,14,85,86,87,88,89,90,91,92,96,97,98,99,5,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,65,1,125,126,127,128,129,130,131,132,129,134,1,136,137,65,7,140,9,142,11,12,54,142,147,128,129,150,151,152,153,154,155,136,157,158,159,6,6,142,143,144,96,97,98,99,14,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,85,5,125,126,127,128,129,130,131,132,6,134,81,136,137,6,65,140,14,142,14,5,65,14,147,148,149,150,151,152,153,154,155,156,96,97,98,99,6,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,1,65,125,126,127,128,129,130,131,132,65,134,6,136,137,65,65,140,146,142,14,158,14,128,147,148,149,150,151,152,153,154,155,156,96,97,98,99,138,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,123,125,126,127,128,129,130,131,132,129,134,65,136,137,166,166,140,166,142,166,166,166,142,147,166,166,150,151,152,153,154,155,166,157,158,166,166,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,166,166,166,147,148,149,150,151,152,153,154,155,166,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,166,166,166,147,166,166,150,151,152,153,154,155,166,157,158,166,166,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,166,166,166,147,148,149,150,151,152,153,154,155,166,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,166,166,166,147,148,149,150,151,152,153,154,155,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,128,129,166,147,166,166,166,151,136,1,2,3,4,5,142,143,144,161,166,11,12,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,166,65,66,166,166,166,70,71,72,73,74,75,76,77,78,79,80,1,2,3,4,5,166,166,166,166,166,11,12,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,1,2,3,4,5,166,166,166,166,166,11,12,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,166,70,71,72,73,74,75,76,77,78,79,80,166,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,166,5,166,7,128,129,166,166,166,166,134,166,136,137,96,97,166,99,142,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,160,166,162,163,96,97,166,99,166,101,102,103,104,105,54,107,108,109,110,111,112,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,128,129,166,166,128,129,166,135,136,166,134,139,136,137,142,166,96,97,142,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,160,0,54,55,56,57,58,59,60,61,62,63,64,166,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,166,166,166,166,166,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,67,68,69,70,71,72,73,74,166,166,166,166,66,166,166,166,70,71,72,73,74,75,76,77,78,79,80,166,166,166,166,166,166,166,166,66,166,166,92,70,71,72,73,74,75,76,77,78,79,80,166,166,166,166,166,6,166,166,166,166,166,92,166,1,2,3,4,5,166,166,166,166,166,11,12,166,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,67,68,69,70,71,72,73,74,166,166,166,65,155,1,2,3,4,5,166,166,166,164,165,11,12,166,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,141,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,98,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,124,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,124,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,124,166,166,166,166,166,128,129,166,166,96,97,166,99,136,101,102,103,104,105,142,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,124,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,166,124,96,97,166,99,166,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,166,166,166,166,166,166,128,129,75,76,77,78,79,80,136,82,166,166,166,166,142,166,144,166,166,166,75,76,77,78,79,80,166,82,166,166,166,166,166,166,166,166,166,166,75,76,77,78,79,80,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,120,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,119,166,13,166,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,166,166,166,166,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,117,118,166,166,166,166,166,166,166,166,166,166,94,95,166,166,166,166,75,76,166,96,97,80,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,115,116,166,125,126,127,128,129,130,131,132,166,134,166,136,137,166,166,140,166,142,166,166,96,97,166,99,166,101,102,103,104,105,155,107,108,109,110,111,112,113,114,164,165,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,114,166,166,166,166,166,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,113,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,111,112,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,166,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,96,97,166,99,166,101,102,103,104,105,166,107,108,109,110,128,129,166,166,166,166,166,135,136,166,166,139,166,166,142];
glsl_parser_ParserTables.shiftUseDefault = -36;
glsl_parser_ParserTables.shiftCount = 168;
glsl_parser_ParserTables.shiftOffsetMin = -35;
glsl_parser_ParserTables.shiftOffsetMax = 2221;
glsl_parser_ParserTables.shiftOffset = [1446,275,183,367,91,-1,459,367,459,367,1111,1191,1191,1605,1539,1605,1605,1605,1605,1605,1605,1605,1605,1225,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1423,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,1605,2103,2103,2103,2103,2085,2067,2103,1526,1410,2221,2221,708,1370,31,-11,278,708,-35,-35,-35,588,1297,26,26,26,717,715,657,174,337,654,579,76,529,514,323,232,237,237,153,153,153,153,158,158,153,158,652,611,83,660,659,645,605,680,664,599,644,563,610,547,590,83,551,443,521,515,499,484,394,487,486,466,463,458,461,384,386,428,434,277,429,426,403,401,398,397,376,372,370,334,309,284,280,262,247,240,212,147,144,147,112,144,108,112,107,108,107,100,95,83,5,4];
glsl_parser_ParserTables.reduceUseDefault = -63;
glsl_parser_ParserTables.reduceCount = 72;
glsl_parser_ParserTables.reduceMin = -62;
glsl_parser_ParserTables.reduceMax = 2424;
glsl_parser_ParserTables.reduceOffset = [2196,586,525,456,899,899,838,773,712,647,959,1177,1262,-62,1634,1607,1050,1544,214,400,308,122,30,1957,1928,1898,1860,1831,1801,1758,1731,1704,1661,2088,2113,2161,1219,2203,1306,1450,2266,2245,2327,2309,2291,1571,2345,1245,1688,1591,2424,2409,2393,2377,2362,1785,2407,1258,975,476,2012,2012,1862,113,21,651,460,228,648,609,604,572,581];
glsl_parser_ParserTables.defaultAction = [548,548,548,548,548,548,548,548,548,548,548,533,548,548,548,534,548,548,548,548,548,548,548,353,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,548,446,446,548,548,548,383,446,548,548,548,400,399,398,375,457,389,388,387,548,548,548,548,450,548,548,453,548,548,548,413,402,401,397,396,395,394,392,391,393,390,548,548,535,548,548,548,548,548,548,548,548,548,548,548,548,525,548,524,548,548,456,436,548,548,548,440,548,548,500,548,548,548,548,548,489,485,484,483,482,481,480,479,478,477,476,475,474,473,472,471,548,412,410,411,408,409,406,407,404,405,403,548,548,348,548,336,541,545,544,543,542,546,517,516,518,531,530,532,547,540,538,539,537,536,529,528,527,526,523,522,515,514,520,519,513,512,511,510,509,508,507,506,505,504,503,462,461,460,452,459,458,439,438,467,466,465,464,463,445,443,449,448,447,444,442,451,441,437,434,494,495,498,501,499,497,496,493,492,491,490,469,468,489,488,487,486,485,484,483,482,481,480,479,478,477,476,475,474,473,472,471,470,433,502,455,454,430,432,521,429,347,346,345,355,427,426,425,424,423,422,421,420,419,418,417,416,428,415,414,383,386,385,384,382,381,380,379,378,377,376,374,373,372,371,370,369,368,367,366,365,364,363,362,361,360,359,357,356,354,352,351,350,349,344,343,342,341,340,339,338,337,431];
glsl_parser_ParserTables.ruleInfo = [[94,1],[96,1],[97,1],[97,1],[97,1],[97,1],[97,3],[99,1],[99,4],[99,1],[99,3],[99,2],[99,2],[100,1],[101,1],[102,2],[102,2],[104,2],[104,1],[103,2],[103,3],[105,2],[107,1],[107,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[108,1],[109,1],[109,2],[109,2],[109,2],[110,1],[110,1],[110,1],[110,1],[111,1],[111,3],[111,3],[111,3],[112,1],[112,3],[112,3],[113,1],[113,3],[113,3],[114,1],[114,3],[114,3],[114,3],[114,3],[115,1],[115,3],[115,3],[116,1],[116,3],[117,1],[117,3],[118,1],[118,3],[119,1],[119,3],[120,1],[120,3],[121,1],[121,3],[122,1],[122,5],[106,1],[106,3],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[123,1],[98,1],[98,3],[124,1],[125,2],[125,2],[125,4],[126,2],[130,1],[130,1],[132,2],[132,3],[131,3],[135,2],[135,5],[133,3],[133,2],[133,3],[133,2],[138,0],[138,1],[138,1],[138,1],[139,1],[139,4],[127,1],[127,3],[127,6],[127,5],[140,1],[140,2],[140,5],[140,4],[140,2],[134,1],[134,2],[137,1],[137,1],[137,1],[137,2],[137,1],[136,1],[136,2],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[129,1],[128,1],[128,1],[128,1],[142,5],[142,4],[143,1],[143,2],[144,3],[145,1],[145,3],[146,1],[146,4],[141,1],[147,1],[148,1],[148,1],[150,1],[150,1],[150,1],[150,1],[150,1],[150,1],[149,2],[149,3],[157,1],[157,1],[158,2],[158,3],[156,1],[156,2],[151,1],[151,2],[152,5],[159,3],[159,1],[160,1],[160,4],[153,5],[153,7],[153,6],[161,1],[161,1],[163,1],[163,0],[162,2],[162,3],[154,2],[154,2],[154,2],[154,3],[154,2],[95,1],[95,2],[164,1],[164,1],[164,1],[165,2],[155,1]];
glsl_parser_ParserTables.tokenIdMap = (function($this) {
	var $r;
	var _g = new haxe_ds_EnumValueMap();
	_g.set(glsl_parser_TokenType.IDENTIFIER,1);
	_g.set(glsl_parser_TokenType.INTCONSTANT,2);
	_g.set(glsl_parser_TokenType.FLOATCONSTANT,3);
	_g.set(glsl_parser_TokenType.BOOLCONSTANT,4);
	_g.set(glsl_parser_TokenType.LEFT_PAREN,5);
	_g.set(glsl_parser_TokenType.RIGHT_PAREN,6);
	_g.set(glsl_parser_TokenType.LEFT_BRACKET,7);
	_g.set(glsl_parser_TokenType.RIGHT_BRACKET,8);
	_g.set(glsl_parser_TokenType.DOT,9);
	_g.set(glsl_parser_TokenType.FIELD_SELECTION,10);
	_g.set(glsl_parser_TokenType.INC_OP,11);
	_g.set(glsl_parser_TokenType.DEC_OP,12);
	_g.set(glsl_parser_TokenType.VOID,13);
	_g.set(glsl_parser_TokenType.COMMA,14);
	_g.set(glsl_parser_TokenType.FLOAT,15);
	_g.set(glsl_parser_TokenType.INT,16);
	_g.set(glsl_parser_TokenType.BOOL,17);
	_g.set(glsl_parser_TokenType.VEC2,18);
	_g.set(glsl_parser_TokenType.VEC3,19);
	_g.set(glsl_parser_TokenType.VEC4,20);
	_g.set(glsl_parser_TokenType.BVEC2,21);
	_g.set(glsl_parser_TokenType.BVEC3,22);
	_g.set(glsl_parser_TokenType.BVEC4,23);
	_g.set(glsl_parser_TokenType.IVEC2,24);
	_g.set(glsl_parser_TokenType.IVEC3,25);
	_g.set(glsl_parser_TokenType.IVEC4,26);
	_g.set(glsl_parser_TokenType.MAT2,27);
	_g.set(glsl_parser_TokenType.MAT3,28);
	_g.set(glsl_parser_TokenType.MAT4,29);
	_g.set(glsl_parser_TokenType.TYPE_NAME,30);
	_g.set(glsl_parser_TokenType.PLUS,31);
	_g.set(glsl_parser_TokenType.DASH,32);
	_g.set(glsl_parser_TokenType.BANG,33);
	_g.set(glsl_parser_TokenType.TILDE,34);
	_g.set(glsl_parser_TokenType.STAR,35);
	_g.set(glsl_parser_TokenType.SLASH,36);
	_g.set(glsl_parser_TokenType.PERCENT,37);
	_g.set(glsl_parser_TokenType.LEFT_OP,38);
	_g.set(glsl_parser_TokenType.RIGHT_OP,39);
	_g.set(glsl_parser_TokenType.LEFT_ANGLE,40);
	_g.set(glsl_parser_TokenType.RIGHT_ANGLE,41);
	_g.set(glsl_parser_TokenType.LE_OP,42);
	_g.set(glsl_parser_TokenType.GE_OP,43);
	_g.set(glsl_parser_TokenType.EQ_OP,44);
	_g.set(glsl_parser_TokenType.NE_OP,45);
	_g.set(glsl_parser_TokenType.AMPERSAND,46);
	_g.set(glsl_parser_TokenType.CARET,47);
	_g.set(glsl_parser_TokenType.VERTICAL_BAR,48);
	_g.set(glsl_parser_TokenType.AND_OP,49);
	_g.set(glsl_parser_TokenType.XOR_OP,50);
	_g.set(glsl_parser_TokenType.OR_OP,51);
	_g.set(glsl_parser_TokenType.QUESTION,52);
	_g.set(glsl_parser_TokenType.COLON,53);
	_g.set(glsl_parser_TokenType.EQUAL,54);
	_g.set(glsl_parser_TokenType.MUL_ASSIGN,55);
	_g.set(glsl_parser_TokenType.DIV_ASSIGN,56);
	_g.set(glsl_parser_TokenType.MOD_ASSIGN,57);
	_g.set(glsl_parser_TokenType.ADD_ASSIGN,58);
	_g.set(glsl_parser_TokenType.SUB_ASSIGN,59);
	_g.set(glsl_parser_TokenType.LEFT_ASSIGN,60);
	_g.set(glsl_parser_TokenType.RIGHT_ASSIGN,61);
	_g.set(glsl_parser_TokenType.AND_ASSIGN,62);
	_g.set(glsl_parser_TokenType.XOR_ASSIGN,63);
	_g.set(glsl_parser_TokenType.OR_ASSIGN,64);
	_g.set(glsl_parser_TokenType.SEMICOLON,65);
	_g.set(glsl_parser_TokenType.PRECISION,66);
	_g.set(glsl_parser_TokenType.IN,67);
	_g.set(glsl_parser_TokenType.OUT,68);
	_g.set(glsl_parser_TokenType.INOUT,69);
	_g.set(glsl_parser_TokenType.INVARIANT,70);
	_g.set(glsl_parser_TokenType.CONST,71);
	_g.set(glsl_parser_TokenType.ATTRIBUTE,72);
	_g.set(glsl_parser_TokenType.VARYING,73);
	_g.set(glsl_parser_TokenType.UNIFORM,74);
	_g.set(glsl_parser_TokenType.SAMPLER2D,75);
	_g.set(glsl_parser_TokenType.SAMPLERCUBE,76);
	_g.set(glsl_parser_TokenType.HIGH_PRECISION,77);
	_g.set(glsl_parser_TokenType.MEDIUM_PRECISION,78);
	_g.set(glsl_parser_TokenType.LOW_PRECISION,79);
	_g.set(glsl_parser_TokenType.STRUCT,80);
	_g.set(glsl_parser_TokenType.LEFT_BRACE,81);
	_g.set(glsl_parser_TokenType.RIGHT_BRACE,82);
	_g.set(glsl_parser_TokenType.IF,83);
	_g.set(glsl_parser_TokenType.ELSE,84);
	_g.set(glsl_parser_TokenType.WHILE,85);
	_g.set(glsl_parser_TokenType.DO,86);
	_g.set(glsl_parser_TokenType.FOR,87);
	_g.set(glsl_parser_TokenType.CONTINUE,88);
	_g.set(glsl_parser_TokenType.BREAK,89);
	_g.set(glsl_parser_TokenType.RETURN,90);
	_g.set(glsl_parser_TokenType.DISCARD,91);
	_g.set(glsl_parser_TokenType.PREPROCESSOR_DIRECTIVE,92);
	$r = _g;
	return $r;
}(this));
glsl_parser_Parser.preprocess = true;
glsl_parser_Parser.errorsSymbol = false;
glsl_parser_Parser.illegalSymbolNumber = 167;
glsl_parser_Parser.nStates = 335;
glsl_parser_Parser.nRules = 213;
glsl_parser_Parser.noAction = 550;
glsl_parser_Parser.acceptAction = 549;
glsl_parser_Parser.errorAction = 548;
glsl_parser_Parser.actionCount = 2550;
glsl_parser_Parser.action = glsl_parser_ParserTables.action;
glsl_parser_Parser.lookahead = glsl_parser_ParserTables.lookahead;
glsl_parser_Parser.shiftUseDefault = -36;
glsl_parser_Parser.shiftCount = 168;
glsl_parser_Parser.shiftOffsetMin = -35;
glsl_parser_Parser.shiftOffsetMax = 2221;
glsl_parser_Parser.shiftOffset = glsl_parser_ParserTables.shiftOffset;
glsl_parser_Parser.reduceUseDefault = -63;
glsl_parser_Parser.reduceCount = 72;
glsl_parser_Parser.reduceMin = -62;
glsl_parser_Parser.reduceMax = 2424;
glsl_parser_Parser.reduceOffset = glsl_parser_ParserTables.reduceOffset;
glsl_parser_Parser.defaultAction = glsl_parser_ParserTables.defaultAction;
glsl_parser_Parser.ruleInfo = glsl_parser_ParserTables.ruleInfo;
glsl_parser_Parser.tokenIdMap = glsl_parser_ParserTables.tokenIdMap;
glsl_parser_Parser.ignoredTokens = glsl_parser_ParserTables.ignoredTokens;
js_Boot.__toStr = {}.toString;
glsl_parser_Preprocessor.force = false;
glsl_parser_Preprocessor.builtinMacros = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	{
		var value = glsl_parser_PPMacro.UnresolveableMacro(glsl_parser_PPMacro.BuiltinMacroObject(function() {
			return Std.string(glsl_parser_Preprocessor.version);
		}));
		if(__map_reserved.__VERSION__ != null) _g.setReserved("__VERSION__",value); else _g.h["__VERSION__"] = value;
	}
	{
		var value1 = glsl_parser_PPMacro.UnresolveableMacro(glsl_parser_PPMacro.BuiltinMacroObject(function() {
			return Std.string(glsl_parser_Preprocessor.tokens[glsl_parser_Preprocessor.i].line);
		}));
		if(__map_reserved.__LINE__ != null) _g.setReserved("__LINE__",value1); else _g.h["__LINE__"] = value1;
	}
	{
		var value2 = glsl_parser_PPMacro.UnresolveableMacro(glsl_parser_PPMacro.BuiltinMacroObject(function() {
			return "0";
		}));
		if(__map_reserved.__FILE__ != null) _g.setReserved("__FILE__",value2); else _g.h["__FILE__"] = value2;
	}
	{
		var value3 = glsl_parser_PPMacro.UnresolveableMacro(glsl_parser_PPMacro.BuiltinMacroObject(function() {
			return "1";
		}));
		if(__map_reserved.GL_ES != null) _g.setReserved("GL_ES",value3); else _g.h["GL_ES"] = value3;
	}
	$r = _g;
	return $r;
}(this));
glsl_parser_Preprocessor.directiveTitleReg = new EReg("^#\\s*([^\\s]*)","");
glsl_parser_Preprocessor.macroNameReg = new EReg("^([a-z_]\\w*)([^\\w]|$)","i");
glsl_parser_PPTokensHelper.identifierTokens = [glsl_parser_TokenType.IDENTIFIER,glsl_parser_TokenType.ATTRIBUTE,glsl_parser_TokenType.UNIFORM,glsl_parser_TokenType.VARYING,glsl_parser_TokenType.CONST,glsl_parser_TokenType.VOID,glsl_parser_TokenType.INT,glsl_parser_TokenType.FLOAT,glsl_parser_TokenType.BOOL,glsl_parser_TokenType.VEC2,glsl_parser_TokenType.VEC3,glsl_parser_TokenType.VEC4,glsl_parser_TokenType.BVEC2,glsl_parser_TokenType.BVEC3,glsl_parser_TokenType.BVEC4,glsl_parser_TokenType.IVEC2,glsl_parser_TokenType.IVEC3,glsl_parser_TokenType.IVEC4,glsl_parser_TokenType.MAT2,glsl_parser_TokenType.MAT3,glsl_parser_TokenType.MAT4,glsl_parser_TokenType.SAMPLER2D,glsl_parser_TokenType.SAMPLERCUBE,glsl_parser_TokenType.BREAK,glsl_parser_TokenType.CONTINUE,glsl_parser_TokenType.WHILE,glsl_parser_TokenType.DO,glsl_parser_TokenType.FOR,glsl_parser_TokenType.IF,glsl_parser_TokenType.ELSE,glsl_parser_TokenType.RETURN,glsl_parser_TokenType.DISCARD,glsl_parser_TokenType.STRUCT,glsl_parser_TokenType.IN,glsl_parser_TokenType.OUT,glsl_parser_TokenType.INOUT,glsl_parser_TokenType.INVARIANT,glsl_parser_TokenType.PRECISION,glsl_parser_TokenType.HIGH_PRECISION,glsl_parser_TokenType.MEDIUM_PRECISION,glsl_parser_TokenType.LOW_PRECISION,glsl_parser_TokenType.BOOLCONSTANT,glsl_parser_TokenType.RESERVED_KEYWORD,glsl_parser_TokenType.TYPE_NAME,glsl_parser_TokenType.FIELD_SELECTION];
glsl_parser_Tokenizer.verbose = false;
glsl_parser_Tokenizer.floatMode = 0;
glsl_parser_Tokenizer.operatorRegex = new EReg("[&<=>|*?!+%(){}.~:,;/\\-\\^\\[\\]]","");
glsl_parser_Tokenizer.startConditionsMap = (function($this) {
	var $r;
	var _g = new haxe_ds_EnumValueMap();
	_g.set(glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT,function() {
		return glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 2) == "/*"?2:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT,function() {
		return glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 2) == "//"?2:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE,function() {
		if(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "#") {
			var j = glsl_parser_Tokenizer.i - 1;
			while(glsl_parser_Tokenizer.source.charAt(j) != "\n" && glsl_parser_Tokenizer.source.charAt(j) != "") {
				if(!new EReg("\\s","").match(glsl_parser_Tokenizer.source.charAt(j))) return null;
				j--;
			}
			return 1;
		}
		return null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.WHITESPACE,function() {
		return new EReg("\\s","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i))?1:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.OPERATOR,function() {
		return glsl_parser_Tokenizer.operatorRegex.match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i))?1:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.LITERAL,function() {
		return new EReg("[a-z_]","i").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i))?1:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT,function() {
		return new EReg("0x[a-f0-9]","i").match(glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 3))?3:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT,function() {
		return new EReg("0[0-7]","").match(glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 2))?2:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT,function() {
		return new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i))?1:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT,function() {
		if(glsl_parser_Tokenizer.startLen(glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT) != null) return 0;
		var j1 = glsl_parser_Tokenizer.i;
		while(new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(j1))) j1++;
		var _i = glsl_parser_Tokenizer.i;
		glsl_parser_Tokenizer.i = j1;
		var exponentFollows = glsl_parser_Tokenizer.startLen(glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART) != null;
		glsl_parser_Tokenizer.i = _i;
		if(j1 > glsl_parser_Tokenizer.i && exponentFollows) return 0;
		return null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT,function() {
		var j2 = glsl_parser_Tokenizer.i;
		while(new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(j2))) j2++;
		if(j2 > glsl_parser_Tokenizer.i && glsl_parser_Tokenizer.source.charAt(j2) == ".") return ++j2 - glsl_parser_Tokenizer.i;
		return new EReg("\\.\\d","").match(glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 2))?2:null;
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART,function() {
		var r = new EReg("^[e][+-]?\\d","i");
		return r.match(glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i,glsl_parser_Tokenizer.i + 3))?r.matched(0).length:null;
	});
	$r = _g;
	return $r;
}(this));
glsl_parser_Tokenizer.endConditionsMap = (function($this) {
	var $r;
	var _g = new haxe_ds_EnumValueMap();
	_g.set(glsl_parser__$Tokenizer_ScanMode.BLOCK_COMMENT,function() {
		return glsl_parser_Tokenizer.source.substring(glsl_parser_Tokenizer.i - 2,glsl_parser_Tokenizer.i) == "*/";
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.LINE_COMMENT,function() {
		return glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "\n" || glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "";
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.PREPROCESSOR_DIRECTIVE,function() {
		return glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "\n" && glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i - 1) != "\\" || glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "";
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.WHITESPACE,function() {
		return !new EReg("\\s","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.OPERATOR,function() {
		var tmp;
		var key = glsl_parser_Tokenizer.buf + glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i);
		var _this = glsl_parser_Tokenizer.operatorMap;
		if(__map_reserved[key] != null) tmp = _this.existsReserved(key); else tmp = _this.h.hasOwnProperty(key);
		return !tmp || glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i) == "";
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.LITERAL,function() {
		return !new EReg("[a-z0-9_]","i").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.HEX_CONSTANT,function() {
		return !new EReg("[a-f0-9]","i").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.OCTAL_CONSTANT,function() {
		return !new EReg("[0-7]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.DECIMAL_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.FLOATING_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.FRACTIONAL_CONSTANT,function() {
		return !new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	_g.set(glsl_parser__$Tokenizer_ScanMode.EXPONENT_PART,function() {
		return !new EReg("[0-9]","").match(glsl_parser_Tokenizer.source.charAt(glsl_parser_Tokenizer.i));
	});
	$r = _g;
	return $r;
}(this));
glsl_parser_Tokenizer.operatorMap = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	{
		var value = glsl_parser_TokenType.LEFT_OP;
		if(__map_reserved["<<"] != null) _g.setReserved("<<",value); else _g.h["<<"] = value;
	}
	{
		var value1 = glsl_parser_TokenType.RIGHT_OP;
		if(__map_reserved[">>"] != null) _g.setReserved(">>",value1); else _g.h[">>"] = value1;
	}
	{
		var value2 = glsl_parser_TokenType.INC_OP;
		if(__map_reserved["++"] != null) _g.setReserved("++",value2); else _g.h["++"] = value2;
	}
	{
		var value3 = glsl_parser_TokenType.DEC_OP;
		if(__map_reserved["--"] != null) _g.setReserved("--",value3); else _g.h["--"] = value3;
	}
	{
		var value4 = glsl_parser_TokenType.LE_OP;
		if(__map_reserved["<="] != null) _g.setReserved("<=",value4); else _g.h["<="] = value4;
	}
	{
		var value5 = glsl_parser_TokenType.GE_OP;
		if(__map_reserved[">="] != null) _g.setReserved(">=",value5); else _g.h[">="] = value5;
	}
	{
		var value6 = glsl_parser_TokenType.EQ_OP;
		if(__map_reserved["=="] != null) _g.setReserved("==",value6); else _g.h["=="] = value6;
	}
	{
		var value7 = glsl_parser_TokenType.NE_OP;
		if(__map_reserved["!="] != null) _g.setReserved("!=",value7); else _g.h["!="] = value7;
	}
	{
		var value8 = glsl_parser_TokenType.AND_OP;
		if(__map_reserved["&&"] != null) _g.setReserved("&&",value8); else _g.h["&&"] = value8;
	}
	{
		var value9 = glsl_parser_TokenType.OR_OP;
		if(__map_reserved["||"] != null) _g.setReserved("||",value9); else _g.h["||"] = value9;
	}
	{
		var value10 = glsl_parser_TokenType.XOR_OP;
		if(__map_reserved["^^"] != null) _g.setReserved("^^",value10); else _g.h["^^"] = value10;
	}
	{
		var value11 = glsl_parser_TokenType.MUL_ASSIGN;
		if(__map_reserved["*="] != null) _g.setReserved("*=",value11); else _g.h["*="] = value11;
	}
	{
		var value12 = glsl_parser_TokenType.DIV_ASSIGN;
		if(__map_reserved["/="] != null) _g.setReserved("/=",value12); else _g.h["/="] = value12;
	}
	{
		var value13 = glsl_parser_TokenType.ADD_ASSIGN;
		if(__map_reserved["+="] != null) _g.setReserved("+=",value13); else _g.h["+="] = value13;
	}
	{
		var value14 = glsl_parser_TokenType.MOD_ASSIGN;
		if(__map_reserved["%="] != null) _g.setReserved("%=",value14); else _g.h["%="] = value14;
	}
	{
		var value15 = glsl_parser_TokenType.SUB_ASSIGN;
		if(__map_reserved["-="] != null) _g.setReserved("-=",value15); else _g.h["-="] = value15;
	}
	{
		var value16 = glsl_parser_TokenType.LEFT_ASSIGN;
		if(__map_reserved["<<="] != null) _g.setReserved("<<=",value16); else _g.h["<<="] = value16;
	}
	{
		var value17 = glsl_parser_TokenType.RIGHT_ASSIGN;
		if(__map_reserved[">>="] != null) _g.setReserved(">>=",value17); else _g.h[">>="] = value17;
	}
	{
		var value18 = glsl_parser_TokenType.AND_ASSIGN;
		if(__map_reserved["&="] != null) _g.setReserved("&=",value18); else _g.h["&="] = value18;
	}
	{
		var value19 = glsl_parser_TokenType.XOR_ASSIGN;
		if(__map_reserved["^="] != null) _g.setReserved("^=",value19); else _g.h["^="] = value19;
	}
	{
		var value20 = glsl_parser_TokenType.OR_ASSIGN;
		if(__map_reserved["|="] != null) _g.setReserved("|=",value20); else _g.h["|="] = value20;
	}
	{
		var value21 = glsl_parser_TokenType.LEFT_PAREN;
		if(__map_reserved["("] != null) _g.setReserved("(",value21); else _g.h["("] = value21;
	}
	{
		var value22 = glsl_parser_TokenType.RIGHT_PAREN;
		if(__map_reserved[")"] != null) _g.setReserved(")",value22); else _g.h[")"] = value22;
	}
	{
		var value23 = glsl_parser_TokenType.LEFT_BRACKET;
		if(__map_reserved["["] != null) _g.setReserved("[",value23); else _g.h["["] = value23;
	}
	{
		var value24 = glsl_parser_TokenType.RIGHT_BRACKET;
		if(__map_reserved["]"] != null) _g.setReserved("]",value24); else _g.h["]"] = value24;
	}
	{
		var value25 = glsl_parser_TokenType.LEFT_BRACE;
		if(__map_reserved["{"] != null) _g.setReserved("{",value25); else _g.h["{"] = value25;
	}
	{
		var value26 = glsl_parser_TokenType.RIGHT_BRACE;
		if(__map_reserved["}"] != null) _g.setReserved("}",value26); else _g.h["}"] = value26;
	}
	{
		var value27 = glsl_parser_TokenType.DOT;
		if(__map_reserved["."] != null) _g.setReserved(".",value27); else _g.h["."] = value27;
	}
	{
		var value28 = glsl_parser_TokenType.COMMA;
		if(__map_reserved[","] != null) _g.setReserved(",",value28); else _g.h[","] = value28;
	}
	{
		var value29 = glsl_parser_TokenType.COLON;
		if(__map_reserved[":"] != null) _g.setReserved(":",value29); else _g.h[":"] = value29;
	}
	{
		var value30 = glsl_parser_TokenType.EQUAL;
		if(__map_reserved["="] != null) _g.setReserved("=",value30); else _g.h["="] = value30;
	}
	{
		var value31 = glsl_parser_TokenType.SEMICOLON;
		if(__map_reserved[";"] != null) _g.setReserved(";",value31); else _g.h[";"] = value31;
	}
	{
		var value32 = glsl_parser_TokenType.BANG;
		if(__map_reserved["!"] != null) _g.setReserved("!",value32); else _g.h["!"] = value32;
	}
	{
		var value33 = glsl_parser_TokenType.DASH;
		if(__map_reserved["-"] != null) _g.setReserved("-",value33); else _g.h["-"] = value33;
	}
	{
		var value34 = glsl_parser_TokenType.TILDE;
		if(__map_reserved["~"] != null) _g.setReserved("~",value34); else _g.h["~"] = value34;
	}
	{
		var value35 = glsl_parser_TokenType.PLUS;
		if(__map_reserved["+"] != null) _g.setReserved("+",value35); else _g.h["+"] = value35;
	}
	{
		var value36 = glsl_parser_TokenType.STAR;
		if(__map_reserved["*"] != null) _g.setReserved("*",value36); else _g.h["*"] = value36;
	}
	{
		var value37 = glsl_parser_TokenType.SLASH;
		if(__map_reserved["/"] != null) _g.setReserved("/",value37); else _g.h["/"] = value37;
	}
	{
		var value38 = glsl_parser_TokenType.PERCENT;
		if(__map_reserved["%"] != null) _g.setReserved("%",value38); else _g.h["%"] = value38;
	}
	{
		var value39 = glsl_parser_TokenType.LEFT_ANGLE;
		if(__map_reserved["<"] != null) _g.setReserved("<",value39); else _g.h["<"] = value39;
	}
	{
		var value40 = glsl_parser_TokenType.RIGHT_ANGLE;
		if(__map_reserved[">"] != null) _g.setReserved(">",value40); else _g.h[">"] = value40;
	}
	{
		var value41 = glsl_parser_TokenType.VERTICAL_BAR;
		if(__map_reserved["|"] != null) _g.setReserved("|",value41); else _g.h["|"] = value41;
	}
	{
		var value42 = glsl_parser_TokenType.CARET;
		if(__map_reserved["^"] != null) _g.setReserved("^",value42); else _g.h["^"] = value42;
	}
	{
		var value43 = glsl_parser_TokenType.AMPERSAND;
		if(__map_reserved["&"] != null) _g.setReserved("&",value43); else _g.h["&"] = value43;
	}
	{
		var value44 = glsl_parser_TokenType.QUESTION;
		if(__map_reserved["?"] != null) _g.setReserved("?",value44); else _g.h["?"] = value44;
	}
	$r = _g;
	return $r;
}(this));
glsl_parser_Tokenizer.keywordMap = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	{
		var value = glsl_parser_TokenType.ATTRIBUTE;
		if(__map_reserved.attribute != null) _g.setReserved("attribute",value); else _g.h["attribute"] = value;
	}
	{
		var value1 = glsl_parser_TokenType.UNIFORM;
		if(__map_reserved.uniform != null) _g.setReserved("uniform",value1); else _g.h["uniform"] = value1;
	}
	{
		var value2 = glsl_parser_TokenType.VARYING;
		if(__map_reserved.varying != null) _g.setReserved("varying",value2); else _g.h["varying"] = value2;
	}
	{
		var value3 = glsl_parser_TokenType.CONST;
		if(__map_reserved["const"] != null) _g.setReserved("const",value3); else _g.h["const"] = value3;
	}
	{
		var value4 = glsl_parser_TokenType.VOID;
		if(__map_reserved["void"] != null) _g.setReserved("void",value4); else _g.h["void"] = value4;
	}
	{
		var value5 = glsl_parser_TokenType.INT;
		if(__map_reserved["int"] != null) _g.setReserved("int",value5); else _g.h["int"] = value5;
	}
	{
		var value6 = glsl_parser_TokenType.FLOAT;
		if(__map_reserved["float"] != null) _g.setReserved("float",value6); else _g.h["float"] = value6;
	}
	{
		var value7 = glsl_parser_TokenType.BOOL;
		if(__map_reserved.bool != null) _g.setReserved("bool",value7); else _g.h["bool"] = value7;
	}
	{
		var value8 = glsl_parser_TokenType.VEC2;
		if(__map_reserved.vec2 != null) _g.setReserved("vec2",value8); else _g.h["vec2"] = value8;
	}
	{
		var value9 = glsl_parser_TokenType.VEC3;
		if(__map_reserved.vec3 != null) _g.setReserved("vec3",value9); else _g.h["vec3"] = value9;
	}
	{
		var value10 = glsl_parser_TokenType.VEC4;
		if(__map_reserved.vec4 != null) _g.setReserved("vec4",value10); else _g.h["vec4"] = value10;
	}
	{
		var value11 = glsl_parser_TokenType.BVEC2;
		if(__map_reserved.bvec2 != null) _g.setReserved("bvec2",value11); else _g.h["bvec2"] = value11;
	}
	{
		var value12 = glsl_parser_TokenType.BVEC3;
		if(__map_reserved.bvec3 != null) _g.setReserved("bvec3",value12); else _g.h["bvec3"] = value12;
	}
	{
		var value13 = glsl_parser_TokenType.BVEC4;
		if(__map_reserved.bvec4 != null) _g.setReserved("bvec4",value13); else _g.h["bvec4"] = value13;
	}
	{
		var value14 = glsl_parser_TokenType.IVEC2;
		if(__map_reserved.ivec2 != null) _g.setReserved("ivec2",value14); else _g.h["ivec2"] = value14;
	}
	{
		var value15 = glsl_parser_TokenType.IVEC3;
		if(__map_reserved.ivec3 != null) _g.setReserved("ivec3",value15); else _g.h["ivec3"] = value15;
	}
	{
		var value16 = glsl_parser_TokenType.IVEC4;
		if(__map_reserved.ivec4 != null) _g.setReserved("ivec4",value16); else _g.h["ivec4"] = value16;
	}
	{
		var value17 = glsl_parser_TokenType.MAT2;
		if(__map_reserved.mat2 != null) _g.setReserved("mat2",value17); else _g.h["mat2"] = value17;
	}
	{
		var value18 = glsl_parser_TokenType.MAT3;
		if(__map_reserved.mat3 != null) _g.setReserved("mat3",value18); else _g.h["mat3"] = value18;
	}
	{
		var value19 = glsl_parser_TokenType.MAT4;
		if(__map_reserved.mat4 != null) _g.setReserved("mat4",value19); else _g.h["mat4"] = value19;
	}
	{
		var value20 = glsl_parser_TokenType.SAMPLER2D;
		if(__map_reserved.sampler2D != null) _g.setReserved("sampler2D",value20); else _g.h["sampler2D"] = value20;
	}
	{
		var value21 = glsl_parser_TokenType.SAMPLERCUBE;
		if(__map_reserved.samplerCube != null) _g.setReserved("samplerCube",value21); else _g.h["samplerCube"] = value21;
	}
	{
		var value22 = glsl_parser_TokenType.BREAK;
		if(__map_reserved["break"] != null) _g.setReserved("break",value22); else _g.h["break"] = value22;
	}
	{
		var value23 = glsl_parser_TokenType.CONTINUE;
		if(__map_reserved["continue"] != null) _g.setReserved("continue",value23); else _g.h["continue"] = value23;
	}
	{
		var value24 = glsl_parser_TokenType.WHILE;
		if(__map_reserved["while"] != null) _g.setReserved("while",value24); else _g.h["while"] = value24;
	}
	{
		var value25 = glsl_parser_TokenType.DO;
		if(__map_reserved["do"] != null) _g.setReserved("do",value25); else _g.h["do"] = value25;
	}
	{
		var value26 = glsl_parser_TokenType.FOR;
		if(__map_reserved["for"] != null) _g.setReserved("for",value26); else _g.h["for"] = value26;
	}
	{
		var value27 = glsl_parser_TokenType.IF;
		if(__map_reserved["if"] != null) _g.setReserved("if",value27); else _g.h["if"] = value27;
	}
	{
		var value28 = glsl_parser_TokenType.ELSE;
		if(__map_reserved["else"] != null) _g.setReserved("else",value28); else _g.h["else"] = value28;
	}
	{
		var value29 = glsl_parser_TokenType.RETURN;
		if(__map_reserved["return"] != null) _g.setReserved("return",value29); else _g.h["return"] = value29;
	}
	{
		var value30 = glsl_parser_TokenType.DISCARD;
		if(__map_reserved.discard != null) _g.setReserved("discard",value30); else _g.h["discard"] = value30;
	}
	{
		var value31 = glsl_parser_TokenType.STRUCT;
		if(__map_reserved.struct != null) _g.setReserved("struct",value31); else _g.h["struct"] = value31;
	}
	{
		var value32 = glsl_parser_TokenType.IN;
		if(__map_reserved["in"] != null) _g.setReserved("in",value32); else _g.h["in"] = value32;
	}
	{
		var value33 = glsl_parser_TokenType.OUT;
		if(__map_reserved.out != null) _g.setReserved("out",value33); else _g.h["out"] = value33;
	}
	{
		var value34 = glsl_parser_TokenType.INOUT;
		if(__map_reserved.inout != null) _g.setReserved("inout",value34); else _g.h["inout"] = value34;
	}
	{
		var value35 = glsl_parser_TokenType.INVARIANT;
		if(__map_reserved.invariant != null) _g.setReserved("invariant",value35); else _g.h["invariant"] = value35;
	}
	{
		var value36 = glsl_parser_TokenType.PRECISION;
		if(__map_reserved.precision != null) _g.setReserved("precision",value36); else _g.h["precision"] = value36;
	}
	{
		var value37 = glsl_parser_TokenType.HIGH_PRECISION;
		if(__map_reserved.highp != null) _g.setReserved("highp",value37); else _g.h["highp"] = value37;
	}
	{
		var value38 = glsl_parser_TokenType.MEDIUM_PRECISION;
		if(__map_reserved.mediump != null) _g.setReserved("mediump",value38); else _g.h["mediump"] = value38;
	}
	{
		var value39 = glsl_parser_TokenType.LOW_PRECISION;
		if(__map_reserved.lowp != null) _g.setReserved("lowp",value39); else _g.h["lowp"] = value39;
	}
	{
		var value40 = glsl_parser_TokenType.BOOLCONSTANT;
		if(__map_reserved["true"] != null) _g.setReserved("true",value40); else _g.h["true"] = value40;
	}
	{
		var value41 = glsl_parser_TokenType.BOOLCONSTANT;
		if(__map_reserved["false"] != null) _g.setReserved("false",value41); else _g.h["false"] = value41;
	}
	{
		var value42 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.asm != null) _g.setReserved("asm",value42); else _g.h["asm"] = value42;
	}
	{
		var value43 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["class"] != null) _g.setReserved("class",value43); else _g.h["class"] = value43;
	}
	{
		var value44 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.union != null) _g.setReserved("union",value44); else _g.h["union"] = value44;
	}
	{
		var value45 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["enum"] != null) _g.setReserved("enum",value45); else _g.h["enum"] = value45;
	}
	{
		var value46 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.typedef != null) _g.setReserved("typedef",value46); else _g.h["typedef"] = value46;
	}
	{
		var value47 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.template != null) _g.setReserved("template",value47); else _g.h["template"] = value47;
	}
	{
		var value48 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["this"] != null) _g.setReserved("this",value48); else _g.h["this"] = value48;
	}
	{
		var value49 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.packed != null) _g.setReserved("packed",value49); else _g.h["packed"] = value49;
	}
	{
		var value50 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["goto"] != null) _g.setReserved("goto",value50); else _g.h["goto"] = value50;
	}
	{
		var value51 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["switch"] != null) _g.setReserved("switch",value51); else _g.h["switch"] = value51;
	}
	{
		var value52 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["default"] != null) _g.setReserved("default",value52); else _g.h["default"] = value52;
	}
	{
		var value53 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.inline != null) _g.setReserved("inline",value53); else _g.h["inline"] = value53;
	}
	{
		var value54 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.noinline != null) _g.setReserved("noinline",value54); else _g.h["noinline"] = value54;
	}
	{
		var value55 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["volatile"] != null) _g.setReserved("volatile",value55); else _g.h["volatile"] = value55;
	}
	{
		var value56 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["public"] != null) _g.setReserved("public",value56); else _g.h["public"] = value56;
	}
	{
		var value57 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["static"] != null) _g.setReserved("static",value57); else _g.h["static"] = value57;
	}
	{
		var value58 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.extern != null) _g.setReserved("extern",value58); else _g.h["extern"] = value58;
	}
	{
		var value59 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.external != null) _g.setReserved("external",value59); else _g.h["external"] = value59;
	}
	{
		var value60 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["interface"] != null) _g.setReserved("interface",value60); else _g.h["interface"] = value60;
	}
	{
		var value61 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["long"] != null) _g.setReserved("long",value61); else _g.h["long"] = value61;
	}
	{
		var value62 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["short"] != null) _g.setReserved("short",value62); else _g.h["short"] = value62;
	}
	{
		var value63 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["double"] != null) _g.setReserved("double",value63); else _g.h["double"] = value63;
	}
	{
		var value64 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.half != null) _g.setReserved("half",value64); else _g.h["half"] = value64;
	}
	{
		var value65 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.fixed != null) _g.setReserved("fixed",value65); else _g.h["fixed"] = value65;
	}
	{
		var value66 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.unsigned != null) _g.setReserved("unsigned",value66); else _g.h["unsigned"] = value66;
	}
	{
		var value67 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.input != null) _g.setReserved("input",value67); else _g.h["input"] = value67;
	}
	{
		var value68 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.output != null) _g.setReserved("output",value68); else _g.h["output"] = value68;
	}
	{
		var value69 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.hvec2 != null) _g.setReserved("hvec2",value69); else _g.h["hvec2"] = value69;
	}
	{
		var value70 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.hvec3 != null) _g.setReserved("hvec3",value70); else _g.h["hvec3"] = value70;
	}
	{
		var value71 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.hvec4 != null) _g.setReserved("hvec4",value71); else _g.h["hvec4"] = value71;
	}
	{
		var value72 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.dvec2 != null) _g.setReserved("dvec2",value72); else _g.h["dvec2"] = value72;
	}
	{
		var value73 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.dvec3 != null) _g.setReserved("dvec3",value73); else _g.h["dvec3"] = value73;
	}
	{
		var value74 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.dvec4 != null) _g.setReserved("dvec4",value74); else _g.h["dvec4"] = value74;
	}
	{
		var value75 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.fvec2 != null) _g.setReserved("fvec2",value75); else _g.h["fvec2"] = value75;
	}
	{
		var value76 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.fvec3 != null) _g.setReserved("fvec3",value76); else _g.h["fvec3"] = value76;
	}
	{
		var value77 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.fvec4 != null) _g.setReserved("fvec4",value77); else _g.h["fvec4"] = value77;
	}
	{
		var value78 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sampler1DShadow != null) _g.setReserved("sampler1DShadow",value78); else _g.h["sampler1DShadow"] = value78;
	}
	{
		var value79 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sampler2DShadow != null) _g.setReserved("sampler2DShadow",value79); else _g.h["sampler2DShadow"] = value79;
	}
	{
		var value80 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sampler2DRect != null) _g.setReserved("sampler2DRect",value80); else _g.h["sampler2DRect"] = value80;
	}
	{
		var value81 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sampler3DRect != null) _g.setReserved("sampler3DRect",value81); else _g.h["sampler3DRect"] = value81;
	}
	{
		var value82 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sampler2DRectShadow != null) _g.setReserved("sampler2DRectShadow",value82); else _g.h["sampler2DRectShadow"] = value82;
	}
	{
		var value83 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.sizeof != null) _g.setReserved("sizeof",value83); else _g.h["sizeof"] = value83;
	}
	{
		var value84 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.cast != null) _g.setReserved("cast",value84); else _g.h["cast"] = value84;
	}
	{
		var value85 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved["namespace"] != null) _g.setReserved("namespace",value85); else _g.h["namespace"] = value85;
	}
	{
		var value86 = glsl_parser_TokenType.RESERVED_KEYWORD;
		if(__map_reserved.using != null) _g.setReserved("using",value86); else _g.h["using"] = value86;
	}
	$r = _g;
	return $r;
}(this));
glsl_parser_Tokenizer.skippableTypes = [glsl_parser_TokenType.WHITESPACE,glsl_parser_TokenType.BLOCK_COMMENT,glsl_parser_TokenType.LINE_COMMENT];
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
