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
  Unit MemInfo.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para obtencao de memoria.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 25/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc meminfo.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit MemInfo;

interface

  procedure DetectMem;
  function GetBlocksCount : Byte;
  function GetMemoryBase(Block : Byte) : LongInt;
  function GetMemoryLimit(Block : Byte) : LongInt;
  function GetMemorySize(Block : Byte) : LongInt;

implementation

{$L BIOS12.OBJ}
{$L BIOS15.OBJ}

function BiosInt12 : Word; external; {near; nostackframe}
{===========================================================================
  function BiosInt12 : Word; external; near; nostackframe
  --------------------------------------------------------------------------
  Obtem a quantidade de memoria baixa em KB.
===========================================================================}

function BiosInt15x88 : Word; external; {near; nostackframe}
{===========================================================================
  function BiosInt15x88 : Word; external; near; nostackframe
  --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida (1M < 64M) em KB.
===========================================================================}

function BiosInt15xE801L: Word; external; {near; nostackframe}
{===========================================================================
  function BiosInt15xE801L: Word; external; near; nostackframe
  --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida (1M < 16M) em KB.
===========================================================================}

function BiosInt15xE801H: Word; external; {near; nostackframe}
{===========================================================================
  function BiosInt15xE801H: Word; external; near; nostackframe
  --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida ( > 16M) em 64 KB.
===========================================================================}

type
  TMemoryBlock = packed record
    Base : LongInt;
    Size : LongInt;
    Limit : LongInt;
  end;

const
  KBytes = 1; {Usando KBytes como unidade}
  MBytes = 1024 * KBytes;
  GBytes = 1024 * MBytes;

  MaxBlock = 3;

var
  vMemory : array[0..MaxBlock] of TMemoryBlock;
  vHighBlock : Byte;

{Atualiza os dados}
procedure DetectMem;
var
  I : Byte;
  vBiosInt12 : Word;
  vBiosInt15x88 : Word;
  vBiosInt15xE801L : Word;
  vBiosInt15xE801H : LongInt; {evita erro de conversao posterior}

begin
  {Definindo a base dos blocos}
  vMemory[0].Base := 0;
  vMemory[1].Base := 1 * MBytes;
  vMemory[2].Base := 1 * MBytes;
  vMemory[3].Base := 16 * MBytes;

  {Pega valores atraves da BIOS}
  vBiosInt12 := BiosInt12;
  vBiosInt15x88 := BiosInt15x88;
  vBiosInt15xE801L := BiosInt15xE801L;
  vBiosInt15xE801H := BiosInt15xE801H;

  {Verificando valores}
  if (vBiosInt12 > 1000) then {o maximo seria 640...}
    vBiosInt12 := 0;

  if (vBiosInt15xE801L > $3C00) then
    vBiosInt15xE801L := 0;

  if (vBiosInt15xE801H >= $2000000) then
    vBiosInt15xE801H := 0;

  {Convertendo 64K para 1K}
  vBiosInt15xE801H := vBiosInt15xE801H * 64;

  {Definindo o tamanho dos blocos}
  vMemory[0].Size := vBiosInt12;
  vMemory[1].Size := vBiosInt15x88; {um bloco continuo de 1M ate max 64M}
  vMemory[2].Size := vBiosInt15xE801L;
  vMemory[3].Size := vBiosInt15xE801H;

  {Calculando Limites}
  for I := 0 to MaxBlock do
    vMemory[I].Limit := vMemory[I].Base + vMemory[I].Size;

  {Verificando quantos blocos existem}
  vHighBlock := 0;

  for I := MaxBlock downto 0 do
    if (vMemory[I].Size > 0) then
    begin
      vHighBlock := I;
      I := 0;
    end;
end;

{Retorna o numero de blocos individuais de memoria}
function GetBlocksCount : Byte;
begin
  GetBlocksCount := vHighBlock + 1;
end;

{Retorna o endereco base do bloco}
function GetMemoryBase(Block : Byte) : LongInt;
begin
  if (Block >= 0) and (Block <= vHighBlock) then
    GetMemoryBase := vMemory[Block].Base shl 10
  else
    GetMemoryBase := 0;
end;

{Retorna o limite superior do bloco}
function GetMemoryLimit(Block : Byte) : LongInt;
begin
  if (Block >= 0) and (Block <= vHighBlock) then
  begin
    if (vMemory[Block].Limit > vMemory[Block].Base) then
      GetMemoryLimit := (vMemory[Block].Limit shl 10) - 1
    else
      GetMemoryLimit := vMemory[Block].Base shl 10
  end
  else
    GetMemoryLimit := 0;
end;

{Retorna o tamanho do bloco em KB}
function GetMemorySize(Block : Byte) : LongInt;
begin
  if (Block >= 0) and (Block <= vHighBlock) then
    GetMemorySize := vMemory[Block].Size
  else
    GetMemorySize := 0;
end;

var
  I : Byte;

begin
  for I := 0 to MaxBlock do
  begin
    vMemory[I].Base := 0;
    vMemory[I].Limit := 0;
    vMemory[I].Size := 0;
  end;

  vHighBlock := 0;
end.
