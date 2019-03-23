unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    N1: TMenuItem;
    Open: TMenuItem;
    Save: TMenuItem;
    SaveAs: TMenuItem;
    Exit: TMenuItem;
    Edit: TMenuItem;
    Undo: TMenuItem;
    Cut: TMenuItem;
    Copy: TMenuItem;
    Insert: TMenuItem;
    SelectAll: TMenuItem;
    Indents: TMenuItem;
    DeleteLine: TMenuItem;
    InsertIndent: TMenuItem;
    DeleteIndent: TMenuItem;
    Search: TMenuItem;
    Find: TMenuItem;
    Replacement: TMenuItem;
    N19: TMenuItem;
    Syntaxes: TMenuItem;
    AboutProgram: TMenuItem;
    UTF8: TMenuItem;
    UTF8BOM: TMenuItem;
    ISO8859: TMenuItem;
    UTF16: TMenuItem;
    C: TMenuItem;
    CPlusPlus: TMenuItem;
    CSharp: TMenuItem;
    Java: TMenuItem;
    Python: TMenuItem;
    JavaScript: TMenuItem;
    Ruby: TMenuItem;
    PHP: TMenuItem;
    Delphi: TMenuItem;
    FASM: TMenuItem;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    RichEdit: TRichEdit;
    OpenFileDialog: TOpenDialog;
    SaveFileDialog: TSaveDialog;
    FindTextDialog: TFindDialog;
    ReplaceTextDialog: TReplaceDialog;
    procedure OpenClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ExitClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.OpenClick(Sender: TObject);
begin
  if OpenFileDialog.Execute then
    RichEdit.Lines.LoadFromFile(OpenFileDialog.FileName);
end;

procedure TMainForm.SaveAsClick(Sender: TObject);
begin
  if SaveFileDialog.Execute then
    RichEdit.Lines.SaveToFile(OpenFileDialog.FileName);
end;

end.
