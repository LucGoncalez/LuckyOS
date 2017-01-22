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
; kwrap.asm
; --------------------------------------------------------------------------
;   Arquivo escrito em Assembly que "envolve" o código escrito em linguagem
; de alto nivel, ele server para fazer a inicializacao inicial do kernel.
; --------------------------------------------------------------------------
; Versao: 0.2
; Data: 22/09/2013
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f elf32 kwrap.asm
; ------------------------------------------------------------------------
; Executar: Este arquivo precisa ser linkado com o LD para ser carregado
;   pelo bootloader.
;===========================================================================

; configuracao do kernel
  CPUModel    EQU 3           ; 80_3_86
  CPUMode     EQU 2           ; {0-real, 1-pm.segmentado, 2-pm.flat, 3-pm-paginado}
  MemAlign    EQU 12          ; 2^12 = 4K
  StackSize   EQU 0x00000000  ; Extensivel
  HeapSize    EQU 0x00000000  ; Extensivel

GLOBAL start

; informacoes da imagem em memoria
EXTERN kernel_start, kernel_end
EXTERN kernel_code, kernel_data, kernel_bss

; rotina principal do kernel
EXTERN kernelinit


SECTION .text

[BITS 32]

  ; IMPORTANTE: nao altere, use as constantes de cofiguracao acima
  ; Implementacao de cabecalho de arquivos do sistema
  LOSHeader:    ; Tabela de cabecalho PADRAO LOS...
  .Begin:
  ; Cabecalho padrao
  .LOSSign      DB  'LOS', 0      ; Assinatura padrao
  .HeaderSize   DW  .End - .Begin ; Automatiza o tamanho do cabecalho (max 64K)
  ; Cabecalho arquivo (Todo LOSHeader tem)
  .FileType     DB  'KRNLIMG', 0  ; Tipo do arquivo
  .TypeVersion  DW  1, 0          ; Versao (do cabecalho) maior/menor
  ; Metadados - arquitetura (Define alguns campos)
  .ArchBase     DB  0             ; x86 (vai que rola um ARM)
  .ArchBits     DB  32            ; influi no tamanho de campos abaixo *
  ; Metadados - requisitos
  .CPUModel     DB  CPUModel      ; Informa o modelo da CPUMin x86
  .CPUMode      DB  CPUMode       ; Informa o modo de operacao x86
  .MemAlign     DB  MemAlign      ; Bits 2^X
  .StackSize    DD  StackSize     ; * Em bytes
  .HeapSize     DD  HeapSize      ; * Em bytes
  ; Metadados - imagem
  .KernelStart  DD  kernel_start  ; * Endereco de inicio da imagem em memoria
  .KernelEnd    DD  kernel_end    ; * Endereco de termino da imagem em memoria
  .EntryPoint   DD  start         ; * Endereco do procedimento principal
  ; Metadados - segmentos
  .Code         DD  kernel_code   ; * Inicio do segmento de codigo
  .Data         DD  kernel_data   ; * Inicio do segmento de dados
  .BSS          DD  kernel_bss    ; * Inicio do segmento BSS
  ; Assinatura de conferencia
  .FootSign     DB  'LOS', 0      ; Assinatura padrao
  .End:         ; Termina o cabecalho


start:
  push eax
  call kernelinit
