unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
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
    aRuby: TAction;
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
    procedure aExitExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.aExitExecute(Sender: TObject);
begin
  Self.Close;
end;

end.
