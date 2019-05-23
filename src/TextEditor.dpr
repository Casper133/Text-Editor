Program TextEditor;

uses
  Vcl.Forms,
  uMainView in 'Forms\uMainView.pas' {FmMain},
  uSyntaxEditorView in 'Forms\uSyntaxEditorView.pas' {FmSyntaxEditor},
  uNewSyntaxView in 'Forms\uNewSyntaxView.pas' {FmNewSyntax},
  uSyntaxHighlighter in 'Units\uSyntaxHighlighter.pas'
    {/uSyntaxFiles in 'Units\uSyntaxFiles.pas';},
  uSyntaxEntity in 'Units\uSyntaxEntity.pas';

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Text Editor';
  Application.CreateForm(TFmMain, FmMain);
  Application.CreateForm(TFmSyntaxEditor, FmSyntaxEditor);
  Application.CreateForm(TFmNewSyntax, FmNewSyntax);
  Application.Run;
End.

