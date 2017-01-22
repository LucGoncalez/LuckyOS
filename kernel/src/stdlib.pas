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
  Unit StdLib.pas
  --------------------------------------------------------------------------
  Unit biblioteca padrao.
  --------------------------------------------------------------------------
  Versao: 0.2
  Data: 26/07/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc stdlib.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit StdLib;

interface

uses ErrorsDef;


  procedure Abort;
  procedure Abort(Error : TErrorCode);
  procedure Abort(Error : TErrorCode; ErrorMsg : PChar);


implementation

uses SystemDef, SysCalls, DebugInfo;


var
  vAborting : Boolean = False;
  vAbortInfo : TAbortRec;


procedure Abort;
const
  cSkipFrames = 1; // Pula o Frame da propria Abort
  cOffsetESP = 0; // Rotina atual nao tem parametro

begin
  if not vAborting then
  begin
    // Evita que uma segunda chamada sobrescreva a primeira
    vAborting := True;

    if (TErrorCode(ErrorNo) = ERROR_NONE) then
      TErrorCode(ErrorNo) := ERROR_UNDEFINED;

    vAbortInfo.Basic := GetDebugInfo;
    vAbortInfo.Stack := GetDebugStack(cSkipFrames, cOffsetESP);
    vAbortInfo.StackLevels := GetSFramesLevels(vAbortInfo.Stack.EBP);
  end;

  SysAbort(TErrorCode(ErrorNo), nil, @vAbortInfo);
end;

procedure Abort(Error : TErrorCode);
const
  cSkipFrames = 1; // Pula o Frame da propria Abort
  cOffsetESP = 4; // TErrorCode = LongWord = 4

begin
  if not vAborting then
  begin
    // Evita que uma segunda chamada sobrescreva a primeira
    vAborting := True;

    if (Error = ERROR_NONE) then
      TErrorCode(ErrorNo) := ERROR_UNDEFINED
    else
      TErrorCode(ErrorNo) := Error;

    vAbortInfo.Basic := GetDebugInfo;
    vAbortInfo.Stack := GetDebugStack(cSkipFrames, cOffsetESP);
    vAbortInfo.StackLevels := GetSFramesLevels(vAbortInfo.Stack.EBP);
  end;

  SysAbort(TErrorCode(ErrorNo), nil, @vAbortInfo);
end;

procedure Abort(Error : TErrorCode; ErrorMsg : PChar);
const
  cSkipFrames = 1; // Pula o Frame da propria Abort
  cOffsetESP = 8; // TErrorCode = LongWord = 4; Msg = Pointer = 4

begin
  if not vAborting then
  begin
    // Evita que uma segunda chamada sobrescreva a primeira
    vAborting := True;

    if (Error = ERROR_NONE) then
      TErrorCode(ErrorNo) := ERROR_UNDEFINED
    else
      TErrorCode(ErrorNo) := Error;

    vAbortInfo.Basic := GetDebugInfo;
    vAbortInfo.Stack := GetDebugStack(cSkipFrames, cOffsetESP);
    vAbortInfo.StackLevels := GetSFramesLevels(vAbortInfo.Stack.EBP);
  end;

  SysAbort(TErrorCode(ErrorNo), ErrorMsg, @vAbortInfo);
end;


end.
