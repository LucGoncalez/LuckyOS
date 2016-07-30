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
; Versao: 0.4
; Data: 07/04/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bootaux.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL CopyFAR16, GoKernel16PM, GetDS, GetSS, GetSP

SEGMENT DATA PUBLIC

  ; Variaveis locais usadas por GoKernel16
  CSeg    RESW  1
  DSeg    RESW  1
  ESeg    RESW  1
  Entry   RESW  1
  Param   RESW  1


SEGMENT CODE PUBLIC USE 16

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
; procedure GoKernel16(CS, DS, ES, SS : Word; Entry, Stack : Word; Param : Word);
;   external; {far}
; --------------------------------------------------------------------------
; Configura e chama o kernel previamente carregado:
;
;   CS : Segmento/descritor do codigo;
;   DS : Segmento/descritor de dados;
;   ES : Segmento/descritor extra;
;   SS : Segmento/descritor da pilha;
;
;   Entry : Ponto de entrada do kernel (Offset em CS);
;   Stack : Base da pilha (Offset em SS);
;   Param : Parametro passado ao kernel em AX;
;===========================================================================
GoKernel16PM:
  ; cria stackframe
  push bp
  mov bp, sp

  ; Parametros na pilha
  ; --------------------
  ; [+18] => W = CS
  ; [+16] => W = DS
  ; [+14] => W = ES
  ; [+12] => W = SS
  ; [+10] => W = Entry
  ; [+8]  => W = Stack
  ; [+6]  => W = Param
  ; ---> 14 bytes
  ; [+4]  ...
  ; [+2]  => D = retf
  ; [bp]  => W = BP


  ; salva valores em variaveis no segmento de dados
  mov ax, [bp + 18] ; CS
  mov [CSeg], ax

  mov ax, [bp + 16] ; DS
  mov [DSeg], ax

  mov ax, [bp + 14] ; ES
  mov [ESeg], ax

  mov ax, [bp + 10] ; Entry
  mov [Entry], ax

  mov ax, [bp + 6]  ; Param
  mov [Param], ax

  ; ativa o modo protegido
  mov eax, cr0
  or eax, 1
  mov cr0, eax

  ; configura nova pilha
  mov dx, [bp + 12] ; pega SS
  mov ax, [bp + 8]  ; pega SP (Stack)

  mov ss, dx  ; atualiza o segmento da pilha
  mov sp, ax  ; atualiza ponteiro do topo da pilha
  mov bp, ax  ; atualiza ponteiro da base da pilha

  xor ax, ax
  mov [bp], ax    ; grava elemento nulo no comeco da pilha

  ; cria endereco do salto
  mov ax, [CSeg]
  push ax

  mov ax, [Entry]
  push ax

  ; coloca valores de DS e ES na pilha
  mov ax, [DSeg]
  push ax

  mov ax, [ESeg]
  push ax

  ; pega parametro
  mov ax, [Param]

  ; atualiza segmentos de dados
  pop es
  pop ds

  ; salta para o kernel (atualiza CS e Entry)
  retf
; Fim da rotina, impossivel retornar a esse ponto...


;===========================================================================
; function GetDS : Word; external; {far}
; --------------------------------------------------------------------------
; Retorna DS
;===========================================================================
GetDS:
  mov ax, ds
retf

;===========================================================================
; function GetSS : Word; external; {far}
; --------------------------------------------------------------------------
; Retorna SS
;===========================================================================
GetSS:
  mov ax, ss
retf

;===========================================================================
; function GetSP : Word; external; {far}
; --------------------------------------------------------------------------
; Retorna SP
;===========================================================================
GetSP:
  mov ax, sp
retf
