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
  Unit KrnlTTY.pas
  --------------------------------------------------------------------------
  Unit de terminal de saida do kernel.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 10/05/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc krnltty.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit KrnlTTY;

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

  // Constantes de caracteres de controle ASCII
  NUL = #00; // ^@ Null
  SOH = #01; // ^A Start of Heading
  STX = #02; // ^B Start of Text
  ETX = #03; // ^C End of Text
  EOT = #04; // ^D End of Transmission
  ENQ = #05; // ^E Enquiry
  ACK = #06; // ^F Acknowledge
  BEL = #07; // ^G Bell
  BS  = #08; // ^H BackSpace
  HT  = #09; // ^I Horizontal tab
  TAB = #09; // ^I Alias para HT
  LF  = #10; // ^J Line Feed, new line
  VT  = #11; // ^K Vertical Tab
  FF  = #12; // ^L Form Feed, new page
  CR  = #13; // ^M Carriage Return
  SO  = #14; // ^N Shift Out
  SI  = #15; // ^O Shift In
  DLE = #16; // ^P Data Link Escape
  DC1 = #17; // ^Q Device Control 1
  DC2 = #18; // ^R Device Control 2
  DC3 = #19; // ^S Device Control 3
  DC4 = #20; // ^T Device Control 4
  NAK = #21; // ^U Negative Acknowledge
  SYN = #22; // ^V Sinchronous Idle
  ETB = #23; // ^W End of Tranference Block
  CAN = #24; // ^X Cancel
  EM  = #25; // ^Y End of Medium
  SUB = #26; // ^Z Substitute
  ESC = #27; // ^[ Escape
  FS  = #28; // ^\ File Separator
  GS  = #29; // ^] Group Separator
  RS  = #30; // ^^ Record Separator
  US  = #31; // ^_ Unit Separator
  DEL = #127; // ^? Delete


  procedure KTTYInit
  (
    CRTPort, CRTSeg : Word;
    CRTRows, CRTCols : Byte;
    Clean : Boolean
  );

  procedure KTTYTextColor(Color : Byte);
  procedure KTTYTextBackground(Color : Byte);

  procedure KTTYHighVideo;
  procedure KTTYLowVideo;
  procedure KTTYNormVideo;

  procedure KTTYClrScr;
  procedure KTTYClrEol;
  procedure KTTYClrLine;

  procedure KTTYGotoXY(X, Y : Byte);
  function KTTYWhereX : Byte;
  function KTTYWhereY : Byte;

  procedure KTTYLineFeed(Rows : Byte);

  procedure KTTYWriteStay(C : Char);

  procedure KTTYWrite(C : Char);
  procedure KTTYWrite(I : LongInt);
  procedure KTTYWrite(W : LongWord);
  procedure KTTYWrite(B : Boolean);
  procedure KTTYWrite(const S : ShortString);

{ Outros procedimentos que poderao ser uteis posteriormente

  function ScrRows : Byte;
  function ScrCols : Byte;
  procedure RawMode(Raw : Boolean);
  procedure CursorOn(Visible : Boolean);
  procedure CursorBig(Big : Boolean);
  procedure DelLine;
  procedure InsLine;
}

var
  KTTYHTSize : Byte;
  KTTYVTSize : Byte;


implementation


uses SysUtils, GrossCRT;

procedure KTTYInit(CRTPort, CRTSeg : Word; CRTRows, CRTCols : Byte; Clean : Boolean);
begin
  GrossInit(CRTPort, CRTSeg, CRTRows, CRTCols, Clean);

  KTTYHTSize := 8;
  KTTYVTSize := 4;
end;

procedure KTTYTextColor(Color : Byte);
begin
  GrossTextColor(Color);
end;

procedure KTTYTextBackground(Color : Byte);
begin
  GrossTextBackground(Color);
end;

procedure KTTYHighVideo;
begin
  GrossHighVideo;
end;

procedure KTTYLowVideo;
begin
  GrossLowVideo;
end;

procedure KTTYNormVideo;
begin
  GrossNormVideo;
end;

procedure KTTYClrScr;
begin
  GrossClrScr;
end;

procedure KTTYClrEol;
begin
  GrossClrEol;
end;

procedure KTTYClrLine;
begin
  GrossClrLine;
end;

procedure KTTYGotoXY(X, Y : Byte);
begin
  GrossGotoXY(X, Y);
end;

function KTTYWhereX : Byte;
begin
  KTTYWhereX := GrossWhereX;
end;

function KTTYWhereY : Byte;
begin
  KTTYWhereY := GrossWhereY;
end;

procedure KTTYLineFeed(Rows : Byte);
begin
  GrossLineFeed(Rows);
end;

procedure KTTYWriteStay(C : Char);
begin
  GrossWriteChar(C);
end;

procedure KTTYWrite(C : Char);
var
  Temp : ShortString;

begin
  Temp := C;

  KTTYWrite(Temp);
end;

procedure KTTYWrite(I : LongInt);
begin
  GrossWriteStr(IntToStr(I));
end;

procedure KTTYWrite(W : LongWord);
begin
  GrossWriteStr(IntToStr(W));
end;

procedure KTTYWrite(B : Boolean);
begin
  if B then
    GrossWriteStr('TRUE')
  else
    GrossWriteStr('FALSE');
end;

procedure KTTYWrite(const S : ShortString);
var
  Len : Byte;
  Temp : String;
  I : Byte;
  Pos : Byte;

  procedure DoWrite;
  begin
    if (Length(Temp) > 0) then
    begin
      GrossWriteStr(Temp);
      Temp := '';
    end;
  end;

begin
  Temp := '';
  Len := Length(S);

  for I := 1 to Len do
  begin
    case S[I] of
      // BackSpace
      BS :
        begin
          DoWrite;

          if (GrossWhereX > 1) then
          begin
            GrossGotoXY(GrossWhereX - 1, GrossWhereY);
            GrossWriteChar(#0);
          end;
        end;

      // Horizontal Tab
      HT :
        begin
          DoWrite;
          Pos := GrossWhereX - 1;

          repeat
            Temp := Temp + #32;
            Inc(Pos);
          until (Pos mod KTTYHTSize) = 0;

          DoWrite;
        end;

      // Vertical Tab
      VT :
        begin
          DoWrite;
          GrossLineFeed(KTTYVTSize);
        end;

      // Line Feed
      LF :
        begin
          DoWrite;
          GrossLineFeed(1);
        end;

      // Carriage Return
      CR :
        begin
          DoWrite;
          GrossGotoXY(1, GrossWhereY);
        end;

      // Form Feed
      FF :
        begin
          Temp := '';
          GrossClrScr;
        end;

    // Outros
    else
      Temp := Temp + S[I];
    end;

    DoWrite;
  end;

  DoWrite;
end;


end.
