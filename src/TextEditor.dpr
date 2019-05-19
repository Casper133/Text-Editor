Program TextEditor;

uses
  Vcl.Forms,
  Main in 'Units\Main.pas' {MainForm},
  SyntaxHighlighter in 'Units\SyntaxHighlighter.pas',
  SyntaxFiles in 'Units\SyntaxFiles.pas',
  SyntaxEditor in 'Units\SyntaxEditor.pas' {FmSyntaxEditor},
  NewSyntaxView in 'Units\NewSyntaxView.pas' {FmNewSyntax};

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Text Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFmSyntaxEditor, FmSyntaxEditor);
  Application.CreateForm(TFmNewSyntax, FmNewSyntax);
  Application.Run;
End.

