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
  Unit FileSystem.pas
  --------------------------------------------------------------------------
  Unit Sistema de Arquivos. (Provisorio)
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 05/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc filesystem.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit FileSystem;

interface

uses SystemDef;


  function FileOpen(Name : PChar; Mode : TFileMode) : SInt;
  function FileClose(FD : UInt) : SInt;

  function FileRead(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
  function FileWrite(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;


implementation

uses GrossTTY, ErrorsDef;


const
  cNodesNames : Array[1..2] of PChar =
  (
    '/dev/null',
    '/dev/grosstty'
  );


var
  vFileDesc : array[0..3] of Byte;
  vInicilized : Boolean = False;


procedure CheckInit;
var
  I : SInt;

begin
  if not vInicilized then
  begin
    for I := Low(vFileDesc) to High(vFileDesc) do
      vFileDesc[I] := 0;

    vInicilized := True;
  end;
end;

function FileOpen(Name : PChar; Mode : TFileMode) : SInt;
var
  vTemp : ShortString;
  I, vNode : Byte;
  vFD : SInt;
  vError : TErrorCode;

begin
  CheckInit;

  // Modo eh ignorado por enquanto

  vTemp := Name;
  vNode := 0;
  vFD := -1;
  vError := ERROR_FS_UNDEFINED;

  for I := Low(cNodesNames) to High(cNodesNames) do
    if (vTemp = cNodesNames[I]) then
    begin
      vNode := I;
      Break;
    end;

  if (vNode <> 0) then
    for I := Low(vFileDesc) to High(vFileDesc) do
      if (vFileDesc[I] = 0) then
      begin
        vFD := I;
        Break;
      end;

  if (vNode = 0) then
    vError := ERROR_FS_FILE_NOT_FOUND
  else
    if (vFD = -1) then
      vError := ERROR_FS_ALL_FD_BUSY
    else
    begin
      vError := ERROR_NONE;
      vFileDesc[vFD] := vNode;
    end;

  if (vError = ERROR_NONE) then
    FileOpen := vFD
  else
    FileOpen := - UInt(vError);
end;

function FileClose(FD : UInt) : SInt;
var
  vError : TErrorCode;

begin
  CheckInit;
  vError := ERROR_NONE;

  if (FD < Low(vFileDesc)) or (FD > High(vFileDesc)) then
    vError := ERROR_FS_INVALID_FD
  else
    if (vFileDesc[FD] = 0) then
      vError := ERROR_FS_CLOSED_FD
    else
      vFileDesc[FD] := 0;

  FileClose := - UInt(vError);
end;

function FileRead(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
var
  vError : TErrorCode;
  vTemp : ShortString;
  vLen : SInt;

begin
  CheckInit;
  vError := ERROR_NONE;
  vLen := 0;

  if (FD < Low(vFileDesc)) or (FD > High(vFileDesc)) then
    vError := ERROR_FS_INVALID_FD
  else
    case vFileDesc[FD] of
      0 : vError := ERROR_FS_CLOSED_FD;

      1 : ; // /dev//null => Nada, simplesmente...

      2 : // /dev/grosstty
        begin
          vTemp := GrossTTYRead;
          vLen := Length(vTemp);

          if (vLen > Count) then
            vLen := Count;

          Move(vTemp[1], Buffer^, vLen);
        end;
    else
      vError := ERROR_FS_INVALID_FD
    end;

  if (vError = ERROR_NONE) then
    FileRead := vLen
  else
    FileRead := - UInt(vError);
end;

function FileWrite(FD : UInt; Buffer : Pointer; Count : SInt) : SInt;
var
  vError : TErrorCode;
  vTemp : ShortString;
  vLen : SInt;

begin
  CheckInit;
  vError := ERROR_NONE;
  vLen := 0;

  if (FD < Low(vFileDesc)) or (FD > High(vFileDesc)) then
    vError := ERROR_FS_INVALID_FD
  else
    case vFileDesc[FD] of
      0 : vError := ERROR_FS_CLOSED_FD;

      1 : vLen := Count; // /dev//null

      2 : // /dev/grosstty
        begin
          vLen := High(vTemp);

          if (vLen > Count) then
            vLen := Count;

          Move(Buffer^, vTemp[1], vLen);
          vTemp[0] := Char(vLen);

          GrossTTYWrite(vTemp);
        end;
    else
      vError := ERROR_FS_INVALID_FD
    end;

  if (vError = ERROR_NONE) then
    FileWrite := vLen
  else
    FileWrite := - UInt(vError);
end;

end.
