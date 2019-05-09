Unit Main;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtDlgs, SyntaxHighlighter, Vcl.ExtCtrls;

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
    mKotlin: TMenuItem;
    mAbout: TMenuItem;
    aAboutProgram: TAction;
    mAboutProgram: TMenuItem;
    fOpenDialog: TOpenTextFileDialog;
    fSaveDialog: TSaveTextFileDialog;
    RichEdit: TRichEdit;
    syntaxTimer: TTimer;
    procedure aExitExecute(Sender: TObject);
    procedure aOpenFileExecute(Sender: TObject);
    procedure aSaveAsFileExecute(Sender: TObject);
    procedure aSaveFileExecute(Sender: TObject);
    procedure aNewFileExecute(Sender: TObject);
    procedure aUndoExecute(Sender: TObject);
    procedure aCutExecute(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure aPasteExecute(Sender: TObject);
    procedure aRedoExecute(Sender: TObject);
    procedure aSelectAllExecute(Sender: TObject);
    procedure aPythonExecute(Sender: TObject);
    procedure aJavaExecute(Sender: TObject);
    procedure onSyntaxTimer(Sender: TObject);
    procedure RichEditChange(Sender: TObject);
    procedure aCLangExecute(Sender: TObject);
    procedure aCSharpExecute(Sender: TObject);
    procedure aCPlusPlusExecute(Sender: TObject);
    procedure aGoLangExecute(Sender: TObject);
    procedure aJavaScriptExecute(Sender: TObject);
    procedure aKotlinExecute(Sender: TObject);
  private
    syntaxFileName: String;
  public
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


procedure TMainForm.aUndoExecute(Sender: TObject);
begin
  RichEdit.Undo;
end;

procedure TMainForm.aRedoExecute(Sender: TObject);
const
  WM_REDO = WM_USER + 84;
begin
  SendMessage(RichEdit.Handle, WM_REDO, 0, 0);
end;

procedure TMainForm.aCutExecute(Sender: TObject);
begin
  RichEdit.CutToClipboard;
end;

procedure TMainForm.aCopyExecute(Sender: TObject);
begin
  RichEdit.CopyToClipboard;
end;

procedure TMainForm.aPasteExecute(Sender: TObject);
begin
  RichEdit.PasteFromClipboard;
end;

procedure TMainForm.aSelectAllExecute(Sender: TObject);
begin
  RichEdit.SelectAll;
end;


procedure TMainForm.RichEditChange(Sender: TObject);
begin
  if syntaxFileName <> '' then
  begin
    syntaxTimer.Enabled := false;
    syntaxTimer.Enabled := true;
  end;
end;

procedure TMainForm.onSyntaxTimer(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  if not ((Word(GetAsyncKeyState(VK_SHIFT)) and $8000) <> 0) then
  begin
    RECopy := TRichEdit.CreateParented(Self.Handle);
    syntaxTimer.Enabled := false;
    Highlight(syntaxFileName, RichEdit, RECopy);
  end;
end;


procedure TMainForm.aCLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCPlusPlusExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C++.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCSharpExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C#.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aGoLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Go.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Java.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaScriptExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'JS.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aKotlinExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Kotlin.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aPythonExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Python.syntax';
  Highlight(syntaxFileName, RichEdit, RECopy);
end;

end.
