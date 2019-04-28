Program TextEditor;

Uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm};

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
End.
