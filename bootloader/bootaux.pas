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
  Unit BootAux.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos que auxiliam o boot.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 30/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc bootaux.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit BootAux;

interface

procedure CopyLinear(Src, Dest, Count : LongInt);
procedure JumpToLinear(Addr : LongInt; Param : Word);

implementation

uses Basic;

{$L BOOTAUX.OBJ}

{==========================================================================}
  procedure CopyFAR16(Src, Dest : LongInt; Count : Word); external; {near;}
{ --------------------------------------------------------------------------
  Copia Count bytes de Src para Dest.
===========================================================================}

{==========================================================================}
  procedure JumpFAR16(Addr : LongInt; Param : Word); external; {near}
{ --------------------------------------------------------------------------
  Salta para a rotina localizada no endereco ADDR, passando Param em AX.
===========================================================================}


{Copia Count bytes de Src para Dest, em enderecos linear}
procedure CopyLinear(Src, Dest, Count : LongInt);
var
  vSrc, vDest : LongInt;

begin
  vSrc := PLinearToPFar16(Src);
  vDest := PLinearToPFar16(Dest);
  CopyFAR16(vSrc, vDest, Count);
end;

{Chama a rotina no endereco linear}
procedure JumpToLinear(Addr : LongInt; Param : Word);
var
  vAddr : LongInt;

begin
  vAddr := PLinearToPFar16(Addr);
  JumpFAR16(vAddr, Param);
end;

end.
