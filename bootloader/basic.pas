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
  Versao: 0.7
  Data: 20/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc basic.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit Basic;

interface

type
  DWord = LongInt;

  PByteArray = ^TByteArray;
  TByteArray = array[0..$FFFF-1] of Byte;

  TPointerFar16 = packed record
    Ofs : Word;
    Seg : Word;
  end;

  function TestBitsByte(ByteVar : Byte; ByteBits : Byte) : Boolean;

  function PFar16ToPLinear(PF16 : TPointerFar16) : DWord;
  function PLinearToPFar16(PL : DWord) : DWord;

  function FileExists(FName : String) : Boolean;

  function LoWord(Value : DWord) : Word;
  function HiWord(Value : DWord) : Word;


implementation

{Testa se ByteBits esta presente em ByteVar}
function TestBitsByte(ByteVar : Byte; ByteBits : Byte) : Boolean;
begin
  TestBitsByte := (ByteVar and ByteBits) = ByteBits;
end;

{Converte ponteiro FAR16 para endereco linear}
function PFar16ToPLinear(PF16 : TPointerFar16) : DWord;
var
  Temp : DWord;

begin
  Temp := PF16.Seg;
  Temp := (Temp * $10) + PF16.Ofs;

  PFar16ToPLinear := Temp;
end;

{Converte endereco linear em ponteiro FAR16}
function PLinearToPFar16(PL : DWord) : DWord;
var
  Temp : TPointerFar16;
begin
  Temp.Seg := PL div $10;
  Temp.Ofs := PL mod $10;

  PLinearToPFar16 := DWord(Temp);
end;

{Verifica se arquivo existe no disco}
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

{Retorna o word baixo do DWord}
function LoWord(Value : DWord) : Word;
begin
  LoWord := Value and $FFFF;
end;

{Retorna o word alto do DWord}
function HiWord(Value : DWord) : Word;
begin
  HiWord := (Value shr 16) and $FFFF;
end;

end.
