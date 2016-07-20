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
  Unit Basic.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos basicos usados por outras diversas Units.
  --------------------------------------------------------------------------
  Versao: 0.2
  Data: 24/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc basic.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit Basic;

interface

function TestBitsByte(ByteVar : Byte; ByteBits : Byte) : Boolean;
function WordToHex(Value : Word; Size : Byte) : String;

implementation

{Constante usada para conversao em hex}
const
  HexValues : array[0..$F] of char =
  ('0', '1', '2', '3', '4', '5', '6' , '7',
   '8', '9', 'A', 'B', 'C', 'D', 'E' , 'F');


{Testa se ByteBits esta presente em ByteVar}
function TestBitsByte(ByteVar : Byte; ByteBits : Byte) : Boolean;
begin
  TestBitsByte := (ByteVar and ByteBits) = ByteBits;
end;

{Converte um valor numerico para string em hex}
function WordToHex(Value : Word; Size : Byte) : String;
var
  Temp : String;
  Result : String;
  Dig : Byte;

begin
  Temp := '';

  while (Value > 0) do
  begin
    Dig := Value mod $10;
    Value := Value div $10;

    Temp := Temp + HexValues[Dig];
  end;

  while (Length(Temp) < Size) do
    Temp := Temp + '0';

  Result := '';

  for Dig := Length(Temp) downto 1 do
    Result := Result + Temp[Dig];

  WordToHex := Result;
end;

end.
