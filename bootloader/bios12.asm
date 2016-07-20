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
; Lib BIOS12.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos de deteccao de memoria.
; --------------------------------------------------------------------------
; Versao: 0.1
; Data: 25/03/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bios12.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL BiosInt12

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function BiosInt12 : Word; external; {near; nostackframe}
; --------------------------------------------------------------------------
; Obtem a quantidade de memoria baixa em KB.
;===========================================================================
BiosInt12:
  xor ax, ax
  call near Int12$
  jc .error   ; funcao nao suportada
  jmp .end
 .error:
  xor ax, ax  ; retorno zero eh erro
 .end:
retn          ; finaliza a rotina

;===========================================================================
; Int12$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina da BIOS.
;===========================================================================
Int12$:
  ; registradore gerais usados como parametros
  ; ax, bx, cx, dx

  ; registradores de segmento que nao se alteram
  ; cs, ss

  ; registradores de ponteiros que nao se alteram
  ; sp, ip

  ; registradores que podem ser alterados durante a chamada
  push ds
  push es
  push si
  push di
  push bp

  int 0x12

  pop bp
  pop di
  pop si
  pop es
  pop ds
retn
