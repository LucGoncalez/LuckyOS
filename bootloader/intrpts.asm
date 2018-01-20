;===========================================================================
; Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
; --------------------------------------------------------------------------
; Copyright (C) 2013 - Luciano L. Goncalez
; --------------------------------------------------------------------------
; a.k.a.: Master Lucky
; eMail : master.lucky.br@gmail.com
; Home  : http://lucky-labs.blogspot.com.br
;===========================================================================
; Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
; sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
; Software Foundation; na versao 2 da Licenca.
;
; Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
; GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
; ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
; Geral GNU para obter mais detalhes.
;
; Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
; este programa; se nao, escreva para a Free Software Foundation, Inc., 59
; Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
; GNU e obtenha sua licenca: http://www.gnu.org/
;===========================================================================
; Lib Intrpts.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos para controle de interrupcoes.
; --------------------------------------------------------------------------
; Versao: 0.1.1
; Data: 12/01/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj intrpts.asm
; --------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2013-0407-0000] {v0.1} <Luciano Goncalez>
;
; - Implementação inicial
; ------------------------------------------------------------------------
; [2018-0112-2101] (v0.1.1) <Luciano Goncalez>
;
; - Adicionando historico ao arquivo.
; - Substituindo identação para espaços.
;===========================================================================


GLOBAL DisableInt, DisableNMIs, EnableInt, EnableNMIs

SEGMENT CODE USE 16

;===========================================================================
; procedure DisableInt; external; {far}
; --------------------------------------------------------------------------
; Disabilita as interrupcoes
;===========================================================================
DisableInt:
  cli
retf

;===========================================================================
; procedure EnableInt; external; {far}
; --------------------------------------------------------------------------
; Habilita as interrupcoes
;===========================================================================
EnableInt:
  sti
retf

;===========================================================================
; procedure DisableNMIs; external; {far}
; --------------------------------------------------------------------------
; Desabilita as NMIs
;===========================================================================
DisableNMIs:
  in al, 0x70
  or al, 0x80
  out 0x70, al
retf

;===========================================================================
; procedure EnableNMIs; external; {far}
; --------------------------------------------------------------------------
; Habilita as NMIs
;===========================================================================
EnableNMIs:
  in al, 0x70
  or al, 0x7F
  out 0x70, al
retf
