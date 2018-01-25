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
; Lib A20Check.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimento para verificacao da A20.
; --------------------------------------------------------------------------
; Versao: 0.1.1
; Data: 11/01/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj a20check.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2013-0411-0000] {v0.1} <Luciano Goncalez>
;
; - Implementação inicial.
; - Criando A20Check.
; ------------------------------------------------------------------------
; [2018-0111-2357] (v0.1.1) <Luciano Goncalez>
;
; - Adicionando historico ao arquivo.
; - Substituindo identação para espaços.
;===========================================================================


GLOBAL CheckA20

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function CheckA20 : Boolean; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Faz o teste "Wrap Around", e retorna se habilitado ou nao.
;===========================================================================
CheckA20:
  ; salva registradores
  pushf
  push ds
  push es
  push di
  push si

  ; definindo posicoes de memoria para testar
  xor ax, ax    ; ax = 0
  mov es, ax

  not ax        ; ax = 0xFFFF
  mov ds, ax

  mov di, 0x0500
  mov si, 0x0510

  ; desabilita as interrrupcoes por seguranca
  cli

  ; salvando valores originais
  mov al, [es:di]
  push ax

  mov al, [ds:si]
  push ax

  ; gravando novos valores na memoria
  mov byte [es:di], 0x00  ; es:di = 0000:0500 => 000500
  mov byte [ds:si], 0xFF  ; ds:si = FFFF:0510 => 100500

  ; invalidar a cache do processador?

  ; copia valor da memoria para DL, 0x00 => A20-ON, 0xFF => A20-OFF
  mov dl, [es:di]

  ; devolvendo os valores originais
  pop ax
  mov [ds:si], al

  pop ax
  mov [es:di], al

  ; salvando valor para reabilitar interrupcao, melhor....
  push dx

  ; reabilitando as interrupcoes
  sti

  ; pega o valor novamente
  pop ax

  ; verifica se houve wrap around
  cmp al, 0xFF
  jne .enabled

 ; desativado
  xor ax, ax
  jmp short .end

 .enabled:
  mov ax, 1

 .end:
  ; recupera registradores
  pop si
  pop di
  pop es
  pop ds
  popf
retf
