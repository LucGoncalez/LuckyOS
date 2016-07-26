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
; Lib BootAux.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos que auxiliam o boot.
; --------------------------------------------------------------------------
; Versao: 0.2
; Data: 01/04/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bootaux.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL CopyFAR16, JumpFAR16

SEGMENT CODE USE 16

;===========================================================================
; procedure CopyFAR16(Src, Dest : DWord; Count : Word); external; {near}
; --------------------------------------------------------------------------
; Copia Count bytes de Src para Dest.
;===========================================================================
CopyFAR16:
  ; cria a stackframe
  push bp
  mov bp, sp

  ; parametros na pilha:
  ;
  ; bp+10 = dword => Src
  ; bp+6  = dword => Dest
  ; bp+4  = word  => Count
  ; bp+2  = retn
  ; bp+0  = bp
  ;
  ; total de bytes para limpar na saida 10

  ; salva registradores
  push ds
  push es
  push si
  push di
  pushf

  lds si, [bp + 10] ; carrega Src
  les di, [bp + 6]  ; carrega Dest
  mov cx, [bp + 4]  ; carrega Count

  cld         ; zera DF = direcao flag, copia incrementando
  rep movsb   ; executa a copia

  ; recupera registradores
  popf
  pop di
  pop si
  pop es
  pop ds

  ; limpa a stackframe
  mov sp, bp
  pop bp
retn 10

;===========================================================================
; procedure JumpFAR16(Addr : DWord; Param : Word); external; {near}
; --------------------------------------------------------------------------
; Salta para a rotina localizada no endereco ADDR, passando Param em AX.
;===========================================================================
JumpFAR16:
  ; cria a stackframe
  push bp
  mov bp, sp

  ; parametros na pilha:
  ;
  ; bp+6  = dword => Addr
  ; bp+4  = word  => Param
  ; bp+2  = retn
  ; bp+0  = bp
  ;
  ; total de bytes para limpar na saida 6

  mov ax, [bp + 4] ; pega o parametro na pilha
  mov bx, [bp + 6] ; pega o offset na pilha
  mov cx, [bp + 8] ; pega o segmento na pilha

  ; cria pilha para para salto
  push cx   ; coloca o segmento na pilha
  push bx   ; coloca o offset na pilha
  retf      ; salta para a rotina (limpa o endereco na pilha)

  ; limpa a stackframe (se o procedimento retornar :-)
  mov sp, bp
  pop bp
retn 6
