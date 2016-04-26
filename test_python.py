from bin.python_exports import haxpression_PythonExports as Expr

print(Expr.parseEvaluate('a + b', { 'a': 1, 'b': 2 }))


print(Expr.toDict('a + b'))
