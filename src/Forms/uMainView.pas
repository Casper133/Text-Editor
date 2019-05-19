unit uMainView;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.StdCtrls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ActnList, Vcl.Menus, Vcl.ComCtrls, Vcl.ExtDlgs, Vcl.ExtCtrls,
  Vcl.ToolWin, Vcl.ImgList, Classes, Actions, ImageList, SysUtils,
  uSyntaxEntity, uSyntaxHighlighter, uSyntaxEditorView;

type
  TFmMain = class(TForm)
    RichEdit: TRichEdit;
    mMenu: TMainMenu;
    miFile: TMenuItem;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miSeparator1: TMenuItem;
    miExit: TMenuItem;
    mEdit: TMenuItem;
    miUndo: TMenuItem;
    miRedo: TMenuItem;
    miCut: TMenuItem;
    miCopy: TMenuItem;
    miPaste: TMenuItem;
    miDelete: TMenuItem;
    miSelectAll: TMenuItem;
    miSeparator2: TMenuItem;
    miInsertIndent: TMenuItem;
    miDeleteIndent: TMenuItem;
    mSearch: TMenuItem;
    miFind: TMenuItem;
    miReplace: TMenuItem;
    mSyntaxes: TMenuItem;
    miSyntaxMenu: TMenuItem;
    miSeparator3: TMenuItem;
    miAbout: TMenuItem;
    miAboutProgram: TMenuItem;
    aList: TActionList;
    actNewFile: TAction;
    actOpenFile: TAction;
    actSaveFile: TAction;
    actSaveAsFile: TAction;
    actExit: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actDelete: TAction;
    actSelectAll: TAction;
    actInsertIndent: TAction;
    actDeleteIndent: TAction;
    actFind: TAction;
    actReplace: TAction;
    actSyntaxMenu: TAction;
    actAboutProgram: TAction;
    tbMain: TToolBar;
    tbNew: TToolButton;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    tbSaveAs: TToolButton;
    tbUndo: TToolButton;
    tbRedo: TToolButton;
    tbCut: TToolButton;
    tbCopy: TToolButton;
    tbPaste: TToolButton;
    tbFind: TToolButton;
    tbSeparator1: TToolButton;
    tbSeparator2: TToolButton;
    dlgOpen: TOpenTextFileDialog;
    dlgSave: TSaveTextFileDialog;
    dlgFind: TFindDialog;
    dlgReplace: TReplaceDialog;
    tmSyntax: TTimer;
    IconsList: TImageList;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure actNewFileExecute(Sender: TObject);
    procedure actOpenFileExecute(Sender: TObject);
    procedure actSaveFileExecute(Sender: TObject);
    procedure actSaveAsFileExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);

    procedure actUndoExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actInsertIndentExecute(Sender: TObject);
    procedure actDeleteIndentExecute(Sender: TObject);

    procedure actFindExecute(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure dlgReplaceFind(Sender: TObject);
    procedure dlgReplaceReplace(Sender: TObject);

    procedure actSyntaxMenuExecute(Sender: TObject);
    procedure onSyntaxClick(Sender: TObject);

    procedure RichEditChange(Sender: TObject);
    procedure onSyntaxTimer(Sender: TObject);
  private
    SyntaxName: string;
    SyntaxPath: string;
    SyntaxList: TSyntaxList;
    FmSyntaxEditor: TFmSyntaxEditor;
  end;

var
  FmMain: TFmMain;

implementation

{$R *.dfm}

procedure TFmMain.FormCreate(Sender: TObject);
var
  SyntaxDir: string;
  Languages: TLangNames;
  i: integer;
  MenuItem: TMenuItem;
begin
  SyntaxDir := '\syntaxes';
  Self.SyntaxPath := GetCurrentDir + SyntaxDir;
  Self.SyntaxList := TSyntaxList.Create(Self.SyntaxPath);

  if not DirectoryExists(Self.SyntaxPath) then
    Self.SyntaxList.CreateDefaultSyntaxes();

  Self.SyntaxList.LoadExistingSyntaxFiles();

  Languages := Self.SyntaxList.GetAllLanguages();
  for i := 0 to Self.SyntaxList.Count - 1 do
  begin
    MenuItem := TMenuItem.Create(Self);
    MenuItem.Caption := Languages[i];
    MenuItem.OnClick := Self.onSyntaxClick;
    Self.mSyntaxes.Insert(i + 2, MenuItem);
  end;
end;

procedure TFmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.SyntaxList.SaveSyntaxFiles();
end;


procedure TFmMain.actNewFileExecute(Sender: TObject);
begin
  with Self.RichEdit, Self.dlgOpen do
  begin
    Clear;
    FileName := '';
  end;
end;

procedure TFmMain.actOpenFileExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  with Self.dlgOpen, Self.RichEdit do
    if Execute then
    begin
      Lines.LoadFromFile(FileName);
      Self.SyntaxName := Self.SyntaxList.CheckFileForCode(FileName);
      if Length(SyntaxName) <> 0 then
      begin
        RECopy := TRichEdit.CreateParented(Self.Handle);
        Highlight(Self.SyntaxList, Self.SyntaxName, Self.RichEdit, RECopy);
      end;
    end;
end;

procedure TFmMain.actSaveFileExecute(Sender: TObject);
begin
  if Length(dlgOpen.FileName) <> 0 then
  begin
    Self.RichEdit.PlainText := True;
    Self.RichEdit.Lines.SaveToFile(Self.dlgOpen.FileName);
  end
  else
  begin
    with Self.dlgSave, Self.RichEdit do
      if Execute then
      begin
        PlainText := True;
        Lines.SaveToFile(FileName);
        Self.dlgOpen.FileName := FileName;
      end;
  end;
end;

procedure TFmMain.actSaveAsFileExecute(Sender: TObject);
begin
  with Self.dlgSave, Self.RichEdit do
    if Execute then
    begin
      PlainText := True;
      Lines.SaveToFile(FileName);
      Self.dlgOpen.FileName := FileName;
    end;
end;

procedure TFmMain.actExitExecute(Sender: TObject);
begin
  Self.Close;
end;


procedure TFmMain.actUndoExecute(Sender: TObject);
begin
  Self.RichEdit.Undo;
end;

procedure TFmMain.actRedoExecute(Sender: TObject);
const
  WM_REDO = WM_USER + 84;
begin
  SendMessage(Self.RichEdit.Handle, WM_REDO, 0, 0);
end;

procedure TFmMain.actCutExecute(Sender: TObject);
begin
  Self.RichEdit.CutToClipboard;
end;

procedure TFmMain.actCopyExecute(Sender: TObject);
begin
  Self.RichEdit.CopyToClipboard;
end;

procedure TFmMain.actPasteExecute(Sender: TObject);
begin
  Self.RichEdit.PasteFromClipboard;
end;

procedure TFmMain.actDeleteExecute(Sender: TObject);
begin
  with Self.RichEdit do
  begin
    SelLength := 1;
    SelText := '';
  end;
end;

procedure TFmMain.actSelectAllExecute(Sender: TObject);
begin
  Self.RichEdit.SelectAll;
end;

procedure TFmMain.actInsertIndentExecute(Sender: TObject);
var
  SavedSelLen: integer;
begin
  with Self.RichEdit do
  begin
    if SelLength <> 0 then
    begin
      SavedSelLen := SelLength;
      SelLength := 0;
      SelText := '    ';
      SelLength := SavedSelLen;
    end
    else
      SelText := '    ';
  end;
end;

procedure TFmMain.actDeleteIndentExecute(Sender: TObject);
var
  SavedSelStart: integer;
  SavedSelLen: integer;
begin
  with Self.RichEdit do
  begin
    SavedSelStart := SelStart;
    SavedSelLen := SelLength;
    SelLength := -4;

    if SelText = '    ' then
      SelText := ''
    else
      SelStart := SavedSelStart;

    SelLength := SavedSelLen;
  end;
end;


procedure TFmMain.actFindExecute(Sender: TObject);
begin
  Self.dlgFind.Execute;
end;

procedure TFmMain.dlgFindFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, SearchLen: Integer;
  SearchTypes: TSearchTypes;
begin
  SearchTypes := [];
  with Self.RichEdit do
  begin
    if frMatchCase in Self.dlgFind.Options then
       SearchTypes := SearchTypes + [stMatchCase];
    if frWholeWord in Self.dlgFind.Options then
       SearchTypes := SearchTypes + [stWholeWord];

    if SelLength <> 0 then
      StartPos := SelStart + SelLength
    else
      StartPos := 0;

    SearchLen := Length(Text) - StartPos;
    FoundAt :=
      FindText(Self.dlgFind.FindText, StartPos, SearchLen, SearchTypes);

    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(Self.dlgFind.FindText);
    end
    else
    begin
      SelLength := 0;
      Beep;
    end;
  end;
end;

procedure TFmMain.actReplaceExecute(Sender: TObject);
begin
  Self.dlgReplace.Execute;
end;

procedure TFmMain.dlgReplaceFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, SearchLen: Integer;
  SearchTypes: TSearchTypes;
begin
  SearchTypes := [];
  with Self.RichEdit do
  begin
    if frMatchCase in Self.dlgReplace.Options then
       SearchTypes := SearchTypes + [stMatchCase];
    if frWholeWord in Self.dlgReplace.Options then
       SearchTypes := SearchTypes + [stWholeWord];

    if SelLength <> 0 then
      StartPos := SelStart + SelLength
    else
      StartPos := 0;

    SearchLen := Length(Text) - StartPos;
    FoundAt :=
      FindText(Self.dlgReplace.FindText, StartPos, SearchLen, SearchTypes);

    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(Self.dlgReplace.FindText);
    end
    else
    begin
      SelLength := 0;
      Beep;
    end;
  end;
end;

procedure TFmMain.dlgReplaceReplace(Sender: TObject);
begin
  with Self.RichEdit do
    if Length(SelText) <> 0 then
      SelText := Self.dlgReplace.ReplaceText;
end;


procedure TFmMain.actSyntaxMenuExecute(Sender: TObject);
begin
  if not Assigned(Self.FmSyntaxEditor) then
  begin
    Self.FmSyntaxEditor := TFmSyntaxEditor.Create(Self);
    Self.FmSyntaxEditor.SyntaxList := Self.SyntaxList;
    Self.FmSyntaxEditor.SyntaxTab := Self.mSyntaxes;
  end;

  Self.FmSyntaxEditor.ShowModal;
end;

procedure TFmMain.onSyntaxClick(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  Self.SyntaxName := TMenuItem(Sender).Caption;
  Delete(Self.SyntaxName, 1, 1);
  Highlight(Self.SyntaxList, Self.SyntaxName, Self.RichEdit, RECopy);
end;


procedure TFmMain.RichEditChange(Sender: TObject);
begin
  if Self.SyntaxName <> '' then
    Self.tmSyntax.Enabled := true;
end;

procedure TFmMain.onSyntaxTimer(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  if not ((Word(GetAsyncKeyState(VK_SHIFT)) and $8000) <> 0) then
  begin
    RECopy := TRichEdit.CreateParented(Self.Handle);
    Self.tmSyntax.Enabled := false;
    Highlight(Self.SyntaxList, Self.SyntaxName, Self.RichEdit, RECopy);
  end;
end;

end.

