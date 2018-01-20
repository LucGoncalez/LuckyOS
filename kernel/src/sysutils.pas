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
  Versao: 0.4.2
  Data: 11/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc sysutils.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0510-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial, RTL limpa.
  ------------------------------------------------------------------------
  [2013-0906-0000] (v0.2) <Luciano Goncalez>

  - Adicionando rotinas de conversão de Inteiros.
  ------------------------------------------------------------------------
  [2014-0726-0000] (v0.3) <Luciano Goncalez>

  - Adequando a nova Abort.
  ------------------------------------------------------------------------
  [2014-1221-0000] (v0.4) <Luciano Goncalez>

  - Adequando a nova Abort.
  ------------------------------------------------------------------------
  [2014-1225-0000] (v0.4.1) <Luciano Goncalez>

  - Adequando Abort.
  ------------------------------------------------------------------------
  [2018-0111-2328] (v0.4.2) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

unit SysUtils;

interface

  function IntToStr(Value : LongInt) : ShortString;
  function IntToStr(Value : LongWord) : ShortString;

  function IntToHex(Value : LongInt; Digits : Byte) : ShortString;
  function IntToHex(Value : LongWord; Digits : Byte) : ShortString;

  function IntToHexX(Value : LongInt; Digits : Byte) : ShortString;
  function IntToHexX(Value : LongWord; Digits : Byte) : ShortString;

  function StrToInt(S : ShortString) : LongInt;
  function StrToIntDef(S : ShortString; Default : LongInt) : LongInt;


implementation

uses StdLib, ErrorsDef;

// Converte numero com sinal para string
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

  if Neg and (Temp <> '') then
    Temp := Temp + '-';

  if (Temp = '') then
    Temp := '0';

  Result := '';

  for I := Length(Temp) downto 1 do
    Result := Result + Temp[I];

  IntToStr := Result;
end;

// Converte numero sem sinal para string
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

  if (Temp = '') then
    Temp := '0';

  Result := '';

  for I := Length(Temp) downto 1 do
    Result := Result + Temp[I];

  IntToStr := Result;
end;

// Converte numero para equivalente hex (sem sufixo)
function IntToHex(Value : LongInt; Digits : Byte) : ShortString;
begin
  IntToHex := IntToHex(LongWord(Value), Digits);
end;

// Converte numero para equivalente hex (sem sufixo)
function IntToHex(Value : LongWord; Digits : Byte) : ShortString;
var
  Temp : ShortString;
  Result : ShortString;
  I : Byte;

const
  HexValues = '0123456789ABCDEF';

begin
  Temp := '';

  while (Value > 0) do
  begin
    Temp := Temp + HexValues[(Value mod $10) + 1];
    Value := Value div $10;
  end;

  while (Length(Temp) < Digits) do
    Temp := Temp + '0';

  Result := '';

  for I := Length(Temp) downto 1 do
    Result := Result + Temp[I];

  IntToHex := Result;
end;


// Converte numero para equivalente hex (com sufixo)
function IntToHexX(Value : LongInt; Digits : Byte) : ShortString;
begin
  IntToHexX := '0x' + IntToHex(Value, Digits);
end;

// Converte numero para equivalente hex (com sufixo)
function IntToHexX(Value : LongWord; Digits : Byte) : ShortString;
begin
  IntToHexX := '0x' + IntToHex(Value, Digits);
end;


// Converte string numerica para numero
function StrToInt(S : ShortString) : LongInt;
var
  vError : Word;
  vTemp : LongInt;

begin
  Val(S, vTemp, vError);

  if (vError = 0) then
    StrToInt := vTemp
  else
    Abort(ERROR_SYSUTILS_INVALID_INTEGER, UI_SYSUTILS, FI_STRTOINT,
      {$I %FILE%}, {$I %LINE%}, 'Valor fornecido nao eh um inteiro valido!');
end;

// Converte string numerica para numero (com default)
function StrToIntDef(S : ShortString; Default : LongInt) : LongInt;
var
  vError : Word;
  vTemp : LongInt;

begin
  Val(S, vTemp, vError);

  if (vError = 0) then
    StrToIntDef := vTemp
  else
    StrToIntDef := Default;
end;


end.
