unit uSyntaxEntity;

interface

uses
  SysUtils, IOUtils, Types, RegularExpressions;

const
  DefaultCount = 8;

type
  TReserved = array [1..50] of string[15];
  TMLineComment = array [1..2] of string[3];

  TSyntaxInfo = packed record
    CodeFileExtension: string[5];
    ReservedWords: TReserved;
    SingleLineComment: string[2];
    MultiLineComment: TMLineComment;
  end;

  PSyntaxInfo = ^TSyntaxInfo;
  TDefaultSyntaxes = array [1..DefaultCount] of TSyntaxInfo;

  TLangNames = array of string;

  TSyntaxNode = class
  private
    FSyntaxInfo: PSyntaxInfo;
    FSyntaxPath: string;
    FSyntaxName: string;
    FSyntaxFileExtension: string;
    FNext: TSyntaxNode;
    FPrev: TSyntaxNode;

    constructor Create(const ASyntaxInfo: PSyntaxInfo; const ASyntaxPath,
      ASyntaxName, ASyntaxFileExtension: string);

    procedure UpdateSyntaxFile();
  end;

  TSyntaxList = class
  private
    FSyntaxPath: string;
    FSyntaxFileExtension: string;
    FHead: TSyntaxNode;
    FTail: TSyntaxNode;
    FSyntaxesCount: Integer;

    procedure FillListAsDefault();
    function GetNodeByCodeExtension(const ACodeExtension: string): TSyntaxNode;
    function GetNodeBySyntaxName(const ASyntaxName: string): TSyntaxNode;
    function GetSyntaxByName(const ASyntaxName: string): PSyntaxInfo;
    function GetSyntaxInfoFromFile(const APathToFile: string): TSyntaxInfo;
    procedure RemoveNode(var ASyntaxNode: TSyntaxNode);
  public
    constructor Create(const ASyntaxPath: string);

    procedure AppendSyntax(const ASyntax: PSyntaxInfo; const ASyntaxName: string);
    function CheckFileForCode(const AFilePath: string): string;
    procedure ClearSyntaxList();
    procedure CreateDefaultSyntaxes();
    function CreateSyntaxInfo(const ACodeFileExtension: ShortString;
      const AReservedWords: TReserved; const ASingleLineComment,
      AMultiLineCommentBegin, AMultiLineCommentEnd: ShortString): TSyntaxInfo;
    function GetAllLanguages(): TLangNames;
    function GetSyntaxesCount(): Integer;
    function IsSyntaxExist(const ASyntaxName: string): Boolean;
    procedure LoadExistingSyntaxFiles();
    procedure RemoveSyntaxByName(const ASyntaxName: string);
    procedure SaveSyntaxFiles();

    property Count: integer read GetSyntaxesCount;
    property Syntaxes[const Name: string]: PSyntaxInfo read GetSyntaxByName; default;
  end;

implementation

{ TSyntaxNode }

{ private }

constructor TSyntaxNode.Create;
begin
  Self.FSyntaxInfo := ASyntaxInfo;
  Self.FSyntaxPath := ASyntaxPath;
  Self.FSyntaxName := ASyntaxName;
  Self.FSyntaxFileExtension := ASyntaxFileExtension;
end;

procedure TSyntaxNode.UpdateSyntaxFile;
var
  SyntaxFile: file of TSyntaxInfo;
  FileName: string;	
begin
  if Self.FSyntaxInfo <> nil then
  begin
    if not DirectoryExists(Self.FSyntaxPath) then
      CreateDir(Self.FSyntaxPath);

    FileName := Self.FSyntaxName + Self.FSyntaxFileExtension;

    AssignFile(SyntaxFile, Self.FSyntaxPath + '\' + FileName);
    Rewrite(SyntaxFile);
    Write(SyntaxFile, Self.FSyntaxInfo^);
    CloseFile(SyntaxFile);
  end;
end;

{ TSyntaxList }

{ private }

procedure TSyntaxList.FillListAsDefault;
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
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'C#',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('cpp', CPlusPlusReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'C++',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('c', CLangReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'C',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('go', GoLangReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'Go',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('java', JavaReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'Java',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('js', JavaScriptReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'JavaScript',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('kt', KotlinReserved, '//', '/*', '*/');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'Kotlin',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();

  New(PSyntax);
  PSyntax^ := CreateSyntaxInfo('py', PythonReserved, '#', '"""', '"""');
  TSyntaxNode.Create(PSyntax, Self.FSyntaxPath, 'Python',
    Self.FSyntaxFileExtension).UpdateSyntaxFile();
end;

function TSyntaxList.GetNodeByCodeExtension;
var
  CurrSyntaxNode: TSyntaxNode;
begin
  CurrSyntaxNode := Self.FHead;
  while CurrSyntaxNode <> nil do
  begin
    if CurrSyntaxNode.FSyntaxInfo.CodeFileExtension = ACodeExtension then
    begin
      Result := CurrSyntaxNode;
      Exit;
    end;

    CurrSyntaxNode := CurrSyntaxNode.FNext;
  end;

  Result := nil;
end;

function TSyntaxList.GetNodeBySyntaxName;
var
  CurrSyntaxNode: TSyntaxNode;
begin
  CurrSyntaxNode := Self.FHead;
  while CurrSyntaxNode <> nil do
  begin
    if CurrSyntaxNode.FSyntaxName = ASyntaxName then
    begin
      Result := CurrSyntaxNode;
      Exit;
    end;

    CurrSyntaxNode := CurrSyntaxNode.FNext;
  end;

  Result := nil;
end;

function TSyntaxList.GetSyntaxByName;
var
  SyntaxNode: TSyntaxNode;
begin
  SyntaxNode := Self.GetNodeBySyntaxName(ASyntaxName);
  if SyntaxNode <> nil then
    Result := SyntaxNode.FSyntaxInfo
  else
    Result := nil;
end;

function TSyntaxList.GetSyntaxInfoFromFile;
var
  SyntaxFile: file of TSyntaxInfo;
  SyntaxInfo: TSyntaxInfo;

begin
  AssignFile(SyntaxFile, APathToFile);
  Reset(SyntaxFile);
  Read(SyntaxFile, SyntaxInfo);
  CloseFile(SyntaxFile);

  Result := SyntaxInfo;
end;

procedure TSyntaxList.RemoveNode;
begin
  if (ASyntaxNode <> Self.FHead) and (ASyntaxNode <> Self.FTail) then
  begin
    ASyntaxNode.FPrev.FNext := ASyntaxNode.FNext;
    ASyntaxNode.FNext.FPrev := ASyntaxNode.FPrev;
  end
  else if ASyntaxNode = Self.FHead then
  begin
    Self.FHead := ASyntaxNode.FNext;
    if Self.FHead <> nil then
      Self.FHead.FPrev := nil;
  end
  else if ASyntaxNode = Self.FTail then
  begin
    Self.FTail := ASyntaxNode.FPrev;
    if Self.FTail <> nil then
      Self.FTail.FNext := nil;
  end;

  DeleteFile(Self.FSyntaxPath + '\' + ASyntaxNode.FSyntaxName +
    ASyntaxNode.FSyntaxFileExtension);
  Dispose(ASyntaxNode.FSyntaxInfo);
  ASyntaxNode.Destroy();
  Dec(Self.FSyntaxesCount);
end;

{ public }

constructor TSyntaxList.Create;
const
  FileExtension = '.syntax';
begin
  Self.FSyntaxPath := ASyntaxPath;
  Self.FSyntaxFileExtension := FileExtension;
end;

procedure TSyntaxList.AppendSyntax;
var
  SyntaxNode: TSyntaxNode;
begin
  SyntaxNode := TSyntaxNode.Create(ASyntax, Self.FSyntaxPath, ASyntaxName,
    Self.FSyntaxFileExtension);

  if Self.FHead = nil then
  begin
    Self.FHead := SyntaxNode;
    Self.FTail := SyntaxNode;
  end
  else
  begin
    Self.FTail.FNext := SyntaxNode;
    SyntaxNode.FPrev := Self.FTail;
    Self.FTail := SyntaxNode;
  end;

  SyntaxNode.UpdateSyntaxFile();
  Inc(Self.FSyntaxesCount);
end;

function TSyntaxList.CheckFileForCode;
const
  FilePattern: string = '\.(.+)$'; // Regular expression
var
  FileExtension: string;
  SyntaxNode: TSyntaxNode;
begin
  FileExtension :=
    AnsiLowerCase(TRegEx.Match(AFilePath, FilePattern).Groups[1].Value);

  if Length(FileExtension) <> 0 then
  begin
    SyntaxNode := Self.GetNodeByCodeExtension(FileExtension);
    if SyntaxNode <> nil then
      Result := SyntaxNode.FSyntaxName
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TSyntaxList.ClearSyntaxList;
var
  CurrSyntaxNode: TSyntaxNode;
begin
  CurrSyntaxNode := Self.FHead;
  while CurrSyntaxNode <> nil do
  begin
    Self.FHead := CurrSyntaxNode.FNext;
    Dispose(CurrSyntaxNode.FSyntaxInfo);
    CurrSyntaxNode.Destroy();
    CurrSyntaxNode := Self.FHead;
  end;

  Self.FHead := nil;
  Self.FTail := nil;
  Self.FSyntaxesCount := 0;
end;

procedure TSyntaxList.CreateDefaultSyntaxes;
begin
  Self.FillListAsDefault();
end;

function TSyntaxList.CreateSyntaxInfo;
var
  SyntaxInfo: TSyntaxInfo;
begin
  with SyntaxInfo do
  begin
    CodeFileExtension := ACodeFileExtension;
    ReservedWords := AReservedWords;
    SingleLineComment := ASingleLineComment;
    MultiLineComment[1] := AMultiLineCommentBegin;
    MultiLineComment[2] := AMultiLineCommentEnd;
  end;

  Result := SyntaxInfo;
end;

function TSyntaxList.GetAllLanguages;
var
  CurrSyntaxNode: TSyntaxNode;
  i: integer;
begin
  CurrSyntaxNode := Self.FHead;
  SetLength(Result, Self.FSyntaxesCount);

  if Self.FSyntaxesCount <> 0 then
    for i := 0 to Self.FSyntaxesCount - 1 do
    begin
      Result[i] := CurrSyntaxNode.FSyntaxName;
      CurrSyntaxNode := CurrSyntaxNode.FNext;
    end;
end;

function TSyntaxList.GetSyntaxesCount;
begin
  Result := Self.FSyntaxesCount;
end;

function TSyntaxList.IsSyntaxExist;
var
  SyntaxNode: TSyntaxNode;
begin
  SyntaxNode := Self.GetNodeBySyntaxName(ASyntaxName);
  if SyntaxNode = nil then
    Result := False
  else
    Result := True;
end;

procedure TSyntaxList.LoadExistingSyntaxFiles;
const
  StrFilePattern = 'syntaxes\\(.+)\.syntax$'; // Regular expression
var
  SyntaxFiles: TStringDynArray;
  FilePattern, FilePath, FileName: string;
  i: integer;
  SyntaxInfo: PSyntaxInfo;
begin
  FilePattern := '*' + Self.FSyntaxFileExtension;
  SyntaxFiles := TDirectory.GetFiles(Self.FSyntaxPath, FilePattern);
  for i := 0 to Length(SyntaxFiles) - 1 do
  begin
    FilePath := SyntaxFiles[i];
    New(SyntaxInfo);
    SyntaxInfo^ := Self.GetSyntaxInfoFromFile(FilePath);
    FileName := TRegEx.Match(FilePath, StrFilePattern).Groups[1].Value;
    Self.AppendSyntax(SyntaxInfo, FileName);
  end;
end;

procedure TSyntaxList.RemoveSyntaxByName;
var
  SyntaxNode: TSyntaxNode;
begin
  SyntaxNode := Self.GetNodeBySyntaxName(ASyntaxName);

  if SyntaxNode <> nil then
    Self.RemoveNode(SyntaxNode);
end;

procedure TSyntaxList.SaveSyntaxFiles;
var
  CurrSyntaxNode: TSyntaxNode;
begin
  CurrSyntaxNode := Self.FHead;
  while CurrSyntaxNode <> nil do
  begin
    CurrSyntaxNode.UpdateSyntaxFile();
    CurrSyntaxNode := CurrSyntaxNode.FNext;
  end;
end;

End.
