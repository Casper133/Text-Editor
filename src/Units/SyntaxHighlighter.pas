Unit SyntaxHighlighter;

Interface

Uses
  SyntaxFilesGenerator, Winapi.Windows, Winapi.Messages, System.Classes,
  Vcl.Graphics, Vcl.ComCtrls, StrUtils;

Function LoadSyntaxFile(fileName: string): TSyntaxInfo;
Procedure Highlight(fileName: string; var RichEdit, RECopy: TRichEdit);

Implementation

Function LoadSyntaxFile(fileName: string): TSyntaxInfo;
var
  syntaxFile: file of TSyntaxInfo;

begin
  AssignFile(syntaxFile, 'syntaxes/' + fileName);
  Reset(syntaxFile);
  Read(syntaxFile, Result);
  CloseFile(syntaxFile);
end;


Procedure Highlight(fileName: string; var RichEdit, RECopy: TRichEdit);
// ����������� - �������, ����� ������� ����� ���� ����������������� �����
const
  Delimiters: string = ' ,(){}[]-+*%/=~!&|<>?:;.' + #$D#$A;

var
  syntaxFile: file of TSyntaxInfo;
  i, n: integer;
  linesCount: integer;
  isMultComment, isInsideStr1, isInsideStr2: boolean;
  mCommentStart, insideStr1, insideStr2, eventMask: integer;
  possibleRWord, textCopy: string;
  textLen, sStart, sLen: integer;
  isHightlightPossible: boolean;
  mStream: TMemoryStream;
  scInfoH, scInfoV: tagSCROLLINFO;
  syntaxInfo: TSyntaxInfo;
  rWords: TReserved;
  sLineComment: string[2];
  mLineComment: TMLineComment;
  testStr: string;

begin
  AssignFile(syntaxFile, 'syntaxes/' + fileName);
  Reset(syntaxFile);
  Read(syntaxFile, syntaxInfo);
  CloseFile(syntaxFile);

  rWords := syntaxInfo.ReservedWords;
  sLineComment := syntaxInfo.SingleLineComment;
  mLineComment := syntaxInfo.MultiLineComment;

  // ���������� ��� ���� �������� �� �����
  sStart := RichEdit.SelStart;
  sLen := RichEdit.SelLength;

  // ������: ����� ���� ����������, �� ��������� �� ���������,
  // ����� �� �������� � ������������ ����������������� ����� � �.�.
  isMultComment := false;
  isInsideStr1 := false;
  isInsideStr2 := false;

  linesCount := 0;

  mCommentStart := -1;
  insideStr1 := -1;
  insideStr2 := -1;

  // ���������� �����������
  RichEdit.DoubleBuffered := true;
  SendMessage(RichEdit.Handle, WM_SETREDRAW, 0, 0);
  eventMask := SendMessage(RichEdit.Handle, WM_USER + 69, 0, 0);

  // �������� � ������ RichEdit
  mStream := TMemoryStream.Create;
  RichEdit.PlainText := true;
  RECopy.PlainText := true;
  try
    RichEdit.Lines.SaveToStream(mStream);
    mStream.Seek(0, soFromBeginning);
    RECopy.Lines.LoadFromStream(mStream);
  finally
    mStream.Free;
  end;

  // ���������� ����� ��������� RichEdit
  FillChar(scInfoV, sizeof(scInfoV), 0);
  scInfoV.cbSize := sizeof(scInfoV);
  scInfoV.fMask := SIF_POS;

  FillChar(scInfoH, sizeof(scInfoH), 0);
  scInfoH.cbSize := sizeof(scInfoH);
  scInfoH.fMask := SIF_POS;

  GetScrollInfo(RichEdit.Handle, SB_VERT, scInfoV);
  GetScrollInfo(RichEdit.Handle, SB_HORZ, scInfoH);

  // ��������������� ��������� ����������
  try
    // ������ ���������� ���������
    RECopy.SelStart := 0;
    RECopy.SelLength := length(RECopy.Text);
    RECopy.SelAttributes := RichEdit.DefAttributes;
    RECopy.SelAttributes.Color := clBlack;
    RECopy.SelAttributes.Style := [];

    i := 0;
    // ����������� ������ � textCopy
    textCopy := RECopy.Text + #$A;
    textLen := length(textCopy);

    // ������� ������
    while (i <= textLen) do
    begin
      i := i + 1;

      if textCopy[i] = #$D then
        inc(linesCount);

      // ����� ��������� ������� � �� ����� ����� ��� ����
      // ������ �� ������ ������� �� ��������� � ������
      if isInsideStr1 and (textCopy[i] = '''') then
      begin
        RECopy.SelStart := insideStr1 - linesCount;
        RECopy.SelLength := i - insideStr1;
        RECopy.SelAttributes.Color := clGreen;
        isInsideStr1 := false;
        continue;
      end;

      // ����� ������� ������� � �� ����� ����� ��� ����
      // ������ �� ������ ������� �� ��������� � ������
      if isInsideStr2 and (textCopy[i] = '"') then
      begin
        RECopy.SelStart := insideStr2 - linesCount;
        RECopy.SelLength := i - insideStr2;
        RECopy.SelAttributes.Color := clGreen;
        isInsideStr2 := false;
        continue;
      end;

      // ����������� ������������� �����������
      if i < textLen then
        if isMultComment and
          (Copy(textCopy, i, Length(mLineComment[2])) = mLineComment[2]) then
        begin
          RECopy.SelStart := mCommentStart - linesCount;
          RECopy.SelLength := i - mCommentStart + 1;
          RECopy.SelAttributes.Color := clGreen;
          testStr := RECopy.SelText;
          isMultComment := false;
          inc(i);
          continue;
        end;

      // ����� ����������������� ���� ��� ������������ � �����
      if (not isMultComment) and (not isInsideStr1) and (not isInsideStr2) then
      begin
        // ��������� �������
        if textCopy[i] = '''' then
        begin
          isInsideStr1 := true;
          insideStr1 := i - 1;
          continue;
        end;

        // ������� �������
        if textCopy[i] = '"' then
        begin
          isInsideStr2 := true;
          insideStr2 := i - 1;
          continue;
        end;

        // ����������� ������������ �����������
        if i < textLen then
        begin
          if (Copy(textCopy, i, Length(sLineComment)) = sLineComment) then
          begin
            RECopy.SelStart := i - 1 - linesCount;
            RECopy.SelLength := PosEx(#$D, textCopy, i) - i;
            RECopy.SelAttributes.Color := clGreen;
            testStr := RECopy.SelText;
            i := PosEx(#$D, textCopy, i) - 1;
            continue;
          end;
        end;

        // ���� ������ ������ �������������� �����������
        if i < textLen then
          if Copy(textCopy, i, Length(mLineComment[1])) = mLineComment[1] then
          begin
            isMultComment := true;
            mCommentStart := i - 1;
            inc(i);
            continue;
          end;

        // ����� ������������������ �����
        // (13 = ����� ������� ���. ����� + 1 ��� ������� �� Delimiters)
        possibleRWord := copy(textCopy, i, 13);

        // ���� ��� ����� ������ - �� ������� � ����� ������
        if length(possibleRWord) < 13 then
          possibleRWord := possibleRWord + ' ';

        isHightlightPossible := false;

        // ���� ������ ������ - ���� ����������������� �����
        if i = 1 then
          isHightlightPossible := true;

        // ���� �� ������, �� ����� �������� ���� ����������� - ����� ����
        if (i > 1) then
          if Pos(textCopy[i - 1], Delimiters) > 0 then
            isHightlightPossible := true;

        if isHightlightPossible then
          for n := 1 to length(rWords) do
            if Length(rWords[n]) <> 0 then
              // ���� ����� �������
              if (Pos(rWords[n], possibleRWord) = 1) and
                (length(possibleRWord) > length(rWords[n])) then
                // � ���� �� ��� ���� �����������
                if Pos(possibleRWord[length(rWords[n]) + 1], Delimiters) > 0 then
                begin
                  // �� ������ ��� � ����� � ������ ������
                  RECopy.SelStart := i - 1 - linesCount;
                  RECopy.SelLength := length(rWords[n]);
                  RECopy.SelAttributes.Color := clBlue;
                  RECopy.SelAttributes.Style := [fsBold];
                  i := i + length(rWords[n]) - 1;
                  continue;
                end;
      end;
    end;

    // ���������, ���� �� ������ ���������
    // ����� ������ ������ ����� �� ������ �����
    i := textLen - 1;
    if isInsideStr1 then
    begin
      RECopy.SelStart := insideStr1 - linesCount;
      RECopy.SelLength := i - insideStr1;
      RECopy.SelAttributes.Color := clGreen;
    end;

    if isInsideStr2 then
    begin
      RECopy.SelStart := insideStr2 - linesCount;
      RECopy.SelLength := i - insideStr2;
      RECopy.SelAttributes.Color := clGreen;
    end;

    if isMultComment then
    begin
      RECopy.SelStart := mCommentStart - linesCount;
      RECopy.SelLength := i - mCommentStart;
      RECopy.SelAttributes.Color := clGreen;
    end;
  except
  end;

  // �������� �� ������ �� RichEdit �����
  mStream := TMemoryStream.Create;
  RECopy.PlainText := false;
  RichEdit.PlainText := false;
  try
    RECopy.Lines.SaveToStream(mStream);
    mStream.Seek(0, soFromBeginning);
    RichEdit.Lines.LoadFromStream(mStream);
  finally
    mStream.Free;
  end;

  // ��������������� ������� ��������
  RichEdit.Perform(WM_VSCROLL, SB_THUMBPOSITION + scInfoV.nPos * 65536, 0);
  RichEdit.Perform(WM_HSCROLL, SB_THUMBPOSITION + scInfoH.nPos * 65536, 0);

  // ����������� ������ �������������� RichEdit
  RECopy.Free;

  // C����� ������ � ��������� � ��������� �����
  RichEdit.SelStart := sStart;
  RichEdit.SelLength := sLen;

  // �������� ����������� ������� � �������������� RichEdit
  SendMessage(RichEdit.Handle, WM_SETREDRAW, 1, 0);
  InvalidateRect(RichEdit.Handle, nil, true);
  SendMessage(RichEdit.Handle, WM_USER + 69, 0, eventMask);
  RichEdit.DoubleBuffered := false;
  RichEdit.Repaint;
end;

End.

