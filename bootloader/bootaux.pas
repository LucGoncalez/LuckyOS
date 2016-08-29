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
  Versao: 0.6
  Data: 14/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc bootaux.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit BootAux;

interface

uses Basic;

  procedure EnableUnreal(DescSeg : Word);
  procedure CopyLinear(Src, Dest, Count : DWord);
  procedure GoKernel32PM(CS, DS, ES, SS : Word; Entry, Stack : DWord; Param : DWord);


implementation

{$L BOOTAUX.OBJ}

{==========================================================================}
  procedure EnableUnreal(DescSeg : Word); external; {far}
{ --------------------------------------------------------------------------
  Habilita o modo Unreal, usando o DescSeg passado.
===========================================================================}

{==========================================================================}
  procedure CopyLinear(Src, Dest, Count : DWord); external; {far}
{ --------------------------------------------------------------------------
  Copia Count bytes de Src para Dest.
===========================================================================}

{==========================================================================}
  procedure GoKernel32PM(CS, DS, ES, SS : Word; Entry, Stack : DWord; Param : DWord);
    external; {far}
{ --------------------------------------------------------------------------
  Configura e chama o kernel previamente carregado:

    CS : Segmento/descritor do codigo;
    DS : Segmento/descritor de dados;
    ES : Segmento/descritor extra;
    SS : Segmento/descritor da pilha;

    Entry : Ponto de entrada do kernel (Offset em CS);
    Stack : Base da pilha (Offset em SS);
    Param : Parametro passado ao kernel em EAX;
===========================================================================}

end.
