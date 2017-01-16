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
  Versao: 0.3
  Data: 06/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc kernel.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit kernel;

interface

  procedure KernelInit(BootTable : Pointer);


implementation

uses BootBT32, GrossTTY, StdLib, StdIO, ConsoleIO, SystemDef, TTYsDef;


const
  cKernelName = 'LOS-KERNEL';
  cKernelVersion = '0.4';


  { Procedimentos internos (forward) }
  procedure KernelIdle; forward;


procedure KernelInit(BootTable : Pointer); alias : 'kernelinit';
var
  vBootTable : ^TBootTable;

begin
  // Inicializa driver de video/terminal
  vBootTable := BootTable;
  GrossTTYInit(vBootTable^.CRTPort, vBootTable^.CRTSeg, vBootTable^.CRTRows, vBootTable^.CRTCols, False);

  // Abre StdIn : fd = 0
  if (FOpen('/dev/null', [fmRead, fmWrite]) <> StdIn) or not CAssign(StdIn) then
    Abort;

  // Abre StdOut : fd = 1
  if (FOpen('/dev/grosstty', [fmRead, fmWrite]) <> StdOut) or not CAssign(StdOut) then
    Abort;

  // Abre StdErr : fd = 2
  if (FOpen('/dev/grosstty', [fmRead, fmWrite]) <> StdErr) or not CAssign(StdErr) then
    Abort;

  CSetColor(Yellow);
  CSetBackground(Green);
  CClrLine;

  CWrite('Kernel UP: ' + cKernelName + '(v');
  CWrite(cKernelVersion);
  CWrite(')');

  KernelIdle;
end;


  { Procedimentos internos }

procedure KernelIdle;
var
  X, Y : Byte;
  vContador : LongWord;

begin
  CSetNormVideo;
  CLineFeed(2);
  CWriteln('Entrado em IDLE...');
  CWrite('Contador: ');

  X := CWhereX;
  Y := CWhereY;

  CSetColor(Yellow);
  vContador := 0;

  while True do
  begin
    CGotoXY(X, Y);
    CWrite(vContador);
    Inc(vContador);
  end;
end;


end.
