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
; kernel.asm
; --------------------------------------------------------------------------
; Este arquivo eh um pequeno kernel para teste do bootloader.
;
; Ele "roda" um caracter na primeira linha, coluna 70.
; --------------------------------------------------------------------------
; Versao: 0.1.1 (pkernel v0.7)
; Data: 12/01/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin -o kernel.bin kernel.asm
; ------------------------------------------------------------------------
; Executar: Executado pelo LoadLOS.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2013-0330-0000] {pkrnl-0.1} <Luciano Goncalez>
;
; - Implementação inicial.
; ------------------------------------------------------------------------
; [2013-0414-0000] {pkrnl-0.2} <Luciano Goncalez>
;
; - Kernel recebe segmento de video em AX.
; ------------------------------------------------------------------------
; [2013-0414-0000] {pkrnl-0.3} <Luciano Goncalez>
;
; - Kernel em 32 bits.
; ------------------------------------------------------------------------
; [2013-0419-0000] {pkrnl-0.4} <Luciano Goncalez>
;
; - Adicionada tabela de boot no kernel.
; ------------------------------------------------------------------------
; [2013-0421-0000] {pkrnl-0.5} <Luciano Goncalez>
;
; - Adicionada suporte a tabela de bootloader.
; ------------------------------------------------------------------------
; [2013-0423-0000] {kernel-0.0} <Luciano Goncalez>
;
; - Muda nome e configurações de heap e stack para extensivel.
; ------------------------------------------------------------------------
;[2013-0614-0000] {kernel-0.1} <Luciano Goncalez>
;
; - Corrigindo falta de campo de versão.
; ------------------------------------------------------------------------
; [2018-0112-2336] (v0.1.1) <Luciano Goncalez>
;
; - Adicionando historico ao arquivo.
; - Substituindo identação para espaços.
; ------------------------------------------------------------------------
;
; SUBSTITUIDA!
;
;===========================================================================


;   Um ponto chave aqui é criar uma tabela de boot fornecidada pelo kernel
; que de informacoes ao bootloader de como o kernel quer ser carregado e
; configurado.
;
;   Esta tabela precisa ter uma assinatura, e um numero de versao, para que
; o bootloader obtenha informaçoes corretas.
;
;   O que o kernel precisa para trabalhar:
;
;   - Um minimo de processador
;   - Um posicao especifica na memoria
;   - Uma quantidade minima de pilha
;   - Uma quantidade minima de memoria de alocacao - heap
;
;   Como a quantidade de memória agora está dividida, cabe ao bootloader
; calcular a memoria minima necessaria.
;
;   Outra coisa que pode ser bem util e o alinhamento da memoria
;

; [map all kernel.map] <- usado para debug

; configuracao do kernel
  CPUMin      EQU 3           ; 80386
  MemAlign    EQU 12          ; 2^12 = 4K
  EntryPoint  EQU 0x00100000  ; 1M
  StackSize   EQU 0x00000000  ; Extensivel
  HeapSize    EQU 0x00000000  ; Extensivel

; constante
  AddrVideoSeg  EQU 24

SECTION .text

[BITS 32]

[ORG EntryPoint]  ; onde o kernel deve ser carregado
start:
  jmp near kstart

  ; *** Tabela de dados do kernel usada no boot
  ; IMPORTANTE: nao altere, use as constantes de cofiguracao acima
  KT:       ; kernel table
  .LOS_Sign   DB  'LOS', 0    ; 4 B
  .KT_Sign    DB  'BKT', 0    ; 4 B
  .Version    DB  1           ; 1 B
  .CPUMin     DB  CPUMin      ; 1 B
  .MemAlign   DB  MemAlign    ; 1 B
  .EntryPoint DD  EntryPoint  ; 4 B
  .StackSize  DD  StackSize   ; 4 B
  .HeapSize   DD  HeapSize    ; 4 B
  ; total 23 bytes
  ; *** Tabela de dados do kernel usada no boot

kstart:
  mov ebx, eax    ; recebe o endereco da tabela de boot

  xor eax, eax
  mov ax, [ebx + AddrVideoSeg] ; pega o endereço de video em AX

  shl eax, 4      ; converte segmento para endereco linear
  add eax, 70*2   ; determina posicao da linha 1/coluna 70
  mov ebx, eax

  xor eax, eax
loop:
  mov [ebx], eax  ; Copia o caracter+atributo para a posicao do video
  inc eax           ; Troca caracter+atributo
  jmp short loop    ; Loop infinito
