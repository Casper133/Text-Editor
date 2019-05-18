unit SyntaxFiles;

interface

uses
  SysUtils;

const
  SCount = 8;

type
  TReserved = array [1..50] of string[15];
  TMLineComment = array [1..2] of string[3];

  TSyntaxInfo = packed record
    FileExtension: string[5];
    ReservedWords: TReserved;
    SingleLineComment: string[2];
    MultiLineComment: TMLineComment;
  end;

  PSyntaxInfo = ^TSyntaxInfo;
  TDefaultSyntaxes = array [1..SCount] of TSyntaxInfo;

  TSyntaxNode = class
  private
    syntax: PSyntaxInfo;
    fileName: string;
    fileExtension: string;
    next: TSyntaxNode;
    prev: TSyntaxNode;
    constructor create(const syntax: PSyntaxInfo; const fileName: string);
    procedure updateSyntaxFile(const projectPath: string; fileName: string);
  end;

  TSyntaxList = class
  private
    projectPath: string;
    head: TSyntaxNode;
    tail: TSyntaxNode;
    count: integer;
    function getNodeByFileName(const name: string): TSyntaxNode;
    procedure removeNode(var Node: TSyntaxNode);
    procedure fillAsDefault();
    Function createSyntaxInfo(const fileExt: shortString; const rWords: TReserved;
                            const sLineComment, mLineCommentBegin,
                            mLineCommentEnd: shortString): TSyntaxInfo;
  public
    constructor create(const projectPath: string);
    procedure createDefaultSyntaxes();
    procedure appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
    procedure removeItemByFileName(const name: string);
    function getSyntaxByFileName(const name: string): PSyntaxInfo;
    property syntaxes[const fileName: string]: PSyntaxInfo read getSyntaxByFileName; default;
  end;

implementation

{ TSyntaxNode }

constructor TSyntaxNode.create(const syntax: PSyntaxInfo; const fileName: string);
const
  SyntaxExtension = '.syntax';
begin
  self.syntax := syntax;
  self.fileName := fileName;
  self.fileExtension := SyntaxExtension;
end;

procedure TSyntaxNode.updateSyntaxFile(const projectPath: string; fileName: string);
var
  syntaxFile: file of TSyntaxInfo;
begin
  if self.syntax <> nil then
  begin
    if not DirectoryExists(projectPath + '\syntaxes') then
      CreateDir(projectPath + '\syntaxes');

    fileName := fileName + self.fileExtension;

    AssignFile(syntaxFile, projectPath + '\syntaxes\' + fileName);
    Rewrite(syntaxFile);
    Write(syntaxFile, self.syntax^);
    CloseFile(syntaxFile);
  end;
end;


{ TSyntaxList }

{ public }

constructor TSyntaxList.create(const projectPath: string);
begin
  self.projectPath := projectPath;
end;

procedure TSyntaxList.createDefaultSyntaxes;
begin
  if DirectoryExists(projectPath + '\syntaxes') then
      RemoveDir(projectPath + '\syntaxes');

  self.fillAsDefault;
end;

procedure TSyntaxList.appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
var
  syntaxNode: TSyntaxNode;
begin
  syntaxNode := TSyntaxNode.create(syntax, fileName);

  if self.head = nil then
  begin
    self.head := syntaxNode;
    self.tail := syntaxNode;
  end
  else
  begin
    self.tail.next := syntaxNode;
    syntaxNode.prev := self.tail;
    self.tail := syntaxNode;
  end;

  syntaxNode.updateSyntaxFile(self.projectPath, fileName);
  inc(self.count);
end;

procedure TSyntaxList.removeItemByFileName(const name: string);
var
  Node: TSyntaxNode;
begin
  Node := Self.getNodeByFileName(name);

  if Node <> nil then
    Self.removeNode(Node);
end;

function TSyntaxList.getSyntaxByFileName(const name: string): PSyntaxInfo;
var
  Node: TSyntaxNode;
begin
  Node := Self.getNodeByFileName(name);
  if Node <> nil then
    Result := Node.syntax
  else
    Result := nil;
end;

{ private }

function TSyntaxList.getNodeByFileName(const name: string): TSyntaxNode;
var
  CurrNode: TSyntaxNode;
begin
  CurrNode := Self.head;
  while CurrNode <> nil do
  begin
    if CurrNode.fileName = name then
    begin
      Result := CurrNode;
      Exit;
    end;

    CurrNode := CurrNode.next;
  end;

  Result := nil;
end;

procedure TSyntaxList.removeNode(var Node: TSyntaxNode);
begin
  if (Node <> Self.head) and (Node <> Self.tail) then
    begin
      Node.prev.next := Node.next;
      Node.next.prev := Node.prev;
    end
    else if Node = Self.head then
      Self.head := Node.next
    else if Node = Self.tail then
      Self.tail := Node.prev;

  Dec(Self.count);
end;

procedure TSyntaxList.fillAsDefault;
const
  CLangReserved: TReserved =
                  ('auto', 'break', 'case', 'char', 'const', 'continue',
                   'default', 'do', 'double', 'else', 'enum', 'extern',
                   'float', 'for', 'goto', 'if', 'int', 'long',
                   'register', 'return', 'short', 'signed', 'sizeof', 'static',
                   'struct', 'switch', 'typedef', 'union', 'unsigned', 'void',
                   'volatile', 'while', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
  CPlusPlusReserved: TReserved =
                  ('and', 'and_eq', 'asm', 'bitand', 'bitor', 'bool', 'break',
                   'case', 'catch', 'char', 'class', 'compl', 'const',
                   'continue', 'default', 'do', 'double', 'else', 'enum',
                   'float', 'for', 'goto', 'if', 'int', 'long', 'mutable',
                   'namespace', 'new', 'not', 'not_eq', 'or', 'or_eq',
                   'private', 'protected', 'public', 'return', 'short',
                   'signed', 'static', 'struct', 'switch', 'syncronized',
                   'throw', 'try', 'virtual', 'void', 'volatile', 'while',
                   'xor', 'xor_eq');
  CSharpReserved: TReserved =
                  ('abstract', 'as', 'base', 'bool', 'break', 'byte', 'case',
                   'catch', 'char', 'class', 'const', 'continue', 'default',
                   'delegate', 'do', 'double', 'else', 'enum', 'finally',
                   'fixed', 'float', 'for', 'foreach', 'goto', 'if', 'in',
                   'int', 'interface', 'internal', 'is', 'lock', 'long', 'new',
                   'namespace', 'override', 'private', 'protected', 'public',
                   'return', 'short', 'static', 'struct', 'switch', 'throw',
                   'try', 'using', 'virtual', 'void', 'volatile', 'while');
  GoLangReserved: TReserved =
                  ('break', 'case', 'chan', 'const', 'continue', 'default',
                   'defer', 'else', 'fallthrough', 'for', 'func', 'go', 'goto',
                   'if', 'import', 'interface', 'map', 'package', 'range',
                   'return', 'select', 'struct', 'switch', 'type', 'var', '',
                   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '');
  JavaReserved: TReserved =
                  ('abstract', 'assert', 'boolean', 'break', 'byte', 'case',
                   'catch', 'char', 'class', 'const', 'continue', 'default',
                   'do', 'double', 'else', 'enum', 'extends', 'final',
                   'finally', 'float', 'for', 'goto', 'if', 'implements',
                   'import', 'instanceof', 'int', 'interface', 'long', 'native',
                   'new', 'package', 'private', 'protected', 'public', 'return',
                   'short', 'static', 'strictfp', 'super', 'switch',
                   'synchronized', 'this', 'throw', 'throws', 'transient',
                   'try', 'void', 'volatile', 'while');
  JavaScriptReserved: TReserved =
                  ('await', 'break', 'case', 'catch', 'class', 'const',
                   'continue', 'debugger', 'default', 'delete', 'do', 'else',
                   'export', 'extends', 'finally', 'for', 'function', 'if',
                   'import', 'in', 'instanceof', 'new', 'return', 'super',
                   'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void',
                   'while', 'with', 'yield', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
  KotlinReserved: TReserved =
                  ('as', 'break', 'class', 'continue', 'do', 'else', 'false',
                   'for', 'fun', 'if', 'in', 'interface', 'is', 'null',
                   'object', 'package', 'return', 'super', 'this', 'throw',
                   'true', 'try', 'typealias', 'val', 'var', 'when', 'while',
                   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
  PythonReserved: TReserved =
                  ('and', 'as', 'assert', 'async', 'await', 'break', 'class',
                   'continue', 'def', 'del', 'elif', 'else', 'except', 'False',
                   'finally', 'for', 'from', 'global', 'if', 'import', 'in',
                   'is', 'lambda', 'None', 'nonlocal', 'not', 'or', 'pass',
                   'raise', 'return', 'True', 'try', 'while', 'with', 'yield',
                   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
var
  syntaxInfo: TSyntaxInfo;
begin
  SyntaxInfo := createSyntaxInfo('c', CLangReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'C');

  syntaxInfo := createSyntaxInfo('cpp', CPlusPlusReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'C++');

  syntaxInfo := createSyntaxInfo('cs', CSharpReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'С#');

  syntaxInfo := createSyntaxInfo('go', GoLangReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'Go');

  syntaxInfo := createSyntaxInfo('java', JavaReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'Java');

  syntaxInfo := createSyntaxInfo('js', JavaScriptReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'JS');

  syntaxInfo := createSyntaxInfo('kt', KotlinReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'Kotlin');

  syntaxInfo := createSyntaxInfo('py', PythonReserved, '#', '"""', '"""');
  self.appendSyntax(@SyntaxInfo, 'Python');
end;

function TSyntaxList.createSyntaxInfo(const fileExt: shortString;
                                      const rWords: TReserved;
                                      const sLineComment, mLineCommentBegin,
                                      mLineCommentEnd: shortString): TSyntaxInfo;
var
  syntaxInfo: TSyntaxInfo;
begin
  with syntaxInfo do
  begin
    FileExtension := fileExt;
    ReservedWords := RWords;
    SingleLineComment := sLineComment;
    MultiLineComment[1] := mLineCommentBegin;
    MultiLineComment[2] := mLineCommentEnd;
  end;

  Result := syntaxInfo;
end;

End.
