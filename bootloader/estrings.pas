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
  Unit EStrings.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para conversao e formatacao de strings.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 01/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc estrings.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit EStrings;

interface

uses Basic;

  function IntToStr(Value : LongInt) : String;
  function WordToStr(Value : DWord) : String;

  function ByteToHex(Value : Byte) : String;
  function WordToHex(Value : Word) : String;
  function DWordToHex(Value : DWord) : String;
  function DWordToHex2(Value : DWord) : String;

  function FillLeft(S : String; Size : Byte; C : Char) : String;
  function FillRight(S : String; Size : Byte; C : Char) : String;

implementation

type
  TStringInt = String[11]; {tamanho max ocupado por um valor longint}

const
  {valor que representa um negativo em um longint}
  cNegRep = $80000000;

  {Constante usada para conversao em hex}
  HexValues : array[0..$F] of char =
  ('0', '1', '2', '3', '4', '5', '6', '7',
   '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');


{Faz a conversao efetiva para hex}
function ConvertToHex(Value : DWord) : TStringInt;
var
  Temp : TStringInt;
  Result : TStringInt;
  Dig : Byte;

begin
  Temp := '';

  while (Value <> 0) do
  begin
    Dig := Value and $F;
    Value := Value shr 4;

    Temp := Temp + HexValues[Dig];
  end;

  if (Length(Temp) = 0) then
    Temp := '0';

  Result := '';

  for Dig := Length(Temp) downto 1 do
    Result := Result + Temp[Dig];

  ConvertToHex := Result;
end;


{converte um valor inteiro com sinal para string}
function IntToStr(Value : LongInt) : String;
var
  Temp : TStringInt;
begin
  Str(Value, Temp);
  IntToStr := Temp;
end;

{converte um valor inteiro sem sinal para string}
function WordToStr(Value : DWord) : String;
var
  TempS : TStringInt;
  TempW : DWord;
  TempB : Byte;

begin
  if ((Value and cNegRep) = cNegRep) then
  begin
    {se valor possui o bit-neg, conversao especial}

    {divide o valor por 10}
    TempW := (Value shr 1) div 5;

    {pega o ultimo decimal}
    TempB := (Value - ((TempW * 5) shl 1)) mod 10;

    {junta tudo}
    TempS := IntToStr(TempW) + IntToStr(TempB);
  end
  else
    {conversao simples}
    Str(Value, TempS);

  WordToStr := TempS;
end;

{converte valor contido em Byte para hex}
function ByteToHex(Value : Byte) : String;
var
  Temp : TStringInt;

begin
  Temp := FillLeft(ConvertToHex(Value), 2, '0');
  ByteToHex := Temp;
end;

{converte valor contido em Word para hex}
function WordToHex(Value : Word) : String;
var
  Temp : TStringInt;

begin
  Temp := FillLeft(ConvertToHex(Value), 4, '0');
  WordToHex := Temp;
end;

{converte valor contido em DWord para hex}
function DWordToHex(Value : DWord) : String;
var
  Temp : TStringInt;

begin
  Temp := FillLeft(ConvertToHex(Value), 8, '0');
  DWordToHex := Temp;
end;

{converte valor contido em DWord para hex, com divisao entre Words}
function DWordToHex2(Value : DWord) : String;
var
  Temp : TStringInt;
begin
  Temp := DWordToHex(Value);

  Insert('.', Temp, 5);

  DWordToHex2 := Temp;
end;

{preenche a esquerda da string com C ate que tenha o tamanho Size}
function FillLeft(S : String; Size : Byte; C : Char) : String;
var
  Temp : String;

begin
  Temp := S;

  while (Length(Temp) < Size) do
    Temp := C + Temp;

  FillLeft := Temp;
end;

{preenche a direita da string com C ate que tenha o tamanho Size}
function FillRight(S : String; Size : Byte; C : Char) : String;
var
  Temp : String;

begin
  Temp := S;

  while (Length(Temp) < Size) do
    Temp := Temp + C;

  FillRight := Temp;
end;

end.
