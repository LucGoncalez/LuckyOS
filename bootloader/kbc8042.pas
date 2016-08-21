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
  Unit KBC8042.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimento para acessar o controlador de teclado 8042.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 11/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc kbc8042.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit KBC8042;

interface

const
  c8042DisableKB  = $AD;
  c8042EnableKB   = $AE;
  c8042ReadOR     = $D0;
  c8042WriteDR    = $D1;
  c8042EnableA20  = $DD;
  c8042DisableA20 = $DF;


  function Read8042StatusReg : Byte;
  procedure Write8042CommandReg(Value : Byte);

  function Read8042OutputReg : Byte;
  procedure Write8042DataReg(Value : Byte);

  procedure Wait8042Empty;
  procedure Wait8042Done;

implementation

{$L KBC8042.OBJ}

{==========================================================================}
  function Read8042StatusReg : Byte; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Le a porta de status (0x64) do 8042, retornando o valor.
===========================================================================}

{==========================================================================}
  procedure Write8042CommandReg(Value : Byte); external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Escreve um comando para a porta de comando (0x64) do 8042.
===========================================================================}

{==========================================================================}
  function Read8042OutputReg : Byte; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Le a porta de saida (0x60) do 8042, retornando o valor.
===========================================================================}

{==========================================================================}
  procedure Write8042DataReg(Value : Byte); external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Escreve um valor para a porta de dados (0x60) do 8042.
===========================================================================}

{==========================================================================}
  procedure Wait8042Empty; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Aguarda que a porta de comando/dados (0x64/0x60) do 8042 esteja vazia.
===========================================================================}

{==========================================================================}
  procedure Wait8042Done; external; {far; nostackframe}
{ --------------------------------------------------------------------------
  Aguarda que a porta de dados (0x60) do 8042 esteja cheia.
===========================================================================}

end.
