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
  Unit BootBT32.pas
  --------------------------------------------------------------------------
  Esta Unit contem a tabela de boot fornecida pelo bootloader.

    Este arquvivo eh uma variacao do BootBT.pas para ser compilado mais
  facilmente pelo FPC sem dependencias vazias.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 29/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc bootbt.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit BootBT32;

interface

{
  Nao usado no FPC

uses Basic;
}

type
  TLOSSign = array[0..3] of char;
  TBTSign = array[0..3] of char;

  TBootTable = packed record
    {assinatura da tabela}
    LOSSign : TLOSSign;
    BTSign : TBTSign;
    {dados}
    CPULevel : Byte;
    LowMemory : DWord;
    HighMemory : DWord;
    CRTInfo : Word;
    CRTRows : Byte;
    CRTCols : Byte;
    CRTPort : Word;
    CRTSeg : Word;
    A20KBC : Boolean;
    A20Bios : Boolean;
    A20Fast : Boolean;
    CodeIni : DWord;
    CodeEnd : DWord;
    StackIni : DWord;
    StackEnd : DWord;
    HeapIni : DWord;
    HeapEnd : DWord;
  end;

const
  cLOSSign  : TLOSSign  = ('L', 'O', 'S', #0);
  cBTSign   : TBTSign   = ('B', 'B', 'T', #0);

implementation

end.
