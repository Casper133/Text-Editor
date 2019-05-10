{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
Unit Main;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtDlgs, Vcl.ExtCtrls, SyntaxHighlighter;

Type
  TTreeRichEdit = class(TRichEdit)
    private
      Text: String;
  end;

  TMainForm = class(TForm)
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
    mSearch: TMenuItem;
    mFind: TMenuItem;
    mReplace: TMenuItem;
    mSyntaxes: TMenuItem;
    mCLang: TMenuItem;
    mCSharp: TMenuItem;
    mCPlusPlus: TMenuItem;
    mGoLang: TMenuItem;
    mJava: TMenuItem;
    mJavaScript: TMenuItem;
    mPython: TMenuItem;
    mKotlin: TMenuItem;
    mAbout: TMenuItem;
    mAboutProgram: TMenuItem;
    fOpenDialog: TOpenTextFileDialog;
    fSaveDialog: TSaveTextFileDialog;
    RichEdit: TRichEdit;
    syntaxTimer: TTimer;
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
    aFind: TAction;
    aReplace: TAction;
    aCLang: TAction;
    aCSharp: TAction;
    aCPlusPlus: TAction;
    aGoLang: TAction;
    aJava: TAction;
    aJavaScript: TAction;
    aKotlin: TAction;
    aPython: TAction;
    aAboutProgram: TAction;
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
    projectDir: string;
  public
  end;

Var
  MainForm: TMainForm;

Implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  projectDir := GetCurrentDir;
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
        Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
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
    Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
  end;
end;


procedure TMainForm.aCLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCPlusPlusExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C++.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aCSharpExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'C#.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aGoLangExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Go.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Java.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aJavaScriptExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'JS.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aKotlinExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Kotlin.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

procedure TMainForm.aPythonExecute(Sender: TObject);
var
  RECopy: TRichEdit;
begin
  RECopy := TRichEdit.CreateParented(Self.Handle);
  syntaxFileName := 'Python.syntax';
  Highlight(projectDir, syntaxFileName, RichEdit, RECopy);
end;

end.

