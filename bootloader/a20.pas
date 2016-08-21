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
  Unit A20.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimento para controle da A20.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 11/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc a20.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit A20;

interface

const
  cA20SupportKBC8042  = $01; {01}
  cA20SupportFastGate = $02; {10}
  cBIOSErrKBSecure    = $01;
  cBIOSErrNSupport    = $86;

  {Verificacao real da A20}
  function CheckA20 : Boolean;

  {Funcoes atraves da BIOS}
  function BiosA20Support : Integer;
  function BiosA20Status : Integer;
  function BiosEnableA20 : Boolean;
  function BiosDisableA20 : Boolean;

  function BiosGetLastError : Word;

  {Funcoes atraves do controlador de teclado 8042}
  function StatusA20KBC8042 : Boolean;
  function EnableA20KBC8042 : Boolean;
  function DisableA20KBC8042 : Boolean;

  {Funcoes pela "System Control Port A" = "Fast Gate" = 0x92}
  function StatusA20FastGate : Boolean;
  function EnableA20FastGate : Boolean;
  function DisableA20FastGate : Boolean;


implementation

uses Basic, Intrpts, Bios, KBC8042;

{$L A20CHECK.OBJ}

{==========================================================================}
  function CheckA20 : Boolean; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Faz o teste "Wrap Around", e retorna se habilitado ou nao.
===========================================================================}


const
  cFastGatePort = $92;

var
  vLastError : Word;


{ ******************************* BIOS ******************************* }

{Retorna o tipo de suporte da A20 pela BIOS}
function BiosA20Support : Integer;
var
  vTemp : Word;

begin
  vTemp := BiosInt15x2403;

  if (Hi(vTemp) = 0) then
  begin
    {sem erro}
    vLastError := 0;
    BiosA20Support := Lo(vTemp);
  end
  else
  begin
    {cdom erro}
    vLastError := Lo(vTemp);
    BiosA20Support := -1;
  end;
end;

{Retorna o status da A20 pela BIOS}
function BiosA20Status : Integer;
var
  vTemp : Word;

begin
  vTemp := BiosInt15x2402;

  if (Hi(vTemp) = 0) then
  begin
    {sem erro}
    vLastError := 0;
    BiosA20Status := Lo(vTemp);
  end
  else
  begin
    {com erro}
    vLastError := Lo(vTemp);
    BiosA20Status := -1;
  end;
end;

{Habilita a A20 pela BIOS}
function BiosEnableA20 : Boolean;
var
  vTemp : Word;

begin
  vTemp := BiosInt15x2401;

  if (vTemp = 0) then
  begin
    {sem erro}
    vLastError := 0;
    BiosEnableA20 := True;
  end
  else
  begin
    {com erro}
    vLastError := Lo(vTemp);
    BiosEnableA20 := False;
  end;
end;

{Desabilita a A20 pela BIOS}
function BiosDisableA20 : Boolean;
var
  vTemp : Word;

begin
  vTemp := BiosInt15x2400;

  if (vTemp = 0) then
  begin
    {sem erro}
    vLastError := 0;
    BiosDisableA20 := True;
  end
  else
  begin
    {com erro}
    vLastError := Lo(vTemp);
    BiosDisableA20 := False;
  end;
end;

{Retorna o tipo de erro pela BIOS}
function BiosGetLastError : Word;
begin
  BiosGetLastError := vLastError;
end;


{ ******************************* 8042 ******************************* }

{Retorna o status da A20 pelo 8042}
function StatusA20KBC8042 : Boolean;
begin
  DisableInt;
  Write8042CommandReg(c8042DisableKB);

  Write8042CommandReg(c8042ReadOR);
  StatusA20KBC8042 := TestBitsByte(Read8042OutputReg, $2);

  Write8042CommandReg(c8042EnableKB);
  Wait8042Empty;
  EnableInt;
end;

{Habilita a A20 pelo 8042}
function EnableA20KBC8042 : Boolean;
var
  vTemp : Byte;

begin
  DisableInt;
  Write8042CommandReg(c8042DisableKB);

  Write8042CommandReg(c8042ReadOR);
  vTemp := Read8042OutputReg;

  vTemp := vTemp or $2;

  Write8042CommandReg(c8042WriteDR);
  Write8042DataReg(vTemp);

  Write8042CommandReg(c8042ReadOR);
  EnableA20KBC8042 := TestBitsByte(Read8042OutputReg, $2);

  Write8042CommandReg(c8042EnableKB);
  Wait8042Empty;
  EnableInt;
end;

{Desabilita a A20 pelo 8042}
function DisableA20KBC8042 : Boolean;
var
  vTemp : Byte;

begin
  DisableInt;
  Write8042CommandReg(c8042DisableKB);

  Write8042CommandReg(c8042ReadOR);
  vTemp := Read8042OutputReg;

  vTemp := vTemp and $FD; {not $2}

  Write8042CommandReg(c8042WriteDR);
  Write8042DataReg(vTemp);

  Write8042CommandReg(c8042ReadOR);
  DisableA20KBC8042 := not TestBitsByte(Read8042OutputReg, $2);

  Write8042CommandReg(c8042EnableKB);
  Wait8042Empty;
  EnableInt;
end;


{ ******************************* Fast Gate ******************************* }

{Retorna o status da A20 pela Fast Gate}
function StatusA20FastGate : Boolean;
begin
  StatusA20FastGate := TestBitsByte(Port[cFastGatePort], 2);
end;

{Habilita a A20 pela Fast Gate}
function EnableA20FastGate : Boolean;
var
  vTemp : Byte;

begin
  vTemp := Port[cFastGatePort];

  if not TestBitsByte(vTemp, $2) then
  begin
    vTemp := vTemp or $2;
    Port[cFastGatePort] := vTemp;
  end;

  EnableA20FastGate := TestBitsByte(Port[cFastGatePort], $2);
end;

{Desabilita a A20 pela Fast Gate}
function DisableA20FastGate : Boolean;
var
  vTemp : Byte;

begin
  vTemp := Port[cFastGatePort];

  if TestBitsByte(vTemp, $2) then
  begin
    vTemp := vTemp and $FD; {not $2}
    Port[cFastGatePort] := vTemp;
  end;

  DisableA20FastGate := not TestBitsByte(Port[cFastGatePort], $2);
end;

{Inicializacao da unit}
begin
  vLastError := 0;
end.
