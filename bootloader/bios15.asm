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
; Versao: 0.4.1
; Data: 12/01/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bios15.asm
; --------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2013-0325-0000] {v0.1} <Luciano Goncalez>
;
; - Implementação inicial.
; - Criado BiosInt15x88, BiosInt15xE801L e BiosInt15xE801H.
; ------------------------------------------------------------------------
; [2013-0410-0000] {v0.3} <Luciano Goncalez>
;
; - Mudando rotinas para far.
; ------------------------------------------------------------------------
; [2013-0410-0000] {v0.4} <Luciano Goncalez>
;
; - Adicionando rotinas BiosInt15x24XX.
; ------------------------------------------------------------------------
; [2018-0112-2049] (v0.4.1) <Luciano Goncalez>
;
; - Adicionando historico ao arquivo.
; - Substituindo identação para espaços.
;===========================================================================


GLOBAL BiosInt15x88, BiosInt15xE801L, BiosInt15xE801H
GLOBAL BiosInt15x2400, BiosInt15x2401, BiosInt15x2402, BiosInt15x2403

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

  jnc .end      ; vai para o fim da rotina

  ;error:       ; funcao nao suportada
  xor ax, ax    ; retorno zero eh erro

 .end:
retf            ; finaliza a rotina

;===========================================================================
; function BiosInt15x2400 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Desabilita o A20
; --------------------------------------------------------------------------
; Retorno: Word::
;
;   0 = Ok
;
;   Hi = 1 = Falha
;     Lo = Codigo de erro
;
;===========================================================================
BiosInt15x2400:
  mov ax, 0x2400  ; funcao 2400h

  call near Int15$

  ; verifica erro por carrier
  jc .error

  ; verifica erro por AH
  cmp ah, 0
  jne .error

  ; Ok, AX retorna 0
  xor ax, ax
  jmp short .end

 .error:
  ; AH contem o codigo de erro
  mov al, ah
  mov ah, 1
  ; se erro, AH = 1, AL contem o codigo de erro

 .end:
retf

;===========================================================================
; function BiosInt15x2401 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Habilita o A20
; --------------------------------------------------------------------------
; Retorno: Word::
;
;   0 = Ok
;
;   Hi = 1 = Falha
;     Lo = Codigo de erro
;
;===========================================================================
BiosInt15x2401:
  mov ax, 0x2401  ; funcao 2401h

  call near Int15$

  ; verifica erro por carrier
  jc .error

  ; verifica erro por AH
  cmp ah, 0
  jne .error

  ; Ok, AX retorna 0
  xor ax, ax
  jmp short .end

 .error:
  ; AH contem o codigo de erro
  mov al, ah
  mov ah, 1
  ; se erro, AH = 1, AL contem o codigo de erro

 .end:
retf

;===========================================================================
; function BiosInt15x2402 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Retorna o Status de A20
; --------------------------------------------------------------------------
; Retorno: Word::
;
;   Hi = 0 = Ok
;     Lo = Status
;       0 = Desativado
;       1 = Ativado
;
;   Hi = 1 = Falha
;     Lo = Codigo de erro
;
;===========================================================================
BiosInt15x2402:
  mov ax, 0x2402  ; funcao 2402h

  call near Int15$

  ; verifica se erro por carrier
  jc .error

  ; verifica se erro por AH
  cmp ah, 0
  jne .error

  ; Ok, AH = 0, AL contem o status de A20
  jmp short .end

 .error:
  ; AH contem o codigo de erro
  mov al, ah
  mov ah, 1
  ; se erro, AH = 1, AL contem o codigo de erro

 .end:
retf

;===========================================================================
; function BiosInt15x2403 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Retorna o tipo de suporte para o A20
; --------------------------------------------------------------------------
; Retorno: Word::
;
;   Hi = 0 = Ok
;     Lo = Suporte
;       0 : 00 = Nenhum
;       1 : 01 = Keyboard (8042)
;       2 : 10 = System Control Port A (0x92)
;       3 : 11 = Ambos
;
;   Hi = 1 = Falha
;     Lo = Codigo de erro
;
;===========================================================================
BiosInt15x2403:
  mov ax, 0x2403  ; funcao 2403h

  call near Int15$

  ; verifica se erro por carrier
  jc .error

  ; verifica se erro por AH
  cmp ah, 0
  jne .error

  mov ax, bx  ; coloca o retorna em AX
  jmp short .end

 .error:
  ; AH contem o codigo de erro
  mov al, ah
  mov ah, 1
  ; se erro, AH = 1, AL contem o codigo de erro

 .end:
retf

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
