Unit Main;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtDlgs, Vcl.ExtCtrls, SyntaxHighlighter, SyntaxFiles;

Type
  TMainForm = class(TForm)
    RichEdit: TRichEdit;
    mMenu: TMainMenu;
    mFile: TMenuItem;
    mNew: TMenuItem;
    mOpen: TMenuItem;
    mSave: TMenuItem;
    mSaveAs: TMenuItem;
    Separator1: TMenuItem;
    mExit: TMenuItem;
    mEdit: TMenuItem;
    mUndo: TMenuItem;
    mRedo: TMenuItem;
    mCut: TMenuItem;
    mCopy: TMenuItem;
    mPaste: TMenuItem;
    mDelete: TMenuItem;
    mSelectAll: TMenuItem;
    Separator2: TMenuItem;
    mInsertIndent: TMenuItem;
    mDeleteIndent: TMenuItem;
    mSearch: TMenuItem;
    mFind: TMenuItem;
    mReplace: TMenuItem;
    mSyntaxes: TMenuItem;
    mSyntaxMenu: TMenuItem;
    Separator3: TMenuItem;
    mAbout: TMenuItem;
    mAboutProgram: TMenuItem;
    aList: TActionList;
    aNewFile: TAction;
    aOpenFile: TAction;
    aSaveFile: TAction;
    aSaveAsFile: TAction;
    aExit: TAction;
    aUndo: TAction;
    aRedo: TAction;
    aCut: TAction;
    aCopy: TAction;
    aPaste: TAction;
    aDelete: TAction;
    aSelectAll: TAction;
    aInsertIndent: TAction;
    aDeleteIndent: TAction;
    aFind: TAction;
    aReplace: TAction;
    aSyntaxMenu: TAction;
    aAboutProgram: TAction;
    fOpenDialog: TOpenTextFileDialog;
    fSaveDialog: TSaveTextFileDialog;
    FindDialog: TFindDialog;
    ReplaceDialog: TReplaceDialog;
    syntaxTimer: TTimer;

    procedure FormCreate(Sender: TObject);

    procedure aNewFileExecute(Sender: TObject);
    procedure aOpenFileExecute(Sender: TObject);
    procedure aSaveFileExecute(Sender: TObject);
    procedure aSaveAsFileExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);

    procedure aUndoExecute(Sender: TObject);
    procedure aRedoExecute(Sender: TObject);
    procedure aCutExecute(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure aPasteExecute(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure aSelectAllExecute(Sender: TObject);
    procedure aInsertIndentExecute(Sender: TObject);
    procedure aDeleteIndentExecute(Sender: TObject);

    procedure aFindExecute(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure aReplaceExecute(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);

    procedure RichEditChange(Sender: TObject);
    procedure onSyntaxTimer(Sender: TObject);

    procedure aCLangExecute(Sender: TObject);
    procedure aCPlusPlusExecute(Sender: TObject);
    procedure aCSharpExecute(Sender: TObject);
    procedure aGoLangExecute(Sender: TObject);
    procedure aJavaExecute(Sender: TObject);
    procedure aJavaScriptExecute(Sender: TObject);
    procedure aKotlinExecute(Sender: TObject);
    procedure aPythonExecute(Sender: TObject);
  private
    syntaxFileName: string;
    ProjectPath: string;
    SyntaxPath: string;
    SyntaxList: TSyntaxList;
  end;

Var
  MainForm: TMainForm;

Implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  SyntaxPath: string;
  Languages: TLangNames;
  i, k: integer;
  MenuItem: TMenuItem;
begin
  SyntaxPath := '\syntaxes';
  Self.ProjectPath := GetCurrentDir;
  Self.SyntaxPath := Self.ProjectPath + SyntaxPath;
  Self.SyntaxList := TSyntaxList.create(Self.SyntaxPath);

  if not DirectoryExists(Self.SyntaxPath) then
    Self.SyntaxList.createDefaultSyntaxes();

  k := Self.SyntaxList.Count;
  Languages := Self.SyntaxList.GetAllLanguages();
  for i := 0 to k - 1 do
  begin
    MenuItem := TMenuItem.Create(Self);
    MenuItem.Caption := Languages[i];
    Self.mSyntaxes.Insert(i + 2, MenuItem);
  end;
end;


Procedure TMainForm.aNewFileExecute(Sender: TObject);
begin
  with RichEdit, fOpenDialog do
  begin
    Clear;
    FileName := '';
  end;
end;

Procedure TMainForm.aOpenFileExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  with fOpenDialog, RichEdit do
    if Execute then
    begin
      Lines.LoadFromFile(FileName);
      syntaxFileName := checkFileForCode(FileName);
      if Length(syntaxFileName) <> 0 then
      begin
        RECopy := TRichEdit.CreateParented(Self.Handle);
        Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
      end;
    end;
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

procedure TMainForm.aDeleteExecute(Sender: TObject);
begin
  with RichEdit do
  begin
    SelLength := 1;
    SelText := '';
  end;
end;

procedure TMainForm.aSelectAllExecute(Sender: TObject);
begin
  RichEdit.SelectAll;
end;

procedure TMainForm.aInsertIndentExecute(Sender: TObject);
var
  sLen: integer;
begin
  with RichEdit do
  begin
    if SelLength <> 0 then
    begin
      sLen := SelLength;
      SelLength := 0;
      SelText := '    ';
      SelLength := sLen;
    end
    else
      SelText := '    ';
  end;
end;

procedure TMainForm.aDeleteIndentExecute(Sender: TObject);
var
  sStart: integer;
  sLen: integer;
begin
  with RichEdit do
  begin
    sStart := SelStart;
    sLen := SelLength;
    SelLength := -4;

    if SelText = '    ' then
      SelText := ''
    else
      SelStart := sStart;

    SelLength := sLen;
  end;
end;


procedure TMainForm.aFindExecute(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TMainForm.FindDialogFind(Sender: TObject);
var
  FoundAt: LongInt;
  startPos, searchLen: Integer;
  searchTypes: TSearchTypes;
begin
  searchTypes := [];
  with RichEdit do
  begin
    if frMatchCase in FindDialog.Options then
       searchTypes := searchTypes + [stMatchCase];
    if frWholeWord in FindDialog.Options then
       searchTypes := searchTypes + [stWholeWord];

    if SelLength <> 0 then
      startPos := SelStart + SelLength
    else
      startPos := 0;

    searchLen := Length(Text) - startPos;
    FoundAt := FindText(FindDialog.FindText, startPos, searchLen, searchTypes);

    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(FindDialog.FindText);
    end
    else
    begin
      SelLength := 0;
      Beep;
    end;
  end;
end;

procedure TMainForm.aReplaceExecute(Sender: TObject);
begin
  ReplaceDialog.Execute;
end;

procedure TMainForm.ReplaceDialogFind(Sender: TObject);
var
  FoundAt: LongInt;
  startPos, searchLen: Integer;
  searchTypes: TSearchTypes;
begin
  searchTypes := [];
  with RichEdit do
  begin
    if frMatchCase in ReplaceDialog.Options then
       searchTypes := searchTypes + [stMatchCase];
    if frWholeWord in ReplaceDialog.Options then
       searchTypes := searchTypes + [stWholeWord];

    if SelLength <> 0 then
      startPos := SelStart + SelLength
    else
      startPos := 0;

    searchLen := Length(Text) - startPos;
    FoundAt := FindText(ReplaceDialog.FindText, startPos, searchLen, searchTypes);

    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(ReplaceDialog.FindText);
    end
    else
    begin
      SelLength := 0;
      Beep;
    end;
  end;
end;

procedure TMainForm.ReplaceDialogReplace(Sender: TObject);
begin
  with RichEdit do
    if Length(SelText) <> 0 then
      SelText := ReplaceDialog.ReplaceText;
end;


procedure TMainForm.RichEditChange(Sender: TObject);
begin
  if syntaxFileName <> '' then
    syntaxTimer.Enabled := true;
end;

procedure TMainForm.onSyntaxTimer(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  if not ((Word(GetAsyncKeyState(VK_SHIFT)) and $8000) <> 0) then
  begin
    RECopy := TRichEdit.CreateParented(Self.Handle);
    syntaxTimer.Enabled := false;
    Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
  end;
end;


procedure TMainForm.aCLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCPlusPlusExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C++.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCSharpExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C#.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aGoLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Go.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Java.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaScriptExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'JS.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aKotlinExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Kotlin.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aPythonExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Python.syntax';
  Highlight(ProjectPath, syntaxFileName, RichEdit, RECopy);
end;

end.

