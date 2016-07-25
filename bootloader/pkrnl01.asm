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
; pKrnl01.asm
; --------------------------------------------------------------------------
; Este arquivo eh um pequeno kernel para teste do bootloader.
;
; Este pico-kernel foi feito para rodar tanto no modo real quanto no modo
; protegido de 16 bits, o segmento de video eh passado pelo registrador AX
; que tanto pode ser o segmento quanto o descritor da GDT.
;
; Ele "roda" um caracter na primeira linha, coluna 70.
; --------------------------------------------------------------------------
; Versao: 0.1
; Data: 30/03/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin -o pkrnl01.bin pkrnl01.asm
; ------------------------------------------------------------------------
; Executar: Executado pelo LoadLOS.
;===========================================================================

SECTION .text

[BITS 16]

start:
  mov es, ax      ; Recebe o segmento(16) de video em AX
  mov bx, 70*2    ; Determina posicao da linha 1/coluna 70
  xor ax, ax
loop:
  mov [es:bx], ax ; Copia o caracter+atributo para a posicao do video
  inc ax          ; Troca caracter+atributo
  jmp short loop  ; Loop infinito
