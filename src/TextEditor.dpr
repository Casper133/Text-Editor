Program TextEditor;

uses
  Vcl.Forms,
  Main in 'Units\Main.pas' {MainForm},
  SyntaxHighlighter in 'Units\SyntaxHighlighter.pas',
  SyntaxFiles in 'Units\SyntaxFiles.pas';

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
End.

