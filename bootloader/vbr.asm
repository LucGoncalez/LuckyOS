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
; vbr.asm
; --------------------------------------------------------------------------
; LOS Boot Sector - Floppy FAT12
;
;   Volume Boot Record, ou stage1, parte do bootloader responsável por
; localizar o stage2 e carregá-lo para a memória e, em seguida, executá-lo.
; --------------------------------------------------------------------------
; Versao: 0.1
; Data: 13/02/2018
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin vbr.asm
; ------------------------------------------------------------------------
; Executar: Este arquivo deve ser instalado no VBR de uma partição FAT12.
;===========================================================================
; Historico de versões
; ------------------------------------------------------------------------
; [2018-0213-1308] {v0.0} <Luciano Goncalez>
;
; - Implementação inicial.
;===========================================================================



;===========================================================================
; ############################ Referências ############################
; --------------------------------------------------------------------------
; (https://wiki.osdev.org/FAT)
; (https://support.microsoft.com/pt-br/help/140418/detailed-explanation-of-fat-boot-sector)
; (http://www.maverick-os.dk/FileSystemFormats/FAT12_FileSystem.html)
;===========================================================================



;===========================================================================
;
; ############################ Definições ############################
;
;===========================================================================

  ; A quantidade de setores configurados aqui deve ser igual ao do BPB
  STAGE1_SECTORS  equ 0x03            ; max 0x38 (56)

  STAGE1_BASE     equ 0x1000          ; (4KB) Local onde o BS será carregado, considerando o autodeslocamento
  STAGE2_BASE     equ 0x10000         ; 64KB.

  LOWMEM_START    equ 0x8000          ; 32KB.
  STACK_BASE      equ 0xFFFC          ; 4 bytes abaixo do final do segmento

  INT_1E_VETOR    equ 0x0078          ; 00:78 = Vetor para Disk Initialization Parameter Table
  EBDA_SEG_VETOR  equ 0x040E
  DIPT            equ 0x0522          ; DOS diskette initialization table

  DIRENTRY_SIZE   equ 32              ; Tamanho de uma entrada de diretorio
  FILENAME_SIZE   equ 11

  CSEG            equ 0x08
  DSEG            equ 0x10



; ### DIPT_Rec ###
struc DIPT_Rec
  .DiskContMode1:               resb 1
  ; 0x0i = Head Step Rate (ms)
  ; 0xi0 = Head Unload Time (ms)

  .DiskContMode2:               resb 1
  ; 0x01 = DMA Flag (0 = use DMA)
  ; 1111_1110 = (head load time/2)-1

  .TimerTicksMotorOff:          resb 1
  ; clocks ticks until motor off

  .BytesPerSector:              resb 1
  ; * BytesPerSector (MFM)
  ; 0 - 128 bytes
  ; 1 - 256 bytes
  ; 2 - 512 bytes
  ; 3 - 1024 bytes

  .LastSectorsOnTrack:          resb 1

  .GapLength:                   resb 1
  ; MFM   Bytes Per Sector  Sector Per Track    Write Gap   Format Gap
  ;  1           256                18             0Ah         0Ch
  ;  1           256                16             20h         32h
  ;  2           512                 8             2Ah         50h
  ;  2           512                 9             1Bh         6Ch
  ;  3          1024                 4             80h         F0h
  ;  4          2048                 2             C8h         FFh
  ;  5          4096                 1             C8h         FFh

  .DiskDataLenght:              resb 1
  ; 80h for 128 bytes/sector
  ; FFh otherwise

  .GapLengthWhenFormatting:     resb 1

  .DataPatternForFormat:        resb 1

  .FloppyHeadBounceDelay:       resb 1 ; ms

  .FloppyMotorStartDelay:       resb 1 ; s/8

  ; .FloppyMotorStopDelay         resb 1 ; s/4 # não usada/carregada
  .Size:
endstruc



;===========================================================================
;
; ############################ Código ############################
;
;===========================================================================

SECTION .text
[ORG STAGE1_BASE]
[BITS 16]
[CPU 8086]

  jmp   _start
  times 0x03 - ($ - $$) nop


; ### OEM ###
OEMID:
  db    'LUCKY_OS'      ; OEM (DB 8 Bytes)
  times 0x0B - ($ - $$) db 0x20


; ### BPB [todas as FATs] ###
; (Os dados aqui são configurados por uma formatação, antes da instalação do vbr)
BPB:
  ; Bytes Per Sector:
  ; This is the size of a hardware sector and for most disks in use in the United States, the value
  ; of this field will be 512.
  .BytesPerSector:
    dw  0x0000          ; padrão 0x0200 (512)

  ; Sectors Per Cluster:
  ; Because FAT is limited in the number of clusters (or "allocation units") that it can track,
  ; large volumes are supported by increasing the number of sectors per cluster. The cluster factor
  ; for a FAT volume is entirely dependent on the size of the volume. Valid values for this field
  ; are 1, 2, 4, 8, 16, 32, 64, and 128. Query in the Microsoft Knowledge Base for the term
  ; "Default Cluster Size" for more information on this subject.
  .SectorsPerCluster:
    db  0x00            ; padrão 0x01

  ; vReserved Sectors:
  ; This represents the number of sectors preceding the start of the first FAT, including the boot
  ; sector itself. It should always have a value of at least 1.
  .ReservedSectors:
    dw  0x0000          ; padrão 0x0001

  ; FATs:
  ; This is the number of copies of the FAT table stored on the disk. Typically, the value of this
  ; field is 2.
  .FATs:
    db  0x00            ; padrão 0x02

  ; Root Entries:
  ; This is the total number of file name entries that can be stored in the root directory of the
  ; volume. On a typical hard drive, the value of this field is 512. Note, however, that one entry
  ; is always used as a Volume Label, and that files with long file names will use up multiple
  ; entries per file. This means the largest number of files in the root directory is typically 511,
  ; but that you will run out of entries before that if long file names are used.
  .RootEntries:
    dw  0x0000          ; padrão 0x00E0 (224)

  ; Small Sectors:
  ; This field is used to store the number of sectors on the disk if the size of the volume is small
  ; enough. For larger volumes, this field has a value of 0, and we refer instead to the
  ; "Large Sectors" value which comes later.
  .SmallSectors:
    dw  0x0000          ; padrão 0x0B40 (2880 (LBA))

  ; Media Descriptor:
  ; This byte provides information about the media being used. The following table lists some of the
  ; recognized media descriptor values and their associated media. Note that the media descriptor
  ; byte may be associated with more than one disk capacity.
  ;   Byte   Capacity   Media Size and Type
  ;   F0     2.88 MB    3.5-inch, 2-sided, 36-sector
  ;   F0     1.44 MB    3.5-inch, 2-sided, 18-sector
  ;   F9     720 KB     3.5-inch, 2-sided, 9-sector
  ;   F9     1.2 MB     5.25-inch, 2-sided, 15-sector
  ;   FD     360 KB     5.25-inch, 2-sided, 9-sector
  ;   FF     320 KB     5.25-inch, 2-sided, 8-sector
  ;   FC     180 KB     5.25-inch, 1-sided, 9-sector
  ;   FE     160 KB     5.25-inch, 1-sided, 8-sector
  ;   F8     -----      Fixed disk
  .MediaDescriptor:
    db  0x00            ; padrão 0xF0

  ; Sectors Per FAT:
  ; This is the number of sectors occupied by each of the FATs on the volume. Given this information,
  ; together with the number of FATs and reserved sectors listed above, we can compute where the
  ; root directory begins. Given the number of entries in the root directory, we can also compute
  ; where the user data area of the disk begins.
  .SectorsPerFAT:
    dw  0x0000          ; padrão 0x0009

  ; Sectors Per Track and Heads:
  ; These values are a part of the apparent disk geometry in use when the disk was formatted.

  .SectorsPerTrack:
    dw  0x0000          ; padrão 0x0012 (18)

  .Heads:
    dw  0x0000          ; padrão 0x0002

  ; Hidden Sectors:
  ; This is the number of sectors on the physical disk preceding the start of the volume. (that is,
  ; before the boot sector itself) It is used during the boot sequence in order to calculate the
  ; absolute offset to the root directory and data areas.
  .HiddenSectors:
    dd  0x0000_0000

  ; Large Sectors:
  ; If the Small Sectors field is zero, this field contains the total number of sectors used by the
  ; FAT volume.
  .LargeSectors:
    dd  0x0000_0000     ; padrão 0x0000_0B40 (2880)


; ### eBPB [FAT 12/16] ###
  ; Physical Drive Number:
  ; This is related to the BIOS physical drive number. Floppy drives are numbered starting with 0x00
  ; for the A: drive, while physical hard disks are numbered starting with 0x80. Typically, you
  ; would set this value prior to issuing an INT 13 BIOS call in order to specify the device to
  ; access. The on-disk value stored in this field is typically 0x00 for floppies and 0x80 for hard
  ; disks, regardless of how many physical disk drives exist, because the value is only relevant if
  ; the device is a boot device.
  .PhysicalDriveNumber:
    db  0x00

  ; Current Head:
  ; This is another field typically used when doing INT13 BIOS calls. The value would originally
  ; have been used to store the track on which the boot record was located, but the value stored on
  ; disk is not currently used as such. Therefore, Windows NT uses this field to store two flags:
  ;   - The low order bit is a "dirty" flag, used to indicate that autochk should run chkdsk against
  ;   the volume at boot time.
  ;   - The second lowest bit is a flag indicating that a surface scan should also be run.
  .CurrentHead:
    db  0x00            ; CurrentHead / WinNTFlags (01b = chkdsk/ 10b = surface scan)

  ; Signature:
  ; The extended boot record signature must be either 0x28 or 0x29 in order to be recognized by
  ; Windows NT.
  .Signature:
    db  0x00            ; padrão 0x29

  ; ID:
  ; The ID is a random serial number assigned at format time in order to aid in distinguishing one
  ; disk from another.
  .ID:
    dd  0x0000_0000     ; VolumeID (Ramdom)

  ; Volume Label:
  ; This field was used to store the volume label, but the volume label is now stored as a special
  ; file in the root directory.
  .VolumeLabel:
    times 11 db 0       ; VolumeLabel (DB 11 Bytes, definido na formatação)
    times 0x36 - ($ - $$) db 0x20		; O nome deve preenchido com espaços

  ; System ID:
  ; This field is either "FAT12" or "FAT16," depending on the format of the disk.
  .SystemID:
    times 8 db 0        ; SystemID (DB 8 Bytes; FAT12 ou FAT16)
    times 0x3E - ($ - $$) db 0x20 	; O nome deve preenchido com espaços



; ### start ###

; Valores obtidos no boot do VirtualBox

; AX = 0xAA55
; BX = 0x0000
; CX = 0x0001
; DX = 0x0000

; CS = 0x0000
; DS = 0x0000
; ES = 0x0000
; SS = 0x0000

; SI = 0xF4A0
; DI = 0xFFF0
; SP = 0x7800
; BP = 0x0000



;===========================================================================
; _start
; --------------------------------------------------------------------------
; Ponto de entrada do VBR
;===========================================================================

_start:
  ; ### Ajustes iniciais ###
  cli
  xor   ax, ax
  mov   ds, ax
  mov   es, ax

  ; Configura a pilha
  mov   ss, ax
  mov   sp, STACK_BASE
  mov   bp, sp

  ; Copia vbr para endereço base
  mov   si, 0x7C00
  mov   di, STAGE1_BASE
  mov   cx, 256               ; 256 words

  rep   movsw

  ; Normalizando linha de execução
  jmp 0:_normalize             ; CS, IP


_normalize:
  ; Salva o número do driver obtido no boot para liberar o registrador
  mov   [BPB.PhysicalDriveNumber], dl

  ; Copia a DIPT - Disk Initialization Parameter Table - da BIOS para área de boot
  push  ds

  mov   bx, INT_1E_VETOR
  lds   si, [bx]               ; valor original 0xF000_EFC7

  mov   di, DIPT
  mov   cx, DIPT_Rec.Size
  cld
  rep   movsb

  pop   ds

  ; Muda INT 1E para que aponte para a tabela de parâmetros do disquete alterada
  ; AX = 0
  mov   [bx + 2], ax
  mov   word [bx], DIPT

  ; INT 13,0000 = reset de disco para carregar a nova tabela de parâmetros
  sti
  call  Int13$
  jc    Error

  ; Ajusta tamnho do FS
  xor   ax,ax
  cmp   ax, [BPB.SmallSectors]
  je    _LoadEBS                ; se SmallSectors = 0; salta
  mov   cx,[BPB.SmallSectors]
  mov   [BPB.LargeSectors],cx

_LoadEBS:
  ; Numero de setores do bootloader tem que ser igual ao reservado do FS
  mov   cx, STAGE1_SECTORS
  cmp   word [BPB.ReservedSectors], cx
  jne   Error

  mov   di, STAGE1_BASE           ; ES:DI = endereço de memória
  mov   ax, [BPB.BytesPerSector]
  add   di, ax                    ; Pula o setor carregado

  xor   dx, dx
  mov   ax, 1                 ; DX:AX = endereço LBA

  dec   cx                    ; CX = quantidade de setores a ler (primeiro setor já está carregado)

  call  ReadLBA

  ; ### Bem-vindo Extended Boot Sector ###
  jmp  WelcomeEBS



;===========================================================================
;
; ############################ Procedimentos ############################
;
;===========================================================================

;===========================================================================
; Error
; --------------------------------------------------------------------------
; Mostra mensagem "Disco sem sistema ou defeituoso...", espera usuário apertar uma tecla,
; depois chama a INT 19 para iniciar o processo de boot novamente.
;===========================================================================

Error:
  mov   ax, ErrorMsg
  call  WriteAnsiStr

  call  Reboot
ret


;===========================================================================
; Reboot
; --------------------------------------------------------------------------
; Mostra mensagem de reboot e reinicia
;===========================================================================

Reboot:
  mov   ax, NewLine
  call  WriteAnsiStr

  mov   ax, RebootMsg
  call  WriteAnsiStr

  xor   ax,ax
  call  Int16$            ; INT 16,0000 = aguarda pressionar uma tecla

  int   0x19              ; reboot
ret


;===========================================================================
; WriteAnsiStr
; --------------------------------------------------------------------------
; Imprime a string terminada em zero contida no endereço DS:AX
;===========================================================================

WriteAnsiStr:
  push  si
  push  bx

  mov   si, ax

  mov   ah,0x0E         ; Indica a rotina de teletipo da BIOS
  mov   bx, 0x0007      ; Número da página de vídeo/Texto branco em fundo preto
.next:
  lodsb
  or    al,al
  jz    .exit           ; Se al=0, string terminou e salta para .exit
  call  Int10$          ; Se não, chama INT 10 para por caracter na tela
  jmp   .next
.exit:
  pop   bx
  pop   si
ret                     ; Retorna à rotina principal


;===========================================================================
; ReadLBA
; --------------------------------------------------------------------------
; Le setores em LBA
;
; DX:AX       Setor LBA
; CX          Numero de setores
; ES:DI       Buffer
;===========================================================================

ReadLBA:
  or  cx, cx
  jz  .exit

.next:
  push  cx
  push  ax
  push  dx
  push  di
  push  es

  call  LBA2CHS
  call  ReadCHS

  pop   es
  pop   di

  add   di, [BPB.BytesPerSector]
  jnc   .0

  mov   ax, es
  add   ax, 0x1000
  mov   es, ax

.0:
  pop   dx
  pop   ax

  inc   ax
  jnz   .1

  inc   dx

.1:
  pop   cx
  loop  .next

.exit:
ret


;===========================================================================
; LBA2CHS
; --------------------------------------------------------------------------
; Procedimento para conversao de LBA para CHS
; O LBA está em DX:AX
;===========================================================================

LBA2CHS:
  ; Verfica se divisão provoca carry
  cmp   dx, [BPB.SectorsPerTrack]
  jae   Error

  ; Obtem o setor
  div   word [BPB.SectorsPerTrack]

  inc   dl
  mov   [CurrentSector], dl

  ; Obtem cabeça e cilindro
  xor   dx, dx
  div   word [BPB.Heads]

  mov   [BPB.CurrentHead], dl
  mov   [CurrentCylinder], ax
ret


;===========================================================================
; ReadCHS
; --------------------------------------------------------------------------
; Procedimento para leitura via int 0x13
; Todos os parametros são obtidos pelas variaveis em memoria
; Um setor somente é lido por vez
; O buffer está em ES:DI
;
; A INT 0x13 usa os seguintes parametros:
;
;   AH = 02
;
;   AL = number of sectors to read  (1-128 dec.)
;   CH = track/cylinder number  (0-1023 dec., see below)
;
;   CL = sector number  (1-17 dec.)
;
;   DH = head number  (0-15 dec.)
;
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   ES:BX = pointer to buffer
;
; on return:
;   AH = status  (see INT 13,STATUS)
;   AL = number of sectors read
;   CF = 0 if successful
;      = 1 if error
;
;===========================================================================

ReadCHS:
  push  bx
  mov   bx, di

  mov   ax, [CurrentCylinder]
  mov   cl, 6
  shl   ah, cl
  xchg  ah, al

  or    al, [CurrentSector]
  mov   cx, ax

  mov   dh, [BPB.CurrentHead]
  mov   dl, [BPB.PhysicalDriveNumber]

  mov   ah, 2
  mov   al, 1

  call  Int13$
  jc    Error

  pop   bx
ret


;===========================================================================
; Int10$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina de video da BIOS.
;===========================================================================

Int10$:
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
ret


;===========================================================================
; Int13$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina de disco da BIOS.
;===========================================================================

Int13$:
  ; registradores que podem ser alterados durante a chamada
  push ds
  push es
  push si
  push di
  push bp

  int 0x13

  pop bp
  pop di
  pop si
  pop es
  pop ds
ret


;===========================================================================
; Int16$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina de teclado da BIOS.
;===========================================================================

Int16$:
  ; registradores que podem ser alterados durante a chamada
  push ds
  push es
  push si
  push di
  push bp

  int 0x16

  pop bp
  pop di
  pop si
  pop es
  pop ds
ret



;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================


ErrorMsg  db  'Disco sem sistema ou sistema defeituoso!', 0
RebootMsg db  'Pressione qualquer tecla para reiniciar... ', 0
NewLine         db  10, 13, 0



;===========================================================================
;
; ############################ Assinatura de boot ############################
;
; --------------------------------------------------------------------------
times (0x200 - 2) - ($ - $$) db 0
db 0x55,0xAA
;===========================================================================



;===========================================================================
;
; ############################ Extended Boot Sector ############################
;
;===========================================================================


;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================

; GDT
align 4, db 0
gdt:
  dq    0                       ; NULL selector.
  dq    0x00_cf9a_000000_ffff   ; code32,r/x,flat,ring0,present (sel=0x08)
  dq    0x00_cf92_000000_ffff   ; data32,r/w,flat,ring0,present (sel=0x10)
gdt_limit equ ($ - gdt) - 1

; IDT nula
align 4,db 0
idt:
  dq    0
idt_limit equ ($ - idt) - 1

; GDT_Desc
align 4, db 0
gdt_desc:
  dw    gdt_limit
  dd    0                       ; Esse offset vai ser normalizado depois.

; IDT_Desc
align 4,db 0
idt_desc:
  dw    idt_limit
  dd    0                       ; Esse offset vai ser normalizado depois.


; Strings
WelcomeEBSstr   db  'Extended Boot Sector Carregado!', 0
ErrorCPU        db  'Erro: CPU minima 80386', 0
ErrorSize       db  'Stage2 muito grande para a memoria!', 0
LoadMsg         db  'Stage2 carregado!', 0

FileName        db  'BOOT    BIN'



;===========================================================================
;
; ############################ Código ############################
;
;===========================================================================

;===========================================================================
; WelcomeEBS
; --------------------------------------------------------------------------
; Continuacao da rotina principal...
; Contida no EBS
;===========================================================================

WelcomeEBS:
  xor   dx, dx
  mov   ax, WelcomeEBSstr
  call  WriteAnsiStr

  mov   ax, NewLine
  call  WriteAnsiStr

  call  CheckCPU
  call  CheckMem

  call  CalcSectors
  call  SearchFile
  call  LoadFile

  call  ConfigPM
  call  GoStage2

; Não deveria chegar aqui
jmp Error



;===========================================================================
;
; ############################ Procedimentos 16 bits ############################
;
;===========================================================================

;===========================================================================
; CheckCPU
; --------------------------------------------------------------------------
; Verifica o tipo da CPU, minimo 386
;===========================================================================

CheckCPU:
  cli
  ; ------------------------------------------------------------------------
  ; Pega os Flags para teste
  ; ------------------------------------------------------------------------
  pushf
  pop   ax            ; poe flags em ax

  mov   dx, ax        ; mantem flags em dx para uso posterior

  ; ------------------------------------------------------------------------
  ; 8086 ou superior
  ; ------------------------------------------------------------------------
  xor   cx, cx        ; cx = 0, cpu 8086

  and   ax, 0x8000    ; testa o bit 15
  jnz   .detectado    ; se bit 15<>0, cpu 8086

  ; ------------------------------------------------------------------------
  ; 80186 ou superior
  ; nao implementado :/
  ; ------------------------------------------------------------------------

  ; ------------------------------------------------------------------------
  ; 80286 ou superior
  ; ------------------------------------------------------------------------
  mov   cl, 2         ; cpu 80286

  mov   ax, dx        ; pega os flags no backup
  xor   ax, 0x4000    ; inverte o bit 14 (Flags.NT)

  push  ax
  popf                ; poe novo valore em flags

  pushf
  pop   ax            ; pega os flags da CPU

  xor   ax, dx        ; compara com os originais
  jz    .detectado    ; se iguais nao pode complementar o bit 14, cpu 80286

  push  dx
  popf                ; volta os flags originais

  ; ------------------------------------------------------------------------
  ; 80386 ou superior
  ; ------------------------------------------------------------------------
  inc   cl            ; cx = 3, cpu 80386

.detectado:
  push  dx
  popf                ; volta os flags originais

.test:
  sti

  cmp   cl, 3         ; ve se eh um 80386
  je   .exit          ; se nao reinicia

  mov   ax, ErrorCPU
  call  WriteAnsiStr

  call  Reboot

.exit:
ret


;===========================================================================
; CheckMem
; --------------------------------------------------------------------------
; Obtem a quantida de memoria inferior disponível e verifica o stage2
;===========================================================================

CheckMem:
  push  bx

  call  Int12$

  mov   cl, 6
  shl   ax, cl

  mov   [LowMemSizePh], ax

  mov   bx, EBDA_SEG_VETOR
  mov   ax, [bx]
  mov   [EBDA_Seg], ax

  cmp   ax, [LowMemSizePh]
  jae   .exit

  mov   [LowMemSizePh], ax

.exit:
  pop   bx
ret


;===========================================================================
; CalcSectors
; --------------------------------------------------------------------------
; Calcula a posição do elementos do FS
;===========================================================================

CalcSectors:
  ; Calcular a posição da FAT
  mov   ax, [BPB.HiddenSectors]
  mov   dx, [BPB.HiddenSectors + 2]

  add   ax,[BPB.ReservedSectors]
  adc   dx,0

  mov   [FAT_LBA], ax
  mov   [FAT_LBA + 2], dx

  ; Calcula a posição do root sector
  xor   ax, ax
  mov   al, [BPB.FATs]
  mul   word [BPB.SectorsPerFAT]

  add   ax, [FAT_LBA]
  adc   dx, [FAT_LBA + 2]

  mov   [Root_LBA], ax
  mov   [Root_LBA + 2], dx

  ; Calcula o tamanho do root sector
  mov   ax, DIRENTRY_SIZE
  mul   word [BPB.RootEntries]
  dec   ax
  mov   bx, [BPB.BytesPerSector]
  div   bx
  inc   ax

  mov   [Root_Size], ax     ; Em setores

  ; Calcula primeiro sector da area de dados
  xor   dx, dx

  add   ax, [Root_LBA]
  adc   dx, [Root_LBA + 2]

  mov   [Data_LBA], ax
  mov   [Data_LBA + 2], dx
ret


;===========================================================================
; SearchFile
; --------------------------------------------------------------------------
; Localiza o stage2 na FAT
;===========================================================================

SearchFile:
  push  bx
  push  si
  push  di

  ; Carrega root dir
  mov   ax, [Root_LBA]
  mov   dx, [Root_LBA + 2]
  mov   cx, [Root_Size]
  mov   di, LOWMEM_START

  call  ReadLBA

  mov   dx, [BPB.RootEntries]
  mov   bx, LOWMEM_START

.loop:
  mov   di, bx
  mov   cx, FILENAME_SIZE
  mov   si, FileName

  repz  cmpsb
  je    .FoundedFile

  add   bx, DIRENTRY_SIZE
  dec   dx
  jnz   .loop

  jmp   .ExitError

.FoundedFile:
  ; Verifica tipo do arquivo
  lea   si, [bx + 11]
  mov   al, [si]
  and   al, 0x18        ; Diretorio e volumeid
  jnz   .ExitError

  ; Pega o primeiro cruster do arquivo
  lea   si, [bx + 26]
  mov   ax, [si]
  mov   [BootFile_Cluster], ax

  ; Pega o tamanho em bytes
  lea   si, [bx + 28]
  mov   ax, [si]
  mov   dx, [si + 2]

  mov   [BootFile_Size], ax
  mov   [BootFile_Size + 2], dx

  pop   di
  pop   si
  pop   bx
ret

.ExitError:
  pop   di
  pop   si
  pop   bx
jmp   Error


;===========================================================================
; LoadFile
; --------------------------------------------------------------------------
; Carrega o stage2 para a memoria
;===========================================================================

LoadFile:
  push  di
  push  bx
  push  es

  ; Carrega a FAT
  mov   ax, [FAT_LBA]
  mov   dx, [FAT_LBA + 2]
  mov   cx, [BPB.SectorsPerFAT]
  mov   di, LOWMEM_START

  call  ReadLBA

  ; Le a flag de EOC
  mov   ax, 1
  call  ReadFatEntry
  mov   [Flag_EOC], ax

  ; Calcula quantos setores deve carregar
  mov   ax, [BootFile_Size]
  mov   dx, [BootFile_Size + 2]

  mov   bx, [BPB.BytesPerSector]
  div   bx

  or    dx, dx
  jz    .0

  inc   ax

.0:
  ; Calcula se cabe na memória
  push  ax

  mov   cl, 5
  shl   ax, cl

  mov   cx, (STAGE2_BASE / 0x10)
  mov   es, cx

  add   ax, cx
  jc    .errorSize

  cmp   ax, [LowMemSizePh]
  jbe   .1

.errorSize:
  pop   ax                    ; descarta pilha

  mov   ax, ErrorSize
  call  WriteAnsiStr

  call  Reboot

.1:
  pop   cx                    ; Num setores. Valor que estava em ax.
  mov   di, (STAGE2_BASE % 0x10)
  mov   ax, [BootFile_Cluster]

.loop:
  cmp   ax, 0x2
  jbe   Error

  cmp   ax, 0xFF0
  ja    Error

  push  cx
  push  ax

  ; Calcula posicao na area de dados
  sub   ax, 2

  xor   cx, cx
  mov   cl, [BPB.SectorsPerCluster]
  mul   cx

  ; Calcula posicao absoluta
  add   ax, [Data_LBA]
  adc   dx, [Data_LBA + 2]

  call  ReadLBA

  pop   ax

  call  ReadFatEntry

  pop   cx
  loop  .loop

  xor    ax, [Flag_EOC]
  jnz    Error

  mov   ax, LoadMsg
  call  WriteAnsiStr

  mov   ax, NewLine
  call  WriteAnsiStr

.exit:
  pop   es
  pop   bx
  pop   di
ret


;===========================================================================
; ReadFatEntry
; --------------------------------------------------------------------------
; Le a entrada N da FAT
;===========================================================================

ReadFatEntry:
  push  bx

  xor   dx, dx
  mov   cx, ax

  shr   ax, 1
  mov   bx, 3
  mul   bx

  add   ax, LOWMEM_START
  mov   bx, ax

  mov   ax, [bx]
  mov   dx, [bx + 2]

  and   cx, 1
  jz    .0

  and   dx, 0x00FF
  mov   bx, 0x1000
  div   bx

.0:
  and   ax, 0xFFF

  pop   bx
ret



;===========================================================================
; Int12$
; --------------------------------------------------------------------------
; Salva registradores e chama a rotina de memoria da BIOS.
;===========================================================================

Int12$:
  ; registradores que podem ser alterados durante a chamada
  push ds
  push es
  push si
  push di
  push bp

  int 0x12

  pop bp
  pop di
  pop si
  pop es
  pop ds
ret



;===========================================================================
;
; ############################ Procedimentos 32 bits ############################
;
;===========================================================================

[CPU 386]


;===========================================================================
; ConfigPM
; --------------------------------------------------------------------------
; Configura a tabelas do PM
;===========================================================================

ConfigPM:
  ; Configura gdt_desc
  mov   eax, gdt
  mov   [gdt_desc + 2], eax

  ; Configura idt_desc
  mov   eax, idt
  mov   [idt_desc + 2], eax
ret


;===========================================================================
; GoStage2
; --------------------------------------------------------------------------
; Configura o PM e salta para o stage2
;===========================================================================

GoStage2:
  ; Desabilita ints
  cli

  ; Desabilita NMIs
  in    al, 0x70
  or    al, 0x80
  out   0x70, al
  in    al, 0x71

  ; Carrega configuracoes
  lgdt  [gdt_desc]
  lidt  [idt_desc]

  ; ativa o modo protegido
  mov   eax, cr0
  or    eax, 1
  mov   cr0, eax

  ; configura nova pilha
  xor   eax, eax

  mov   ax, DSEG
  mov   ss, ax                ; atualiza o segmento da pilha

  mov   ax, [LowMemSizePh]
  shl   eax, 4
  sub   eax, 4

  mov   esp, eax              ; atualiza ponteiro do topo da pilha
  mov   ebp, eax              ; atualiza ponteiro da base da pilha

  xor   eax, eax
  mov   [ebp], eax            ; grava elemento nulo no comeco da pilha

  ; Configura DS e ES
  mov   ax, DSEG
  mov   ds, ax
  mov   es, ax

  ; coloca endereco do salto na pilha
  mov   ax, CSEG
  push  ax

  mov   eax, STAGE2_BASE
  push  eax

  mov   eax, esp              ; poe o ponteiro para o salto em EAX
  mov   esp, ebp              ; limpa o ponteiro da pilha (mantem valores la...)

  ; salta para o stage2 (atualiza CS e Entry)
  jmp   dword far [eax]
; Fim da rotina, impossivel retornar a esse ponto...
hlt



;===========================================================================
;
; ############################ BSS ############################
;
;===========================================================================

; Evita que a BSS seja sobreescrita pela carga do EBS
times (0x200 * STAGE1_SECTORS) - ($ - $$) db 0

SECTION .bss
; ### Variaveis criadas pelo bootloader ###
  CurrentCylinder     resw 1
  CurrentSector       resb 1

  LowMemSizePh        resw 1

  EBDA_Seg            resw 1

  FAT_LBA             resd 1
  Root_LBA            resd 1
  Data_LBA            resd 1

  Root_Size           resw 1

  BootFile_Cluster    resw 1
  BootFile_Size       resd 1

  Flag_EOC            resw 1
