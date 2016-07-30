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
; Lib PM.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos para controle do modo protegido.
; --------------------------------------------------------------------------
; Versao: 0.1
; Data: 07/04/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj pm.asm
; --------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL LoadGDT

SEGMENT CODE USE 16

;===========================================================================
; procedure LoadGDT(GDTR : Pointer); external; {far}
; --------------------------------------------------------------------------
; Carrega a GDT
;===========================================================================
LoadGDT:
  push bp
  mov bp, sp

  ; Elementos na pilha:
  ;
  ; [+8]        => GDTR.Seg
  ; [+6]  : dw  => GDTR.Ofs
  ; ------------------------
  ; [+4]        => retf.seg
  ; [+2]  : dw  => retf.ofs
  ; [bp]  : w   => bp

  push ds

  mov ax, [bp+8]  ; pega o segmento do ponteiro
  mov ds, ax      ; poe o segmento em DS
  mov bx, [bp+6]  ; pega o offest do ponteiro

  lgdt [bx]       ; bx ja usa o segmento ds; equivale a ds:bx

  pop ds

  mov sp, bp
  pop bp
retf 4
