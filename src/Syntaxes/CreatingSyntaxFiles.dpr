Program CreatingSyntaxFiles;

{$APPTYPE CONSOLE}

Type
  TReservedArray = array [1..50] of String[15];
  TSyntaxInfo = record
    FileExtension: String[5];
    ReservedWords: TReservedArray;
    SingleLineComment: String[2];
    MultiLineComment: array [1..2] of String[6];
  end;

Var
  SyntaxRecord: TSyntaxInfo;
  FileInfo: file of TSyntaxInfo;
  CLangReserved: TReservedArray =
                  ('auto', 'break', 'case', 'char', 'const', 'continue',
                   'default', 'do', 'double', 'else', 'enum', 'extern',
                   'float', 'for', 'goto', 'if', 'int', 'long',
                   'register', 'return', 'short', 'signed', 'sizeof', 'static',
                   'struct', 'switch', 'typedef', 'union', 'unsigned', 'void',
                   'volatile', 'while', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
  CPlusPlusReserved: TReservedArray =
                  ('and', 'and_eq', 'asm', 'bitand', 'bitor', 'bool', 'break',
                   'case', 'catch', 'char', 'class', 'compl', 'const',
                   'continue', 'default', 'do', 'double', 'else', 'enum',
                   'float', 'for', 'goto', 'if', 'int', 'long', 'mutable',
                   'namespace', 'new', 'not', 'not_eq', 'or', 'or_eq',
                   'private', 'protected', 'public', 'return', 'short',
                   'signed', 'static', 'struct', 'switch', 'syncronized',
                   'throw', 'try', 'virtual', 'void', 'volatile', 'while',
                   'xor', 'xor_eq');
  CSharpReserved: TReservedArray =
                  ('abstract', 'as', 'base', 'bool', 'break', 'byte', 'case',
                   'catch', 'char', 'class', 'const', 'continue', 'default',
                   'delegate', 'do', 'double', 'else', 'enum', 'finally',
                   'fixed', 'float', 'for', 'foreach', 'goto', 'if', 'in',
                   'int', 'interface', 'internal', 'is', 'lock', 'long', 'new',
                   'namespace', 'override', 'private', 'protected', 'public',
                   'return', 'short', 'static', 'struct', 'switch', 'throw',
                   'try', 'using', 'virtual', 'void', 'volatile', 'while');
  GoLangReserved: TReservedArray =
                  ('break', 'case', 'chan', 'const', 'continue', 'default',
                   'defer', 'else', 'fallthrough', 'for', 'func', 'go', 'goto',
                   'if', 'import', 'interface', 'map', 'package', 'range',
                   'return', 'select', 'struct', 'switch', 'type', 'var', '',
                   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '');
  JavaReserved: TReservedArray =
                  ('abstract', 'assert', 'boolean', 'break', 'byte', 'case',
                   'catch', 'char', 'class', 'const', 'continue', 'default',
                   'do', 'double', 'else', 'enum', 'extends', 'final',
                   'finally', 'float', 'for', 'goto', 'if', 'implements',
                   'import', 'instanceof', 'int', 'interface', 'long', 'native',
                   'new', 'package', 'private', 'protected', 'public', 'return',
                   'short', 'static', 'strictfp', 'super', 'switch',
                   'synchronized', 'this', 'throw', 'throws', 'transient',
                   'try', 'void', 'volatile', 'while');
  JavaScriptReserved: TReservedArray =
                  ('await', 'break', 'case', 'catch', 'class', 'const',
                   'continue', 'debugger', 'default', 'delete', 'do', 'else',
                   'export', 'extends', 'finally', 'for', 'function', 'if',
                   'import', 'in', 'instanceof', 'new', 'return', 'super',
                   'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void',
                   'while', 'with', 'yield', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '');
  PythonReserved: TReservedArray =
                  ('and', 'as', 'assert', 'async', 'await', 'break', 'class',
                   'continue', 'def', 'del', 'elif', 'else', 'except', 'False',
                   'finally', 'for', 'from', 'global', 'if', 'import', 'in',
                   'is', 'lambda', 'None', 'nonlocal', 'not', 'or', 'pass',
                   'raise', 'return', 'True', 'try', 'while', 'with', 'yield',
                   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
  RubyReserved: TReservedArray =
                  ('BEGIN', 'END', '__ENCODING__', '__END__', '__FILE__',
                   '__LINE__', 'alias', 'and', 'begin', 'break', 'case',
                   'class', 'def', 'defined HUY', 'do', 'else', 'elsif', 'end',
                   'ensure', 'false', 'for', 'if', 'in', 'module', 'next',
                   'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return',
                   'self', 'super', 'then', 'true', 'undef', 'unless',
                   'until', 'when', 'while', 'yield', '', '', '', '', '', '',
                   '', '');

Begin
  Assign(FileInfo, 'syntaxes/C.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'c';
    ReservedWords := CLangReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/C++.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'cpp';
    ReservedWords := CPlusPlusReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/C#.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'cs';
    ReservedWords := CSharpReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/Go.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'go';
    ReservedWords := GoLangReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/Java.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'java';
    ReservedWords := JavaReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/JS.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'js';
    ReservedWords := JavaScriptReserved;
    SingleLineComment := '//';
    MultiLineComment[1] := '/*';
    MultiLineComment[2] := '*/';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/Python.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'py';
    ReservedWords := PythonReserved;
    SingleLineComment := '#';
    MultiLineComment[1] := '"""';
    MultiLineComment[2] := '"""';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);

  Assign(FileInfo, 'syntaxes/Ruby.syntax');
  Rewrite(FileInfo);
  with SyntaxRecord do
  begin
    FileExtension := 'rb';
    ReservedWords := RubyReserved;
    SingleLineComment := '#';
    MultiLineComment[1] := '=begin';
    MultiLineComment[2] := '=end';
  end;
  Write(FileInfo, SyntaxRecord);
  Close(FileInfo);
End.
