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
  Unit StdIO.pas
  --------------------------------------------------------------------------
  Unit biblioteca de entrada e saida padrao.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 05/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc stdio.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit StdIO;

interface

uses SystemDef;


  function FOpen(const Name : ShortString; Mode : TFileMode) : SInt;
  function FClose(FD : UInt) : Boolean;

  function FRead(FD : UInt; var Buffer; Count : SInt) : SInt;
  function FWrite(FD : UInt; const Buffer; Count : SInt) : SInt;


implementation

uses SysCalls, ErrorsDef;


function FOpen(const Name : ShortString; Mode : TFileMode) : SInt;
var
  vName : ShortString;
  vFD : SInt;

begin
  vName := Name + #0;

  vFD := SysOpen(@vName[1], Mode);

  if (vFD < 0) then
  begin
    ErrorNo := - vFD;
    FOpen := -1;
  end
  else
    FOpen := vFD;
end;

function FClose(FD : UInt) : Boolean;
var
  vSysRes : SInt;

begin
  vSysRes := SysClose(FD);

  FClose := (vSysRes = 0);

  if not FClose then
    ErrorNo := - vSysRes;
end;

function FRead(FD : UInt; var Buffer; Count : SInt) : SInt;
var
  vSysRes : SInt;

begin
  vSysRes := SysRead(FD, @Buffer, Count);

  if (vSysRes >= 0) then
    FRead := vSysRes
  else
  begin
    ErrorNo := - vSysRes;
    FRead := -1;
  end;
end;

function FWrite(FD : UInt; const Buffer; Count : SInt) : SInt;
var
  vSysRes : SInt;

begin
  vSysRes := SysWrite(FD, @Buffer, Count);

  if (vSysRes >= 0) then
    FWrite := vSysRes
  else
  begin
    ErrorNo := - vSysRes;
    FWrite := -1;
  end;
end;


end.
