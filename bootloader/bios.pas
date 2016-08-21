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
  Unit Bios.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos da BIOS.
  --------------------------------------------------------------------------
  Versao: 0.4
  Data: 10/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc bios.pas
  --------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit Bios;

interface

uses Basic;

type
  TBiosInt10x0F_Result = packed record
    Mode : Byte;
    Cols : Byte;
    Page : Byte;
    Nul1 : Byte;
  end;

  TBiosInt10x1130B_Result = packed record
    BytesPerChar : Word;
    Rows : Byte;
    Nul1 : Byte;
  end;


  function BiosInt10x0F : DWord;
  function BiosInt10x1130B(FuncNo : Byte) : DWord;

  function BiosInt12 : Word;

  function BiosInt15x2400 : Word;
  function BiosInt15x2401 : Word;
  function BiosInt15x2402 : Word;
  function BiosInt15x2403 : Word;

  function BiosInt15x88 : Word;

  function BiosInt15xE801L: Word;
  function BiosInt15xE801H: Word;


implementation

{$L BIOS10.OBJ}
{$L BIOS12.OBJ}
{$L BIOS15.OBJ}

{==========================================================================}
  function BiosInt10x0F : DWord; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Obtem o estado do video atual.
  --------------------------------------------------------------------------
  Retorno: DWord::

    TBiosInt10x0FResult = packed record
      Mode : Byte;
      Cols : Byte;
      Page : Byte;
      Nul1 : Byte;
    end;

===========================================================================}

{==========================================================================}
  function BiosInt10x1130B(FuncNo : Byte) : DWord; external; {far}
{ --------------------------------------------------------------------------
  Obtem o estado do video atual.
  --------------------------------------------------------------------------
  Retorno: DWord::

    TBiosInt10x1130B_Result = packed record
      BytesPerChar : Word;
      Rows : Byte;
      Nul1 : Byte;
    end;

===========================================================================}

{==========================================================================}
  function BiosInt12 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Obtem a quantidade de memoria baixa em KB.
===========================================================================}

{==========================================================================}
  function BiosInt15x2400 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Desabilita o A20
  --------------------------------------------------------------------------
  Retorno: Word::

    0 = Ok

    Hi = 1 = Falha
      Lo = Codigo de erro

===========================================================================}

{==========================================================================}
  function BiosInt15x2401 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Habilita o A20
  --------------------------------------------------------------------------
  Retorno: Word::

    0 = Ok

    Hi = 1 = Falha
      Lo = Codigo de erro

===========================================================================}

{==========================================================================}
  function BiosInt15x2402 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Retorna o Status de A20
  --------------------------------------------------------------------------
  Retorno: Word::

    Hi = 0 = Ok
      Lo = Status
        0 = Desativado
        1 = Ativado

    Hi = 1 = Falha
      Lo = Codigo de erro

===========================================================================}

{==========================================================================}
  function BiosInt15x2403 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Retorna o tipo de suporte para o A20
  --------------------------------------------------------------------------
  Retorno: Word::

    Hi = 0 = Ok
      Lo = Suporte
        0 : 00 = Nenhum
        1 : 01 = Keyboard (8042)
        2 : 10 = System Control Port A (0x92)
        3 : 11 = Ambos

    Hi = 1 = Falha
      Lo = Codigo de erro

===========================================================================}

{==========================================================================}
  function BiosInt15x88 : Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida (1M < 64M) em KB.
===========================================================================}

{==========================================================================}
  function BiosInt15xE801L: Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida (1M < 16M) em KB.
===========================================================================}

{==========================================================================}
  function BiosInt15xE801H: Word; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Obtem a quantidade de memoria extendida ( > 16M) em 64 KB.
===========================================================================}

end.
