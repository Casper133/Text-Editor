Unit Main;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtDlgs;

Type
  TMainForm = class(TForm)
    aList: TActionList;
    aNewFile: TAction;
    aUndo: TAction;
    aOpenFile: TAction;
    aSaveFile: TAction;
    aSaveAsFile: TAction;
    aExit: TAction;
    aRedo: TAction;
    aCut: TAction;
    aCopy: TAction;
    aPaste: TAction;
    aDelete: TAction;
    aSelectAll: TAction;
    aInsertIndent: TAction;
    aDeleteIndent: TAction;
    mMenu: TMainMenu;
    mFile: TMenuItem;
    mEdit: TMenuItem;
    mNew: TMenuItem;
    mOpen: TMenuItem;
    mSave: TMenuItem;
    mSaveAs: TMenuItem;
    N5: TMenuItem;
    mExit: TMenuItem;
    mUndo: TMenuItem;
    mRedo: TMenuItem;
    mCut: TMenuItem;
    mCopy: TMenuItem;
    mPaste: TMenuItem;
    mDelete: TMenuItem;
    mSelectAll: TMenuItem;
    mInsertIndent: TMenuItem;
    mDeleteIndent: TMenuItem;
    N8: TMenuItem;
    aFind: TAction;
    aReplace: TAction;
    mSearch: TMenuItem;
    mFind: TMenuItem;
    mReplace: TMenuItem;
    mSyntaxes: TMenuItem;
    aCLang: TAction;
    aCSharp: TAction;
    aCPlusPlus: TAction;
    aGoLang: TAction;
    aJava: TAction;
    aJavaScript: TAction;
    aPython: TAction;
    aKotlin: TAction;
    mCLang: TMenuItem;
    mCSharp: TMenuItem;
    mCPlusPlus: TMenuItem;
    mGoLang: TMenuItem;
    mJava: TMenuItem;
    mJavaScript: TMenuItem;
    mPython: TMenuItem;
    mRuby: TMenuItem;
    mAbout: TMenuItem;
    aAboutProgram: TAction;
    mAboutProgram: TMenuItem;
    RichEdit: TRichEdit;
    fOpenDialog: TOpenTextFileDialog;
    fSaveDialog: TSaveTextFileDialog;
    procedure aExitExecute(Sender: TObject);
    procedure aOpenFileExecute(Sender: TObject);
    procedure aSaveAsFileExecute(Sender: TObject);
    procedure aSaveFileExecute(Sender: TObject);
    procedure aNewFileExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Var
  MainForm: TMainForm;

Implementation

{$R *.dfm}

Procedure TMainForm.aNewFileExecute(Sender: TObject);
begin
  with RichEdit, fOpenDialog do
  begin
    Clear;
    FileName := '';
  end;
end;

Procedure TMainForm.aOpenFileExecute(Sender: TObject);
begin
  with fOpenDialog, RichEdit do
    if Execute then
      Lines.LoadFromFile(FileName);
end;

Procedure TMainForm.aSaveFileExecute(Sender: TObject);
begin
  if Length(fOpenDialog.FileName) <> 0 then
  begin
    RichEdit.PlainText := True;
    RichEdit.Lines.SaveToFile(fOpenDialog.FileName);
  end
  else
  begin
    with fSaveDialog, RichEdit do
      if Execute then
      begin
        PlainText := True;
        Lines.SaveToFile(FileName);
        fOpenDialog.FileName := FileName;
      end;
  end;
end;

Procedure TMainForm.aSaveAsFileExecute(Sender: TObject);
begin
  with fSaveDialog, RichEdit do
    if Execute then
    begin
      PlainText := True;
      Lines.SaveToFile(FileName);
      fOpenDialog.FileName := FileName;
    end;
end;

Procedure TMainForm.aExitExecute(Sender: TObject);
begin
  Self.Close;
end;

end.
