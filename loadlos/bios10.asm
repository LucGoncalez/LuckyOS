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
; Lib BIOS10.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos da Int10h.
; --------------------------------------------------------------------------
; Versao: 0.3.1
; Data: 12/01/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bios10.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2013-0324-0000] {v0.1} <Luciano Goncalez>
;
; - Implementação inicial.
; - Criado BiosInt10x0F e BiosInt10x1130B.
; ------------------------------------------------------------------------
; [2013-0331-0000] {v0.1.1} <Luciano Goncalez>
;
; - Revisão.
; ------------------------------------------------------------------------
; [2013-0401-0000] {v0.2} <Luciano Goncalez>
;
; - Mudando os retornos.
; ------------------------------------------------------------------------
; [2013-0410-0000] {v0.3} <Luciano Goncalez>
;
; - Mudando rotinas para far.
; ------------------------------------------------------------------------
; [2018-0112-1940] (v0.3.1) <Luciano Goncalez>
;
; - Adicionando historico ao arquivo.
; - Substituindo identação para espaços.
;===========================================================================


GLOBAL BiosInt10x0F, BiosInt10x1130B

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function BiosInt10x0F : DWord; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Obtem o estado do video atual.
; --------------------------------------------------------------------------
; Retorno: DWord::
;
;   TBiosInt10x0FResult = packed record
;     Mode : Byte;
;     Cols : Byte;
;     Page : Byte;
;     Nul1 : Byte;
;   end;
;
;===========================================================================
BiosInt10x0F:
  xor ax, ax
  mov ah, 0x0F  ; Funcao Get Video State

  call near Int10$
  ; AL => Modo do video
  ; AH => Numero de colunas
  ; BH => Numero da pagina de video atual

  xor dx, dx
  mov dl, bh
retf

;===========================================================================
; function BiosInt10x1130B(FuncNo : Byte) : DWord; external; {far}
; --------------------------------------------------------------------------
; Obtem o estado do video atual.
; --------------------------------------------------------------------------
; Retorno: DWord::
;
;   TBiosInt10x1130B_Result = packed record
;     BytesPerChar : Word;
;     Rows : Byte;
;     Nul1 : Byte;
;   end;
;
;===========================================================================
BiosInt10x1130B:
  ; bp+4  => FuncNo
  ; bp+2  => IP-Retorno
  ; bp    => BP

  push bp
  mov bp, sp

  xor bx, bx
  xor dx, dx

  mov bh, [bp + 4]  ; coloca FuncNo em BH
  mov ax, 0x1130

  call near Int10$
  ; CX => Numero de bytes por caracter (pontos?)
  ; DL => Numero de linhas (-1)
  ; ES:BP => Ponteiro para a tabela (suprimido na chamada Int10$)

  mov ax, cx

  mov sp, bp
  pop bp
retf 2

;===========================================================================
; Int10$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina de video da BIOS.
;===========================================================================
Int10$:
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

  int 0x10

  pop bp
  pop di
  pop si
  pop es
  pop ds
retn
