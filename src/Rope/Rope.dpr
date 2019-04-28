Program Rope;

{$APPTYPE CONSOLE}

Type
  pNode = ^TNode;
  TNode = record
    leftNode: pNode;
    rightNode: pNode;
    nodeWeight: Integer;
    value: String;
  end;

Var
  Tree: pNode;


Procedure BuildTree(var tree: pNode; const inputStr: String);
begin

end;


Begin
  Tree := nil;

End.
