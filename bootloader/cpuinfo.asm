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
; Lib CPUInfo.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos para obtencao de dados do processador.
; --------------------------------------------------------------------------
; Versao: 0.1
; Data: 22/03/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj cpuinfo.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL GetCPUInfoFlags

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function GetCPUInfoFlags : Word; external; {near; nostackframe}
; --------------------------------------------------------------------------
; Obtem informacoes basicas da CPU.
; --------------------------------------------------------------------------
; Retorno:
;
; WordRec(GetCPUInfo16).Lo :
;
;   - 0 : 8086
;   - 1 : 80186 (nao implementado)
;   - 2 : 80286
;   - 3 : 80386
;   - 4 : 80486
;   - 5 : 80586 ou superior (possui CPUID, pode ser tambem um 80486)
;
; WordRec(GetCPUInfo16).Hi :
;
;   - 0 : Processador em Modo Real
;   - 1 : Processador em Modo Protegido
;
;===========================================================================

GetCPUInfoFlags:
  cli
  ; ------------------------------------------------------------------------
  ; Pega os Flags para teste
  ; ------------------------------------------------------------------------
  pushf
  pop ax            ; poe flags em ax

  mov dx, ax        ; mantem flags em dx para uso posterior

  ; ------------------------------------------------------------------------
  ; 8086 ou superior
  ; ------------------------------------------------------------------------
  xor cx, cx        ; cx = 0, cpu 8086

  ; para debug, simula 8086
  ; or ax, 0x8000   ; seta o bit 15 (Flags,Reserved)
  ; ^ debug

  and ax, 0x8000    ; testa o bit 15
  jnz .detectado    ; se bit 15<>0, cpu 8086

  ; ------------------------------------------------------------------------
  ; 80186 ou superior
  ; nao implementado :/
  ; ------------------------------------------------------------------------

  ; ------------------------------------------------------------------------
  ; 80286 ou superior
  ; ------------------------------------------------------------------------
  mov cl, 2         ; cpu 80286

  mov ax, dx        ; pega os flags no backup
  xor ax, 0x4000    ; inverte o bit 14 (Flags.NT)

  push ax
  popf              ; poe novo valore em flags

  ; para debug, simula 80286
  ; push dx
  ; popf
  ; ^ debug

  pushf
  pop ax            ; pega os flags da CPU

  xor ax, dx        ; compara com os originais
  jz .detectado     ; se iguais nao pode complementar o bit 14, cpu 80286

  push dx
  popf              ; volta os flags originais

  ; ------------------------------------------------------------------------
  ; Como eh um 80386 ou superior podemos usar instrucoes 386+ para testar
  ;   os bits ;)
  ; ------------------------------------------------------------------------
  ; Pega EFlags para teste
  ; ------------------------------------------------------------------------
  pushfd
  pop eax           ; poe EFlags em eax

  mov edx, eax      ; mantem EFlags em edx para uso posterior

  ; ------------------------------------------------------------------------
  ; 80386 ou superior
  ; ------------------------------------------------------------------------
  inc cl            ; cx = 3, cpu 80386

  xor eax, 0x40000  ; inverte o bit 18 (EFlags.AC)

  push eax
  popfd             ; poe novo valor em EFlags

  ; para debug, simula 80386
  ; push edx
  ; popfd
  ; ^ debug

  pushfd
  pop eax           ; pega os EFlags da CPU

  xor eax, edx      ; compara com os originais
  jz .detectado     ; se iguais nao pode complementar o flag 18, cpu 80386

  ; ------------------------------------------------------------------------
  ; 80486 ou superior
  ; ------------------------------------------------------------------------
  inc cl            ; cx = 4, cpu 80486

  mov eax, edx      ; pega os EFlags originais

  xor eax, 0x200000 ; inverte o bit 21 (EFlags.ID)

  push eax
  popfd             ; poe novo valor em EFlags

  ; para debug, simula 80486
  ; push edx
  ; popfd
  ; ^ debug

  pushfd
  pop eax           ; pega os EFlags da CPU

  xor eax, edx      ; compara com os originais
  jz .detectado     ; se iguais nao pode complementar o flag 21, cpu 80486

  ; ------------------------------------------------------------------------
  ; 80586 ou superior
  ; Alguns processadores 80486 possuem CPUID, o que pode confundir, no teste
  ; acima, use CPUID para testar daqui em diante
  ; ------------------------------------------------------------------------
  inc cl            ; cx = 5, cpu 80586 ou 80486 com CPUID

  push edx
  popfd             ; Devolve os EFlags originais

  ; ------------------------------------------------------------------------
  ; Passo 2 detectar o modo protegido
  ; ------------------------------------------------------------------------
 .detectado:
  xor ax, ax

  cmp cx, 2         ; ve se eh um 80286 ou superior
  jb .end           ; se nao for termina

  smsw ax           ; pega os bits em msw (usando msw que eh mais generico)
  and al, 1         ; pega somente o bit PE
  mov ah, al        ; poe as informacoes no byte mais significativo

 .end:
  mov al, cl        ; poe o tipo da cpu no byte menos significativo
  sti
retn
