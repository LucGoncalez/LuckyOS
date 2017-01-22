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
  Unit SysCalls.pas
  --------------------------------------------------------------------------
  Unit biblioteca de chamadas de sistema.
  --------------------------------------------------------------------------
  Versao: 0.2.1
  Data: 21/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc syscalls.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit SysCalls;

interface

uses SystemDef, ErrorsDef;

  procedure SysAbort(Error : TErrorCode; ErrorMsg : PChar; AbortRec : PAbortRec);
  procedure SysExit(Status : SInt);

  function  SysOpen(Name : PChar; Mode : TFileMode) : SInt;
  function  SysClose(FD : UInt) : SInt;

  function  SysRead(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
  function  SysWrite(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;


implementation

uses SysCallsDef
{$IFDEF KERNEL}
  , SystemCalls
{$ENDIF}
;


function DoCall(CallNo : TSysCall; Param1 : UInt) : SInt; forward;
function DoCall(CallNo : TSysCall; Param1, Param2 : UInt) : SInt; forward;
function DoCall(CallNo : TSysCall; Param1, Param2, Param3 : UInt) : SInt; forward;


procedure SysAbort(Error : TErrorCode; ErrorMsg : PChar; AbortRec : PAbortRec);
begin
  DoCall(Sys_Abort, UInt(Error), UInt(ErrorMsg), UInt(AbortRec));
end;

procedure SysExit(Status : SInt);
begin
  DoCall(Sys_Exit, UInt(Status));
end;


function  SysOpen(Name : PChar; Mode : TFileMode) : SInt;
begin
  SysOpen := DoCall(Sys_Open, UInt(Name), UInt(Mode));
end;

function  SysClose(FD : UInt) : SInt;
begin
  SysClose := DoCall(Sys_Close, FD);
end;


function  SysRead(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
begin
  SysRead := DoCall(Sys_Read, FD, UInt(Buffer), UInt(Count));
end;

function  SysWrite(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
begin
  SysWrite := DoCall(Sys_Write, FD, UInt(Buffer), SInt(Count));
end;


{$IFDEF KERNEL}
function DoCall(CallNo : TSysCall; Param1 : UInt) : SInt;
begin
  DoCall := DirectCall(UInt(CallNo), Param1, 0, 0);
end;

function DoCall(CallNo : TSysCall; Param1, Param2 : UInt) : SInt;
begin
  DoCall := DirectCall(UInt(CallNo), Param1, Param2, 0);
end;

function DoCall(CallNo : TSysCall; Param1, Param2, Param3 : UInt) : SInt;
begin
  DoCall := DirectCall(UInt(CallNo), Param1, Param2, Param3);
end;
{$ENDIF}


end.
