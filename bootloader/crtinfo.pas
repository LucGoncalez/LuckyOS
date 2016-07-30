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
  Unit CRTInfo.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para obtencao de dados do CRT.
  --------------------------------------------------------------------------
  Versao: 0.3
  Data: 10/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc crtinfo.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit CRTInfo;

interface

type
  TCRTInfoResult = packed record
    CRTMode : Byte; {retorno da BIOS}
    CRTFlags : Byte;
  end;

{ CRTFlags armazena informacoes especiais, derivadas do modo
  76543210
  |||||||\->\ Indicam o tipo do adaptador conforme abaixo.
  ||||||\-->/
  |||||\--->  RESERVADO
  ||||\---->  Indica que esta no Modo Extendido (43/50 linhas)
  |||\----->  Indica que esta no Modo de 80 Colunas
  ||\------>  Indica que esta no modo compativel com MDA
  |\------->  Indica que esta no Modo Colorido
  \-------->  Indica condicao de erro

  Tipo do adaptador:
    00 - 0 - Adaptador MDA ou condicao de erro
    01 - 1 - Adaptador CGA
    10 - 2 - Adaptador EGA
    11 - 3 - Adaptador VGA
}
  TCRTType = (CRTA_MDA, CRTA_CGA, CRTA_EGA, CRTA_VGA);


const
  {Flags}
  CRT_Adapt = {00000011} 3;
  CRT_Ex    = {00001000} 8;
  CRT_80C   = {00010000} 16;
  CRT_MDA   = {00100000} 32;
  CRT_Color = {01000000} 64;
  CRT_Error = {10000000} 128;

  procedure DetectCRT;
  function GetCRTInfo : Word;

  function GetCRTMode : Byte;
  function GetCRTType : TCRTType;

  function GetCRT_Ex : Boolean;
  function GetCRT_80C : Boolean;
  function GetCRT_MDA : Boolean;
  function GetCRT_Color : Boolean;
  function GetCRT_Error : Boolean;

  function GetCRTCols : Byte;
  function GetCRTRows : Byte;

  function GetCRTSeg : Word;
  function GetCRTAddr6845 : Word;


implementation

uses Basic, Bios;

{Constates de enderecos}
const
  MDASeg = $B000;
  CGASeg = $B800;

  BDASeg = $0040;
  BDAAddr6845 = $63;


{Variavel global que armazena as informacoes para as funcoes}
var
  vCRTInfo : Word;
  vCRTCols : Byte;
  vCRTRows : Byte;
  vCRTSeg : Word;
  vCRTAddr6845 : Word;


{ *** Funcao interna da Unit que processa as informacoes coletadas *** }
procedure _GetCRTInfo;
var
  Error : Boolean;

  vDWordTemp : DWord;
  vCRTMode : Byte;
  vFlags : Byte;
  vCRTType : TCRTType;
  vResultRec : TCRTInfoResult;

  Addr6845 : Word absolute BDASeg:BDAAddr6845;

begin
  Error := False;

  {Pega informacoes de modo e colunas}
  vDWordTemp := BiosInt10x0F;
  vCRTMode := TBiosInt10x0F_Result(vDWordTemp).Mode;
  vCRTCols := TBiosInt10x0F_Result(vDWordTemp).Cols;

  {Pega informacoes de linhas}
  vDWordTemp := BiosInt10x1130B(0);
  vCRTRows := TBiosInt10x1130B_Result(vDWordTemp).Rows;

  {No modo de 25 linhas normalmente o retorno eh zero, corrigir}
  if (vCRTRows = 0 ) then
    vCRTRows := 25
  else
  {Quando retornado o numero de linhas ela eh baseada em zero, corrigir}
    Inc(vCRTRows);

  {Define os Flags baseado no modo do video}
  case vCRTMode of
    0 : vFlags := 0; {BW40}
    1 : vFlags := CRT_Color; {CO40}
    2 : vFlags := CRT_80C; {BW80}
    3 : vFlags := CRT_Color + CRT_80C; {CO80}
    7 : vFlags := CRT_MDA {CRT_Mono}
  else
    vFlags := 0;
    Error := True;
  end;

  {Define o tipo do adaptador baseado no numero de linhas}
  case vCRTRows of
    25 : vCRTType := CRTA_CGA;

    43 :
      begin
        vCRTType := CRTA_EGA;
        vFlags := vFlags + CRT_Ex;
      end;

    50 :
      begin
        vCRTType := CRTA_VGA;
        vFlags := vFlags + CRT_Ex;
      end;
  else
    vCRTType := CRTA_MDA;
    Error := True;
  end;

  vResultRec.CRTMode := vCRTMode;

  if Error then
  begin
    {Se ocorrer um erro reporta-o e retorna sempre nulo, exceto o modo}
    vResultRec.CRTFlags := CRT_Error;
    vCRTSeg := 0;
    vCRTAddr6845 := 0;
  end
  else
  begin
    {Junta os Flags com o tipo do adaptador}
    vResultRec.CRTFlags := vFlags + Byte(vCRTType);

    {Configura o segmento de video}
    if TestBitsByte(vFlags, CRT_MDA) then
      vCRTSeg := MDASeg
    else
      vCRTSeg := CGASeg;

    {Pega a porta do controlador}
    vCRTAddr6845 := Addr6845;
  end;

  vCRTInfo := Word(vResultRec);
end;

{Atualiza os dados}
procedure DetectCRT;
begin
  _GetCRTInfo;
end;

{Retorna as informacoes basicas sobre a CRT}
function GetCRTInfo : Word;
begin
  _GetCRTInfo;
  GetCRTInfo := vCRTInfo;
end;

{Retorna o modo detectado na BIOS}
function GetCRTMode : Byte;
begin
  GetCRTMode := TCRTInfoResult(vCRTInfo).CRTMode;
end;

{Retorna o tipo do adaptador de video}
function GetCRTType : TCRTType;
var
  Temp : Byte;
begin
  Temp := (TCRTInfoResult(vCRTInfo).CRTFlags and CRT_Adapt);
  GetCRTType := TCRTType(Temp);
end;

{Retorna se o modo suporta 43/50 linhas}
function GetCRT_Ex : Boolean;
begin
  GetCRT_Ex := TestBitsByte(TCRTInfoResult(vCRTInfo).CRTFlags, CRT_Ex);
end;

{Retorna se o modo suporta 80 colunas}
function GetCRT_80C : Boolean;
begin
  GetCRT_80C := TestBitsByte(TCRTInfoResult(vCRTInfo).CRTFlags, CRT_80C);
end;

{Retorna se o modo eh compativel com MDA}
function GetCRT_MDA : Boolean;
begin
  GetCRT_MDA := TestBitsByte(TCRTInfoResult(vCRTInfo).CRTFlags, CRT_MDA);
end;

{Retorna se o modo suporta cores}
function GetCRT_Color : Boolean;
begin
  GetCRT_Color := TestBitsByte(TCRTInfoResult(vCRTInfo).CRTFlags, CRT_Color);
end;

{Retorna se houve erro durante a obtencao dos dados da CRT}
function GetCRT_Error : Boolean;
begin
  GetCRT_Error := TestBitsByte(TCRTInfoResult(vCRTInfo).CRTFlags, CRT_Error);
end;

{Retorna o numero de colunas}
function GetCRTCols : Byte;
begin
  GetCRTCols := vCRTCols;
end;

{Retorna o numero de linhas}
function GetCRTRows : Byte;
begin
  GetCRTRows := vCRTRows;
end;

{Retorna o segmento do video}
function GetCRTSeg : Word;
begin
  GetCRTSeg := vCRTSeg;
end;

{Retorna o endereco da porta do controlador}
function GetCRTAddr6845 : Word;
begin
  GetCRTAddr6845 := vCRTAddr6845;
end;

{Inicializacao da Unit, guardando as informacoes em uma variavel global}
begin
  vCRTInfo := 0;
  vCRTCols := 0;
  vCRTRows := 0;
  vCRTSeg := 0;
  vCRTAddr6845 := 0;
end.
