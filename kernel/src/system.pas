{===========================================================================
  Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
  --------------------------------------------------------------------------
  Copyright (C) 2013 - Luciano L. Goncalez
  --------------------------------------------------------------------------
  a.k.a.: Master Lucky
  eMail : master.lucky.br@gmail.com
  Home  : http://lucky-labs.blogspot.com.br
============================================================================
  Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
  sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
  Software Foundation; na versao 2 da Licenca.

  Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
  GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
  ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
  Geral GNU para obter mais detalhes.

  Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
  este programa; se nao, escreva para a Free Software Foundation, Inc., 59
  Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
  GNU e obtenha sua licenca: http://www.gnu.org/
============================================================================
  Unit System.pas
  --------------------------------------------------------------------------
  Unit principal do compilador, crosscompiler, que substitui a RTL normal.
  --------------------------------------------------------------------------
  Versao: 0.3.1
  Data: 11/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc system.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0429-0000] (v0.0) <Luciano Goncalez>

  - Implementação inicial, RTL limpa.
  ------------------------------------------------------------------------
  [2013-0507-0000] (v0.1) <Luciano Goncalez>

  - Adicionando rotinas Move, FillChar, FillByte, FillWord, FillDWord.
  ------------------------------------------------------------------------
  [2013-0510-0000] (v0.2) <Luciano Goncalez>

  - Adicionando rotinas de trabalho com strings.
  ------------------------------------------------------------------------
  [2013-0906-0000] (v0.3) <Luciano Goncalez>

  - Adicionando outras rotinas de trabalho com strings.
  ------------------------------------------------------------------------
  [2018-0111-2326] (v0.3.1) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

unit System;

{$mode objfpc} // Obrigatorio por usar out-parameters

interface

type
  HResult = LongWord; // Obrigatorio

  // Tamanhos automatizados (maximos da arquitetura)
  SInt = LongInt; // Inteiro com sinal
  UInt = LongWord; // Inteiro sem sinal

  DWord = LongWord;

  PByte = ^Byte;
  PWord = ^Word;
  PDWord = ^DWord;

  PChar = ^Char;
  PShortString = ^ShortString;


  procedure Move(const Src; var Dest; Count : LongInt);
  function CompareByte(const Buff1, Buff2; Len : LongInt) : LongInt;

  procedure FillChar(var X; Count : LongInt; Value : Char);
  procedure FillByte(var X; Count : LongInt; Value : Byte);
  procedure FillWord(var X; Count : LongInt; Value : Word);
  procedure FillDWord(var X; Count : LongInt; Value : DWord);

  function  Pos(const SubStr, SrcStr : ShortString) : Byte;
  function  Pos(C : Char; const Source : ShortString) : Byte;

  function StrLen(P : PChar) : LongInt; external name 'FPC_PCHAR_LENGTH';

  procedure fpc_shortstr_assign(Len : LongInt; SSrc, SDest : Pointer);
    register; compilerproc;

  procedure fpc_shortstr_concat(var DestStr : ShortString; const Src1, Src2 : ShortString);
    register; compilerproc;

  procedure fpc_shortstr_concat_multi(var DestStr : ShortString; const SrcArr : array of PShortString);
    register; compilerproc;

  function fpc_shortstr_compare_equal(const StrLeft, StrRight : ShortString) : LongInt;
    register; compilerproc;

  procedure fpc_shortstr_to_shortstr(out Res: ShortString; const SSrc: ShortString);
    register; compilerproc;


  function fpc_val_sint_shortstr(DestSize : LongInt; const S : ShortString;
    out Error : LongInt) : LongInt; register; compilerproc;


  procedure fpc_chararray_to_shortstr(out Res : ShortString;
    const Arr: array of char; ZeroBased : Boolean = true);
    register; compilerproc;

  function fpc_pchar_length(P : PChar) : LongInt; compilerproc;

  procedure fpc_pchar_to_shortstr(out Res : ShortString; P : PChar);
    register; compilerproc;


implementation


  function InitVal(const S : ShortString; out Negative : Boolean; out Base : Byte) : LongInt; forward;


procedure Move(const Src; var Dest; Count : LongInt); alias : 'FPC_MOVE';
var
  PSrc, PDest, PEnd : PByte;
begin
  if (Count > 0) and (@Src <> @Dest) then
  begin
    if (@Dest < @Src) or ((@Src + Count) < @Dest) then
    begin
      // copia crescente
      PSrc := @Src;
      PDest := @Dest;
      PEnd := PSrc + Count;

      while (PSrc < PEnd) do
      begin
        PDest^ := PSrc^;
        Inc(PSrc);
        Inc(PDest);
      end;

    end
    else
    begin
      // copia decrescente
      PSrc := @Src + Count - 1;
      PDest := @Dest + Count - 1;
      PEnd := @Src;

      while (PSrc >= PEnd) do
      begin
        PDest^ := PSrc^;
        Dec(PSrc);
        Dec(PDest);
      end;
    end;
  end;
end;

function CompareByte(const Buff1, Buff2; Len : LongInt) : LongInt;
var
  PBuff1D, PBuff2D : PDWord;
  PBuff1B, PBuff2B : PByte;
  vBlocks : LongInt;
  vRest : Byte;

begin
  PBuff1D := @Buff1;
  PBuff2D := @Buff2;

  vBlocks := Len div 4;
  vRest := Len mod 4;
  Result := 0;

  while (vBlocks > 0) and (Result = 0) do
  begin
    Result := PBuff1D^ - PBuff2D^;
    Inc(PBuff1D);
    Inc(PBuff2D);
    Dec(vBlocks);
  end;

  PBuff1B := Pointer(PBuff1D);
  PBuff2B := Pointer(PBuff2D);

  while (vRest > 0) and (Result = 0) do
  begin
    Result := PBuff1B^ - PBuff2B^;
    Inc(PBuff1B);
    Inc(PBuff2B);
    Dec(vRest);
  end;

  // 0 = True;
end;


procedure FillChar(var X; Count : LongInt; Value : Char);
begin
  FillByte(X, Count, Byte(Value));
end;

procedure FillByte(var X; Count : LongInt; Value : Byte);
var
  PDestD : PDWord;
  PDestB : PByte;
  vBlocks : LongInt;
  vRest : Byte;
  vTemp : DWord;

begin
  if (Count > 0) then
  begin
    // otimiza para gravar 32 bits (4 Bytes por bloco)
    PDestD := @X;
    vBlocks := Count div 4;
    vRest := Count mod 4;

    if (vBlocks > 0) then
    begin
      vTemp := (Value shl 8) or Value;
      vTemp := (vTemp shl 16) or vTemp;

      repeat
        PDestD^ := vTemp;
        Inc(PDestD);
        Dec(vBlocks);
      until vBlocks = 0;
    end;

    PDestB := Pointer(PDestD);

    // grava o resto
    while (vRest > 0)  do
    begin
      PDestB^ := Value;
      Inc(PDestB);
      Dec(vRest);
    end;
  end;
end;

procedure FillWord(var X; Count : LongInt; Value : Word);
var
  PDestD : PDWord;
  PDestW : PWord;
  vBlocks : LongInt;
  vRest : Byte;
  vTemp : DWord;

begin
  if (Count > 0) then
  begin
    // otimiza para gravar 32 bits (2 words por bloco)
    PDestD := @X;
    vBlocks := Count div 2;
    vRest := Count mod 2;

    if (vBlocks > 0) then
    begin
      vTemp := (Value shl 16) or Value;

      repeat
        PDestD^ := vTemp;
        Inc(PDestD);
        Dec(vBlocks);
      until vBlocks = 0;
    end;

    PDestW := Pointer(PDestD);

    // grava o resto
    while (vRest > 0) do
    begin
      PDestW^ := Value;
      Inc(PDestW);
      Dec(vRest);
    end;
  end;
end;

procedure FillDWord(var X; Count : LongInt; Value : DWord);
var
  PDestD : PDWord;

begin
  if (Count > 0) then
  begin
    PDestD := @X;

    while (Count > 0) do
    begin
      PDestD^ := Value;
      Inc(PDestD);
      Dec(Count);
    end;
  end;
end;


function  Pos(const SubStr, SrcStr : ShortString) : Byte;
var
  vLenSub  : Byte;
  vEnd, vSrc : PChar;

begin
  Pos := 0;
  vLenSub := Length(SubStr);

  if (vLenSub > 0) and (vLenSub <= Length(SrcStr)) then
  begin
    vEnd := @SrcStr[Length(SrcStr) - vLenSub + 1];
    vSrc := @SrcStr[1];

    while (vSrc <= vEnd) do
    begin
      if (SubStr[1] = vSrc^) and (CompareByte(SubStr[1], vSrc^, vLenSub) = 0) then
      begin
        Pos := vSrc - @SrcStr[0];
        Exit;
      end;

      Inc(vSrc);
    end;
  end;
end;

function  Pos(C : Char; const Source : ShortString) : Byte;
var
  vEnd, vSrc : PChar;

begin
  Pos := 0;

  vEnd := @Source[Length(Source)];
  vSrc := @Source[1];

  while (vSrc <= vEnd) do
  begin
    if (C = vSrc^) then
    begin
      Pos := vSrc - @Source[0];
      Exit;
    end;

    Inc(vSrc);
  end;
end;


procedure fpc_shortstr_assign(Len : LongInt; SSrc, SDest : Pointer);
  register; compilerproc;
  alias : 'FPC_SHORTSTR_ASSIGN';

var
  LenSrc : Byte;

begin
  LenSrc := Length(PShortString(SSrc)^);

  if (LenSrc < Len) then
    Len := LenSrc;

  Move(SSrc^, SDest^, Len + 1);

  if (LenSrc > Len) then
    PChar(SDest)^ := Char(Len);
end;


procedure fpc_shortstr_concat(var DestStr : ShortString; const Src1, Src2 : ShortString);
  register; compilerproc;
  alias : 'FPC_SHORTSTR_CONCAT';

var
  LenSrc1, LenSrc2, LenDest : LongInt;

begin
  LenSrc1 := Length(Src1);
  LenSrc2 := Length(Src2);
  LenDest := High(DestStr);

  if ((LenSrc1 + LenSrc2) > LenDest) then
    LenSrc2 := LenDest - LenSrc1;

  if (@DestStr = @Src1) then
    // Somente adiciona
    Move(Src2[1], DestStr[LenSrc1 + 1], LenSrc2)
  else
    if (@DestStr = @Src2) then
    begin
      // Copia para cima e adiciona
      Move(DestStr[1], DestStr[LenSrc1 + 1], LenSrc2);
      Move(Src1[1], DestStr[1], LenSrc1);
    end
    else
    begin
      Move(Src1[1], DestStr[1], LenSrc1);
      Move(Src2[1], DestStr[LenSrc1 + 1], LenSrc2);
    end;

  DestStr[0] := Char(LenSrc1 + LenSrc2);
end;

procedure fpc_shortstr_concat_multi(var DestStr : ShortString; const SrcArr : array of PShortString);
  register; compilerproc;
  alias : 'FPC_SHORTSTR_CONCAT_MULTI';
var
  TempStr : ShortString;
  I : LongInt;

begin
  if (High(SrcArr) = 0) then
    DestStr := ''
  else
  begin
    TempStr := '';

    for I := Low(SrcArr) to High(SrcArr) do
    begin
      if (Length(TempStr) >= High(DestStr)) then
        Break;

      TempStr := TempStr + SrcArr[I]^;
    end;

    DestStr := TempStr;
  end;
end;


function fpc_shortstr_compare_equal(const StrLeft, StrRight : ShortString) : LongInt;
  register; compilerproc;
  alias:'FPC_SHORTSTR_COMPARE_EQUAL';

begin
  Result := LongInt(StrLeft[0]) - LongInt(StrRight[0]);

  if (Result = 0) then
    Result := CompareByte(StrLeft[1], StrRight[1], LongInt(StrLeft[0]));

  // 0 := True;
end;


procedure fpc_shortstr_to_shortstr(out Res: ShortString; const SSrc: ShortString);
  register; compilerproc;
  alias : 'FPC_SHORTSTR_TO_SHORTSTR';

var
  LenSrc : SmallInt;

begin
  LenSrc := Length(SSrc);

  { Da "Warning: unreachable code" porque High(Res) sempre da 255, o limite do byte,
  * e o compilador otimiza if LenSrc > 255 then -> if false then, eliminando o codigo}

  if LenSrc > High(Res) then
    LenSrc := High(Res);

  Move(SSrc[0], Res[0], LenSrc + 1);
  Res[0] := Char(LenSrc);
end;


function fpc_val_sint_shortstr(DestSize : LongInt; const S : ShortString;
  out Error : LongInt) : LongInt; register; compilerproc;
  alias : 'FPC_VAL_SINT_SHORTSTR';
  // Essa definicao ehhh pura gambiarra, ahhh pessoal do fpc :/

var
  vPos, vLen : SmallInt;
  vNeg : Boolean;
  vBase, vDig : Byte;
  vTemp, vPrev, vNew : LongWord;

begin
  fpc_val_sint_shortstr := 0;
  Error := 1;

  vLen := Length(S);
  vPos := InitVal(S, vNeg, vBase);

  if (vPos > vLen) then
    Exit;

  if (S[vPos] = #0) then
  begin
    if (vPos > 1) and (S[vPos - 1] = '0') then
      Error := 0;

    Exit;
  end;

  vTemp := 0;

  while (vPos <= vLen) do
  begin
    case S[vPos] of
      '0'..'9' : vDig := Ord(S[vPos]) - Ord('0');
      'A'..'F' : vDig := Ord(S[vPos]) - Ord('A') + 10;
      'a'..'f' : vDig := Ord(S[vPos]) - Ord('a') + 10;
      #0 : Break;
    else
      vDig := 16;
    end;

    vPrev := vTemp;
    vTemp := vTemp * vBase;
    vNew := vTemp + vDig;

    if (vDig >= vBase) or (vTemp < vPrev) or (vNew < vPrev) then
      Exit;

    vTemp := vNew;
    Inc(vPos);
  end;

  if vNeg then
    fpc_val_sint_shortstr := LongInt(0 - vTemp)
  else
    fpc_val_sint_shortstr := LongInt(vTemp);

  if (vNeg and (fpc_val_sint_shortstr > 0)) or
     (not vNeg and (fpc_val_sint_shortstr < 0)) then
  begin
    fpc_val_sint_shortstr := 0;
    Exit;
  end;

  case DestSize of
    1 : fpc_val_sint_shortstr := ShortInt(fpc_val_sint_shortstr);
    2 : fpc_val_sint_shortstr := SmallInt(fpc_val_sint_shortstr);
  end;

  Error := 0;
end;


procedure fpc_chararray_to_shortstr(out Res : ShortString;
  const Arr: array of char; ZeroBased : Boolean = true);
  register; compilerproc;
  alias:'FPC_CHARARRAY_TO_SHORTSTR';

var
  Len : LongInt;
  I : LongInt;

begin
  Len := High(Arr) + 1;

  if (Len > High(Res)) then
    Len := High(Res)
  else
    if (Len < 0) then
      Len := 0;

  if ZeroBased then
    for I := 0 to (Len - 1) do
      if (Arr[I] = #0) then
      begin
        Len := I;
        Break;
      end;

  Move(Arr[0], Res[1], Len);
  Res[0] := Char(Len);
end;


function fpc_pchar_length(P : PChar) : LongInt; compilerproc;
  alias : 'FPC_PCHAR_LENGTH';
var
  I : LongInt;

begin
  I := 0;

  if Assigned(P) then
    while (P[I] <> #0) do
      Inc(I);

  fpc_pchar_length := I;
end;


procedure fpc_pchar_to_shortstr(out Res : ShortString; P : PChar); register; compilerproc;
  alias : 'FPC_PCHAR_TO_SHORTSTR';
var
  vLen : LongInt;
  vTemp : ShortString;

begin
  vLen := StrLen(P);

  if (vLen > High(Res)) then
    vLen := High(Res);

  if (vLen > 0) then
    Move(P^, vTemp[1], vLen);

  vTemp[0] := Char(vLen);
  Res := vTemp;
end;


function InitVal(const S : ShortString; out Negative : Boolean; out Base : Byte) : LongInt;
var
  vPos, vLen : SmallInt;

begin
  vPos := 1;
  vLen := Length(S);
  Negative := False;
  Base := 10;

  if (vLen = 0) then
  begin
    InitVal := 1;
    Exit
  end;

  while (vPos <= vLen) and (S[vPos] in [' ', #9]) do
    Inc(vPos);

  case s[vPos] of
    '-' :
      begin
        Negative := True;
        Inc(vPos);
      end;

    '+' : Inc(vPos);
  end;

  if (vPos <= vLen) then
    case S[vPos] of
      '$', 'X', 'x' :
        begin
          Base := 16;
          Inc(vPos);
        end;

      '%' :
        begin
          Base := 2;
          Inc(vPos);
        end;

      '&' :
        begin
          Base := 8;
          Inc(vPos);
        end;

      '0' :
        if (vPos < vLen) and (S[vPos + 1] in ['x', 'X']) then
        begin
          Base := 16;
          Inc(vPos, 2);
        end;
    end;

  while (vPos < vLen) and (S[vPos] = '0') do
    Inc(vPos);

  InitVal := vPos;
end;


end.
