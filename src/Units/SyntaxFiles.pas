unit SyntaxFiles;

interface

uses
  SysUtils;

const
  DefaultCount = 8;

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
  TDefaultSyntaxes = array [1..DefaultCount] of TSyntaxInfo;

  TLangNames = array of string;

  TSyntaxNode = class
  private
    syntax: PSyntaxInfo;
    syntaxPath: string;
    fileName: string;
    fileExtension: string;
    next: TSyntaxNode;
    prev: TSyntaxNode;
    constructor create(const syntax: PSyntaxInfo; const syntaxPath, fileName, fileExt: string);
    procedure updateSyntaxFile();
  end;

  TSyntaxList = class
  private
    syntaxPath: string;
    fileExtension: string;
    head: TSyntaxNode;
    tail: TSyntaxNode;
    FCount: integer;
    function getNodeByFileName(const name: string): TSyntaxNode;
    procedure removeNode(var Node: TSyntaxNode);
    procedure fillAsDefault();
    Function createSyntaxInfo(const fileExt: shortString; const rWords: TReserved;
                            const sLineComment, mLineCommentBegin,
                            mLineCommentEnd: shortString): TSyntaxInfo;
  public
    constructor create(const SyntaxPath: string);
    procedure createDefaultSyntaxes();
    procedure appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
    procedure removeSyntaxByFileName(const name: string);
    function getSyntaxByFileName(const name: string): PSyntaxInfo;
    function GetCount(): integer;
    procedure SaveSyntaxFiles();
    function GetAllLanguages(): TLangNames;
    property syntaxes[const fileName: string]: PSyntaxInfo read getSyntaxByFileName; default;
    property Count: integer read GetCount;
  end;

implementation

{ TSyntaxNode }

constructor TSyntaxNode.create(const syntax: PSyntaxInfo; const syntaxPath, fileName, fileExt: string);
begin
  self.syntax := syntax;
  self.syntaxPath := syntaxPath;
  self.fileName := fileName;
  self.fileExtension := fileExt;
end;

procedure TSyntaxNode.updateSyntaxFile();
var
  syntaxFile: file of TSyntaxInfo;
  fileName: string;
begin
  if self.syntax <> nil then
  begin
    if not DirectoryExists(Self.syntaxPath) then
      CreateDir(Self.syntaxPath);

    fileName := Self.fileName + self.fileExtension;

    AssignFile(syntaxFile, Self.syntaxPath + '\' + fileName);
    Rewrite(syntaxFile);
    Write(syntaxFile, Self.syntax^);
    CloseFile(syntaxFile);
  end;
end;


{ TSyntaxList }

{ public }

constructor TSyntaxList.create(const SyntaxPath: string);
const
  FileExtension = '.syntax';
begin
  self.syntaxPath := SyntaxPath;
  self.fileExtension := FileExtension;
end;

procedure TSyntaxList.createDefaultSyntaxes;
begin
  if DirectoryExists(Self.syntaxPath) then
      RemoveDir(Self.syntaxPath);

  Self.fillAsDefault;
end;

procedure TSyntaxList.appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
var
  syntaxNode: TSyntaxNode;
begin
  syntaxNode := TSyntaxNode.create(syntax, self.syntaxPath, fileName, self.fileExtension);

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

  syntaxNode.updateSyntaxFile();
  inc(self.FCount);
end;

procedure TSyntaxList.removeSyntaxByFileName(const name: string);
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

function TSyntaxList.GetCount(): integer;
begin
  Result := Self.FCount;
end;

procedure TSyntaxList.SaveSyntaxFiles();
var
  CurrNode: TSyntaxNode;
begin
  CurrNode := Self.head;
  while CurrNode <> nil do
  begin
    CurrNode.updateSyntaxFile();
    CurrNode := CurrNode.next;
  end;
end;

function TSyntaxList.GetAllLanguages(): TLangNames;
var
  CurrNode: TSyntaxNode;
  i: integer;
begin
  CurrNode := Self.head;
  SetLength(Result, Self.FCount);

  if Self.FCount <> 0 then
    for i := 0 to Self.FCount - 1 do
    begin
      Result[i] := CurrNode.fileName;
      CurrNode := CurrNode.next;
    end;
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

  DeleteFile(Self.syntaxPath + '\' + Node.fileName + Node.fileExtension);
  Dec(Self.FCount);
end;

procedure TSyntaxList.fillAsDefault();
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
  self.appendSyntax(@SyntaxInfo, 'C#');

  syntaxInfo := createSyntaxInfo('go', GoLangReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'Go');

  syntaxInfo := createSyntaxInfo('java', JavaReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'Java');

  syntaxInfo := createSyntaxInfo('js', JavaScriptReserved, '//', '/*', '*/');
  self.appendSyntax(@SyntaxInfo, 'JavaScript');

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
