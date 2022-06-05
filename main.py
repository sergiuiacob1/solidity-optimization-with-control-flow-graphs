import solcast # this puts a definition body in the <AST_NODE>.nodes field
import json
from enum import Enum
# import solc


class NodeType(Enum):
    # might differ based on solidity version
    ReturnType = "Return"
    FunctionDefinition = "FunctionDefinition"
    BlockType = "Block"
    IfStatement = "IfStatement"
    Assignment = "Assignment"
    Identifier = "Identifier"
    IndexAccess = "IndexAccess"
    VariableDeclarationStatement = "VariableDeclarationStatement"
    VariableDeclaration = "VariableDeclaration"


pending_nodes_for_elimination = set()
unused_assignments = []

# with open("dataset/termination.sol") as f:
#     code = f.read()

with open("dataset/termination.ast") as f:
    ast = f.read()

# # get ast
# ast = solc.compile_files(["./dataset/termination.sol"])

cotract = list(json.loads(ast)["sources"].keys())[0]

node = solcast.from_ast(json.loads(ast)["sources"][cotract]["AST"])

# TODO this could return more variables
def get_left_var_from_assignment(node):
    assert node.nodeType == NodeType.Assignment.value
    left = node.leftHandSide
    if left.nodeType == NodeType.Identifier.value:
        return left.name
    elif left.nodeType == NodeType.IndexAccess.value:
        return left.baseExpression.name + "[" + left.indexExpression.value + "]"
    elif left.nodeType == NodeType.VariableDeclarationStatement.value:
        declaration = left.declarations[0]
        assert declaration.nodeType == NodeType.VariableDeclaration.value
        return declaration.name
    
    return None

def get_left_var_from_declaration(node):
    return node.declarations[0].name

# TODO make sure this returns the node ID
def find_unused_assignments(parents, return_node):
    global unused_assignments

    print("Parents of return node with id", return_node.id)
    for parent in parents:
        print(parent.nodeType, end=" ")
    print("\n")

    parent = parents[-1]

    # TODO handle false body
    # TODO this function needs to know for which body the return corresponds to (true body / false body)
    if parent.nodeType == NodeType.IfStatement.value:
        nodes = parent.trueBody
    else:
        nodes = parent.nodes

    print("same level return node with id", return_node.id)
    for node in nodes:
        print(node.nodeType, end=" ")

    for node in nodes:
        print(node.nodeType, end = " ")
        if node.nodeType == "ExpressionStatement":
            expression = node.expression
            if expression.nodeType == "Assignment":
                var = get_left_var_from_assignment(expression)
                unused_assignments.append(var)
        elif node.nodeType == NodeType.VariableDeclarationStatement.value:
            var = get_left_var_from_declaration(node)
            unused_assignments.append(var)

    print("\n")
    print("assignments / declarations for return node with id", return_node.id, ":", unused_assignments)
    unused_assignments = []

def check_body(parents, node):
    ...

# Only searches for return / stop / revert statements in a DFS manner
def find_termination_flow(parents, node):
    global unused_assignments
    print("find_termination_flow", node.id, node.nodeType)

    if node.nodeType == NodeType.ReturnType.value:
        find_unused_assignments(parents, node)
        return # TODO make sure a return node does not have children

    if node.nodeType == "IfStatement":
        if "trueBody" in node.fields:
            true_body = node.trueBody
            for statement in true_body:
                find_termination_flow(parents + [node], statement)
        # TODO handle false body

    # go through the body
    if node.nodeType == NodeType.BlockType.value:
        check_body(parents, node)
        for statement in node.statements:
            print(statement.fields)

    if node.nodeType == NodeType.FunctionDefinition.value:
        print("Children of FunctionDefinition")
        for x in node.nodes:
            print("\t", x.nodeType)
            if x.nodeType == NodeType.BlockType.value:
                print("am gasit body", x)
        print("")

    if "body" in node.fields:
        print("da am gasit aici")
        find_termination_flow(parents + [node], node.body)
    
    if "nodes" in node.fields:
        for child_node in node.nodes:
            find_termination_flow(parents + [node], child_node)

for child_node in node.nodes:
    find_termination_flow([node], child_node)

print(unused_assignments)