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
  Versao: 0.13
  Data: 21/04/2013
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

uses CopyRigh, Basic, CPUInfo, MemInfo, CRTInfo, EStrings, BootKT, BootBT,
  A20, Intrpts, BootAux,  PM, CRT;

{Constantes gerais}
const
  cKernelName = 'pkrnl05.bin';
  cCPUMin = CT80386;  {minimo para o boot}
  cCPUMax = CT80586;  {maximo detectavel}
  cHighMemoryMin = 1024; {1M}
  cMaxBuffer = $FFF0;

{Variaveis globais}
var
  {detectado}
  vKernelSize : DWord;
  vCPUType :TCPUType;
  vLowMemory : DWord;
  vHighMemory : DWord;
  vCRTInfo : Word;
  vCRTRows, vCRTCols : Byte;
  vCRTPort, vCRTSeg : Word;
  vA20Bios : Boolean;
  vA20KBC : Boolean;
  vA20Fast : Boolean;
  {fornecido pelo kernel}
  vCPUMin : TCPUType;
  vMemAlign : Byte;
  vEntryPoint : DWord;
  vStackSize : DWord;
  vHeapSize : DWord;
  {estrutural}
  GDT : array[0..3] of TDescrSeg;
  GDTR : TGdtR;
  vCodeDesc : Word;
  vDataDesc : Word;
  vStackDesc : Word;
  {calculado}
  vStackStart : DWord;
  vHeapStart : DWord;
  {passado ao kernel}
  vBootTable : TBootTable;


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
procedure WaitKey;
var
  vKey : Char;

begin
  Writeln;
  Write('Pressione qualquer tecla para continuar... ');
  vKey := ReadKey;
  ClrScr;
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
  vKernel : File;
  vTeste : Boolean;
  vKernelTable : TKernelTable;

begin
  {abre arquivo de kernel}
  Assign(vKernel, cKernelName);
  Reset(vKernel, 1);

  vKernelSize := FileSize(vKernel);

  {verifica se o arquivo contem um cabecalho valido}
  Write('Verificando cabecalho... ');

  vTeste := (vKernelSize >= SizeOf(TKernelTable));

  if vTeste then
  begin
    {se o arquivo tem tamanho para conter uma tabela, le a tabela...}
    BlockRead(vKernel, vKernelTable, SizeOf(TKernelTable));

    {verifica se tem o jmp inicial}
    vTeste := (vKernelTable.JumpInst = $E9);
  end;

  if vTeste then
  begin
    {se jmp ok, verifica assinatura}
    vTeste := (vKernelTable.LOS_Sign = cLOS_Sign) and (vKernelTable.KT_Sign = cKT_Sign);
  end;

  if vTeste then
  begin
    {se assinaturas ok, verifica versao da tabela}
    vTeste := (vKernelTable.KT_Vers = 1);
  end;

  {se falha no cabecalho, termina}
  if not vTeste then
  begin
    Writeln('FALHA');
    Writeln('Imagem de kernel invalida. Abortando!');
    Finish;
  end
  else
    Writeln('OK');

  {cabecalho ok, pegando informacoes}
  vCPUMin := TCPUType(vKernelTable.CPU_Min);
  vMemAlign := vKernelTable.MemAlign;
  vEntryPoint := vKernelTable.EntryPoint;
  vStackSize := vKernelTable.StackSize;
  vHeapSize := vKernelTable.HeapSize;

  Writeln;
  Writeln('Parametros do kernel:');

  {mostra valores, util para debug}
  Writeln;
  Writeln('CPU Minimal:  ', CPUType2Str(vCPUMin));
  Writeln('Memory Align: ', vMemAlign);
  Writeln('Entry Point:  0x', DWordToHex2(vEntryPoint));
  Writeln('Stack Size:   0x', DWordToHex2(vStackSize));
  Writeln('Heap Size:    0x', DWordToHex2(vHeapSize));

  {fecha arquivo do kernel}
  Close(vKernel);
end;

{Verifica se parametros sao correspondidos}
procedure CheckParam;
var
  vBlockSize : DWord;

  vHighMemoryIni : DWord;
  vHighMemoryEnd : DWord;
  vHighMemoryBSize : DWord;

  vFreeMemIni : DWord;
  vFreeMemEnd : DWord;

  vCodeIni : DWord;
  vCodeEnd : DWord;
  vCodeSize : DWord;

  vStackHigh : Boolean;
  vStackBSize : DWord;
  vStackIni : DWord;
  vStackEnd : DWord;

  vHeapBSize : DWord;
  vHeapIni : DWord;
  vHeapEnd : DWord;

  vFreeMemStart : DWord;
  vFreeMemBSize : DWord;
  vFreeMemSize  : DWord;

begin
  { *** verificando a CPU *** }
  Write('Verificando CPU minima (', CPUType2Str(vCPUMin), '): ');

  if (vCPUType > vCPUMin) then
    Writeln('OK')
  else
    Writeln('FALHA');

  { *** calculando memoria disponivel *** }
  Writeln;
  Writeln('Verificando memoria...');

  vBlockSize := 1 shl vMemAlign;

  Writeln(' * Alinhamento : ', vBlockSize, ' bytes');

  vHighMemoryIni := ($FFFFF shr vMemAlign) + 1;
  vHighMemoryEnd := (($100000 + (vHighMemory shl 10)) shr vMemAlign) - 1;
  vHighMemoryBSize := vHighMemoryEnd - vHighMemoryIni + 1;

  Writeln(' - Tamanho: ', vHighMemory, ' Kbytes [ ', vHighMemoryBSize, ' bloco(s) ]');

  vFreeMemIni := vHighMemoryIni;
  vFreeMemEnd := vHighMemoryEnd;

  { *** calculando posicao do bloco de codigo *** }
  Writeln;
  Writeln(' Codigo:');
  Writeln(' - Ponto de entrada: 0x', DWordToHex2(vEntryPoint));

  vCodeIni := vEntryPoint shr vMemAlign;
  vCodeEnd := (vEntryPoint + vKernelSize) shr vMemAlign;
  vCodeSize := vCodeEnd - vCodeIni + 1;

  Writeln(' - Tamanho: ', vKernelSize, ' bytes [ ', vCodeSize, ' bloco(s) ]');

  if (vCodeIni < vFreeMemIni) or (vCodeEnd > vFreeMemEnd) then
  begin
    Writeln;
    Writeln('Codigo posicionado fora da memoria. Abortando!');
    Finish;
  end;

  {calculando memoria livre}
  vFreeMemIni := vCodeEnd + 1;

  { *** calculando posicao do bloco de pilha *** }
  Writeln;
  Writeln(' Pilha:');

  vStackHigh := (vStackSize = 0);

  if vStackHigh then
    Writeln(' - Modo Expansivel')
  else
    Writeln(' - Modo Fixo');

  if vStackHigh then
    vStackSize := vBlockSize;

  vStackBSize := ((vStackSize - 1) shr vMemAlign) + 1;

  Writeln(' - Tamanho: ', vStackSize, ' bytes [ ', vStackBSize, ' bloco(s) ]');

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
    Writeln;
    Writeln('Pilha posicionada fora da memoria. Abortando!');
    Finish;
  end;

  vStackStart := ((vStackEnd + 1) shl vMemAlign) - 4;
  vStackSize := (vStackEnd - vStackIni + 1) shl vMemAlign;
  Writeln(' - Inicio:  0x', DWordToHex2(vStackStart));

  {calculando memoria livre}
  if vStackHigh then
    vFreeMemEnd := vStackIni - 1
  else
    vFreeMemIni := vStackEnd + 1;

  { *** calculando posicao do bloco de heap *** }
  Writeln;
  Writeln(' Heap:');

  if (vHeapSize <> 0) then
    vHeapBSize := ((vHeapSize - 1) shr vMemAlign) + 1
  else
    vHeapBSize := 0;

  Writeln(' - Tamanho: ', vHeapSize, ' bytes [ ', vHeapBSize, ' bloco(s) ]');

  if (vHeapSize = 0) then
  begin
    Writeln(' * Nenhum heap necessario, ignorando...');

    vHeapStart := $FFFFFFFF;
  end
  else
  begin
    vHeapIni := vFreeMemIni;
    vHeapEnd := vHeapIni + vHeapBSize -1;

    if (vHeapIni < vFreeMemIni) or (vHeapEnd > vFreeMemEnd) then
    begin
      Writeln;
      Writeln('Heap posicionado fora da memoria. Abortando!');
      Finish;
    end;

    vHeapStart := vHeapIni shl vMemAlign;
    vHeapSize := (vHeapEnd - vHeapIni + 1) shl vMemAlign;
    Writeln(' - Inicio:  0x', DWordToHex2(vHeapStart));

    {calculando memoria livre}
    vFreeMemIni := vHeapEnd + 1;
  end;

  { *** memoria livre *** }
  Writeln;
  Writeln('Memoria livre:');

  vFreeMemBSize := vFreeMemEnd - vFreeMemIni + 1;
  vFreeMemSize := (vFreeMemBSize shl vMemAlign) shr 10;

  if (vFreeMemBSize = 0) then
    vFreeMemStart := $FFFFFFFF
  else
    vFreeMemStart := vFreeMemIni shl vMemAlign;

  Writeln(' - Inicio:  0x', DWordToHex2(vFreeMemStart));
  Writeln(' - Tamanho: ', vFreeMemSize, ' Kbytes [ ', vFreeMemBSize, ' bloco(s) ]');
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

    Writeln('0x', WordToHex(vDesc),
      ' => Base: ', DWordToHex2(Base),
      '  Limite: ', DWordToHex2(Limite),
      '  ACS: ', ByteToHex(ACS),
      '  ATR: ', ByteToHex(ATR));

    DoSetup := vDesc;
  end;

begin
  Writeln('Configurando GDT... ');
  Writeln;

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

  Writeln('Preparando para carregar o kernel...');
  Writeln('Ponto de entrada: 0x', DWordToHex2(vEntryPoint));
  Writeln('Kernel com ', vKernelSize, ' Bytes.');

  {criando buffer}
  vMaxAvail := MaxAvail;

  if (vMaxAvail > cMaxBuffer) then
    vBufferSize := cMaxBuffer;

  if (vBufferSize > vKernelSize) then
    vBufferSize := vKernelSize;

  GetMem(vBuffer , vBufferSize);

  vBufferSeg := TPointerFar16(vBuffer);
  vBufferLinear := PFar16ToPLinear(vBufferSeg);

  Writeln('Buffer criado com ', vBufferSize, ' bytes em 0x', DWordToHex2(vBufferLinear));
  Writeln;

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
    CopyLinear(vBufferLinear, vEntryPoint + ((vPasso - 1) * vBufferSize), vLidos);
  end;

  {mostra informacao e fecha o arquivo}
  Writeln(' carregado!');
  Close(vKernel);
end;

{Configura a tabela de boot passada ao kernel}
procedure ConfigBootTable;
begin
  {assinatura da tabela}
  vBootTable.LOSSign := cLOSSign;
  vBootTable.BTSign := CBTSign;
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
  vBootTable.CodeIni := vEntryPoint;
  vBootTable.CodeEnd := vEntryPoint + vKernelSize - 1;
  vBootTable.StackIni := vStackStart + 3;
  vBootTable.StackEnd := vStackStart - vStackSize + 4;
  vBootTable.HeapIni := vHeapStart;
  vBootTable.HeapEnd := vHeapStart + vHeapSize - 1;
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
  vEntry := vEntryPoint;

  vDS := vDataDesc;
  vES := vDataDesc;

  vSS := vStackDesc;
  vStack := vStackStart;

  {convertendo o endereco da tabela de boot}
  Pointer(PTemp) := @vBootTable;
  vParam := PFar16ToPLinear(PTemp);

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
  Writeln('Executando kernel em 0x', DWordToHex2(vEntry));

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
  ShowWarning;

  {verifica requisitos}
  Writeln;
  TestCPU;
  TestMem;
  TestCRT;

  Writeln;
  Writeln('Imagem do kernel: ', cKernelName);

  {verifica se existe a imagem do kernel}
  if not FileExists(cKernelName) then
  begin
    Writeln('Imagem de kernel nao encotrada. Abortando!');
    Finish;
  end;

  {pegando parametros do kernel}
  GetKernelParam;

  WaitKey;

  {verifica parametros}
  Writeln;
  CheckParam;

  WaitKey;

  {habilita A20}
  Writeln;
  EnableA20;

  {configura a GDT}
  Writeln;
  ConfigGDT;

  {habilita Unreal Mode}
  Writeln;
  StartUnReal(vDataDesc);

  WaitKey;

  {carrega o kernel}
  Writeln;
  LoadKernel;

  {configura a tabela de boot}
  ConfigBootTable;

  {informacoes sobre a tabela de boot}
  WaitKey;
  Writeln;
  Writeln('Tabela de boot:');
  Writeln;
  Writeln('CPULevel: ', vBootTable.CPULevel);
  Writeln('LowMemory: ', vBootTable.LowMemory);
  Writeln('HighMemory: ', vBootTable.HighMemory);
  Writeln('CRTInfo: 0x', WordToHex(vBootTable.CRTInfo));
  Writeln('CRTRows: ', vBootTable.CRTRows);
  Writeln('CRTCols; ', vBootTable.CRTCols);
  Writeln('CRTPort; 0x', WordToHex(vBootTable.CRTPort));
  Writeln('CRTSeg: 0x', WordToHex(vBootTable.CRTSeg));
  Writeln('A20KBC: ', vBootTable.A20KBC);
  Writeln('A20Bios: ', vBootTable.A20Bios);
  Writeln('A20Fast: ', vBootTable.A20Fast);
  Writeln('CodeIni: 0x', DWordToHex2(vBootTable.CodeIni));
  Writeln('CodeEnd: 0x', DWordToHex2(vBootTable.CodeEnd));
  Writeln('StackIni: 0x', DWordToHex2(vBootTable.StackIni));
  Writeln('StackEnd: 0x', DWordToHex2(vBootTable.StackEnd));
  Writeln('HeapIni: 0x', DWordToHex2(vBootTable.HeapIni));
  Writeln('HeapEnd: 0x', DWordToHex2(vBootTable.HeapEnd));
  Writeln;
  Writeln('Para debug => Ofset do CRTSeg: ', Ofs(vBootTable.CRTSeg) - Ofs(vBootTable));
  WaitKey;

  {chama o kernel}
  ExecKernel;
end.
