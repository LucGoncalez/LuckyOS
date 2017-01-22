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
  Unit GrossTTY.pas (substitui KrnlTTY.pas)
  --------------------------------------------------------------------------
  Unit de driver de terminal.
  --------------------------------------------------------------------------
  Versao: 0.2.2
  Data: 25/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc grosstty.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit GrossTTY;

interface

  procedure  GrossTTYInit
  (
    CRTPort, CRTSeg : Word;
    CRTRows, CRTCols : Byte;
    Clean : Boolean
  );

  function  GrossTTYRead : ShortString;
  procedure GrossTTYWrite(const Value : ShortString);


implementation


uses SysUtils, StdLib, TinyStrScanner, GrossCRT, ErrorsDef, TTYsDef;


var
  vModeRaw : Boolean;
  vRows, vCols : Byte;
  vHTSize, vVTSize : Byte;
  vBufferWrite : ShortString;
  vBufferSend : array[0..1] of ShortString;


  { Procedimentos internos (forward) }
  procedure TTYReset; forward;
  procedure DoWrite; forward;
  procedure SendReply(const Value : ShortString); forward;
  procedure ProcessCommand(const S : ShortString); forward;
  procedure ExecCommand(const Command : ShortString); forward;
  procedure TTYSendInfo; forward;


  { Procedimentos externos }

procedure  GrossTTYInit
  (
    CRTPort, CRTSeg : Word;
    CRTRows, CRTCols : Byte;
    Clean : Boolean
  );
begin
  GrossInit(CRTPort, CRTSeg, CRTRows, CRTCols, Clean);

  vRows := CRTRows;
  vCols := CRTCols;

  TTYReset;
end;


function  GrossTTYRead : ShortString;
begin
  GrossTTYRead := vBufferSend[0];

  if (Length(vBufferSend[1]) = 0) then
    // Todos os buffers vazios
    vBufferSend[0] := ''
  else
  begin
    // Move o Buffer1 para o 0
    vBufferSend[0] := vBufferSend[1];
    vBufferSend[1] := '';
  end;
end;


procedure GrossTTYWrite(const Value : ShortString);
var
  vLen, I : SInt;
  vPos : Byte;

begin
  vLen := Length(Value);
  I := 1;

  while (I <= vLen) do
  begin
    if vModeRaw then
    begin
      // TTY em modo RAW
      if (Value[I] = NUL) then
      begin
        // Desativa
        DoWrite;
        vModeRaw := False;
      end
      else
        vBufferWrite := vBufferWrite + Value[I];

      Inc(I);
    end
    else
    begin
      // TTY em modo Processado

      case Value[I] of

        NUL : {#00; ^@ Null}
          Inc(I); // Despreza

        // SOH  : {#01; ^A Start of Heading} ;
        // STX  : {#02; ^B Start of Text} ;
        // ETX  : {#03; ^C End of Text} ;
        // EOT  : {#04; ^D End of Transmission} ;

        ENQ : {#05; ^E Enquiry}
          begin
            Inc(I);
            DoWrite;
            SendReply(ACK);
          end;

        // ACK  : {#06; ^F Acknowledge} ;
        // BEL  : {#07; ^G Bell} ;

        BS  : {#08; ^H BackSpace}
          begin
            Inc(I);
            DoWrite;

            if (GrossWhereX > 1) then
            begin
              // Volta na mesma linha
              GrossGotoXY(GrossWhereX - 1, GrossWhereY);
              GrossWriteChar(#0);
            end
            else
              // Volta no final da linha anterior
              if (GrossWhereY > 1) then
              begin
                GrossGotoXY(vCols, GrossWhereY - 1);
                GrossWriteChar(#0);
              end;
          end;

        HT  : {#09; ^I Horizontal tab}
          begin
            Inc(I);
            DoWrite;
            vPos := GrossWhereX - 1;

            repeat
              vBufferWrite := vBufferWrite + #32;
              Inc(vPos);
            until (vPos mod vHTSize) = 0;

            DoWrite;
          end;

        LF  : {#10; ^J Line Feed, new line}
          begin
            Inc(I);
            DoWrite;
            GrossLineFeed(1);
          end;

        VT  : {#11; ^K Vertical Tab}
          begin
            Inc(I);
            DoWrite;
            GrossLineFeed(vVTSize);
          end;

        FF  : {#12; ^L Form Feed, new page}
          begin
            Inc(I);
            vBufferWrite := '';
            GrossClrScr;
          end;

        CR  : {#13; ^M Carriage Return}
          begin
            Inc(I);
            DoWrite;
            GrossGotoXY(1, GrossWhereY);
          end;

        // SO : {#14; ^N Shift Out} ;
        // SI : {#15; ^O Shift In} ;

        DLE : {#16; ^P Data Link Escape : ORAW}
          begin
            Inc(I);
            DoWrite;
            vModeRaw := True;
          end;

        // DC1  : {#17; ^Q Device Control 1 : XON} ;
        // DC2  : {#18; ^R Device Control 2 : IRAW} ;
        // DC3  : {#19; ^S Device Control 3 : XOFF} ;
        // DC4  : {#20; ^T Device Control 4 : IPROC} ;
        // NAK  : {#21; ^U Negative Acknowledge} ;
        // SYN  : {#22; ^V Sinchronous Idle} ;
        // ETB  : {#23; ^W End of Tranference Block} ;
        // CAN  : {#24; ^X Cancel} ;
        // EM : {#25; ^Y End of Medium} ;
        // SUB  : {#26; ^Z Substitute} ;

        ESC : {#27; ^[ Escape}
          begin
            Inc(I); // Despreza ESC

            if (I <= vLen) then
              if (Value[I] = '[') then
              begin
                // Sequencia de comando
                Inc(I); // Despreza [
                DoWrite;

                ProcessCommand(GetSubStr(Value, I, ']'));
              end
              else
              begin
                // Escape de caracter simples
                vBufferWrite := vBufferWrite + Value[I];
                Inc(I);
              end;
          end;

        // FS : {#28; ^\ File Separator} ;
        // GS : {#29; ^] Group Separator} ;
        // RS : {#30; ^^ Record Separator} ;
        // US : {#31; ^_ Unit Separator} ;
        // DEL  : {#127; ^? Delete} ;

      else
        vBufferWrite := vBufferWrite + Value[I];
        Inc(I);
      end;
    end;
  end;

  DoWrite;
end;


{ Procedimentos internos (forward) }

procedure TTYReset;
begin
  vModeRaw := False;
  vBufferSend[0] := '';
  vBufferSend[1] := '';
  vBufferWrite := '';
  vHTSize := 8;
  vVTSize := 4;
end;

procedure DoWrite;
begin
  if (Length(vBufferWrite) > 0) then
  begin
    GrossWriteStr(vBufferWrite);
    vBufferWrite := '';
  end;
end;

procedure SendReply(const Value : ShortString);
begin
  if (Length(vBufferSend[1]) = 0) then
  begin
    // Somente Buffer0 esta em uso
    if ((Length(vBufferSend[0]) + Length(Value)) <= High(vBufferSend[0])) then
      // Cabe em Buffer0
      vBufferSend[0] := vBufferSend[0] + Value
    else
      // Nao cabe em Buffer0
      vBufferSend[1] := Value;
  end
  else
  begin
    // Buffer0 lotado

    if ((Length(vBufferSend[1]) + Length(Value)) <= High(vBufferSend[1])) then
      // Cabe em Buffer1
      vBufferSend[1] := vBufferSend[1] + Value
    else
    begin
      // Nao cabe em Buffer1, despreza Buffer0
      vBufferSend[0] := vBufferSend[1];
      vBufferSend[1] := Value;
    end;
  end;
end;

procedure ProcessCommand(const S : ShortString);
var
  vLen, I : SInt;
  vTemp : ShortString;

begin
  vLen := Length(S);
  I := 1;

  while (I <= vLen) do
  begin
    case S[I] of
      ';', ' ' : Inc(I);

      '/' :
        begin
          Inc(I);
          ExecCommand(GetSubStr(S, I, '/'));
        end;

      'B' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{B' + IntToStr((GrossTextAttr and $70 {0111.0000}) shr 4) + '}';
              SendReply(vTemp);
            end
            else
              GrossTextBackground(ReadInteger(S, I) and $07 {0000.0111});
        end;

      'C' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{C' + IntToStr(vCols) + '}';
              SendReply(vTemp);
            end;
        end;

      'F' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{F' + IntToStr(GrossTextAttr and $0F {0000.1111}) + '}';
              SendReply(vTemp);
            end
            else
              GrossTextColor(ReadInteger(S, I) and $0F {0000.1111});
        end;

      'R' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{R' + IntToStr(vRows) + '}';
              SendReply(vTemp);
            end;
        end;

      'X' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{X' + IntToStr(GrossWhereX) + '}';
              SendReply(vTemp);
            end
            else
              GrossGotoXY(ReadInteger(S, I), GrossWhereY);
        end;

      'Y' :
        begin
          Inc(I);

          if (I <= vLen) then
            if (S[I] = '?') then
            begin
              Inc(I);
              vTemp := ESC + '{Y' + IntToStr(GrossWhereY) + '}';
              SendReply(vTemp);
            end
            else
              GrossGotoXY(GrossWhereX, ReadInteger(S, I));
        end;

    else
      Abort(ERROR_TTY_INVALID_TOKEN, UI_GROSSTTY, FI_PROCESSCOMMAND,
        {$I %FILE%}, {$I %LINE%}, 'O escape passado nao eh valido!');
    end;
  end;
end;

procedure ExecCommand(const Command : ShortString);
begin
  if (Command = cCmdReset) then
    TTYReset
  else if (Command = cCmdInfo) then
    TTYSendInfo
  else if (Command = cCmdClrEol) then
    GrossClrEol
  { Nao suportado ainda

  else if (Command = cCmdDelLine) then
  begin

  end
  else if (Command = cCmdInsLine) then
  begin

  end
  }
  else
    Abort(ERROR_TTY_INVALID_COMMAND, UI_GROSSTTY, FI_EXECCOMMAND,
      {$I %FILE%}, {$I %LINE%}, 'O comando passado nao eh valido!');
end;

procedure TTYSendInfo;
var
  vTemp : ShortString;

begin
  vTemp := ESC + '{';

  vTemp := vTemp + 'T:o;';

  if vModeRaw then
    vTemp := vTemp + 'M:o0;'
  else
    vTemp := vTemp + 'M:o1;';

  vTemp := vTemp + 'D' + IntToStr(LongWord(ctUnder)) + ';';

  vTemp := vTemp + 'R' + IntToStr(vRows) + ';';
  vTemp := vTemp + 'C' + IntToStr(vCols) + ';';

  vTemp := vTemp + 'B' + IntToStr((GrossTextAttr and $70 {0111.0000}) shr 4) + ';';
  vTemp := vTemp + 'F' + IntToStr(GrossTextAttr and $0F {0000.1111}) + ';';

  vTemp := vTemp + 'X' + IntToStr(GrossWhereX) + ';';
  vTemp := vTemp + 'Y' + IntToStr(GrossWhereY) + ';';

  vTemp := vTemp + '}';

  SendReply(vTemp);
end;


end.
