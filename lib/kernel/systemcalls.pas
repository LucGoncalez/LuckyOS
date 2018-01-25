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
  Unit SystemCalls.pas
  --------------------------------------------------------------------------
  Unit interface de chamadas de sistema do kernel.
  --------------------------------------------------------------------------
  Versao: 0.2.2
  Data: 11/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc systemcalls.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0905-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial.
  ------------------------------------------------------------------------
  [2014-0726-0000] (v0.2) <Luciano Goncalez>

  - Modificando a chamada Abort.
  ------------------------------------------------------------------------
  [2014-1221-0000] (v0.2.1) <Luciano Goncalez>

  - Modificando a chamada Abort - adicionando informações de localização dos fontes.
  ------------------------------------------------------------------------
  [2018-0111-2311] (v0.2.2) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

unit SystemCalls;

interface

  function DirectCall(AEAX, AEBX, AECX, AEDX : UInt) : SInt;


implementation

uses SystemDef, SysCallsDef, ErrorsDef,
  KernelLib, FileSystem;


function DirectCall(AEAX, AEBX, AECX, AEDX : UInt) : SInt;
begin
  case TSysCall(AEAX) of

    {0  Sys_Abort = Error : TErrorCode; ErrorMsg : PChar; AbortRec : PAbortRec}
    Sys_Abort : KernelPanic(TErrorCode(AEBX), PChar(AECX), PAbortRec(AEDX));

    {1  Sys_Exit = Status : SInt}

    {2  Sys_Open = Name : PChar; Mode : TFileMode => SInt}
    Sys_Open : DirectCall := FileOpen(PChar(AEBX), TFileMode(AECX));

    {3  Sys_Close = FD : UInt => SInt}
    Sys_Close : DirectCall := FileClose(AEBX);

    {4  Sys_Read = FD : UInt; Buffer : Pointer; Count : SInt => SInt}
    Sys_Read : DirectCall := FileRead(AEBX, Pointer(AECX), SInt(AEDX));

    {5  Sys_Write = FD : UInt; Buffer : Pointer; Count : SInt => SInt}
    Sys_Write : DirectCall := FileWrite(AEBX, Pointer(AECX), SInt(AEDX));

  else
    KernelPanic(ERROR_SYSCALL_INVALID_CALL, nil, nil);
  end;
end;


end.
