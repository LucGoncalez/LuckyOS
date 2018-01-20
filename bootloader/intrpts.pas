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
  Unit Intrpts.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para controle de interrupcoes.
  --------------------------------------------------------------------------
  Versao: 0.1.1
  Data: 12/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc intrpts.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0407-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial.
  - Criando DisableInt, EnableInt, DisableNMIs e EnableNMIs.
  ------------------------------------------------------------------------
  [2018-0112-2237] (v0.1.1) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

unit Intrpts;

interface

procedure DisableInt;
procedure EnableInt;
procedure DisableNMIs;
procedure EnableNMIs;

implementation

{$L INTRPTS.OBJ}

{==========================================================================}
  procedure DisableInt; external; {far}
{ --------------------------------------------------------------------------
  Disabilita as interrupcoes
===========================================================================}

{==========================================================================}
  procedure EnableInt; external; {far}
{ --------------------------------------------------------------------------
  Habilita as interrupcoes
===========================================================================}

{==========================================================================}
  procedure DisableNMIs; external; {far}
{ --------------------------------------------------------------------------
  Desabilita as NMIs
===========================================================================}

{==========================================================================}
  procedure EnableNMIs; external; {far}
{ --------------------------------------------------------------------------
 Habilita as NMIs
===========================================================================}

end.
