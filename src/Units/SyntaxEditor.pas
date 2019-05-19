unit SyntaxEditor;

interface

uses
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Classes,
  UITypes, SysUtils, SyntaxFiles, NewSyntaxView;

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

    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure btnCreateClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure cbbSyntaxChange(Sender: TObject);
  private
    FSyntaxList: TSyntaxList;
    FSyntaxTab: TMenuItem;
    FmNewSyntax: TFmNewSyntax;
    procedure SetSyntaxList(SyntaxList: TSyntaxList);
    procedure SetSyntaxTab(SyntaxTab: TMenuItem);
    procedure ClearTextFields();
    procedure UpdateMenu();
    function TransformReservedWords(): TReserved;
    procedure RemoveSyntaxFromMenu(const SyntaxName: string);
  public
    property SyntaxList: TSyntaxList Write SetSyntaxList;
    property SyntaxTab: TMenuItem Write SetSyntaxTab;
  end;

var
  FmSyntaxEditor: TFmSyntaxEditor;

implementation

{$R *.dfm}

uses
  Main;

{ published }

procedure TFmSyntaxEditor.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Languages: TLangNames;
  i: integer;
  mSyntaxMenu, mSeparator, SyntaxItem: TMenuItem;
begin
  Self.FSyntaxTab.Clear;

  mSyntaxMenu := TMenuItem.Create(Self);
  mSyntaxMenu.Action := Main.MainForm.aSyntaxMenu;
  mSeparator := TMenuItem.Create(Self);
  mSeparator.Caption := '-';
  Self.FSyntaxTab.Insert(0, mSyntaxMenu);
  Self.FSyntaxTab.Insert(1, mSeparator);

  Languages := Self.FSyntaxList.GetAllLanguages();
  for i := 0 to Self.FSyntaxList.Count - 1 do
  begin
    SyntaxItem := TMenuItem.Create(Self);
    SyntaxItem.Caption := Languages[i];
    SyntaxItem.OnClick := Main.MainForm.onSyntaxClick;
    Self.FSyntaxTab.Insert(i + 2, SyntaxItem);
  end;

  Self.UpdateMenu();
  Self.ClearTextFields();
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
  SyntaxName: string;
  PSyntax: PSyntaxInfo;
  ReservedWords: TReserved;
begin
  SyntaxName := Self.cbbSyntax.Text;
  if SyntaxName <> '' then
  begin
    PSyntax := Self.FSyntaxList[SyntaxName];

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
      Self.FSyntaxList.AppendSyntax(PSyntax, SyntaxName);
    end;

    ShowMessage('Синтаксис языка ' + SyntaxName + ' успешно сохранён!');
  end
  else
    ShowMessage('Вы не выбрали язык программирования.');
end;

procedure TFmSyntaxEditor.cbbSyntaxChange(Sender: TObject);
var
  SyntaxName: string;
  RWord: string[15];
  PSyntax: PSyntaxInfo;
  i: integer;
begin
  SyntaxName := Self.cbbSyntax.Text;
  PSyntax := Self.FSyntaxList[SyntaxName];
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
      Self.FSyntaxList.RemoveSyntaxByName(SyntaxName);
      Self.ClearTextFields();
      Self.RemoveSyntaxFromMenu(SyntaxName);
      Self.cbbSyntax.Text := '';
      ShowMessage('Синтаксис языка ' + SyntaxName + ' успешно удалён.');
    end;
  end
  else
    ShowMessage('Вы не выбрали язык программирования.');
end;

procedure TFmSyntaxEditor.btnResetClick(Sender: TObject);
var
  btnSelected: integer;
begin
  btnSelected := MessageDlg('Это действие отменит изменения в синтаксисах ' +
    'стандартных языков (C#, C++, C, Go, Java, JavaScript, Kotlin, Python). ' +
    'Вы согласны?', mtWarning, [mbYes, mbNo], 0);

  if btnSelected = mrYes then
  begin
    Self.FSyntaxList.ClearList();
    Self.FSyntaxList.createDefaultSyntaxes();
    Self.FSyntaxList.LoadExistingSyntaxFiles();
    Self.UpdateMenu();
    Self.ClearTextFields();
    ShowMessage('Настройки стандартных языков сброшены.');
  end;
end;

{ private }

procedure TFmSyntaxEditor.SetSyntaxList(SyntaxList: TSyntaxList);
begin
  Self.FSyntaxList := SyntaxList;
  Self.UpdateMenu();
end;

procedure TFmSyntaxEditor.SetSyntaxTab(SyntaxTab: TMenuItem);
begin
  Self.FSyntaxTab := SyntaxTab;
end;

procedure TFmSyntaxEditor.ClearTextFields();
begin
  Self.edtFileExtension.Text := '';
  Self.memReservedWords.Text := '';
  Self.edtSingleLnComment.Text := '';
  Self.edtMultLnCommentBegin.Text := '';
  Self.edtMultLnCommentEnd.Text := '';
end;

procedure TFmSyntaxEditor.UpdateMenu();
var
  Languages: TLangNames;
  i: integer;
begin
  Self.cbbSyntax.Clear;

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

procedure TFmSyntaxEditor.RemoveSyntaxFromMenu(const SyntaxName: string);
var
  i, Count: integer;
begin
  Count := Self.cbbSyntax.Items.Count;
  for i := 0 to Count - 1 do
    if Self.cbbSyntax.Items[i] = SyntaxName then
    begin
      Self.cbbSyntax.Items.Delete(i);
      break;
    end;
end;

end.
