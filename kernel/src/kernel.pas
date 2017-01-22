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
  Versao: 0.6.2
  Data: 25/12/2014
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

uses SysUtils, BootBT32, GrossTTY, StdLib, StdIO, ConsoleIO,
  SystemDef, TTYsDef;


const
  cKernelName = 'LOS-KERNEL';
  cKernelVersion = '0.6';
  cKernelDate = {$I %DATE%};
  cKernelTime = {$I %TIME%};
  cFPCVersion = {$I %FPCVERSION%};
  cTargetCPU = {$I %FPCTARGETCPU%};

  { Enderecos criados pelo linker, usar @ antes dos nomes}
  procedure KernelStart; external name 'kernel_start';
  procedure KernelCode; external name 'kernel_code';
  procedure KernelData; external name 'kernel_data';
  procedure KernelBSS; external name 'kernel_bss';
  procedure KernelEnd; external name 'kernel_end';

  { Procedimentos internos (forward) }
  procedure KernelIdle; forward;


procedure KernelInit(BootTable : Pointer); alias : 'kernelinit';
var
  vBootTable : PBootTable;

begin
  // Testa a tabela de boot
  if not CheckBootTable(BootTable) then
    Abort;

  vBootTable := BootTable;

  // Inicializa driver de video/terminal
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

  CWrite('Kernel UP: ' + cKernelName + '.' + cTargetCPU + '(v' + cKernelVersion + ')');
  CWrite(' [Build: ' + cKernelDate + '-' + cKernelTime + ' FPC:' + cFPCVersion + ']');

  CSetNormVideo;
  CLineFeed(2);

  CSetColor(Yellow);
  CWriteln('Parametros recebidos do Bootloader:');
  CSetNormVideo;

  CWrite('CPU:                        ');

  if (vBootTable^.CPULevel >= 3) and (vBootTable^.CPULevel <= 5) then
    CSetColor(LightGreen)
  else
    CSetColor(LightRed);

  case vBootTable^.CPULevel of
    0 : CWriteln('8086?');
    1 : CWriteln('80186?');
    2 : CWriteln('80286?');
    3 : CWriteln('80386');
    4 : CWriteln('80486');
    5 : CWriteln('80586 ou superior');
  else
    CWriteln('Nao conhecida!');
  end;

  CSetNormVideo;

  CWrite('Memoria (Low/High) KB:      ');
  CSetColor(LightGreen);
  CWrite(vBootTable^.LowMemory);
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(vBootTable^.HighMemory);

  CSetNormVideo;

  CWrite('Video (Rows x Cols) :       ');
  CSetColor(LightGreen);
  CWrite(vBootTable^.CRTRows);
  CSetNormVideo;
  CWrite('x');
  CSetColor(LightGreen);
  CWriteln(vBootTable^.CRTCols);

  CSetNormVideo;

  CWrite('A20 suporte:                ');

  if vBootTable^.A20Bios then
  begin
    CWrite('[');
    CSetColor(LightGreen);
    CWrite('Bios');
    CSetNormVideo;
    CWrite('] ');
  end;

  if vBootTable^.A20KBC then
  begin
    CWrite('[');
    CSetColor(LightGreen);
    CWrite('KBC8042');
    CSetNormVideo;
    CWrite('] ');
  end;

  if vBootTable^.A20Fast then
  begin
    CWrite('[');
    CSetColor(LightGreen);
    CWrite('FastGate');
    CSetNormVideo;
    CWrite('] ');
  end;

  CWriteln;
  CWriteln;

  CWrite('Imagem do kernel (Ini/End):       ');
  CSetColor(LightGreen);
  CWrite(IntToHexX(vBootTable^.ImgIni, 8));
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(IntToHexX(vBootTable^.ImgEnd, 8));

  CSetNormVideo;

  CWrite('Pilha (Ini/End):                  ');
  CSetColor(LightGreen);
  CWrite(IntToHexX(vBootTable^.StackIni, 8));
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(IntToHexX(vBootTable^.StackEnd, 8));

  CSetNormVideo;

  CWrite('Heap (Ini/End):                   ');
  CSetColor(LightGreen);
  CWrite(IntToHexX(vBootTable^.HeapIni, 8));
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(IntToHexX(vBootTable^.HeapEnd, 8));

  CSetNormVideo;
  CWriteln;

  CWrite('Memoria livre inferior (Ini/End): ');
  CSetColor(LightGreen);
  CWrite(IntToHexX(vBootTable^.FreeLowIni, 8));
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(IntToHexX(vBootTable^.FreeLowEnd, 8));

  CSetNormVideo;

  CWrite('Memoria livre superior (Ini/End): ');
  CSetColor(LightGreen);
  CWrite(IntToHexX(vBootTable^.FreeHighIni, 8));
  CSetNormVideo;
  CWrite('/');
  CSetColor(LightGreen);
  CWriteln(IntToHexX(vBootTable^.FreeHighEnd, 8));

  CSetNormVideo;

  CWriteln;
  CSetColor(Yellow);
  CWriteln('Parametros internos do Kernel:');
  CSetNormVideo;

  CWrite('Kernel_Start: ');
  CSetColor(LightGreen);
  CWriteln(@KernelStart);
  CSetNormVideo;

  CWrite('Kernel_End:   ');
  CSetColor(LightGreen);
  CWriteln(@KernelEnd);
  CSetNormVideo;

  CWriteln;

  CWrite('Kernel_Code:  ');
  CSetColor(LightGreen);
  CWriteln(@KernelCode);
  CSetNormVideo;

  CWrite('Kernel_Data:  ');
  CSetColor(LightGreen);
  CWriteln(@KernelData);
  CSetNormVideo;

  CWrite('Kernel_BSS:   ');
  CSetColor(LightGreen);
  CWriteln(@KernelBSS);
  CSetNormVideo;

  KernelIdle;
end;


  { Procedimentos internos }

procedure KernelIdle;
var
  X, Y : Byte;
  vContador : LongWord;

begin
  CWriteln;
  CSetColor(LightRed);
  CWriteln('Entrando em IDLE...');
  CSetNormVideo;
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
