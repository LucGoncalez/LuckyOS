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
  Unit ConsoleIO.pas
  --------------------------------------------------------------------------
  Biblioteca de procedimentos de consoles.
  --------------------------------------------------------------------------
  Versao: 0.3.1
  Data: 25/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc consoleio.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit ConsoleIO;

interface

uses TTYsDef;

  { Procedimentos de inicialização }
  function  CAssign(FD : SInt) : Boolean;
  function  CRelease(CID : SInt) : Boolean;
  procedure CReset(CID : SInt);
  function  CGetType(CID : SInt) : TttyType;

  { Procedimentos Gerais }
  procedure CSetInModeRaw(CID : SInt; Raw : Boolean);
  function  CGetInModeRaw(CID : SInt) : Boolean;
  procedure CSetOutModeRaw(CID : SInt; Raw : Boolean);
  function  CGetOutModeRaw(CID : SInt) : Boolean;

  // Procedimentos para TTY-out
  procedure CSetCursor(CID : SInt; CurrType : TttyCurrType);
  function  CGetCursor(CID : SInt) : TttyCurrType;

  procedure CSetRows(CID : SInt; Rows : Byte);
  function  CGetRows(CID : SInt) : Byte;
  procedure CSetCols(CID : SInt; Cols : Byte);
  function  CGetCols(CID : SInt) : Byte;

  procedure CSetColor(CID : SInt; Color : Byte);
  function  CGetColor(CID : SInt) : Byte;
  procedure CSetBackground(CID : SInt; Color : Byte);
  function  CGetBackground(CID : SInt) : Byte;

  procedure CSetHighVideo(CID : SInt);
  procedure CSetLowVideo(CID : SInt);
  procedure CSetNormVideo(CID : SInt);

  procedure CClrScr(CID : SInt);
  procedure CClrEol(CID : SInt);
  procedure CClrLine(CID : SInt);

  { Sem suporte no terminal ainda
  procedure CDelLine(CID : SInt);
  procedure CInsLine(CID : SInt);
  }

  procedure CGotoXY(CID : SInt; X, Y : Byte);
  function  CWhereX(CID : SInt) : Byte;
  function  CWhereY(CID : SInt) : Byte;

  procedure CLineFeed(CID : SInt; Rows : Byte);

  procedure CWrite(CID : SInt; C : Char);
  procedure CWrite(CID : SInt; I : LongInt);
  procedure CWrite(CID : SInt; W : LongWord);
  procedure CWrite(CID : SInt; P : Pointer);
  procedure CWrite(CID : SInt; B : Boolean);
  procedure CWrite(CID : SInt; const S : ShortString);

  procedure CWriteln(CID : SInt; C : Char);
  procedure CWriteln(CID : SInt; I : LongInt);
  procedure CWriteln(CID : SInt; W : LongWord);
  procedure CWriteln(CID : SInt; P : Pointer);
  procedure CWriteln(CID : SInt; B : Boolean);
  procedure CWriteln(CID : SInt; const S : ShortString);

  // Procedimentos para TTY-in
  // function  CSendCommand(CID : SInt; const Command : ShortString) : ShortString;
  // function  CRead(CID : SInt) : ShortString;
  // function  CReadln(CID : SInt) : ShortString;

  { Procedimentos para StdOut }
  procedure CSetCursor(CurrType : TttyCurrType);
  function  CGetCursor : TttyCurrType;

  procedure CSetRows(Rows : Byte);
  function  CGetRows : Byte;
  procedure CSetCols(Cols : Byte);
  function  CGetCols : Byte;

  procedure CSetColor(Color : Byte);
  function  CGetColor : Byte;
  procedure CSetBackground(Color : Byte);
  function  CGetBackground : Byte;

  procedure CSetHighVideo;
  procedure CSetLowVideo;
  procedure CSetNormVideo;

  procedure CClrScr;
  procedure CClrEol;
  procedure CClrLine;

  { Sem suporte no terminal ainda
  procedure CDelLine;
  procedure CInsLine;
  }

  procedure CGotoXY(X, Y : Byte);
  function  CWhereX : Byte;
  function  CWhereY : Byte;

  procedure CLineFeed(Rows : Byte);

  procedure CWrite(C : Char);
  procedure CWrite(I : LongInt);
  procedure CWrite(W : LongWord);
  procedure CWrite(P : Pointer);
  procedure CWrite(B : Boolean);
  procedure CWrite(const S : ShortString);

  procedure CWriteln;
  procedure CWriteln(C : Char);
  procedure CWriteln(I : LongInt);
  procedure CWriteln(W : LongWord);
  procedure CWriteln(P : Pointer);
  procedure CWriteln(B : Boolean);
  procedure CWriteln(const S : ShortString);

  { Procedimentos para StdIn }
  // function  CSendCommand(const Command : ShortString) : ShortString;
  // function  CRead : ShortString;
  // function  CReadln : ShortString;


implementation


uses SysUtils, StdLib, StdIO, TinyStrScanner, ErrorsDef;


type
  PTTYInfo = ^TTTYInfo;
  TTTYInfo = record
    Opened : Boolean;
    TermType : TttyType;
    InModeRaw, OutModeRaw : Boolean;
    Cursor : TttyCurrType;
    TextColor, BackColor : Byte;
    Rows, Cols : Byte;
    X, Y : Byte;
    WriteBuffer : ShortString;
    ReadBuffer : array[0..1] of ShortString;
  end;


const
  cTTYInfoNulStdFile : TTTYInfo =
  (
    Opened : False;
    TermType : [ttFile];
    InModeRaw : True;
    OutModeRaw : True;
    Cursor : ctUnder;
    TextColor : 0;
    BackColor : 0;
    Rows : 0;
    Cols : 0;
    X : 0;
    Y : 0;
    WriteBuffer : '';
    ReadBuffer : ('', '');
  );

  cFirstTTY = 0;
  cLastTTY = StdTTYs - 1;

  cTrueStr = 'TRUE';
  cFalseStr = 'FALSE';


var
  vAutoFlush : Boolean;
  vInitialized : Boolean = False;
  vTTYArray : array[cFirstTTY..cLastTTY] of TTTYInfo;


{ Procedimentos internos (forward) }
  procedure InitLib; forward;

  function  IsOpen(CID : SInt) : Boolean; forward;
  function  IsFile(CID : SInt) : Boolean; forward;

  procedure CheckOpen(CID : SInt); forward;
  procedure CheckIn(CID : SInt); forward;
  procedure CheckOut(CID : SInt); forward;

  function  TTYRead(CID : SInt) : ShortString; forward;
  procedure TTYWrite(CID : SInt; const Value : ShortString); forward;
  procedure TTYFlush(CID : SInt; Force : Boolean); forward;

  procedure TTYSendCommand(CID : SInt; const Command : ShortString; Flush : Boolean); forward;

  procedure TTYProcessReply(CID : SInt); forward;
  procedure TTYParseReply(CID : SInt; const Reply : ShortString); forward;


{ Procedimentos de inicialização }
function CAssign(FD : SInt) : Boolean;
begin
  if IsOpen(FD) then
    Exit(False);

  vTTYArray[FD].Opened := True; // Reset so funciona se aberto
  CReset(FD);

  CAssign := True;
end;

function CRelease(CID : SInt) : Boolean;
begin
  if not IsOpen(CID) then
    Exit(False);

  vTTYArray[CID].Opened := False; // O resto é feito ao abrir

  CRelease := True;
end;

procedure CReset(CID : SInt);
var
  vTTYInfo : PTTYInfo;
  vTemp : ShortString;
  vRes : SInt;

begin
  CheckOpen(CID);

  vTTYInfo := @vTTYArray[CID];
  vTTYInfo^ := cTTYInfoNulStdFile; // Considera que seja um arquivo
  vTTYInfo^.Opened := True;

  // Verifica se é um terminal ou arquivo
  vTemp := NUL + ENQ;
  vRes := Length(vTemp);

  if (FWrite(CID, vTemp[1], vRes) <> vRes) then
    Abort(ERROR_CTTY_BROKEN_TTY, UI_CONSOLEIO, FI_CRESET,
      {$I %FILE%}, {$I %LINE%}, 'Comunicacao com o terminal foi interrompida!');

  vRes := FRead(CID, vTemp[1], High(vTemp));

  if (vRes < 0) then
    Abort(ERROR_CTTY_BROKEN_TTY, UI_CONSOLEIO, FI_CRESET,
      {$I %FILE%}, {$I %LINE%}, 'Comunicacao com o terminal foi interrompida!');

  Byte(vTemp[0]) := vRes;

  if (vTemp = ACK) then
  begin
    // Nao eh arquivo
    vTTYInfo^.TermType := [ttOutput, ttInput];

    // Reseta o terminal e obtem parametros
    vTemp := ESC + '[/' + cCmdReset + '/;/' + cCmdInfo + '/]';

    TTYSendCommand(CID, vTemp, True);
    TTYProcessReply(CID);
  end
  else
    // Eh arquivo, nao faz mais nada
    if (Length(vTemp) > 0) then
      vTTYInfo^.ReadBuffer[0] := vTemp;
end;


function CGetType(CID : SInt) : TttyType;
begin
  if IsOpen(CID) then
    CGetType := vTTYArray[CID].TermType
  else
    CGetType := []; // Vazio indica fechado
end;


{ Procedimentos Gerais }
procedure CSetInModeRaw(CID : SInt; Raw : Boolean);
begin
  if not IsFile(CID) then
  begin
    CheckIn(CID);

    if Raw then
      TTYSendCommand(CID, DC2, True) // Ativa o modo de leitura raw
    else
      TTYSendCommand(CID, DC4, True); // Ativa o modo processado

    vTTYArray[CID].InModeRaw := Raw;
  end;
end;

function  CGetInModeRaw(CID : SInt) : Boolean;
begin
  if IsFile(CID) then
    CGetInModeRaw := True // Arquivo sempre eh raw
  else
  begin
    CheckIn(CID);
    CGetInModeRaw := vTTYArray[CID].InModeRaw;
  end;
end;

procedure CSetOutModeRaw(CID : SInt; Raw : Boolean);
begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    if Raw then
      TTYWrite(CID, NUL+DLE) // Ativa o modo Raw (Nul eh para garantir)
    else
      TTYWrite(CID, NUL); // Desativa o modo Raw

    TTYFlush(CID, False);

    vTTYArray[CID].OutModeRaw := Raw;
  end;
end;

function  CGetOutModeRaw(CID : SInt) : Boolean;
begin
  if IsFile(CID) then
    CGetOutModeRaw := True // Arquivo sempre eh raw
  else
  begin
    CheckOut(CID);
    CGetOutModeRaw := vTTYArray[CID].OutModeRaw;
  end;
end;

// Procedimentos para TTY-out
procedure CSetCursor(CID : SInt; CurrType : TttyCurrType);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[D' + IntToStr(LongWord(CurrType)) + ']';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

function  CGetCursor(CID : SInt) : TttyCurrType;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CGetCursor := ctHidden // Arquivo retorna oculto
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[D?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CGetCursor := vTTYArray[CID].Cursor;
  end;
end;


procedure CSetRows(CID : SInt; Rows : Byte);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[R' + IntToStr(Rows) + ']';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

function  CGetRows(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CGetRows := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[R?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CGetRows := vTTYArray[CID].Rows;
  end;
end;

procedure CSetCols(CID : SInt; Cols : Byte);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[C' + IntToStr(Cols) + ']';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

function  CGetCols(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CGetCols := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[C?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CGetCols := vTTYArray[CID].Cols;
  end;
end;


procedure CSetColor(CID : SInt; Color : Byte);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    if (Color < cColors) then
    begin
      vCommand := ESC + '[F' + IntToStr(Color) + ']';
      TTYSendCommand(CID, vCommand, False);
    end;
  end;
end;

function  CGetColor(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CGetColor := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[F?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CGetColor := vTTYArray[CID].TextColor;
  end;
end;

procedure CSetBackground(CID : SInt; Color : Byte);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    if (Color < cColors) then
    begin
      vCommand := ESC + '[B' + IntToStr(Color) + ']';
      TTYSendCommand(CID, vCommand, False);
    end;
  end;
end;

function  CGetBackground(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CGetBackground := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[B?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CGetBackground := vTTYArray[CID].BackColor;
  end;
end;


procedure CSetHighVideo(CID : SInt);
var
  vColor : Byte;
  vBlink : Boolean;

begin
  if not IsFile(CID) then
  begin
    vColor := CGetColor(CID);
    vBlink := (vColor >= Blink);

    if vBlink then
      vColor := vColor - Blink;

    if (vColor < HighColor) then
      vColor := vColor + HighColor;

    if vBlink then
      vColor := vColor + Blink;

    CSetColor(CID, vColor);
  end;
end;

procedure CSetLowVideo(CID : SInt);
var
  vColor : Byte;
  vBlink : Boolean;

begin
  if not IsFile(CID) then
  begin
    vColor := CGetColor(CID);
    vBlink := (vColor >= Blink);

    if vBlink then
      vColor := vColor - Blink;

    if (vColor >= HighColor) then
      vColor := vColor - HighColor;

    if vBlink then
      vColor := vColor + Blink;

    CSetColor(CID, vColor);
  end;
end;

procedure CSetNormVideo(CID : SInt);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[B' + IntToStr(cNormBackground) +
      ';F' + IntToStr(cNormTextColor) + ']';

    TTYSendCommand(CID, vCommand, False);
  end;
end;


procedure CClrScr(CID : SInt);
begin
  if IsFile(CID) then
  begin
    TTYWrite(CID, LF); // Em arquivo simplemente envia uma nova linha
    TTYFlush(CID, False);
  end
  else
  begin
    CheckOut(CID);
    TTYSendCommand(CID, FF, False);
  end;
end;

procedure CClrEol(CID : LongInt);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[/' + cCmdClrEol + '/]';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

procedure CClrLine(CID : SInt);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := CR + ESC + '[/' + cCmdClrEol + '/]';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

{ Sem suporte no terminal ainda

procedure CDelLine(CID : SInt);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[/' + cCmdDelLine + '/]';

    TTYSendCommand(CID, vCommand, False);
  end;
end;

procedure CInsLine(CID : SInt);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    vCommand := ESC + '[/' + cCmdInsLine + '/]';

    TTYSendCommand(CID, vCommand, False);
  end;
end;
}

procedure CGotoXY(CID : SInt; X, Y : Byte);
var
  vCommand : ShortString;

begin
  if not IsFile(CID) then
  begin
    CheckOut(CID);

    if (X > 0) and (X <= vTTYArray[CID].Cols) and
       (Y > 0) and (Y <= vTTYArray[CID].Rows) then
    begin
      vCommand := ESC + '[X' + IntToStr(X) + ';Y' + IntToStr(Y) + ']';
      TTYSendCommand(CID, vCommand, False);
    end;
  end;
end;

function  CWhereX(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CWhereX := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[X?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CWhereX := vTTYArray[CID].X;
  end;
end;

function  CWhereY(CID : SInt) : Byte;
var
  vCommand : ShortString;

begin
  if IsFile(CID) then
    CWhereY := 0 // Arquivo retorna zero
  else
  begin
    CheckOut(CID);

    vCommand := ESC + '[Y?]';
    TTYSendCommand(CID, vCommand, True);
    TTYProcessReply(CID);

    CWhereY := vTTYArray[CID].Y;
  end;
end;


procedure CLineFeed(CID : SInt; Rows : Byte);
var
  vTemp : ShortString;
  I : Byte;

begin
  if (Rows > 0) then
  begin
    vTemp := '';

    for I := 1 to Rows do
      vTemp := vTemp + LF;

    if IsFile(CID) then
    begin
      TTYWrite(CID, vTemp); // Em arquivo envia quebra de linha normalmente
      TTYFlush(CID, False);
    end
    else
    begin
      CheckOut(CID);
      TTYSendCommand(CID, vTemp, False);
    end;
  end;
end;


procedure CWrite(CID : SInt; C : Char);
var
  vTemp : ShortString;

begin
  vTemp := C;
  CWrite(CID, vTemp);
end;

procedure CWrite(CID : SInt; I : LongInt);
begin
  CWrite(CID, IntToStr(I));
end;

procedure CWrite(CID : SInt; W : LongWord);
begin
  CWrite(CID, IntToStr(W));
end;

procedure CWrite(CID : SInt; P : Pointer);
begin
  CWrite(CID, IntToHexX(LongWord(P), 8));
end;

procedure CWrite(CID : SInt; B : Boolean);
begin
  if B then
    CWrite(CID, cTrueStr)
  else
    CWrite(CID, cFalseStr);
end;

procedure CWrite(CID : SInt; const S : ShortString);
begin
  CheckOut(CID);

  TTYWrite(CID, S);

  TTYFlush(CID, False);
end;


procedure CWriteln(CID : SInt; C : Char);
var
  vTemp : ShortString;

begin
  vTemp := C;
  CWriteln(CID, vTemp);
end;

procedure CWriteln(CID : SInt; I : LongInt);
begin
  CWriteln(CID, IntToStr(I));
end;

procedure CWriteln(CID : SInt; W : LongWord);
begin
  CWriteln(CID, IntToStr(W));
end;

procedure CWriteln(CID : SInt; P : Pointer);
begin
  CWriteln(CID, IntToHexX(LongWord(P), 8));
end;

procedure CWriteln(CID : SInt; B : Boolean);
begin
  if B then
    CWriteln(CID, cTrueStr)
  else
    CWriteln(CID, cFalseStr);
end;

procedure CWriteln(CID : SInt; const S : ShortString);
var
  vOldFlush : Boolean;

begin
  CheckOut(CID);

  vOldFlush := vAutoFlush;
  vAutoFlush := False;

  CWrite(CID, S);
  CLineFeed(CID, 1);

  vAutoFlush := vOldFlush;
  TTYFlush(CID, False);
end;


{ Procedimentos para StdOut }
procedure CSetCursor(CurrType : TttyCurrType);
begin
  CSetCursor(StdOut, CurrType);
end;

function  CGetCursor : TttyCurrType;
begin
  CGetCursor := CGetCursor(StdOut);
end;


procedure CSetRows(Rows : Byte);
begin
  CSetRows(StdOut, Rows);
end;

function  CGetRows : Byte;
begin
  CGetRows := CGetRows(StdOut);
end;

procedure CSetCols(Cols : Byte);
begin
  CSetCols(StdOut, Cols);
end;

function  CGetCols : Byte;
begin
  CGetCols := CGetCols(StdOut);
end;


procedure CSetColor(Color : Byte);
begin
  CSetColor(StdOut, Color);
end;

function  CGetColor : Byte;
begin
  CGetColor := CGetColor(StdOut);
end;

procedure CSetBackground(Color : Byte);
begin
  CSetBackground(StdOut, Color);
end;

function  CGetBackground : Byte;
begin
  CGetBackground := CGetBackground(StdOut);
end;


procedure CSetHighVideo;
begin
  CSetHighVideo(StdOut);
end;

procedure CSetLowVideo;
begin
  CSetLowVideo(StdOut);
end;

procedure CSetNormVideo;
begin
  CSetNormVideo(StdOut);
end;


procedure CClrScr;
begin
  CClrScr(StdOut);
end;

procedure CClrEol;
begin
  CClrEol(StdOut);
end;

procedure CClrLine;
begin
  CClrLine(StdOut);
end;

{ Sem suporte no terminal ainda
procedure CDelLine;
begin
  CDelLine(StdOut);
end;

procedure CInsLine;
begin
  CInsLine(StdOut);
end;
}

procedure CGotoXY(X, Y : Byte);
begin
  CGotoXY(StdOut, X, Y);
end;

function  CWhereX : Byte;
begin
  CWhereX := CWhereX(StdOut);
end;

function  CWhereY : Byte;
begin
  CWhereY := CWhereY(StdOut);
end;


procedure CLineFeed(Rows : Byte);
begin
  CLineFeed(StdOut, Rows);
end;


procedure CWrite(C : Char);
begin
  CWrite(StdOut, C);
end;

procedure CWrite(I : LongInt);
begin
  CWrite(StdOut, I);
end;

procedure CWrite(W : LongWord);
begin
  CWrite(StdOut, W);
end;

procedure CWrite(P : Pointer);
begin
  CWrite(StdOut, P);
end;

procedure CWrite(B : Boolean);
begin
  CWrite(StdOut, B);
end;

procedure CWrite(const S : ShortString);
begin
  CWrite(StdOut, S);
end;


procedure CWriteln;
begin
  CLineFeed(StdOut, 1);
end;

procedure CWriteln(C : Char);
begin
  CWriteln(StdOut, C);
end;

procedure CWriteln(I : LongInt);
begin
  CWriteln(StdOut, I);
end;

procedure CWriteln(W : LongWord);
begin
  CWriteln(StdOut, W);
end;

procedure CWriteln(P : Pointer);
begin
  CWriteln(StdOut, P);
end;

procedure CWriteln(B : Boolean);
begin
  CWriteln(StdOut, B);
end;

procedure CWriteln(const S : ShortString);
begin
  CWriteln(StdOut, S);
end;



// Procedimentos internos

procedure InitLib;
var
  I : SInt;

begin
  if not vInitialized then
  begin
    // Inicializa o array dos TTYs
    for I := cFirstTTY to cLastTTY do
      vTTYArray[I] := cTTYInfoNulStdFile;

    vInitialized := True;
    vAutoFlush := True; // Faz o flush a cada chamada
  end;
end;


function  IsOpen(CID : SInt) : Boolean;
begin
  if not vInitialized then
    InitLib;

  if (CID < cFirstTTY) or (CID > cLastTTY) then
    Abort(ERROR_CTTY_INVALID_CID, UI_CONSOLEIO, FI_ISOPEN,
      {$I %FILE%}, {$I %LINE%}, 'O CID fornecido nao eh um terminal valido!');

  IsOpen := vTTYArray[CID].Opened;
end;

function IsFile(CID : SInt) : Boolean;
begin
  CheckOpen(CID);

  IsFile := (ttFile in vTTYArray[CID].TermType);
end;


procedure CheckOpen(CID : SInt);
begin
  if not IsOpen(CID) then
    Abort(ERROR_CTTY_CLOSED_TTY, UI_CONSOLEIO, FI_CHECKOPEN,
      {$I %FILE%}, {$I %LINE%}, 'O CID fornecido nao eh um terminal aberto!');
end;

procedure CheckIn(CID : SInt);
begin
  CheckOpen(CID);

  if (not (ttFile in vTTYArray[CID].TermType)) and
     (not (ttInput in vTTYArray[CID].TermType)) then
    Abort(ERROR_CTTY_ISNOT_INPUT, UI_CONSOLEIO, FI_CHECKIN,
      {$I %FILE%}, {$I %LINE%}, 'O CID fornecido nao eh um terminal entrada!');
end;

procedure CheckOut(CID : SInt);
begin
  CheckOpen(CID);

  if (not (ttFile in vTTYArray[CID].TermType)) and
     (not (ttOutput in vTTYArray[CID].TermType)) then
    Abort(ERROR_CTTY_ISNOT_OUTPUT, UI_CONSOLEIO, FI_CHECKOUT,
      {$I %FILE%}, {$I %LINE%}, 'O CID fornecido nao eh um terminal saida!');
end;


function  TTYRead(CID : SInt) : ShortString;
var
  vBuffer0, vBuffer1 : PShortString;
  vRes : SInt;

begin
  vBuffer0 := @vTTYArray[CID].ReadBuffer[0];
  vBuffer1 := @vTTYArray[CID].ReadBuffer[1];

  // Tenta juntar os buffers
  if ((Length(vBuffer0^) + Length(vBuffer1^)) <= High(vBuffer0^)) then
  begin
    // Se buffer0 e buffer1 cabem em um so
    vBuffer0^ := vBuffer0^ + vBuffer1^;
    vBuffer1^ := '';
  end;

  // Se buffer0 for vazio, buffer1 tambem eh

  if (Length(vBuffer0^) = 0) then
  begin
    vRes := FRead(CID, vBuffer0^[1], High(vBuffer0^));

    if (vRes < 0) then
      Abort(ERROR_CTTY_BROKEN_TTY, UI_CONSOLEIO, FI_TTYREAD,
        {$I %FILE%}, {$I %LINE%}, 'Comunicacao com o terminal foi interrompida!');

    Byte(vBuffer0^[0]) := vRes;
  end;

  TTYRead := vBuffer0^;

  if (Length(vBuffer1^) = 0) then
    vBuffer0^ := ''
  else
  begin
    vBuffer0^ := vBuffer1^;
    vBuffer1^ := '';
  end;
end;

procedure TTYWrite(CID : SInt; const Value : ShortString);
var
  vBuffer : PShortString;
  vFree : Byte;

begin
  vBuffer := @vTTYArray[CID].WriteBuffer;
  vFree := High(vBuffer^) - Length(vBuffer^);

  if (Length(Value) > vFree) then
  begin
    // Value nao cabe no buffer
    TTYFlush(CID, True);
    vBuffer^ := Value;
  end
  else
    vBuffer^ := vBuffer^ + Value;
end;

procedure TTYFlush(CID : SInt; Force : Boolean);
var
  vBuffer : PShortString;
  vSize : Byte;

begin
  vBuffer := @vTTYArray[CID].WriteBuffer;
  vSize := Length(vBuffer^);

  if (vSize > 0) and (vAutoFlush or Force) then
  begin
    // Faz o flush
    if (FWrite(CID, vBuffer^[1], vSize) <> vSize) then
      Abort(ERROR_CTTY_BROKEN_TTY, UI_CONSOLEIO, FI_TTYFLUSH,
        {$I %FILE%}, {$I %LINE%}, 'Comunicacao com o terminal foi interrompida!');

    vBuffer^ := '';
  end;
end;


procedure TTYSendCommand(CID : SInt; const Command : ShortString; Flush : Boolean);
var
  vOldFlush : Boolean;
  vRaw : Boolean;

begin
  if not IsFile(CID) then
  begin
    vOldFlush := vAutoFlush;
    vAutoFlush := False;

    vRaw := CGetOutModeRaw(CID);

    if vRaw then
      CSetOutModeRaw(CID, False);

    // Comandos sao sempre enviados para o modo processado
    TTYWrite(CID, Command);

    if vRaw then
      CSetOutModeRaw(CID, True);

    vAutoFlush := vOldFlush;
    TTYFlush(CID, Flush);
  end;
end;


procedure TTYProcessReply(CID : SInt);
var
  vReply, vNorm : ShortString;
  vLen, I : SInt;
  vBuffer0, vBuffer1 : PShortString;

begin
  vReply := '';
  vLen := FRead(CID, vReply[1], High(vReply));

  if (vLen < 0) then
    Abort(ERROR_CTTY_BROKEN_TTY, UI_CONSOLEIO, FI_TTYPROCESSREPLY,
      {$I %FILE%}, {$I %LINE%}, 'Comunicacao com o terminal foi interrompida!');

  Byte(vReply[0]) := vLen;

  I := 1;
  vNorm := '';

  while (I <= vLen) do
    if (vReply[I] = ESC) then
    begin
      // Sequencia de resposta ou de escape
      if (I < vLen) and (vReply[I+1] = '{') then
      begin
        // Sequencia de resposta
        Inc(I, 2); // Despreza ESC e {

        TTYParseReply(CID, GetSubStr(vReply, I, '}'));
      end
      else
        // Sequencia de escape
        if (I < vLen) then
        begin
          // Dois caracteres
          vNorm := vNorm + ESC + vReply[I+1];
          Inc(I, 2);
        end
        else
        begin
          // Somente ESC
          vNorm := vNorm + ESC;
          Inc(I);
        end;
    end
    else
    begin
      // Caracter normal
      vNorm := vNorm + vReply[I];
      Inc(I);
    end;

  vLen := Length(vNorm);

  if (vLen > 0) then
  begin
    // vNorm contem todos os caracteres que nao fazem parte de qualquer resposta
    vBuffer0 := @vTTYArray[CID].ReadBuffer[0];
    vBuffer1 := @vTTYArray[CID].ReadBuffer[1];

    if ((Length(vBuffer0^) + Length(vBuffer1^)) <= High(vBuffer0^)) then
    begin
      // Se buffer0 e buffer1 cabem em um so
      vBuffer0^ := vBuffer0^ + vBuffer1^;
      vBuffer1^ := '';
    end;

    if (Length(vBuffer1^) = 0) then
    begin
      // Se somente o Buffer0 esta sendo usado
      if ((Length(vBuffer0^) + vLen) <= High(vBuffer0^)) then
        // Cabe em Buffer0
        vBuffer0^ := vBuffer0^ + vNorm
      else
        // Nao cabe em Buffer0
        vBuffer1^ := vNorm;
    end
    else
    begin
      // Buffer1 esta sendo usado
      if ((Length(vBuffer1^) + vLen) <= High(vBuffer1^)) then
        // Cabe em Buffer1
        vBuffer1^ := vBuffer1^ + vNorm
      else
      begin
        // Nao cabe em Buffer1 despreza Buffer0
        vBuffer0^ := vBuffer1^;
        vBuffer1^ := vNorm;
      end;
    end;
  end;
end;

procedure TTYParseReply(CID : SInt; const Reply : ShortString);
var
  vTTYInfo : PTTYInfo;
  vLen, I : SInt;
  vTermType : TttyType;
  vInt : SInt;

begin
  vTTYInfo := @vTTYArray[CID];
  vLen := Length(Reply);
  I := 1;

  while (I <= vLen) do
    case Reply[I] of

      ';', ' ' : Inc(I); // Separador de campos

      'B' :
        begin
          Inc(I);
          vTTYInfo^.BackColor := ReadInteger(Reply, I);
        end;

      'C' :
        begin
          Inc(I);
          vTTYInfo^.Cols := ReadInteger(Reply, I);
        end;

      'D' :
        begin
          Inc(I);
          vInt := ReadInteger(Reply, I);

          if (vInt >= Ord(Low(TttyCurrType))) and (vInt <= Ord(High(TttyCurrType))) then
            vTTYInfo^.Cursor := TttyCurrType(vInt);
        end;

      'F' :
        begin
          Inc(I);
          vTTYInfo^.TextColor := ReadInteger(Reply, I);
        end;

      'M' :
        begin
          if (I < vLen) and (Reply[I + 1] = ':') then
          begin
            Inc(I, 2); // Despreza 'M:'

            while (I < vLen) do
              case  Reply[I] of

                ',' : Inc(I);

                'i' :
                  begin
                    Inc(I);

                    case Reply[I] of

                      '0' :
                        begin
                          Inc(I);
                          vTTYInfo^.InModeRaw := True;
                        end;

                      '1' :
                        begin
                          Inc(I);
                          vTTYInfo^.InModeRaw := False;
                        end;

                    end;
                  end;

                'o' :
                  begin
                    Inc(I);

                    case Reply[I] of

                      '0' :
                        begin
                          Inc(I);
                          vTTYInfo^.OutModeRaw := True;
                        end;

                      '1' :
                        begin
                          Inc(I);
                          vTTYInfo^.OutModeRaw := False;
                        end;

                    end;

                    // O modo pode ter sido alterado, normalmente eh, depois
                    // de ter recebido esta reposta.
                    // Para garantir que o TTY esta nesse modo
                    // envia novamente o modo

                    if vTTYInfo^.OutModeRaw then
                      TTYWrite(CID, NUL+DLE)
                    else
                      TTYWrite(CID, NUL);
                  end;

              else
                Break;
              end;
          end
          else
            Abort(ERROR_CTTY_INVALID_TOKEN, UI_CONSOLEIO, FI_PARSEREPLY,
              {$I %FILE%}, {$I %LINE%}, 'O escape retornado nao eh valido!');
        end;

      'R' :
        begin
          Inc(I);
          vTTYInfo^.Rows := ReadInteger(Reply, I);
        end;

      'T' :
        begin
          if (I < vLen) and (Reply[I + 1] = ':') then
          begin
            Inc(I, 2); // Despreza 'T:'

            vTermType := [];

            while (I <= vLen) do
              case Reply[I] of

                'i' :
                  begin
                    Inc(I);
                    vTermType := vTermType + [ttInput];
                  end;

                'o' :
                  begin
                    Inc(I);
                    vTermType := vTermType + [ttOutput];
                  end;

              else
                Break;
              end;

            vTTYInfo^.TermType := vTermType;
          end
          else
            Abort(ERROR_CTTY_INVALID_TOKEN, UI_CONSOLEIO, FI_PARSEREPLY,
              {$I %FILE%}, {$I %LINE%}, 'O escape retornado nao eh valido!');
        end;

      'X' :
        begin
          Inc(I);
          vTTYInfo^.X := ReadInteger(Reply, I);
        end;

      'Y' :
        begin
          Inc(I);
          vTTYInfo^.Y := ReadInteger(Reply, I);
        end;

    else
      Abort(ERROR_CTTY_INVALID_TOKEN, UI_CONSOLEIO, FI_PARSEREPLY,
        {$I %FILE%}, {$I %LINE%}, 'O escape retornado nao eh valido!');
    end;
end;

end.
