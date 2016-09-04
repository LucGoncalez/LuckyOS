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
  Unit SysUtils.pas
  --------------------------------------------------------------------------
  Unit SysUtils, crosscompiler, que substitui a RTL normal.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 10/05/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc sysutils.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit SysUtils;

interface

  function IntToStr(Value : LongInt) : ShortString;
  function IntToStr(Value : LongWord) : ShortString;


implementation


function IntToStr(Value : LongInt) : ShortString;
var
  Neg : Boolean;
  Temp : ShortString;
  Result : ShortString;
  I : Byte;

begin
  Neg := (Value < 0);

  if Neg then
  Value := 0 - Value;

  Temp := '';

  while (Value > 0) do
  begin
    Temp := Temp + Char((Value mod 10) + Ord('0'));
    Value := Value div 10;
  end;

  if Neg then
    Temp := Temp + '-';

  Result := '';

  for I := Length(Temp) downto 1 do
    Result := Result + Temp[I];

  IntToStr := Result;
end;

function IntToStr(Value : LongWord) : ShortString;
var
  Temp : ShortString;
  Result : ShortString;
  I : Byte;

begin
  Temp := '';

  while (Value > 0) do
  begin
    Temp := Temp + Char((Value mod 10) + Ord('0'));
    Value := Value div 10;
  end;

  Result := '';

  for I := Length(Temp) downto 1 do
    Result := Result + Temp[I];

  IntToStr := Result;
end;

end.
