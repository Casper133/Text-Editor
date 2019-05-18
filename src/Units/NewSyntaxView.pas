unit NewSyntaxView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, SyntaxFiles;

type
  TFmNewSyntax = class(TForm)
    lblName: TLabel;
    edtName: TEdit;
    btnAdd: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    FCbbSyntax: TComboBox;
    procedure SetCbbSyntax(cbbSyntax: TComboBox);
  public
    property cbbSyntax: TComboBox write SetCbbSyntax;
  end;

var
  FmNewSyntax: TFmNewSyntax;

implementation

{$R *.dfm}

{ public/protected }

procedure TFmNewSyntax.btnAddClick(Sender: TObject);
var
  SyntaxName: string;
  cbbItems: TStrings;
  ItemsCount: integer;
  IsNameExist: boolean;
  i: Integer;
begin
  IsNameExist := False;
  SyntaxName := Self.edtName.Text;
  SyntaxName := Trim(SyntaxName);

  if SyntaxName <> '' then
  begin
    cbbItems := Self.FCbbSyntax.Items;
    ItemsCount := cbbItems.Count;
    for i := 1 to ItemsCount do
      if SyntaxName = cbbItems[i] then
        IsNameExist := True;
    if not IsNameExist then
    begin
      Self.FCbbSyntax.Items.Append(SyntaxName);
      ShowMessage('Синтаксис добавлен!');
      Self.Close;
    end
    else
      ShowMessage('Такой синтаксис уже существует. Попробуйте другое имя');
  end
  else
    ShowMessage('Имя не может быть пустым');
end;

procedure TFmNewSyntax.btnCancelClick(Sender: TObject);
begin
  Self.Close;
end;

{ private }

procedure TFmNewSyntax.SetCbbSyntax(cbbSyntax: TComboBox);
begin
  Self.FCbbSyntax := cbbSyntax;
end;

end.
