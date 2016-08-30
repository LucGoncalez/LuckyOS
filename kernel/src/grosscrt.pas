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
  Unit GrossCRT.pas
  --------------------------------------------------------------------------
  Unit de controle simples para o video. Com procedimentos bem grosseiros...
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 07/05/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc grosscrt.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit GrossCRT; // Bruto, grosseiro..

interface

const
  // Cores de frente do video
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;
  // Cores de fundo
  BgBlack       = 0 * $10;
  BgBlue        = 1 * $10;
  BgGreen       = 2 * $10;
  BgCyan        = 3 * $10;
  BgRed         = 4 * $10;
  BgMagenta     = 5 * $10;
  BgBrown       = 6 * $10;
  BgGray        = 7 * $10;
  // Blink
  Blink         = $80;


  procedure GrossInit
  (
    CRTPort, CRTSeg : Word;
    CRTRows, CRTCols : Byte;
    Clean : Boolean
  );

  procedure GrossTextColor(Color : Byte);
  procedure GrossTextBackground(Color : Byte);

  procedure GrossHighVideo;
  procedure GrossLowVideo;
  procedure GrossNormVideo;

  procedure GrossClrScr;
  procedure GrossClrEol;
  procedure GrossClrLine;

  procedure GrossGotoXY(X, Y : Byte);
  function GrossWhereX : Byte;
  function GrossWhereY : Byte;

  procedure GrossLineFeed(Rows : Byte);

  procedure GrossWriteChar(C : Char);
  procedure GrossWriteStr(const S : ShortString);


var
  GrossTextAttr : Byte;


implementation


type
  TCRTChar = packed record
    Caract : Char;
    Attrib : Byte;
  end;

  PCRTMem = ^TCRTMem;
  TCRTMem = array[0..$3FFF] of TCRTChar;


var
  vCRTPort : Word;
  vCRTMem : PCRTMem;
  vCRTRows : Byte;
  vCRTCols : Byte;
  vGrossInit : Boolean = False;
  vRow, vCol : Byte;


const
  cNormAttr = LightGray;


// Procedimentos locais


procedure SetCursorPos;
var
  vPos : Word;

begin
  vPos := (vRow * vCRTCols) + vCol;

  asm
    mov cx, vPos  // pega a posicao cursor atual

    // escreve o MSB
    mov dx, vCRTPort

    mov al, $0E   // cursos MSB
    out dx, al

    mov al, ch
    inc dx
    out dx, al

    // escreve o LSB
    dec dx

    mov al, $0F   // cursor LSB
    out dx, al

    mov al, cl
    inc dx
    out dx, al
  end;
end;

procedure ScrollUp(Rows : Byte); public;
var
  nTotal : Word;
  nScroll : Word;
  nMoves : LongInt;
  vCRTChar : TCRTChar;

begin
  nTotal := vCRTRows * vCRTCols;
  nScroll := Rows * vCRTCols;
  nMoves := nTotal - nScroll;

  Move(vCRTMem^[nScroll], vCRTMem^, nMoves * 2);

  vCRTChar.Caract := #0;
  vCRTChar.Attrib := GrossTextAttr;

  FillWord(vCRTMem^[nMoves], nScroll, Word(vCRTChar));
end;

procedure CheckEOL;
begin
  if (vCol >= vCRTCols) then
  begin
    Inc(vRow, vCol div vCRTCols);
    vCol := vCol mod vCRTCols;
  end;

  if (vRow >= vCRTRows) then
  begin
    ScrollUp(vRow - vCRTRows + 1);
    vRow := vCRTRows - 1;
  end;
end;


// Procedimentos publicos


procedure GrossInit(CRTPort, CRTSeg : Word; CRTRows, CRTCols : Byte; Clean : Boolean);
begin
  // Parametros passados
  vCRTPort := CRTPort;
  vCRTMem := Pointer(CRTSeg shl 4);
  vCRTRows := CRTRows;
  vCRTCols := CRTCols;

  // Inicializacao
  GrossTextAttr := cNormAttr;
  vGrossInit := True; // terminou a inicializacao

  if Clean then
    GrossClrScr
  else
  begin
    vRow := CRTRows - 1;
    GrossLineFeed(1);
  end;
end;

procedure GrossTextColor(Color : Byte);
begin
  if vGrossInit then
    GrossTextAttr := (GrossTextAttr and $70 {0111.0000}) or (Color and $8F {10001111});
end;

procedure GrossTextBackground(Color : Byte);
var
  vColor : Byte;

begin
  if vGrossInit then
  begin
    vColor := Color and $0F {0000.1111};

    if (vColor = 0) then
    begin
      vColor := Color and $70 {0111.0000};
      GrossTextAttr := (GrossTextAttr and $8F {1000.1111}) or vColor;
    end
    else
      GrossTextAttr := (GrossTextAttr and $0F {0000.1111}) or (vColor shl 4);
  end;
end;

procedure GrossHighVideo;
begin
  if vGrossInit then
    GrossTextAttr := GrossTextAttr or $08 {0000.1000};
end;

procedure GrossLowVideo;
begin
  if vGrossInit then
    GrossTextAttr := GrossTextAttr and $F7 {1111.0111};
end;

procedure GrossNormVideo;
begin
  if vGrossInit then
    GrossTextAttr := cNormAttr;
end;

procedure GrossClrScr;
var
  vCRTChar : TCRTChar;

begin
  if vGrossInit then
  begin
    vCRTChar.Caract := #0;
    vCRTChar.Attrib := GrossTextAttr;

    FillWord(vCRTMem^, vCRTRows * vCRTCols, Word(vCRTChar));

    vRow := 0;
    vCol := 0;
    SetCursorPos;
  end;
end;

procedure GrossClrEol;
var
  vPosIni : Word;
  vCount : Word;
  vCRTChar : TCRTChar;

begin
  if vGrossInit then
  begin
    vPosIni := (vRow * vCRTCols) + vCol;
    vCount := vCRTCols - vCol;

    vCRTChar.Caract := #0;
    vCRTChar.Attrib := GrossTextAttr;

    FillWord(vCRTMem^[vPosIni], vCount, Word(vCRTChar));
  end;
end;

procedure GrossClrLine;
var
  vPosIni : Word;
  vCRTChar : TCRTChar;

begin
  if vGrossInit then
  begin
    vPosIni := (vRow * vCRTCols);

    vCRTChar.Caract := #0;
    vCRTChar.Attrib := GrossTextAttr;

    FillWord(vCRTMem^[vPosIni], vCRTCols, Word(vCRTChar));

    vCol := 0;
    SetCursorPos;
  end;
end;

procedure GrossGotoXY(X, Y : Byte);
begin
  if vGrossInit then
  begin
    vCol := X - 1;
    vRow := Y - 1;

    CheckEOL;
    SetCursorPos;
  end;
end;

function GrossWhereX : Byte;
begin
  if vGrossInit then
    GrossWhereX := vCol + 1
  else
    GrossWhereX := 0;
end;

function GrossWhereY : Byte;
begin
  if vGrossInit then
    GrossWhereY := vRow + 1
  else
    GrossWhereY := 0;
end;

procedure GrossLineFeed(Rows : Byte);
begin
  if vGrossInit then
  begin
    vRow := vRow + Rows;
    vCol := 0;

    CheckEOL;
    SetCursorPos;
  end;
end;

procedure GrossWriteChar(C : Char);
var
  vCRTChar : TCRTChar;

begin
  if vGrossInit then
  begin
    vCRTChar.Caract := C;
    vCRTChar.Attrib := GrossTextAttr;

    vCRTMem^[(vRow * vCRTCols) + vCol] := vCRTChar;
  end;
end;

procedure GrossWriteStr(const S : ShortString);
var
  Len, I : Byte;
  vCRTChar : TCRTChar;

begin
  if vGrossInit then
  begin
    Len := Length(S);
    vCRTChar.Attrib := GrossTextAttr;

    for I := 1 to Len do
    begin
      vCRTChar.Caract := s[I];
      vCRTMem^[(vRow * vCRTCols) + vCol] := vCRTChar;
      Inc(vCol);
      CheckEOL;
    end;

    SetCursorPos;
  end;
end;


end.
