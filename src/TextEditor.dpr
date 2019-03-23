Program TextEditor;

Uses
  Vcl.Forms,
  System.SysUtils,
  Main in 'Main.pas' {MainForm};

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
End.
