Unit SyntaxFilesGenerator;

Interface

Uses
  SysUtils, Winapi.Windows;

Type
  TReserved = array [1..50] of string[15];
  TMLineComment = array [1..2] of string[3];

  TSyntaxInfo = record
    FileExtension: string[5];
    ReservedWords: TReserved;
    SingleLineComment: string[2];
    MultiLineComment: TMLineComment;
  end;

Procedure createFiles;
Procedure runSyntaxFilesGenerator;

Implementation

Procedure createSyntaxFile(fileName: string; fileExt: shortString;
                           rWords: TReserved; sLineComment: shortString;
                           mLineCommentBegin, mLineCommentEnd: shortString);
var
  syntaxInfo: TSyntaxInfo;
  syntaxFile: file of TSyntaxInfo;

begin
  AssignFile(syntaxFile, 'syntaxes/' + fileName);
  Rewrite(syntaxFile);
  with syntaxInfo do
  begin
    FileExtension := fileExt;
    ReservedWords := RWords;
    SingleLineComment := sLineComment;
    MultiLineComment[1] := mLineCommentBegin;
    MultiLineComment[2] := mLineCommentEnd;
  end;
  Write(syntaxFile, syntaxInfo);
  CloseFile(syntaxFile);
end;


Procedure createFiles;
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
  createSyntaxFile('C.syntax', 'c', CLangReserved, '//', '/*', '*/');
  createSyntaxFile('C++.syntax', 'cpp', CPlusPlusReserved, '//', '/*', '*/');
  createSyntaxFile('C#.syntax', 'cs', CSharpReserved, '//', '/*', '*/');
  createSyntaxFile('Go.syntax', 'go', GoLangReserved, '//', '/*', '*/');
  createSyntaxFile('Java.syntax', 'java', JavaReserved, '//', '/*', '*/');
  createSyntaxFile('JS.syntax', 'js', JavaScriptReserved, '//', '/*', '*/');
  createSyntaxFile('Kotlin.syntax', 'kt', KotlinReserved, '//', '/*', '*/');
  createSyntaxFile('Python.syntax', 'py', PythonReserved, '#', '"""', '"""');
end;


Procedure runSyntaxFilesGenerator;
begin
  if not DirectoryExists('syntaxes') then
    CreateDir('syntaxes');

  if not FileExists('syntaxes/C.syntax') then
    createFiles
end;

End.

