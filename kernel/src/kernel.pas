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
  Unit Kernel.pas
  --------------------------------------------------------------------------
  Unit principal do kernel.
  --------------------------------------------------------------------------
  Versao: 0.0
  Data: 29/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc kernel.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit kernel;

interface

  procedure KernelInit(BootTable : Pointer); stdcall;

implementation

uses BootBT32;

const
  nRows = 25;
  nCols = 80;

type
  TCRTMem = array[1..nRows, 1..nCols] of Word;

procedure KernelInit(BootTable : Pointer); stdcall; alias : 'kernelinit';
var
  vBootTable : ^TBootTable;
  vCRTMem : ^TCRTMem;
  vCursor : Word;

begin
  vBootTable := BootTable;
  vCRTMem := Pointer((vBootTable^.CRTSeg) shl 4);

  vCursor := 0;

  while true do {não volte a kwrap}
  begin
    vCRTMem^[1, 70] := vCursor;
    Inc(vCursor);
  end;
end;

end.
