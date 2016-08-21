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
  Versao: 0.6
  Data: 13/04/2013
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

uses CopyRigh, CPUInfo, MemInfo, CRTInfo, Basic, EStrings, BootAux, PM,
  Intrpts, CRT, A20;

{Constantes gerais}
const
  cCPUMin = CT80386;
  cCPUMax = CT80586;
  cHighMemoryMin = 2048; {2M}
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
  vA20Bios : Boolean;
  vA20KBC : Boolean;
  vA20Fast : Boolean;

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
  Writeln;

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
  Base : DWord;
  Limite : DWord;
  GDT : array[0..4] of TDescrSeg;
  PTemp : TPointerFar16;
  GDTR : TGdtR;

  vCS : Word;
  vDS : Word;
  vES : Word;
  VSS : Word;
  vEntry : Word;
  vStack : Word;
  vParam : Word;

begin
  Writeln('Configurando GDT... ');
  Writeln;

  {cria GDT, configura}

  {0x00 -- descritor nulo}
  Base := 0;
  Limite := 0;

  SetupGDT(GDT[0], Base, Limite, 0, 0);
  Writeln('0x00 => Base: ', DWordToHex2(Base), ' Limite: ', DWordToHex2(Limite));

  {Todos os descritores abaixo usam o mesmo limite}
  Limite := $FFFF;

  {0x08 -- descritor do segmento de codigo, kernel}
  SetupGDT(GDT[1],  vExecLinear, Limite, ACS_CODE, 0);
  Writeln('0x08 => Base: ', DWordToHex2(vExecLinear), ' Limite: ', DWordToHex2(Limite));

  {0x10 -- descritor do segmento de dados}
  PTemp.Seg := GetDS;
  PTemp.Ofs := 0;
  {convertendo o endereco linear para DWord}
  Base := PFar16ToPLinear(PTemp);
  SetupGDT(GDT[2], Base, Limite, ACS_DATA, 0);
  Writeln('0x10 => Base: ', DWordToHex2(Base), ' Limite: ', DWordToHex2(Limite));

  {0x18 -- descritor do segmento de pilha}
  PTemp.Seg := GetSS;
  PTemp.Ofs := 0;
  {convertendo o endereco linear para DWord}
  Base := PFar16ToPLinear(PTemp);
  SetupGDT(GDT[3], Base, Limite, ACS_STACK, 0);
  Writeln('0x18 => Base: ', DWordToHex2(Base), ' Limite: ', DWordToHex2(Limite));

  {0x20 -- descritor do segmento de video em modo texto}
  PTemp.Seg := vCRTSeg;
  PTemp.Ofs := 0;
  {convertendo o endereco linear para DWord}
  Base := PFar16ToPLinear(PTemp);
  SetupGDT(GDT[4], Base, Limite, ACS_DATA, 0);
  Writeln('0x20 => Base: ', DWordToHex2(Base), ' Limite: ', DWordToHex2(Limite));

  {setando o registrador GDTR}

  {pegando o endereco da GDT}
  PTemp.Seg := Seg(GDT);
  PTemp.Ofs := Ofs(GDT);
  {convertendo o endereco linear para DWord}
  Base := PFar16ToPLinear(PTemp);

  GDTR.Base  := Base;
  GDTR.Limit := SizeOf(GDT) - 1;

  LoadGDT(@GDTR);

  Writeln;
  Writeln('Configurado!');

  {prepara parametros para a chamada do kernel}
  vCS := $08; {descritor para o segmento de codigo}
  vEntry := 0;

  vDS := $10; {descritor para o segmento de dados}
  vES := $10;

  vSS := $18; {descritor para o segmento de pilha}
  vStack := GetSP;

  {1k de pilha eh suficiente para teste}
  if (vStack > $400) then
    vStack := $3FE
  else
    vStack := ((vStack - 10) div $10) * $10;

  vParam := $20; {descritor do segmento de video}

  Writeln;
  Writeln('Ambiente de execucao:');
  Writeln('CS: ', WordToHex(vCS));
  Writeln('DS: ', WordToHex(vDS));
  Writeln('ES: ', WordToHex(vES));
  Writeln('SS: ', WordToHex(vSS));
  Writeln('Entry: ', WordToHex(vEntry));
  Writeln('Stack: ', WordToHex(vStack));
  Writeln('Param: ', WordToHex(vParam));
  Writeln;
  Writeln('Executando kernel em 0x', DWordToHex2(vExecLinear));

  {desabilita as interrupcoes para que as IRQs nao causem excecoes}
  DisableInt;

  {desabilita as NMIs tambem}
  DisableNMIs;

  {Vai para o modo protegido chamando o kernel}
  GoKernel16PM(vCS, vDS, vES, vSS, vEntry, vStack, vParam);

  {Impossivel o retorno a esse ponto pelo kernel}
end;


var
  vKey : Char;

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

  {habilita A20}
  EnableA20;
  Writeln;

  {cria o espaco de execucao}
  MakeExecSpace;

  {carrega o kernel}
  Writeln;
  Writeln('Imagem do kernel: ', cKernelName);
  LoadKernel;

  Write('Pressione qualquer tecla para continuar... ');
  vKey := ReadKey;
  Writeln;
  Writeln;

  {chama o kernel}
  ExecKernel;

  Finish;
end.
