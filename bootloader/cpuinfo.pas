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
  Unit CPUInfo.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para obtencao de dados do processador.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 22/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc cpuinfo.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit CPUInfo;

interface

type
  TCPUType = (CT8086, CT80186, CT80286, CT80386, CT80486, CT80586);

  TCPUInfoResult = packed record
    CPUType : TCPUType;
    CPUFlags : Byte;
  end;

{ CPUFlags armazena informacoes especiais, derivadas do tipo

  76543210
  |||||||\-> Indica se suporta Modo Protegido
  ||||||\--> Indica se esta no Modo Protegido
  |||||\---> Indica se suporta Ia32
  ||||\----> RESERVADO
  |||\-----> RESERVADO
  ||\------> RESERVADO
  |\-------> RESERVADO
  \--------> Indica se suporta CPUID
  }

const
  {Flags}
  CPU_PM    = {00000001 = } 1;
  CPU_PE    = {00000010 = } 2;
  CPU_IA32  = {00000100 = } 4;
  CPU_ID    = {10000000 = } 128;

{Todas as funcoes podem ser chamadas independentemente, pois GetCPUinfo ja eh
executada na inicializacao da Unit}

procedure DetectCPU;
function GetCPUInfo : Word;
function GetCPUType : TCPUType;
function GetCPU_PM : Boolean;
function GetCPU_PE : Boolean;
function GetCPU_IA32 : Boolean;
function GetCPU_ID : Boolean;

implementation

uses Basic;

{$L CPUINFO.OBJ}

{==========================================================================}
function GetCPUInfoFlags : Word; external; {near; nostackframe}
{ --------------------------------------------------------------------------
  Obtem informacoes basicas da CPU.
  --------------------------------------------------------------------------
  Retorno:

  WordRec(GetCPUInfoBas).Lo :

    - 0 : 8086
    - 1 : 80186 (nao implementado)
    - 2 : 80286
    - 3 : 80386
    - 4 : 80486
    - 5 : 80586 ou superior (possui CPUID, pode ser tambem um 80486)

  WordRec(GetCPUInfoBas).Hi :

    - 0 : Processador em Modo Real
    - 1 : Processador em Modo Protegido

===========================================================================}

{Funcao interna da Unit que processa as informacoes coletadas}
function _GetCPUInfo : Word;
var
  vTempW : Word;
  vTempR : TCPUInfoResult;
  vCPU_PM : Byte;
  vCPU_PE : Byte;
  vCPU_IA32 : Byte;
  vCPU_ID : Byte;

begin
  vTempW := GetCPUInfoFlags;
  vTempR := TCPUInfoResult(vTempW);

  if (vTempR.CPUType >= CT80286) then
  begin
    vCPU_PM := CPU_PM; {CPU_PM ativado}

    if (vTempR.CPUFlags = 1) then
      vCPU_PE := CPU_PE {CPU_PE ativado}
    else
      vCPU_PE := 0; {CPU_PE desativado}
  end
  else
  begin
    vCPU_PM := 0; {CPU_PM desativado}
    vCPU_PE := 0; {CPU_PE desativado}
  end;

  if (vTempR.CPUType >= CT80386) then
    vCPU_IA32 := CPU_IA32 {CPU_IA32 ativado}
  else
    vCPU_IA32 := 0; {CPU_IA32 desativado}

  if (vTempR.CPUType >= CT80586) then
    vCPU_ID := CPU_ID {CPU_ID ativado}
  else
    vCPU_ID := 0; {CPU_ID desativado}

  vTempR.CPUFlags := vCPU_PM + vCPU_PE + vCPU_IA32 + vCPU_ID;

  _GetCPUInfo := Word(vTempR);
end;

{Variavel global que armazena as informacoes para as funcoes}
var
  vCPUInfo : Word;

{Atualiza os dados}
procedure DetectCPU;
begin
  vCPUInfo := _GetCPUInfo;
end;

{Retorna todos as informacoes sobre a CPU}
function GetCPUInfo : Word;
begin
  vCPUInfo := _GetCPUInfo;
  GetCPUInfo := vCPUInfo;
end;

{Retorna o tipo da CPU}
function GetCPUType : TCPUType;
begin
  GetCPUType := TCPUInfoResult(vCPUInfo).CPUType;
end;

{Retorna se a CPU suporta Modo Protegido}
function GetCPU_PM : Boolean;
begin
  GetCPU_PM := TestBitsByte(TCPUInfoResult(vCPUInfo).CPUFlags, CPU_PM);
end;

{Retorna se a CPU está em Modo Protegido}
function GetCPU_PE : Boolean;
begin
  GetCPU_PE := TestBitsByte(TCPUInfoResult(vCPUInfo).CPUFlags, CPU_PE);
end;

{Retorna se a CPU eh de 32 bits}
function GetCPU_IA32 : Boolean;
begin
  GetCPU_IA32 := TestBitsByte(TCPUInfoResult(vCPUInfo).CPUFlags, CPU_IA32);
end;

{Retorna se a CPU possui a Instrucao CPUID}
function GetCPU_ID : Boolean;
begin
  GetCPU_ID :=TestBitsByte(TCPUInfoResult(vCPUInfo).CPUFlags, CPU_ID);
end;

{Inicializacao da Unit, guardando as informacoes em uma variavel global}
begin
  vCPUInfo := 0;
end.
