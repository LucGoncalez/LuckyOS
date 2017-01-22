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
  Versao: 0.15
  Data: 22/09/2013
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

uses CRT, CopyRigh, Basic, EStrings, BootAux, BootBT, PM, Intrpts, A20,
  CPUInfo, MemInfo, CRTInfo, LosHdr, KrnlHdr;

{Constantes gerais}
const
  cKernelName = 'kernel.bin';
  cCPUMin = CT80386;  {minimo para o boot}
  cCPUMax = CT80586;  {maximo detectavel}
  cHighMemoryMin = 1024; {1024K => 1M}
  cMaxBuffer = $FFF0;
  cDebugMode = 0;
  {
    0 = Sem debug;
    1 = Debug rapido;
    2 = Debug completo;
  }

{Variaveis globais}
var
  { * detectado * }
  vFileSize : DWord;
  vCPUType :TCPUType;
  vLowMemory : DWord;
  vHighMemory : DWord;
  vCRTInfo : Word;
  vCRTRows, vCRTCols : Byte;
  vCRTPort, vCRTSeg : Word;
  vA20Bios : Boolean;
  vA20KBC : Boolean;
  vA20Fast : Boolean;
  { * fornecido pelo kernel * }
  vKernelTable : TKrnlHdr_x86_32;
  { * estrutural * }
  GDT : array[0..3] of TDescrSeg;
  GDTR : TGdtR;
  vCodeDesc : Word;
  vDataDesc : Word;
  vStackDesc : Word;
  { * calculado * }
  vStackStart : DWord;
  vHeapStart : DWord;
  vFreeLowMemStart : DWord;
  vFreeLowMemSize : DWord;
  vFreeHighMemStart : DWord;
  vFreeHighMemSize : DWord;
  { * passado ao kernel * }
  vBootTable : TBootTable;
  { * interno * }
  vDebug : Boolean;
  vKernelName : String;


{Usado internamente}
procedure GetCommandLine;
var
  I : Byte;
  vSkip : Boolean;
  vHelp : Boolean;
  vError : Boolean;
  vWarning : Boolean;
  vTemp : String;

begin
  vSkip := False;
  vDebug := (cDebugMode = 2);
  vHelp := False;
  vError := False;
  vWarning := False;
  vKernelName := '';

  for I := 1 to ParamCount do
  begin
    vTemp := ParamStr(I);

    case vTemp[1] of
      ':' :
        if (vTemp = ':)') then
          vSkip := True
        else
          vError := True;

      '-' :
        if (vTemp = '-s') or (vTemp = '-S') then
          vSkip := True
        else if (vTemp = '-d') or (vTemp = '-D') then
          vDebug := True
        else if (vTemp = '-h') or (vTemp = '-H') then
          vHelp := True
        else if (vTemp = '-w') or (vTemp = '-W') then
          vWarning := True
        else
          vError := True;
    else
      if (vKernelName = '') then
        vKernelName := vTemp
      else
      begin
        vKernelName := '';
        vError := True;
      end;
    end;
  end;

  if vError then
  begin
    Writeln;
    Writeln('Parametro incorreto passado ao programa, tente -h para mais opcoes.');
    Finish;
  end;

  if vHelp then
  begin
    Writeln;
    Writeln('<<<<<< LoadLOS - Carregador do LuckyOS >>>>>>');
    Writeln;
    Writeln('Este programa carrega o kernel do Sistema Operacional LuckyOS');
    Writeln;
    Writeln('Uso:');
    Writeln;
    Writeln(' loadlos -d -h -s -w <kernelname>');
    Writeln;
    Writeln('  -d : Modo de depuracao;');
    Writeln('  -h : Mostra este texto de ajuda;');
    Writeln('  -s : Pula a tela de aviso inicial;');
    Writeln('  -W : Mostra a tela de aviso inicial e sai.');
    Writeln;
    Writeln('  kernelname : Informa o nome do arquivo de imagem do kernel,');
    Writeln('    se nenhum nome eh informado "kernel.bin" eh usado.');
    Finish;
  end;

  if vWarning then
  begin
    ShowWarning;
    Finish;
  end;

  {vDebug esta configurado....}
  if vDebug then
    vSkip := True;

  if (vKernelName = '') then
    vKernelName := cKernelName
  else
    vSkip := True;

  if not vSkip then
    ShowWarning;

  if vDebug then
  begin
    Writeln;
    Writeln(' <<< Modo de depuracao ativado! >>>');
  end;
end;

{Usado internamente}
function CPUType2Str(CPUType : TCPUType) : String;
begin
  CPUType2Str := '';

  case CPUType of
    CT8086  : CPUType2Str := '8086';
    CT80186 : CPUType2Str := '80186';
    CT80286 : CPUType2Str := '80286';
    CT80386 : CPUType2Str := '80386';
    CT80486 : CPUType2Str := '80486';
    CT80586 : CPUType2Str := '80586';
  end;
end;

{Usado internamente}
procedure WaitKey(Always : Boolean);
var
  vKey : Char;

begin
  if vDebug or Always then
  begin
    Writeln;
    Write('Pressione qualquer tecla para continuar... ');
    vKey := ReadKey;
    ClrScr;
  end;
end;

{Verifica a CPU}
procedure TestCPU;
var
  vTemp : String;

begin
  DetectCPU;
  {armazena o tipo da CPU em uma variavel global}
  vCPUType := GetCPUType;

  {mostra informacoes da CPU}
  vTemp := CPUType2Str(vCPUType);
  if (vTemp <> '') then
    Writeln('CPU ', vTemp, ' detectado')
  else
    Writeln('CPU desconhecido...');

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

{Obtem parametros da imagem do kernel}
procedure GetKernelParam;
var
  vLOSHeader : PLOSHeader;
  vTeste : Boolean;
  vError : String;

begin
  {verifica se o arquivo contem um cabecalho valido}
  Write('Verificando imagem... ');

  {obtem o cabecalho}
  vLOSHeader := GetLOSHeader(vKernelName);

  vError := '';
  vTeste := (vLOSHeader <> nil);

  {se nao eh arquivo LOS}
  if not vTeste then
    vError := 'Arquivo nao eh um arquivo LOS valido';

  {verifica por imagem de kernel}
  if vTeste then
  begin
    vTeste := (vLOSHeader^.FileType = 'KRNLIMG');

    {se nao eh imagem de kernel}
    if not vTeste then
      vError := 'Arquivo nao eh uma imagem de kernel (Dado: ' +
        vLOSHeader^.FileType + ')';
  end;

  {verifica versao}
  if vTeste then
  begin
    vTeste := (vLOSHeader^.TypeVersion.Major = cKrnlHdrVersion.Major) and
      (vLOSHeader^.TypeVersion.Minor = cKrnlHdrVersion.Minor);

    {se versao incorreta}
    if not vTeste then
      vError := 'Versao incorreta da imagem (Esperado: ' +
        IntToStr(cKrnlHdrVersion.Major) + '.' +
        IntToStr(cKrnlHdrVersion.Minor) + '; Dado: ' +
        IntToStr(vLOSHeader^.TypeVersion.Major) + '.' +
        IntToStr(vLOSHeader^.TypeVersion.Minor) + ')';
  end;

  {verifica arquitetura}
  if vTeste then
  begin
    vTeste  := (vLOSHeader^.MetaSize >= SizeOf(TKrnlHdrArch)) and
      (vLOSHeader^.MetaData <> nil);

    if not vTeste then
      vError := 'Tamanho do MetaDados errado (Esperado >= ' +
      IntToStr(SizeOf(TKrnlHdrArch)) + '; Dado: ' +
      IntToStr(vLOSHeader^.MetaSize) + ')';

    if vTeste then
    begin
      vTeste := (PKrnlHdrArch(vLOSHeader^.MetaData)^.ArchBase = 0) and
        (PKrnlHdrArch(vLOSHeader^.MetaData)^.ArchBits = 32);

      {arquitetura incorreta}
      if not vTeste then
        vError := 'Arquitetura incorreta (Esperado: 0/32; Dado: ' +
          IntToStr(PKrnlHdrArch(vLOSHeader^.MetaData)^.ArchBase) + '/' +
          IntToStr(PKrnlHdrArch(vLOSHeader^.MetaData)^.ArchBits) + ')';
    end;
  end;

  {verifica o tamanho do Metadata}
  if vTeste then
  begin
    vTeste := (vLOSHeader^.MetaSize = SizeOf(TKrnlHdr_x86_32));

    {tamanho errado}
    if not vTeste then
      vError := 'Tamanho do MetaDados errado (Esperado: ' +
        IntToStr(SizeOf(TKrnlHdr_x86_32)) + '; Dado: ' +
        IntToStr(vLOSHeader^.MetaSize) + ')';
  end;

  {se falha no cabecalho, termina}
  if not vTeste then
  begin
    Writeln('FALHA');
    Writeln(vError);
    Writeln('Imagem de kernel invalida. Abortando!');
    Finish;
  end
  else
    Writeln('OK');

  {cabecalho ok, pegando informacoes}
  vKernelTable := PKrnlHdr_x86_32(vLOSHeader^.MetaData)^;

  if vDebug then
  begin
    {mostra valores, util para debug}
    Writeln;
    Writeln('Parametros do kernel:');
    Writeln;
    Writeln('*** Metadados - requisitos ***');
    Writeln('CPU Model: ', CPUType2Str(TCPUType(vKernelTable.CPUModel)));
    Writeln('CPU Mode:  ', vKernelTable.CPUMode);
    Writeln('Memory Align: ', vKernelTable.MemAlign);
    Writeln('Stack Size: 0x', DWordToHex2(vKernelTable.StackSize));
    Writeln('Heap Size:  0x', DWordToHex2(vKernelTable.HeapSize));
    Writeln;
    Writeln('*** Metadados - imagem ***');
    Writeln('KernelStart: 0x', DWordToHex2(vKernelTable.KernelStart));
    Writeln('KernelEnd:   0x', DWordToHex2(vKernelTable.KernelEnd));
    Writeln('Entry Point: 0x', DWordToHex2(vKernelTable.EntryPoint));
    Writeln;
    Writeln('*** Metadados - segmentos ***');
    Writeln('Code: 0x', DWordToHex2(vKernelTable.Code));
    Writeln('Data: 0x', DWordToHex2(vKernelTable.Data));
    Writeln('BSS:  0x', DWordToHex2(vKernelTable.BSS));
  end;
end;

{Verifica se parametros sao correspondidos}
procedure CheckParam;
var
  vBlockSize : DWord;

  vMemoryIni : DWord;
  vMemoryEnd : DWord;
  vMemorySize : DWord;

  vFreeMemIni : DWord;
  vFreeMemEnd : DWord;

  vImgIni : DWord;
  vImgEnd : DWord;
  vImgSize : DWord;

  vStackHigh : Boolean;
  vStackBSize : DWord;
  vStackIni : DWord;
  vStackEnd : DWord;

  vHeapGrow : Boolean;
  vHeapIni : DWord;
  vHeapEnd : DWord;
  vHeapBSize : DWord;

  vFreeMemBSize : DWord;
  vFreeMemSize  : DWord;
  vFreeMemStart : DWord;

begin
  { *** verificando a CPU *** }
  Write('Verificando CPU minima (', CPUType2Str(TCPUType(vKernelTable.CPUModel)), '): ');

  if (vCPUType > TCPUType(vKernelTable.CPUModel)) then
    Writeln('OK')
  else
  begin
    Writeln('FALHA');
    Finish;
  end;

  if (vKernelTable.CPUMode <> 2) then
    {0-real, 1-pm.segmentado, 2-pm.flat, 3-pm-paginado}
  begin
    Writeln('Imagem utiliza o processador em um modo nao suportado. Abortando!');
    Finish;
  end;

  { *** calculando memoria disponivel *** }
  if vDebug then
    Writeln;

  Write('Verificando memoria... ');

  if vDebug then
    Writeln;

  vBlockSize := 1 shl vKernelTable.MemAlign;

  vMemoryIni := ($FFFFF shr vKernelTable.MemAlign) + 1;
  vMemoryEnd := (($100000 + (vHighMemory shl 10)) shr vKernelTable.MemAlign) - 1;
  vMemorySize := vMemoryEnd - vMemoryIni + 1;

  vFreeMemIni := vMemoryIni;
  vFreeMemEnd := vMemoryEnd;

  if vDebug then
  begin
    Writeln(' ------------------------------ Superior ------------------------------ ');
    Writeln(' * Alinhamento : ', vBlockSize, ' bytes');
    Writeln(' - Tamanho: ', vHighMemory, ' Kbytes [ ', vMemorySize, ' bloco(s) ]');
  end;

  { *** calculando posicao imagem *** }
  vImgIni := vKernelTable.KernelStart shr vKernelTable.MemAlign;
  vImgEnd := (vKernelTable.KernelEnd - 1) shr vKernelTable.MemAlign;
  vImgSize := vImgEnd - vImgIni + 1;

  if vDebug then
  begin
    Writeln(' ------------------------------- Imagem ------------------------------- ');
    Writeln(' - Inicio: ', DWordToHex2(vKernelTable.KernelStart));
    Writeln(' - Tamanho: ', vKernelTable.KernelEnd - vKernelTable.KernelStart,
      ' bytes [ ', vImgSize, ' bloco(s) ]');
    Writeln(' - Ponto de entrada: 0x', DWordToHex2(vKernelTable.EntryPoint));
  end;

  {verifica se ponto de entrada esta na imagem}
  if (vKernelTable.EntryPoint < vKernelTable.KernelStart) or
    (vKernelTable.EntryPoint > vKernelTable.KernelEnd) then
  begin
    if not vDebug then
      Writeln('FALHA');

    Writeln;
    Writeln('Ponto de Entrada localizado fora da imagem do Kernel. Abortando!');
    Finish;
  end;

  {verifica se tem memoria para a imagem}
  if (vImgIni < vFreeMemIni) or (vImgEnd > vFreeMemEnd) then
  begin
    if not vDebug then
      Writeln('FALHA');

    Writeln;
    Writeln('Imagem posicionada fora da memoria. Abortando!');
    Finish;
  end;

  {calculando memoria livre}
  vFreeMemIni := vImgEnd + 1;

  { *** calculando posicao do bloco de pilha *** }
  vStackHigh := (vKernelTable.StackSize = 0);

  if vStackHigh then
    vKernelTable.StackSize := vBlockSize;

  vStackBSize := ((vKernelTable.StackSize - 1) shr vKernelTable.MemAlign) + 1;

  if vDebug then
  begin
    Writeln(' ------------------------------- Pilha -------------------------------- ');

    if vStackHigh then
      Writeln(' - Modo Expansivel')
    else
      Writeln(' - Modo Fixo');

    Writeln(' - Tamanho: ', vKernelTable.StackSize, ' bytes [ ', vStackBSize, ' bloco(s) ]');
  end;

  if vStackHigh then
  begin
    {pilha na parte superior da memoria}
    vStackEnd := vFreeMemEnd;
    vStackIni := vStackEnd - vStackBSize + 1;
  end
  else
  begin
    {pilha apos o codigo}
    vStackIni := vFreeMemIni;
    vStackEnd := vStackIni + vStackBSize - 1;
  end;

  if (vStackIni < vFreeMemIni) or (vStackEnd > vFreeMemEnd) then
  begin
    if not vDebug then
      Writeln('FALHA');

    Writeln;
    Writeln('Pilha posicionada fora da memoria. Abortando!');
    Finish;
  end;

  vStackStart := ((vStackEnd + 1) shl vKernelTable.MemAlign) - 4;
  vKernelTable.StackSize := (vStackEnd - vStackIni + 1) shl vKernelTable.MemAlign;

  if vDebug then
    Writeln(' - Inicio:  0x', DWordToHex2(vStackStart));

  {calculando memoria livre}
  if vStackHigh then
    vFreeMemEnd := vStackIni - 1
  else
    vFreeMemIni := vStackEnd + 1;

  { *** calculando posicao do bloco de heap *** }
  vHeapGrow := (vKernelTable.HeapSize = 0);

  if vHeapGrow then
  begin
    {heap expansivel}
    vHeapIni := vFreeMemIni;
    vHeapEnd := vFreeMemEnd;

    vHeapBSize := vHeapEnd - vHeapIni + 1;
    vKernelTable.HeapSize := vHeapBSize shl vKernelTable.MemAlign;
  end
  else
  begin
    {heap fixo}
    vHeapBSize := ((vKernelTable.HeapSize - 1) shr vKernelTable.MemAlign) + 1;

    vHeapIni := vFreeMemIni;
    vHeapEnd := vHeapIni + vHeapBSize - 1;
  end;

  if vDebug then
  begin
    Writeln(' ------------------------------- Heap --------------------------------- ');

    if vHeapGrow then
      Writeln(' - Modo Expansivel')
    else
      Writeln(' - Modo Fixo');

    Writeln(' - Tamanho: ', vKernelTable.HeapSize, ' bytes [ ', vHeapBSize, ' bloco(s) ]');
  end;

  if (vHeapIni < vFreeMemIni) or (vHeapEnd > vFreeMemEnd) then
  begin
    if not vDebug then
      writeln('FALHA');

    Writeln;
    Writeln('Heap posicionado fora da memoria. Abortando!');
    Finish;
  end;

  vHeapStart := vHeapIni shl vKernelTable.MemAlign;
  vKernelTable.HeapSize := (vHeapEnd - vHeapIni + 1) shl vKernelTable.MemAlign;

  if vDebug then
    Writeln(' - Inicio:  0x', DWordToHex2(vHeapStart));

  {calculando memoria livre}
  vFreeMemIni := vHeapEnd + 1;

  { *** memoria livre *** }
  vFreeMemBSize := vFreeMemEnd - vFreeMemIni + 1;
  vFreeMemSize := (vFreeMemBSize shl vKernelTable.MemAlign);

  if (vFreeMemBSize = 0) then
    vFreeMemStart := $FFFFFFFF
  else
    vFreeMemStart := vFreeMemIni shl vKernelTable.MemAlign;

  vFreeHighMemStart := vFreeMemStart;
  vFreeHighMemSize := vFreeMemSize;

  if vDebug then
  begin
    Writeln(' ---------------------------- Memoria livre --------------------------- ');
    Writeln(' - Inicio:  0x', DWordToHex2(vFreeMemStart));
    Writeln(' - Tamanho: ', vFreeMemSize, ' Kbytes [ ', vFreeMemBSize, ' bloco(s) ]');
    Writeln(' ---------------------------------------------------------------------- ');
  end
  else
    Writeln('OK');
end;

{Testa suporte de A20 pela BIOS}
function TestA20Bios : Boolean;
  function DoTest : Boolean;
  var
    vTemp : Integer;
    vStatus : Boolean;
    vCheck : Boolean;

  begin
    {padrao retornar false}
    DoTest := False;

    { * pega o status atual * }
    vTemp := BiosA20Status;

    if (vTemp = -1) then
      {a bios retornou erro}
      Exit;

    {a bios retornou ok}
    vStatus := (vTemp = 1);
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status pela bios diferente do teste}
      Exit;

    {bios e teste combinam}

    {alterna o estado}
    if vStatus then
      {se habilitado, desabilite}
      vStatus := BiosDisableA20
    else
      {se desabilitado, habilite}
      vStatus := BiosEnableA20;

    if not vStatus then
      {funcao resultou erro}
      Exit;

    {funcao retornou ok}
    {pega o status atual}
    vTemp := BiosA20Status;

    if (vTemp = -1) then
      {a bios retornou erro}
      Exit;

    {a bios retornou ok}
    vStatus := (vTemp = 1);

    {verifica se inverteu o estado, vCheck ainda possui valor anterior}
    if (vStatus = vCheck) then
      {status igual o anterior}
      Exit;

    {faz novo teste de memoria}
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status pela bios diferente do teste}
      Exit;

    {bios e teste combinam, passou!}
    DoTest := True;
  end;

var
  vResult : Boolean;

begin
  {faz o teste uma vez, inverte o estado}
  vResult := DoTest;

  if vResult then
    {se 1o teste foi ok faz novamente, revertendo}
    vResult := DoTest;

  TestA20Bios := vResult;
end;

{Testa suporte de A20 pelo KBC}
function TestA20KBC : Boolean;
  function DoTest : Boolean;
  var
    vStatus : Boolean;
    vCheck : Boolean;

  begin
    {padrao retornar false}
    DoTest := False;

    { * pega o status atual * }
    vStatus := StatusA20KBC8042;
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status diferente do teste}
      Exit;

    {status e teste combinam}
    {alterna o estado}
    if vStatus then
      {se habilitado, desabilite}
      vStatus := DisableA20KBC8042
    else
      {se desabilitado, habilite}
      vStatus := EnableA20KBC8042;

    if not vStatus then
      {funcao resultou erro}
      Exit;

    {funcao retornou ok}
    {pega o status atual}
    vStatus := StatusA20KBC8042;

    {verifica se inverteu o estado, vCheck ainda possui valor anterior}
    if (vStatus = vCheck) then
      {status igual o anterior}
      Exit;

    {faz novo teste de memoria}
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status diferente do teste}
      Exit;

    {Status e teste combinam, passou!}
    DoTest := True;
  end;

var
  vResult : Boolean;

begin
  {faz o teste uma vez, inverte o estado}
  vResult := DoTest;

  if vResult then
    {se 1o teste foi ok faz novamente, revertendo}
    vResult := DoTest;

  TestA20KBC := vResult;
end;

{Testa suporte de A20 pelo Fast Gate}
function TestA20Fast : Boolean;
  function DoTest : Boolean;
  var
    vStatus : Boolean;
    vCheck : Boolean;

  begin
    {padrao retornar false}
    DoTest := False;

    { * pega o status atual * }
    vStatus := StatusA20FastGate;
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status diferente do teste}
      Exit;

    {status e teste combinam}
    {alterna o estado}
    if vStatus then
      {se habilitado, desabilite}
      vStatus := DisableA20FastGate
    else
      {se desabilitado, habilite}
      vStatus := EnableA20FastGate;

    if not vStatus then
      {funcao resultou erro}
      Exit;

    {funcao retornou ok}
    {pega o status atual}
    vStatus := StatusA20FastGate;

    {verifica se inverteu o estado, vCheck ainda possui valor anterior}
    if (vStatus = vCheck) then
      {status igual o anterior}
      Exit;

    {faz novo teste de memoria}
    vCheck := CheckA20;

    if (vStatus <> vCheck) then
      {status diferente do teste}
      Exit;

    {Status e teste combinam, passou!}
    DoTest := True;
  end;

var
  vResult : Boolean;

begin
  {faz o teste uma vez, inverte o estado}
  vResult := DoTest;

  if vResult then
    {se 1o teste foi ok faz novamente, revertendo}
    vResult := DoTest;

  TestA20Fast := vResult;
end;

{Detecta suporte a Fast Gate pelo KBC}
function DetectA20Fast : Boolean;
var
  vStatus : Boolean;
  vResult : Boolean;

begin
  {padrao retornar false}
  DetectA20Fast := False;

  vStatus := StatusA20KBC8042;

  if (vStatus <> StatusA20FastGate) then
    Exit;

  if vStatus then
    {habilitado, desabilita}
    vResult := DisableA20KBC8042
  else
    {desabilitado, habilita}
    vResult := EnableA20KBC8042;

  if not vResult then
    Exit;

  {inverte o status}
  vStatus := not vStatus;

  if (vStatus <> StatusA20KBC8042) then
    Exit;

  if (vStatus <> StatusA20FastGate) then
    Exit;

  {Ok, Fast Gate possivelmente suportada}
  DetectA20Fast := True;
end;

{Habilita o A20}
procedure EnableA20;
var
  vTemp : Integer;

begin
  Write('Verificando suporte a A20 pela BIOS... ');

  vTemp := BiosA20Support;

  vA20Bios := (vTemp <> -1) ;

  if vA20Bios then
  begin
    Writeln('OK');

    vA20KBC := TestBitsByte(vTemp, cA20SupportKBC8042);
    vA20Fast := TestBitsByte(vTemp, cA20SupportFastGate);
  end
  else
    Writeln('FALHOU');

  if vDebug then
    Writeln;

  if vA20Bios then
  begin
    {Testa suporte pela BIOS}
    Write('Testando suporte A20 pela BIOS... ');

    vA20Bios := TestA20Bios;

    if vA20Bios then
      Writeln('OK')
    else
      Writeln('FALHOU');
  end;

  {se Bios falhar}
  if not vA20Bios then
  begin
    {inicializa variaveis, considera possivel que tenha para testes posteriores...}
    vA20KBC := True;
    vA20Fast := False; {se não conseguir detectar considera como sem suporte...}
  end;

  if vA20KBC then
  begin
    {Testa suporte pelo KBC}
    Write('Testando suporte A20 pelo KBC8042... ');

    vA20KBC := TestA20KBC;

    if vA20KBC then
      Writeln('OK')
    else
      Writeln('FALHOU');
  end;

  if ((not vA20Bios) and vA20KBC) then
  begin
    {Sem suporte da BIOS, tenta detectar se possivel Fast Gate}
    {Usa o KBC8042 como maneira segura}
    Write('Tentando detectar a Fast Gate pelo KBC8042... ');

    vA20Fast := DetectA20Fast;

    if vA20Fast then
      Writeln('OK')
    else
      Writeln('FALHOU');
  end;

  if vA20Fast then
  begin
    {se Fast Gate detectado, testa ele}
    Write('Testando suporte A20 por Fast Gate... ');

    vA20Fast := TestA20Fast;

    if vA20Fast then
      Writeln('OK')
    else
      Writeln('FALHOU');
  end;

  if vDebug then
    Writeln;

  {verifica se ha pelo menos um suporte}
  if (vA20Bios or vA20KBC or vA20Fast) then
  begin
    {verifica de A20 ficou habilitada, se nao habilita}

    if vA20Fast then
    begin
      {faca pelo meio rapido}

        if not StatusA20FastGate then
        begin
          Write('Habilitando A20 por Fast Gate... ');

          if EnableA20FastGate then
            Writeln('OK')
          else
            Writeln('FALHOU');
        end;
    end
    else
      if vA20Bios then
      begin
        {faca pelo meio seguro}

        vTemp := BiosA20Status;

        if (vTemp = -1) then
          Writeln('Falha na habilitacao da A20 pela BIOS')
        else
          if (vTemp = 0) then
          begin
            Write('Habilitando A20 pela BIOS... ');

            if BiosEnableA20 then
              Writeln('OK')
            else
              Writeln('FALHOU');
          end;
      end
      else
      begin
        {faca pelo meio antigo}
        if not StatusA20KBC8042 then
        begin
          Write('Habilitando A20 pelo KBC8042... ');

          if EnableA20KBC8042 then
            Writeln('OK')
          else
            Writeln('FALHOU');
        end;
      end;

    {executa o teste final}
    Write('Verificado se realmente a A20 esta habilitada... ');

    if CheckA20 then
      Writeln('OK')
    else
    begin
      Writeln('FALHA');
      Writeln('Houve um erro durante o processo de habilitacao da A20, abortando!');
      Finish;
    end;
  end
  else
  begin
    Writeln('Sem suporte a A20 detectado, abortando!');
    Finish;
  end;
end;

{Configura a GDT}
procedure ConfigGDT;
var
  Base : DWord;
  Limite : DWord;
  ACS : Byte;
  ATR : Byte;

  PTemp : TPointerFar16;

  function DoSetup(Entrada : Word) : Word;
  var
    vDesc : Word;

  begin
    SetupGDT(GDT[Entrada], Base, Limite, ACS, ATR);

    vDesc := Entrada shl 3;

    if vDebug then
    begin
      Writeln('0x', WordToHex(vDesc),
        ' => Base: ', DWordToHex2(Base),
        '  Limite: ', DWordToHex2(Limite),
        '  ACS: ', ByteToHex(ACS),
        '  ATR: ', ByteToHex(ATR));
    end;

    DoSetup := vDesc;
  end;

begin
  Write('Configurando GDT... ');

  if vDebug then
  begin
    Writeln;
    Writeln;
  end;

  {cria GDT, configura}

  {0x00 -- descritor nulo}
  Base := 0;
  Limite := 0;
  ACS := 0;
  ATR := 0;
  vCodeDesc := DoSetup(0); {usando temporariamente...}

  {todos os descritores usam as mesmas definicoes}
  Base := $0;
  Limite := $FFFFF;
  ATR := ATR_FLAT32;

  {0x08 -- descritor do segmento de codigo, kernel}
  ACS := ACS_CODE;
  vCodeDesc := DoSetup(1);

  {0x10 -- descritor do segmento de dados}
  ACS := ACS_DATA;
  vDataDesc := DoSetup(2);

  {0x18 -- descritor do segmento de pilha}
  ACS := ACS_STACK;
  vStackDesc := DoSetup(3);

  {setando o registrador GDTR}

  {pegando o endereco da GDT}
  PTemp.Seg := Seg(GDT);
  PTemp.Ofs := Ofs(GDT);
  {convertendo o endereco linear para DWord}
  Base := PFar16ToPLinear(PTemp);

  GDTR.Base  := Base;
  GDTR.Limit := SizeOf(GDT) - 1;

  LoadGDT(@GDTR);

  if not vDebug then
    Writeln('OK');
end;

{Habilita o Modo Unreal}
procedure StartUnReal(DescFlat : Word);
begin
  Write('Configurando o UnReal Mode (atraves do descritor 0x', WordToHex(DescFlat), ') ... ');

  {desabilita as interrupcoes para que as IRQs nao causem excecoes}
  DisableInt;

  {desabilita as NMIs tambem}
  DisableNMIs;

  {chama o procedimento para habilitar o Unreal}
  EnableUnreal(DescFlat);

  {habilita as NMIs}
  EnableNMIs;

  {habilita as interrupcoes}
  EnableInt;

  Writeln('OK');
end;

{Copia o kernel para a memoria}
procedure LoadKernel;
var
  vKernel : File;
  vKernelSize : DWord;
  vBufferSize : Word;
  vBuffer : Pointer;
  vBufferSeg : TPointerFar16;
  vBufferLinear : DWord;
  nPassos : Word;
  vPasso : Word;
  vLidos : Word;

begin
  {abre a imagem de kernel}
  Assign(vKernel, vKernelName);
  Reset(vKernel, 1);

  {pega o tamanho do arquivo}
  vFileSize := FileSize(vKernel);

  {pega o tamanho final do kernel}
  vKernelSize := vKernelTable.KernelEnd - vKernelTable.KernelStart;

  {se arquivo for menor copia so o que tem no arquivo}
  if (vFileSize < vKernelSize) then
    vKernelSize := vFileSize;

  if vDebug then
  begin
    Writeln('Preparando para carregar o kernel...');
    Writeln('Inico do kernel: 0x', DWordToHex2(vKernelTable.KernelStart));
    Writeln('Kernel com ', vKernelSize, ' Bytes.');
  end;

  {criando buffer}
  if (cMaxBuffer < MaxAvail) then
    vBufferSize := cMaxBuffer
  else
    vBufferSize := MaxAvail;

  if (vBufferSize > vKernelSize) then
    vBufferSize := vKernelSize;

  GetMem(vBuffer , vBufferSize);

  vBufferSeg := TPointerFar16(vBuffer);
  vBufferLinear := PFar16ToPLinear(vBufferSeg);

  if vDebug then
  begin
    Writeln('Buffer criado com ', vBufferSize, ' bytes em 0x', DWordToHex2(vBufferLinear));
    Writeln;
  end;

  {Verificando que o kernel pode ser copiado em quantos passos}
  if (vKernelSize > vBufferSize) then
  begin
    nPassos := vKernelSize div vBufferSize;

    if ((vKernelSize mod vBufferSize) <> 0) then
      Inc(nPassos);

    Write('Kernel grande, carregando em ', nPassos, ' passos...');
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
    CopyLinear(vBufferLinear, vKernelTable.KernelStart + ((vPasso - 1) * vBufferSize), vLidos);
  end;

  {mostra informacao e fecha o arquivo}
  Writeln(' carregado!');
  Close(vKernel);
end;

{Configura dados sobre a memoria inferior}
procedure ConfigLowMem;
var
  vTempSeg : TPointerFar16;
  vLowMemEnd : DWord;
  vEBDASeg : Word absolute $40:$0E;
  vEBDAAddr : DWord;

begin
  vTempSeg.Ofs := 0;

  {pega o endereço de inicio do bootloader (pode ser sobreecrito)}
  vTempSeg.Seg := CSeg;
  vFreeLowMemStart := PFar16ToPLinear(vTempSeg);

  {pega o endereco final da memoria inferior}
  vLowMemEnd := (vLowMemory * 1024) - 1;

  {pega o endereco da EBDA}
  vTempSeg.Seg := vEBDASeg;
  vEBDAAddr := PFar16ToPLinear(vTempSeg);

  {verifica se EBDA esta na memoria livre}
  if (vEBDAAddr > vFreeLowMemStart) and (vEBDAAddr < vLowMemEnd) then
    vLowMemEnd := vEBDAAddr - 1;

  vFreeLowMemSize := vLowMemEnd - vFreeLowMemStart + 1;
end;

{Configura a tabela de boot passada ao kernel}
procedure ConfigBootTable;
begin
  {assinatura da tabela}
  vBootTable.LOSSign := cLOSSign;
  vBootTable.BTSign := cBTSign;
  vBootTable.Version := cBTVersion;
  {dados}
  vBootTable.CPULevel := Byte(vCPUType);
  vBootTable.LowMemory := vLowMemory;
  vBootTable.HighMemory := vHighMemory;
  vBootTable.CRTInfo := vCRTInfo;
  vBootTable.CRTRows := vCRTRows;
  vBootTable.CRTCols := vCRTCols;
  vBootTable.CRTPort := vCRTPort;
  vBootTable.CRTSeg := vCRTSeg;
  vBootTable.A20KBC := vA20KBC;
  vBootTable.A20Bios := vA20Bios;
  vBootTable.A20Fast := vA20Fast;
  vBootTable.ImgIni := vKernelTable.KernelStart;
  vBootTable.ImgEnd := vKernelTable.KernelEnd - 1;
  vBootTable.StackIni := vStackStart + 3;
  vBootTable.StackEnd := vStackStart - vKernelTable.StackSize + 4;
  vBootTable.HeapIni := vHeapStart;
  vBootTable.HeapEnd := vHeapStart + vKernelTable.HeapSize - 1;
  { adicionados na versao 2 }
  vBootTable.FreeLowIni := vFreeLowMemStart;
  vBootTable.FreeLowEnd := vFreeLowMemStart + vFreeLowMemSize  - 1;
  vBootTable.FreeHighIni := vFreeHighMemStart;
  vBootTable.FreeHighEnd := vFreeHighMemStart + vFreeHighMemSize - 1;
  vBootTable.FootSign := cLOSSign;
end;

{Chama o kernel}
procedure ExecKernel;
var
  vCS : Word;
  vDS : Word;
  vES : Word;
  VSS : Word;

  vEntry : DWord;
  vStack : DWord;
  vParam : DWord;

  PTemp : TPointerFar16;

begin
  {prepara parametros para a chamada do kernel}
  vCS := vCodeDesc;
  vEntry := vKernelTable.EntryPoint;

  vDS := vDataDesc;
  vES := vDataDesc;

  vSS := vStackDesc;
  vStack := vStackStart;

  {convertendo o endereco da tabela de boot}
  Pointer(PTemp) := @vBootTable;
  vParam := PFar16ToPLinear(PTemp);

  if vDebug then
  begin
    Writeln;
    Writeln('Ambiente de execucao:');
    Writeln('CS: ', WordToHex(vCS));
    Writeln('DS: ', WordToHex(vDS));
    Writeln('ES: ', WordToHex(vES));
    Writeln('SS: ', WordToHex(vSS));
    Writeln('Entry: ', DWordToHex2(vEntry));
    Writeln('Stack: ', DWordToHex2(vStack));
    Writeln('Param: ', DWordToHex2(vParam));
    Writeln;
  end;

  Writeln('Executando kernel em 0x', DWordToHex2(vEntry));
  WaitKey(cDebugMode <> 0);

  {desabilita as interrupcoes para que as IRQs nao causem excecoes}
  DisableInt;

  {desabilita as NMIs tambem}
  DisableNMIs;

  {Vai para o modo protegido chamando o kernel}
  GoKernel32PM(vCS, vDS, vES, vSS, vEntry, vStack, vParam);

  {Impossivel o retorno a esse ponto pelo kernel}
end;

{Procedimento principal}
begin
  GetCommandLine;

  {verifica requisitos}
  Writeln;
  TestCPU;
  TestMem;
  TestCRT;

  WaitKey(False);

  Writeln;
  Writeln('Imagem do kernel: ', vKernelName);

  {verifica se existe a imagem do kernel}
  if not FileExists(vKernelName) then
  begin
    Writeln('Imagem de kernel nao encotrada. Abortando!');
    Finish;
  end;

  {pegando parametros do kernel}
  GetKernelParam;

  WaitKey(False);

  {verifica parametros}
  Writeln;
  CheckParam;

  WaitKey(False);

  {habilita A20}
  Writeln;
  EnableA20;

  {configura a GDT}
  Writeln;
  ConfigGDT;

  {habilita Unreal Mode}
  if vDebug then
    Writeln;

  StartUnReal(vDataDesc);

  {configura dados sobre a memoria inferior}
  ConfigLowMem;

  {configura a tabela de boot}
  ConfigBootTable;
  WaitKey(False);

  {mostra tavela de boot se debug}
  if vDebug then
  begin
    {informacoes sobre a tabela de boot}
    Writeln;
    Writeln('Tabela de boot:');
    Writeln;
    Writeln('CPULevel: ', vBootTable.CPULevel);
    Writeln('Memory (Low/High): ', vBootTable.LowMemory, '/',
      vBootTable.HighMemory);
    Writeln;
    Writeln('CRTInfo:         0x', WordToHex(vBootTable.CRTInfo));
    Writeln('CRTRows/CRTCols: ', vBootTable.CRTRows, '/', vBootTable.CRTCols);
    Writeln('CRTPort/CRTSeg:  0x', WordToHex(vBootTable.CRTPort), '/0x',
      WordToHex(vBootTable.CRTSeg));
    Writeln;
    Write('A20 Support: ');
    if vBootTable.A20Bios then Write(' Bios ');
    if vBootTable.A20KBC then Write(' KBC8042 ');
    if vBootTable.A20Fast then Write(' FastGate ');
    Writeln;
    Writeln;
    Writeln('Image (Ini/End): 0x', DWordToHex2(vBootTable.ImgIni), '/0x',
      DWordToHex2(vBootTable.ImgEnd));
    Writeln('Stack (Ini/End): 0x', DWordToHex2(vBootTable.StackIni), '/0x',
      DWordToHex2(vBootTable.StackEnd));
    Writeln('Heap  (Ini/End): 0x', DWordToHex2(vBootTable.HeapIni), '/0x',
      DWordToHex2(vBootTable.HeapEnd));
    Writeln;
    Writeln('Free Low Memory  (Ini/End): 0x', DWordToHex2(vBootTable.FreeLowIni),
      '/0x', DWordToHex2(vBootTable.FreeLowEnd));
    Writeln('Free High Memory (Ini/End): 0x', DWordToHex2(vBootTable.FreeHighIni),
      '/0x', DWordToHex2(vBootTable.FreeHighEnd));
    Writeln;

    WaitKey(True);
  end;

  {carrega o kernel}
  Writeln;
  LoadKernel;

  {chama o kernel}
  ExecKernel;
end.
