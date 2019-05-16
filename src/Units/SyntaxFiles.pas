Unit SyntaxFiles;

Interface

Uses
  SysUtils;

Const
  SCount = 8;

Type
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
    procedure createSyntaxFile(const projectPath: string; fileName: string);
  end;

  TSyntaxList = class
  private
    projectPath: string;
    head: TSyntaxNode;
    tail: TSyntaxNode;
    count: integer;
    function getNodeByFileName(const name: string): TSyntaxNode;
    procedure removeNode(const syntax: TSyntaxNode);
    procedure fillAsDefault();
  public
    constructor create(const projectPath: string);
    procedure createDefaultSyntaxes();
    procedure appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
    procedure removeItemByFileName(const name: string);
    function getSyntaxByFileName(const name: string): PSyntaxInfo;
    property syntaxes[const fileName: string]: PSyntaxInfo read getSyntaxByFileName;
  end;

Implementation

{ TSyntaxNode }

Constructor TSyntaxNode.create(const syntax: PSyntaxInfo; const fileName: string);
Const
  SyntaxExtension = '.syntax';
begin
  self.syntax := syntax;
  self.fileName := fileName;
  self.fileExtension := SyntaxExtension;
end;

Procedure TSyntaxNode.createSyntaxFile(const projectPath: string; fileName: string);
var
  syntaxFile: file of TSyntaxInfo;
begin
  if self.syntax <> nil then
  begin
    if not DirectoryExists(projectPath + '\syntaxes') then
      CreateDir(projectPath + 'syntaxes');

    fileName := fileName + self.fileExtension;

    if not FileExists(projectPath + '\syntaxes\' + fileName) then
    begin
      AssignFile(syntaxFile, projectPath + '\syntaxes\' + fileName);
      Rewrite(syntaxFile);
      Write(syntaxFile, self.syntax^);
      CloseFile(syntaxFile);
    end;
  end;
end;


{ TSyntaxList }

{ public }

Constructor TSyntaxList.create(const projectPath: string);
begin
  self.projectPath := projectPath;
end;

Procedure TSyntaxList.createDefaultSyntaxes;
begin
  self.fillAsDefault;
end;

Procedure TSyntaxList.appendSyntax(const syntax: PSyntaxInfo; const fileName: string);
begin

end;

Procedure TSyntaxList.removeItemByFileName(const name: string);
begin

end;

Function TSyntaxList.getSyntaxByFileName(const name: string): PSyntaxInfo;
begin

end;

{ private }

Function TSyntaxList.getNodeByFileName(const name: string): TSyntaxNode;
begin

end;

Procedure TSyntaxList.removeNode(const syntax: TSyntaxNode);
begin

end;

Procedure TSyntaxList.fillAsDefault;
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
begin

end;

End.
