unit SyntaxFiles;

interface

uses
  SysUtils, IOUtils, Types, RegularExpressions;

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
    function GetSyntaxInfoFromFile(PathToFile: string): TSyntaxInfo;
    function GetNodeByFileName(const name: string): TSyntaxNode;
    function GetNodeByFileExtension(const FileExt: string): TSyntaxNode;
    procedure RemoveNode(var Node: TSyntaxNode);
    procedure FillAsDefault();
    function CreateSyntaxInfo(const fileExt: shortString; const rWords: TReserved;
                            const sLineComment, mLineCommentBegin,
                            mLineCommentEnd: shortString): TSyntaxInfo;
  public
    constructor create(const SyntaxPath: string);
    procedure createDefaultSyntaxes();
    procedure LoadExistingSyntaxFiles();
    procedure appendSyntax(const Syntax: PSyntaxInfo; const fileName: string);
    procedure removeSyntaxByFileName(const name: string);
    function getSyntaxByFileName(const name: string): PSyntaxInfo;
    function GetCount(): integer;
    procedure SaveSyntaxFiles();
    function GetAllLanguages(): TLangNames;
    function CheckFileForCode(const FilePath: string): string;
    property Syntaxes[const fileName: string]: PSyntaxInfo read getSyntaxByFileName; default;
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
  Self.syntaxPath := SyntaxPath;
  Self.fileExtension := FileExtension;
end;

procedure TSyntaxList.createDefaultSyntaxes();
begin
  if DirectoryExists(Self.syntaxPath) then
      RemoveDir(Self.syntaxPath);

  Self.FillAsDefault();
end;

procedure TSyntaxList.LoadExistingSyntaxFiles();
const
  StrFilePattern = 'syntaxes\\(.+)\.syntax$'; // Regular expression
var
  SyntaxFiles: TStringDynArray;
  FilePattern, FilePath, fileName: string;
  i: integer;
  Syntax: PSyntaxInfo;
begin
  FilePattern := '*' + Self.fileExtension;
  SyntaxFiles := TDirectory.GetFiles(Self.syntaxPath, FilePattern);
  for i := 0 to Length(SyntaxFiles) - 1 do
  begin
    FilePath := SyntaxFiles[i];
    New(Syntax);
    Syntax^ := Self.GetSyntaxInfoFromFile(FilePath);
    fileName := TRegEx.Match(FilePath, StrFilePattern).Groups[1].Value;
    Self.appendSyntax(Syntax, fileName);
  end;
end;

procedure TSyntaxList.appendSyntax(const Syntax: PSyntaxInfo; const fileName: string);
var
  syntaxNode: TSyntaxNode;
begin
  syntaxNode := TSyntaxNode.create(Syntax, self.syntaxPath, fileName, self.fileExtension);

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
  Node := Self.GetNodeByFileName(name);

  if Node <> nil then
    Self.RemoveNode(Node);
end;

function TSyntaxList.getSyntaxByFileName(const name: string): PSyntaxInfo;
var
  Node: TSyntaxNode;
begin
  Node := Self.GetNodeByFileName(name);
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

function TSyntaxList.CheckFileForCode(const FilePath: string): string;
const
  pattern: string = '\.(.+)$'; // Regular expression
var
  FileExtension: string;
  SyntaxNode: TSyntaxNode;
begin
  FileExtension := AnsiLowerCase(TRegEx.Match(filePath, pattern).Groups[1].Value);

  if Length(FileExtension) <> 0 then
  begin
    SyntaxNode := Self.GetNodeByFileExtension(FileExtension);
    if SyntaxNode <> nil then
      Result := SyntaxNode.fileName
    else
      Result := '';
  end
  else
    Result := '';
end;

{ private }

function TSyntaxList.GetSyntaxInfoFromFile(PathToFile: string): TSyntaxInfo;
var
  SyntaxFile: file of TSyntaxInfo;
  SyntaxInfo: TSyntaxInfo;

begin
  AssignFile(SyntaxFile, PathToFile);
  Reset(SyntaxFile);
  Read(SyntaxFile, SyntaxInfo);
  CloseFile(SyntaxFile);


  Result := SyntaxInfo;
end;

function TSyntaxList.GetNodeByFileName(const name: string): TSyntaxNode;
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

function TSyntaxList.GetNodeByFileExtension(const FileExt: string): TSyntaxNode;
var
  CurrNode: TSyntaxNode;
begin
  CurrNode := Self.head;
  while CurrNode <> nil do
  begin
    if CurrNode.syntax.FileExtension = FileExt then
    begin
      Result := CurrNode;
      Exit;
    end;

    CurrNode := CurrNode.next;
  end;

  Result := nil;
end;

procedure TSyntaxList.RemoveNode(var Node: TSyntaxNode);
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

  Dispose(Node.syntax);
  Node.Destroy();

  DeleteFile(Self.syntaxPath + '\' + Node.fileName + Node.fileExtension);
  Dec(Self.FCount);
end;

procedure TSyntaxList.FillAsDefault();
const
  CSharpReserved: TReserved =
                  ('abstract', 'as', 'base', 'bool', 'break', 'byte', 'case',
                   'catch', 'char', 'class', 'const', 'continue', 'default',
                   'delegate', 'do', 'double', 'else', 'enum', 'finally',
                   'fixed', 'float', 'for', 'foreach', 'goto', 'if', 'in',
                   'int', 'interface', 'internal', 'is', 'lock', 'long', 'new',
                   'namespace', 'override', 'private', 'protected', 'public',
                   'return', 'short', 'static', 'struct', 'switch', 'throw',
                   'try', 'using', 'virtual', 'void', 'volatile', 'while');
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
  CLangReserved: TReserved =
                  ('auto', 'break', 'case', 'char', 'const', 'continue',
                   'default', 'do', 'double', 'else', 'enum', 'extern',
                   'float', 'for', 'goto', 'if', 'int', 'long',
                   'register', 'return', 'short', 'signed', 'sizeof', 'static',
                   'struct', 'switch', 'typedef', 'union', 'unsigned', 'void',
                   'volatile', 'while', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
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
  PSyntax: PSyntaxInfo;
begin
  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('cs', CSharpReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'C#');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('cpp', CPlusPlusReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'C++');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('c', CLangReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'C');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('go', GoLangReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'Go');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('java', JavaReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'Java');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('js', JavaScriptReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'JavaScript');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('kt', KotlinReserved, '//', '/*', '*/');
  self.appendSyntax(PSyntax, 'Kotlin');

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('py', PythonReserved, '#', '"""', '"""');
  self.appendSyntax(PSyntax, 'Python');
end;

function TSyntaxList.CreateSyntaxInfo(const fileExt: shortString;
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
