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
  Programa LoadLOS.pas
  --------------------------------------------------------------------------
    Este programa eh um BootLoader, responsavel por carregar o kernel para
  a memoria e executa-lo.
  --------------------------------------------------------------------------
  Versao: 0.3
  Data: 06/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc /b loadlos.pas
  ------------------------------------------------------------------------
  Executar: Pode ser executado somente no DOS em Modo Real.
  > loadlos.exe

  * Se voce leu esse aviso acima, entao pode nao querer ficar respendo toda
  vez, para evitar isso basta acrescentar um ' :)' apos o nome, assim:
  > detecmem.exe :)
===========================================================================}

program LoadLOS;

uses CopyRigh, CPUInfo, MemInfo, CRTInfo, Basic, EStrings, BootAux;

{Constantes gerais}
const
  cCPUMin = CT80386;
  cCPUMax = CT80586;
  cHighMemoryMin = 0;
  cKernelName = 'pkrnl01.bin';
  cMaxExecSpace = $FFF0;
  cMaxBuffer = $FFF0;

{Variaveis globais}
var
  vCPUType :TCPUType;
  vLowMemory : DWord;
  vHighMemory : DWord;
  vCRTInfo : Word;
  vCRTRows, vCRTCols : Byte;
  vCRTPort, vCRTSeg : Word;
  vExecLinear : DWord;
  vExecSize : DWord;

{Verifica a CPU}
procedure TestCPU;
begin
  DetectCPU;
  {armazena o tipo da CPU em uma variavel global}
  vCPUType := GetCPUType;

  {mostra informacoes da CPU}
  case vCPUType of
    CT8086  : Writeln('CPU 8086 detectado');
    CT80186 : Writeln('CPU 80186 detectado');
    CT80286 : Writeln('CPU 80286 detectado');
    CT80386 : Writeln('CPU 80386 detectado');
    CT80486 : Writeln('CPU 80486 detectado');
    CT80586 : Writeln('CPU 80586 detectado');
  else
    Writeln('CPU Desconhecido...');
  end;

  {verifica o tipo da CPU}
  if (vCPUType < cCPUMin) or (vCPUType > cCPUMax) then
  begin
    Writeln('CPU nao suportada. Abortando!');
    Finish;
  end;

  {verifica se Modo Protegido}
  if GetCPU_PE then
  begin
    Writeln('CPU esta no Modo Protegido. Abortando!');
    Finish;
  end;
end;

{Verifica a Memoria}
procedure TestMem;
begin
  DetectMem;

  {armazena a quantidade de memoria detectada em variaveis globais}
  vLowMemory := GetMemorySize(0);
  vHighMemory := GetMemorySize(1);

  {mostra informacoes da memoria}
  Writeln('Memoria baixa/alta (KB): ', vLowMemory, '/', vHighMemory);

  {verifica se tem memoria minima instalada}
  if (vHighMemory < cHighMemoryMin) then
  begin
    Writeln('Memoria insuficiente. Abortando!');
    Finish;
  end;
end;

{Verifica o Video}
procedure TestCRT;
begin
  DetectCRT;

  {armazena informacoes do video em variaveis globais}
  vCRTInfo := GetCRTInfo;
  vCRTRows := GetCRTRows;
  vCRTCols := GetCRTCols;
  vCRTPort := GetCRTAddr6845;
  vCRTSeg  := GetCRTSeg;

  {mostra informacoes do video}
  Write('Video: ');

  case GetCRTType of
    CRTA_MDA : Write('MDA');
    CRTA_CGA : Write('CGA');
    CRTA_EGA : Write('EGA');
    CRTA_VGA : Write('VGA');
  else
    Write('Desconhecido');
  end;

  Write(' ', vCRTRows, 'x', vCRTCols, ' ');

  if GetCRT_MDA then
    Write('Mono')
  else
    if GetCRT_Color then
      Write('Color')
    else
      Write('Grayscale');

  Writeln(' (Port/Mem: 0x', WordToHex(vCRTPort), '/0x', WordToHex(vCRTSeg), ')');

  {verifica se retornou erro durante a deteccao do video}
  if GetCRT_Error then
  begin
    Writeln('Falha na deteccao do video. Abortando!');
    Finish;
  end;
end;

{Cria um espaco de execucao}
procedure MakeExecSpace;
var
  vMaxAvail : DWord;
  vTempSize : Word;
  vTempPointer : Pointer;
  vTempSpace : TPointerFar16;
  vTempLinear : DWord;

begin
  {aloca espaco em Temp}
  vMaxAvail := MaxAvail;

  if (vMaxAvail > cMaxExecSpace) then
    vTempSize := cMaxExecSpace;

  GetMem(vTempPointer, vTempSize);

  vTempSpace := TPointerFar16(vTempPointer);
  vTempLinear := PFar16ToPLinear(vTempSpace);

  {corrige espaco de execucao se necessario}
  if ((vTempLinear mod $10) = 0) then
    vExecLinear := vTempLinear
  else
    vExecLinear := ((vTempLinear div $10) + 1) * $10;

  {calcula o tamanho efetivo do espaco de execucao}
  vExecSize := vTempSize - (vExecLinear - vTempLinear);

  {mostra informacoes do espaco de execucao}
  Writeln('"Espaco de execucao" criado com ', vExecSize, ' bytes em 0x', DWordToHex2(vExecLinear));
end;


{Copia o kernel para a memoria}
procedure LoadKernel;
var
  vKernel : File;
  vKernelSize : DWord;
  vMaxAvail : DWord;
  vBufferSize : Word;
  vBuffer : Pointer;
  vBufferSeg : TPointerFar16;
  vBufferLinear : DWord;
  nPassos : Word;
  vPasso : Word;
  vLidos : Word;

begin
  {abre a imagem de kernel}
  Assign(vKernel, cKernelName);
  Reset(vKernel, 1);

  vKernelSize := FileSize(vKernel);
  Writeln('Kernel com ', vKernelSize, ' Bytes.');

  {Verificando se ha espaco suficiente para carregar o kernel}
  if (vExecSize < vKernelSize) then
  begin
    Writeln('Espaco de execucao insuficiente para o kernel. Abortando!');
    Close(vKernel);
    Finish;
  end;

  {Definindo tamanho buffer}
  vMaxAvail := MaxAvail;

  if (vMaxAvail > cMaxBuffer) then
    vBufferSize := cMaxBuffer;

  if (vBufferSize > vKernelSize) then
    vBufferSize := vKernelSize;

  GetMem(vBuffer , vBufferSize);

  vBufferSeg := TPointerFar16(vBuffer);
  vBufferLinear := PFar16ToPLinear(vBufferSeg);

  Writeln('Buffer criado com ', vBufferSize, ' bytes em 0x', DWordToHex2(vBufferLinear));

  {Verificando que o kernel pode ser copiado em quantos passos}
  if (vKernelSize > vBufferSize) then
  begin
    nPassos := vKernelSize div vBufferSize;

    if ((vKernelSize mod vBufferSize) <> 0) then
      Inc(nPassos);

    Writeln('Kernel grande, carregando em ', nPassos, ' passos...');
  end
  else
  begin
    nPassos := 1;

    Write('Carregando kernel... ')
  end;

  {Copiando kernel}
  for vPasso := 1 to nPassos do
  begin
    BlockRead(vKernel, vBuffer^, vBufferSize, vLidos);
    CopyLinear(vBufferLinear, vExecLinear + ((vPasso - 1) * vBufferSize), vLidos);
  end;

  {mostra informacao e fecha o arquivo}
  Writeln(' carregado!');
  Close(vKernel);
end;

{Chama o kernel}
procedure ExecKernel;
var
  vCS : Word;
  vDS : Word;
  vES : Word;
  VSS : Word;
  vEntry : Word;
  vStack : Word;
  vParam : Word;

begin
  Writeln('Executando kernel em 0x', DWordToHex2(vExecLinear));

  vCS := vExecLinear div $10;
  vEntry := vExecLinear mod $10;

  vParam := vCRTSeg;

  vDS := GetDS;
  vES := vDS;

  vSS := GetSS;
  vStack := GetSP;

  if (vStack > $400) then
    vStack := $3FE
  else
    vStack := ((vStack - 10) div $10) * $10;

  GoKernel16(vCS, vDS, vES, vSS, vEntry, vStack, vParam);

  {Impossivel o retorno a esse ponto pelo kernel}
end;

{Procedimento principal}
begin
  ShowWarning;

  {verifica requisitos}
  Writeln;
  TestCPU;
  TestMem;
  TestCRT;
  Writeln;

  {verifica se existe a imagem do kernel}
  if not FileExists(cKernelName) then
  begin
    Writeln('Imagem do kernel: ', cKernelName);
    Writeln('Imagem de kernel nao encotrada. Abortando!');
    Finish;
  end;

  {cria o espaco de execucao}
  MakeExecSpace;

  {carrega o kernel}
  Writeln;
  Writeln('Imagem do kernel: ', cKernelName);
  LoadKernel;

  {chama o kernel}
  Writeln;
  ExecKernel;

  Finish;
end.
