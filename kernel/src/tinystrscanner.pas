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
  Unit TinyStrScanner.pas
  --------------------------------------------------------------------------
  Unit Scaner de strings simples.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 03/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc tinystrscanner.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit TinyStrScanner;

interface

  function GetSubStr(const S : ShortString; var Pos : SInt; Delim : Char) : ShortString;
  function ReadInteger(const S : ShortString; var Pos : SInt) : SInt;


implementation

uses SysUtils;


function GetSubStr(const S : ShortString; var Pos : SInt; Delim : Char) : ShortString;
var
  vTemp : ShortString;
  vLen : SInt;

begin
  vTemp := '';
  vLen := Length(S);

  while (Pos <= vLen) and (S[Pos] <> Delim) do
  begin
    vTemp := vTemp + S[Pos];
    Inc(Pos);
  end;

  if (Pos <= vLen) and (S[Pos] = Delim) then
    Inc(Pos); // Despreza o Delim

  GetSubStr := vTemp;
end;

function ReadInteger(const S : ShortString; var Pos : SInt) : SInt;
var
  vTemp : ShortString;
  vLen : SInt;
  vNeg : Boolean;

begin
  vLen := Length(S);

  // Verifica se negativo
  if (Pos <= vLen) and (S[Pos] = '-') then
  begin
    vNeg := True;
    Inc(Pos);
  end
  else
    vNeg := False;

  vTemp := '';

  while (Pos <= vLen) do
    if (S[Pos] >= '0') and (S[Pos] <= '9') then
    begin
      vTemp := vTemp + S[Pos];
      Inc(Pos);
    end
    else
      Break;

  if(vTemp = '') then
    ReadInteger := 0
  else
    if vNeg then
      ReadInteger := - StrToInt(vTemp)
    else
      ReadInteger := StrToInt(vTemp);
end;

end.
