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
  Versao: 0.4
  Data: 30/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc basic.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit Basic;

interface

type
  TPointerFar16 = packed record
    Ofs : Word;
    Seg : Word;
  end;

function TestBitsByte(ByteVar : Byte; ByteBits : Byte) : Boolean;

function WordToHex(Value : Word; Size : Byte) : String;
function DWordToHex(Value : LongInt; Size : Byte; Divisor : Byte) : String;

function FileExists(FName : String) : Boolean;

function PFar16ToPLinear(PF16 : TPointerFar16) : LongInt;
function PLinearToPFar16(PL : LongInt) : LongInt;

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

{Converte um valor numerico para string em hex}
function DWordToHex(Value : LongInt; Size : Byte; Divisor : Byte) : String;
var
  Temp : String;
  Result : String;
  Dig : Byte;

begin
  Temp := '';

  while (Value <> 0) do
  begin
    Dig := Value and $F;
    Value := Value shr 4;

    Temp := Temp + HexValues[Dig];
  end;

  while (Length(Temp) < Size) do
    Temp := Temp + '0';

  Result := '';

  for Dig := Length(Temp) downto 1 do
  begin
    Result := Result + Temp[Dig];

    if (Divisor > 0) and (Dig > 1) then
      if (((Dig - 1) mod Divisor) = 0) then
        Result := Result + #39;
  end;

  DWordToHex := Result;
end;

{Verifica se arquivo exite no disco}
function FileExists(FName : String) : Boolean;
var
  F : File;

begin
  Assign(F, FName);

  {$I-}
  Reset(F);
  {$I+}

  if (IOResult = 0) then
  begin
    Close(F);
    FileExists := True;
  end
  else
    FileExists := False;
end;

{Converte ponteiro FAR16 para endereco linear}
function PFar16ToPLinear(PF16 : TPointerFar16) : LongInt;
var
  Temp : LongInt;

begin
  Temp := PF16.Seg;
  Temp := (Temp * $10) + PF16.Ofs;

  PFar16ToPLinear := Temp;
end;

{Converte endereco linear em ponteiro FAR16}
function PLinearToPFar16(PL : LongInt) : LongInt;
var
  Temp : TPointerFar16;
begin
  Temp.Seg := PL div $10;
  Temp.Ofs := PL mod $10;

  PLinearToPFar16 := LongInt(Temp);
end;

end.
