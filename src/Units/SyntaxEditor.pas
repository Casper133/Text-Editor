unit SyntaxEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, SyntaxFiles, NewSyntaxView;

type
  TFmSyntaxEditor = class(TForm)
    cbbSyntax: TComboBox;
    btnCreate: TButton;
    lblFileExtension: TLabel;
    edtFileExtension: TEdit;
    lblReservedWords: TLabel;
    memReservedWords: TMemo;
    lblSingleLnComment: TLabel;
    edtSingleLnComment: TEdit;
    lblMultLnCommentBegin: TLabel;
    edtMultLnCommentBegin: TEdit;
    lblMultLnCommentEnd: TLabel;
    edtMultLnCommentEnd: TEdit;
    btnSave: TButton;
    btnReset: TButton;
    btnRemove: TButton;
    procedure cbbSyntaxChange(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  private
    FSyntaxList: TSyntaxList;
    FmNewSyntax: TFmNewSyntax;
    procedure SetSyntaxList(SyntaxList: TSyntaxList);
    function TransformReservedWords(): TReserved;
  public
    property SyntaxList: TSyntaxList Write SetSyntaxList;
  end;

var
  FmSyntaxEditor: TFmSyntaxEditor;

implementation

{$R *.dfm}

{ public/published }

procedure TFmSyntaxEditor.cbbSyntaxChange(Sender: TObject);
var
  FileName: string;
  RWord: string[15];
  PSyntax: PSyntaxInfo;
  i: integer;
begin
  FileName := Self.cbbSyntax.Text;
  PSyntax := Self.FSyntaxList.GetSyntaxByFileName(FileName);
  if PSyntax <> nil then
    with PSyntax^ do
    begin
      Self.memReservedWords.Clear;

      for i := 1 to 50 do
      begin
        RWord := ReservedWords[i];
        if RWord <> '' then
          Self.memReservedWords.Text := Self.memReservedWords.Text + RWord + ' '
        else
          break;
      end;

      Self.edtFileExtension.Text := FileExtension;
      Self.edtSingleLnComment.Text := SingleLineComment;
      Self.edtMultLnCommentBegin.Text := MultiLineComment[1];
      Self.edtMultLnCommentEnd.Text := MultiLineComment[2];
    end
  else
  begin
    Self.edtFileExtension.Text := '';
    Self.memReservedWords.Text := '';
    Self.edtSingleLnComment.Text := '';
    Self.edtMultLnCommentBegin.Text := '';
    Self.edtMultLnCommentEnd.Text := '';
  end;
end;

procedure TFmSyntaxEditor.btnCreateClick(Sender: TObject);
begin
  if not Assigned(Self.FmNewSyntax) then
  begin
    Self.FmNewSyntax := TFmNewSyntax.Create(Self);
    Self.FmNewSyntax.cbbSyntax := Self.cbbSyntax;
  end;

  Self.FmNewSyntax.ShowModal;
end;

procedure TFmSyntaxEditor.btnSaveClick(Sender: TObject);
var
  FileName: string;
  PSyntax: PSyntaxInfo;
  ReservedWords: TReserved;
begin
  FileName := Self.cbbSyntax.Text;
  if FileName <> '' then
  begin
    PSyntax := Self.FSyntaxList.GetSyntaxByFileName(FileName);

    if PSyntax <> nil then
    begin
      PSyntax^.FileExtension := Self.edtFileExtension.Text;
      PSyntax^.ReservedWords := Self.TransformReservedWords();
      PSyntax^.SingleLineComment := Self.edtSingleLnComment.Text;
      PSyntax^.MultiLineComment[1] := Self.edtMultLnCommentBegin.Text;
      PSyntax^.MultiLineComment[2] := Self.edtMultLnCommentEnd.Text;
    end
    else
    begin
      New(PSyntax);
      ReservedWords := Self.TransformReservedWords();
      PSyntax^ := Self.FSyntaxList.CreateSyntaxInfo(
        Trim(Self.edtFileExtension.Text), ReservedWords,
        Trim(Self.edtSingleLnComment.Text),
        Trim(Self.edtMultLnCommentBegin.Text),
        Trim(Self.edtMultLnCommentEnd.Text));
      Self.FSyntaxList.AppendSyntax(PSyntax, FileName);
    end;

    ShowMessage('Синтаксис языка ' + FileName + ' успешно сохранён!');
  end
  else
    ShowMessage('Вы не выбрали язык программирования');
end;

procedure TFmSyntaxEditor.btnRemoveClick(Sender: TObject);
var
  btnSelected: integer;
  SyntaxName: string;
begin
  SyntaxName := Self.cbbSyntax.Text;
  if SyntaxName <> '' then
  begin
    btnSelected := MessageDlg('Вы действительно хотите удалить этот синтаксис?',
      mtWarning, [mbYes, mbNo], 0);

    if btnSelected = mrYes then
    begin
      Self.FSyntaxList.removeSyntaxByFileName(SyntaxName);
      ShowMessage('Синтаксис языка ' + SyntaxName + ' успешно удалён');
    end;
  end
  else
    ShowMessage('Вы не выбрали язык программирования');
end;

procedure TFmSyntaxEditor.btnResetClick(Sender: TObject);
var
  btnSelected: integer;
begin
  btnSelected := MessageDlg('Это действие отменит изменения во всех ' +
    'стандартных синтаксисах. Вы согласны?', mtWarning, [mbYes, mbNo], 0);

  if btnSelected = mrYes then
  begin
    Self.FSyntaxList.createDefaultSyntaxes();
    Self.FSyntaxList.ClearList();
    Self.FSyntaxList.LoadExistingSyntaxFiles();
    Self.cbbSyntaxChange(Self);
  end;
end;

{ private }

procedure TFmSyntaxEditor.SetSyntaxList(SyntaxList: TSyntaxList);
var
  Languages: TLangNames;
  i: integer;
begin
  Self.FSyntaxList := SyntaxList;

  Languages := Self.FSyntaxList.GetAllLanguages();
  for i := 0 to Self.FSyntaxList.Count - 1 do
    Self.cbbSyntax.Items.Append(Languages[i]);
end;

function TFmSyntaxEditor.TransformReservedWords(): TReserved;
var
  Text, RWord: string;
  i, k: integer;
begin
  Text := Self.memReservedWords.Text;
  Text := StringReplace(Text, #$D#$A, ' ', [rfReplaceAll]);
  for i := 1 to 50 do
  begin
    k := Pos(' ', Text);
    if k <> 0 then
    begin
      RWord := Copy(Text, 1, k - 1);
      while RWord = '' do
      begin
        Delete(Text, 1, k);
        k := Pos(' ', Text);
        if k <> 0 then
          RWord := Copy(Text, 1, k - 1)
        else
          break;
      end;

      if k <> 0 then
      begin
        Result[i] := RWord;
        Delete(Text, 1, k);
      end;
    end
    else if Copy(Text, 1, 1) <> '' then
    begin
      Result[i] := Text;
      Delete(Text, 1, Length(Text));
    end
    else
      Result[i] := '';
  end;
end;

end.
