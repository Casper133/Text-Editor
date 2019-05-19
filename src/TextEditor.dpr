Program TextEditor;

uses
  Vcl.Forms,
  Main in 'Forms\Main.pas' {MainForm},
  uSyntaxEditorView in 'Forms\uSyntaxEditorView.pas' {FmSyntaxEditor},
  uNewSyntaxView in 'Forms\uNewSyntaxView.pas' {FmNewSyntax},
  uSyntaxHighlighter in 'Units\uSyntaxHighlighter.pas' {/uSyntaxFiles in 'Units\uSyntaxFiles.pas';},
  uSyntaxEntity in 'Units\uSyntaxEntity.pas';

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

