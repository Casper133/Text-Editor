unit uSyntaxHighlighter;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.Graphics, Vcl.ComCtrls, Classes,
  StrUtils, uSyntaxEntity;

procedure RepaintOff(var ARichEdit: TRichEdit; var AEventMask: Integer);
procedure RepaintRichEdit(var ARichEdit: TRichEdit; var AEventMask: Integer);

procedure SaveSelects(var ARichEdit: TRichEdit; var ASelStart, ASelLen: Integer);
procedure LoadSelects(var ARichEdit: TRichEdit; var ASelStart, ASelLen: Integer);

procedure SaveScrolls(var ARichEdit: TRichEdit; var AScrollInfoH,
  AScrollInfoV: tagSCROLLINFO);
procedure LoadScrolls(var ARichEdit: TRichEdit; var AScrollInfoH,
  AScrollInfoV: tagSCROLLINFO);

procedure FillMemoryRichEdit(var ARichEditMain, ARichEditCopy: TRichEdit);
procedure FillMainRichEdit(var ARichEditMain, ARichEditCopy: TRichEdit);

procedure Highlight(var i: Integer; const ATextLen,
  ALinesCount: Integer; const ATextCopy, ASLineComment, ADelimiters: string;
  var ARichEditCopy: TRichEdit; const AReservedWords: TReserved);

procedure HighlightText(var ASyntaxList: TSyntaxList; const ASyntaxName: string;
  var ARichEditMain, ARichEditCopy: TRichEdit);

implementation

procedure RepaintOff;
begin
  ARichEdit.DoubleBuffered := True;
  SendMessage(ARichEdit.Handle, WM_SETREDRAW, 0, 0);
  AEventMask := SendMessage(ARichEdit.Handle, WM_USER + 69, 0, 0);
end;

procedure RepaintRichEdit;
begin
  SendMessage(ARichEdit.Handle, WM_SETREDRAW, 1, 0);
  InvalidateRect(ARichEdit.Handle, nil, True);
  SendMessage(ARichEdit.Handle, WM_USER + 69, 0, AEventMask);
  ARichEdit.DoubleBuffered := False;
  ARichEdit.Repaint;
end;

procedure SaveSelects;
begin
  ASelStart := ARichEdit.SelStart;
  ASelLen := ARichEdit.SelLength;
end;

procedure LoadSelects;
begin
  ARichEdit.SelStart := ASelStart;
  ARichEdit.SelLength := ASelLen;
end;

procedure SaveScrolls;
begin
  FillChar(AScrollInfoV, SizeOf(AScrollInfoV), 0);
  AScrollInfoV.cbSize := SizeOf(AScrollInfoV);
  AScrollInfoV.fMask := SIF_POS;

  FillChar(AScrollInfoH, SizeOf(AScrollInfoH), 0);
  AScrollInfoH.cbSize := SizeOf(AScrollInfoH);
  AScrollInfoH.fMask := SIF_POS;

  GetScrollInfo(ARichEdit.Handle, SB_VERT, AScrollInfoV);
  GetScrollInfo(ARichEdit.Handle, SB_HORZ, AScrollInfoH);
end;

procedure LoadScrolls;
begin
  ARichEdit.Perform(WM_VSCROLL, SB_THUMBPOSITION +
    AScrollInfoV.nPos * 65536, 0);
  ARichEdit.Perform(WM_HSCROLL, SB_THUMBPOSITION +
    AScrollInfoH.nPos * 65536, 0);
end;

procedure FillMemoryRichEdit;
var
  MemoryStream: TMemoryStream;
begin
  MemoryStream := TMemoryStream.Create;
  ARichEditMain.PlainText := True;
  ARichEditCopy.PlainText := True;
  try
    ARichEditMain.Lines.SaveToStream(MemoryStream);
    MemoryStream.Seek(0, soFromBeginning);
    ARichEditCopy.Lines.LoadFromStream(MemoryStream);
  finally
    MemoryStream.Free;
  end;
end;

procedure FillMainRichEdit;
var
  MemoryStream: TMemoryStream;
begin
  MemoryStream := TMemoryStream.Create;
  ARichEditCopy.PlainText := False;
  ARichEditMain.PlainText := False;
  try
    ARichEditCopy.Lines.SaveToStream(MemoryStream);
    MemoryStream.Seek(0, soFromBeginning);
    ARichEditMain.Lines.LoadFromStream(MemoryStream);
  finally
    MemoryStream.Free;
    ARichEditCopy.Free;
  end;
end;


procedure Highlight;
var
  PossibleRWord, TextBuf: string;
  IsHightlightPossible: Boolean;
  n, PosBuf: Integer;
begin
  // Однострочный комментарий (окрашивание до конца строки)
  if i < ATextLen then
  begin
    TextBuf := Copy(ATextCopy, i, Length(ASLineComment));
    if TextBuf = ASLineComment then
    begin
      ARichEditCopy.SelStart := i - 1 - ALinesCount;
      ARichEditCopy.SelLength := PosEx(#$D, ATextCopy, i) - i;
      ARichEditCopy.SelAttributes.Color := clGreen;
      i := PosEx(#$D, ATextCopy, i) - 1;
      Exit;
    end;
  end;

  { Поиск зарезервированного слова.
    15 = самое длинное возможное зар. слово + 1 для символа из Delimiters }
  PossibleRWord := Copy(ATextCopy, i, 16);

  // Если это конец текста - добавление пробела для возможности выделения
  if Length(PossibleRWord) < 16 then
    PossibleRWord := PossibleRWord + ' ';

  IsHightlightPossible := False;

  // Если начало текста
  if i = 1 then
    IsHightlightPossible := True;

  // Если перед словом есть разделитель
  PosBuf := Pos(ATextCopy[i - 1], ADelimiters);
  if (i > 1) and (PosBuf > 0) then
      IsHightlightPossible := True;

  if IsHightlightPossible then
    for n := 1 to Length(AReservedWords) do
      if Length(AReservedWords[n]) <> 0 then
        // Если зарезервированное слово найдено ...
        if (Pos(AReservedWords[n], PossibleRWord) = 1) and
          (Length(PossibleRWord) > Length(AReservedWords[n])) then
        begin
          // ... и если за ним идет разделитель ...
          PosBuf :=
            Pos(PossibleRWord[Length(AReservedWords[n]) + 1], ADelimiters);
          if PosBuf > 0 then
          begin
            // ... то окрашивание слова
            ARichEditCopy.SelStart := i - 1 - ALinesCount;
            ARichEditCopy.SelLength := Length(AReservedWords[n]);
            ARichEditCopy.SelAttributes.Color := clBlue;
            ARichEditCopy.SelAttributes.Style := [fsBold];
            i := i + Length(AReservedWords[n]) - 1;
            Exit;
          end;
        end;
end;


procedure HighlightText;
const
  Delimiters: string = ' ,(){}[]-+*%/=~!&|<>?:;.' + #$D#$A;

{ Delimiters - символы, около которых могут быть зарезервированные слова }

var
  i: Integer;
  LinesCount: Integer;
  IsMLineComment, IsInsideStr1, IsInsideStr2: Boolean;
  MCommentStart, InsideStrPos1, InsideStrPos2: Integer;
  EventMask: Integer;
  TextCopy: string;
  TextLen, SavedSelStart, SavedSelLen: Integer;
  ScrollInfoH, ScrollInfoV: tagSCROLLINFO;
  PSyntax: PSyntaxInfo;
  ReservedWords: TReserved;
  SLineComment: string[2];
  MLineComment: TMLineComment;
begin
  // Отключение перерисовки RichEdit на форме, сохранение всего нужного
  RepaintOff(ARichEditMain, EventMask);
  SaveSelects(ARichEditMain, SavedSelStart, SavedSelLen);
  SaveScrolls(ARichEditMain, ScrollInfoH, ScrollInfoV);
  FillMemoryRichEdit(ARichEditMain, ARichEditCopy);

  PSyntax := ASyntaxList[ASyntaxName];

  ReservedWords := PSyntax^.ReservedWords;
  SLineComment := PSyntax^.SingleLineComment;
  MLineComment := PSyntax^.MultiLineComment;

  // Флажки чтобы не находить в комментариях/строках зарезервированные слова
  IsMLineComment := False;
  IsInsideStr1 := False;
  IsInsideStr2 := False;

  { Считаем количество строк т.к. в RichEdit 2.0 при окрашивании
    не учитывается символ \r (#$D), из-за чего текст окрашивается не полностью }
  LinesCount := 0;

  MCommentStart := -1;
  InsideStrPos1 := -1;
  InsideStrPos2 := -1;

  // Чистка предыдущей подсветки
  ARichEditCopy.SelStart := 0;
  ARichEditCopy.SelLength := Length(ARichEditCopy.Text);
  ARichEditCopy.SelAttributes := ARichEditMain.DefAttributes;
  ARichEditCopy.SelAttributes.Color := clBlack;
  ARichEditCopy.SelAttributes.Style := [];

  TextCopy := ARichEditCopy.Text + #$A;
  TextLen := length(TextCopy);

  // Проход по всему тексту
  i := 0;
  while (i >= 0) and (i <= TextLen) do
  begin
    i := i + 1;

    if TextCopy[i] = #$D then
      Inc(LinesCount);

    // Закрывающая одиночная кавычка (окрашивание)
    if IsInsideStr1 and (TextCopy[i] = '''') then
    begin
      ARichEditCopy.SelStart := InsideStrPos1 - LinesCount;
      ARichEditCopy.SelLength := i - InsideStrPos1;
      ARichEditCopy.SelAttributes.Color := clGreen;
      IsInsideStr1 := False;
      Continue;
    end;

    // Закрывающая двойная кавычка (окрашивание)
    if IsInsideStr2 and (TextCopy[i] = '"') then
    begin
      ARichEditCopy.SelStart := InsideStrPos2 - LinesCount;
      ARichEditCopy.SelLength := i - InsideStrPos2;
      ARichEditCopy.SelAttributes.Color := clGreen;
      IsInsideStr2 := False;
      Continue;
    end;

    // Конец многострочного комментария (окрашивание)
    if i < TextLen then
      if IsMLineComment and
        (Copy(TextCopy, i, Length(MLineComment[2])) = MLineComment[2]) then
      begin
        ARichEditCopy.SelStart := MCommentStart - LinesCount;
        ARichEditCopy.SelLength := i - MCommentStart + 1;
        ARichEditCopy.SelAttributes.Color := clGreen;
        IsMLineComment := False;
        Inc(i);
        Continue;
      end;

    if (not IsMLineComment) and (not IsInsideStr1) and (not IsInsideStr2) then
    begin
      // Открывающая одиночная кавычка
      if TextCopy[i] = '''' then
      begin
        IsInsideStr1 := True;
        InsideStrPos1 := i - 1;
        Continue;
      end;

      // Открывающая двойная кавычка
      if TextCopy[i] = '"' then
      begin
        IsInsideStr2 := True;
        InsideStrPos2 := i - 1;
        Continue;
      end;

      // Начало многострочного комментария
      if i < TextLen then
        if Copy(TextCopy, i, Length(MLineComment[1])) = MLineComment[1] then
        begin
          IsMLineComment := True;
          MCommentStart := i - 1;
          Inc(i);
          Continue;
        end;

      Highlight(i, TextLen, LinesCount, TextCopy, SLineComment,
        Delimiters, ARichEditCopy, ReservedWords);

      Continue;
    end;
  end;

  // Проверки на "рваные" выделения (комментарий/строка до конца текста)
  i := TextLen - 1;
  if IsInsideStr1 then
  begin
    ARichEditCopy.SelStart := InsideStrPos1 - LinesCount;
    ARichEditCopy.SelLength := i - InsideStrPos1;
    ARichEditCopy.SelAttributes.Color := clGreen;
  end;
  if IsInsideStr2 then
  begin
    ARichEditCopy.SelStart := InsideStrPos2 - LinesCount;
    ARichEditCopy.SelLength := i - InsideStrPos2;
    ARichEditCopy.SelAttributes.Color := clGreen;
  end;
  if IsMLineComment then
  begin
    ARichEditCopy.SelStart := MCommentStart - LinesCount;
    ARichEditCopy.SelLength := i - MCommentStart;
    ARichEditCopy.SelAttributes.Color := clGreen;
  end;

  // Восстановление всего нужного, перерисовка RichEdit на форме
  FillMainRichEdit(ARichEditMain, ARichEditCopy);
  LoadScrolls(ARichEditMain, ScrollInfoH, ScrollInfoV);
  LoadSelects(ARichEditMain, SavedSelStart, SavedSelLen);
  RepaintRichEdit(ARichEditMain, EventMask);
end;

End.

