unit uNewSyntaxView;

interface

uses
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Controls, Classes, SysUtils;

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
  ItemsCount: Integer;
  IsNameExist: Boolean;
  i: Integer;
begin
  IsNameExist := False;
  SyntaxName := Self.edtName.Text;
  SyntaxName := Trim(SyntaxName);

  if SyntaxName <> '' then
  begin
    ItemsCount := Self.FCbbSyntax.Items.Count;
    for i := 0 to ItemsCount - 1 do
      if SyntaxName = Self.FCbbSyntax.Items[i] then
        IsNameExist := True;
    if not IsNameExist then
    begin
      Self.FCbbSyntax.Items.Append(SyntaxName);
      Self.FCbbSyntax.Text := SyntaxName;
      ShowMessage('Черновик языка ' + SyntaxName + ' успешно добавлен. ' +
        'Не забудьте сохранить его!');
      Self.Close;
    end
    else
      ShowMessage('Такой синтаксис уже существует. Попробуйте другое имя.');
  end
  else
    ShowMessage('Имя не может быть пустым.');
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
