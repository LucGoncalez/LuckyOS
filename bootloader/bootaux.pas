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
  Versao: 0.3
  Data: 06/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc bootaux.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit BootAux;

interface

uses Basic;

procedure CopyLinear(Src, Dest, Count : DWord);

procedure GoKernel16(CS, DS, ES, SS : Word; Entry, Stack : Word; Param : Word);
{Carrega e chama o kernel previamente configurado:

  CS : Segmento/descritor do codigo;
  DS : Segmento/descritor de dados;
  ES : Segmento/descritor extra;
  SS : Segmento/descritor da pilha;

  Entry : Ponto de entrada do kernel (Offset em CS);
  Stack : Base da pilha (Offset em SS);
  Param : Parametro passado ao kernel em AX;
}

function GetDS : Word;
function GetSS : Word;
function GetSP : Word;

implementation

{$L BOOTAUX.OBJ}

{==========================================================================}
  procedure CopyFAR16(Src, Dest : DWord; Count : Word); external; {near;}
{ --------------------------------------------------------------------------
  Copia Count bytes de Src para Dest.
===========================================================================}


{Copia Count bytes de Src para Dest, em enderecos linear}
procedure CopyLinear(Src, Dest, Count : DWord);
var
  vSrc, vDest : DWord;

begin
  vSrc := PLinearToPFar16(Src);
  vDest := PLinearToPFar16(Dest);
  CopyFAR16(vSrc, vDest, Count);
end;

{==========================================================================}
procedure GoKernel16(CS, DS, ES, SS : Word; Entry, Stack : Word; Param : Word); external; {far}
{ --------------------------------------------------------------------------
  Configura e chama o kernel previamente carregado:

    CS : Segmento/descritor do codigo;
    DS : Segmento/descritor de dados;
    ES : Segmento/descritor extra;
    SS : Segmento/descritor da pilha;

    Entry : Ponto de entrada do kernel (Offset em CS);
    Stack : Base da pilha (Offset em SS);
    Param : Parametro passado ao kernel em AX;
===========================================================================}

{==========================================================================}
function GetDS : Word; external; {far}
{ --------------------------------------------------------------------------
  Retorna DS
===========================================================================}

{==========================================================================}
function GetSS : Word; external; {far}
{ --------------------------------------------------------------------------
  Retorna SS
===========================================================================}

{==========================================================================}
function GetSP : Word; external; {far}
{ --------------------------------------------------------------------------
  Retorna SP
===========================================================================}

end.
