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
; Lib BIOS15.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos da Int15h.
; --------------------------------------------------------------------------
; Versao: 0.3
; Data: 10/04/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bios15.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL BiosInt15x88, BiosInt15xE801L, BiosInt15xE801H

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function BiosInt15x88 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Obtem a quantidade de memoria extendida (1M < 64M) em KB.
;===========================================================================
BiosInt15x88:
  xor ax, ax
  mov ah, 0x88  ; funcao 88h
  call near Int15$
  jc .error     ; funcao nao suportada
  jmp .end      ; vai para o fim da rotina
 .error:
  xor ax, ax    ; retorno zero eh erro
 .end:
retf            ; finaliza a rotina

;===========================================================================
; function BiosInt15xE801L: Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Obtem a quantidade de memoria extendida (1M < 16M) em KB.
;===========================================================================
BiosInt15xE801L:
  call near BiosInt15xE801
  mov ax, cx
retf

;===========================================================================
; function BiosInt15xE801H: Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Obtem a quantidade de memoria extendida ( > 16M) em 64 KB.
;===========================================================================
BiosInt15xE801H:
  call near BiosInt15xE801
  mov ax, dx
retf

;===========================================================================
; BiosInt15xE801
; --------------------------------------------------------------------------
; Rotina comum a diversas chamadas
;===========================================================================
BiosInt15xE801:
  xor cx, cx
  xor dx, dx
  mov ax, 0xE801

  call near Int15$

  jc .error
  cmp ah, 0x86
  je .error
  cmp ah, 0x80
  je .error
  jmp .end
 .error:
  xor ax, ax
  xor bx, bx
  xor cx, cx
  xor dx, dx
 .end:
retn

;===========================================================================
; Int15$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina da BIOS.
;===========================================================================
Int15$:
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

  int 0x15

  pop bp
  pop di
  pop si
  pop es
  pop ds
retn
