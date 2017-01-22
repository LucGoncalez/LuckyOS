{===========================================================================
  Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
  --------------------------------------------------------------------------
  Copyright (C) 2013 - Luciano L. Goncalez
  --------------------------------------------------------------------------
  a.k.a.: Master Lucky
  eMail : master.lucky.br@gmail.com
  Home  : http://lucky-labs.blogspot.com.br
============================================================================
  Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
  sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
  Software Foundation; na versao 2 da Licenca.

  Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
  GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
  ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
  Geral GNU para obter mais detalhes.

  Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
  este programa; se nao, escreva para a Free Software Foundation, Inc., 59
  Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
  GNU e obtenha sua licenca: http://www.gnu.org/
============================================================================
  Unit DebugInfo.pas
  --------------------------------------------------------------------------
  Unit com procedimentos de Depuracao.
  --------------------------------------------------------------------------
  Versao: 0.2.1
  Data: 25/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc debuginfo.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit DebugInfo;

interface

uses ErrorsDef;


{ Registradores
  Geral:    32bits  = eax, ebx, ecx, edx
  Segmento: 16bits  = cs, ds, es, ss, fs, gs
  Indice:   32bits  = esi, edi
  Ponteiro: 32bits  = eip, esp, ebp
  Flags:    32bits  = eflags
  Controle: 32bits  = cr0, cr2, cr3, cr4,
  Debug:    32bits  = dr0, dr1, dr2, dr3, dr6, dr7
  FPU:      80bits  = st0, st1, st2, st3, st4, st5, st6, st7
  MMX:      64bits  = mm0, mm1, mm2, mm3, mm4, mm5, mm6, mm7
  SSE:      128bits = xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
}


type
  PDebugSource = ^TDebugSource;
  TDebugSource = record
    UnitID : TUnitID;
    FuncID : TFuncID;
    FileName : PChar;
    LineNo : UInt;
  end;

  PDebugBas = ^TDebugBas;
  TDebugBas = record
    EAX, EBX, ECX, EDX : LongWord;
    CS, DS, ES, SS, FS, GS : Word;
    ESI, EDI : LongWord;
    EFlags : LongWord;
  end;

  PDebugStack = ^TDebugStack;
  TDebugStack = record
    EIP, ESP, EBP : Pointer;
  end;

{$IFDEF KERNEL}
  PDebugEx = ^TDebugEx;
  TDebugEx = record
    CR0, CR2, CR3, CR4 : LongWord;
  end;
{$ENDIF}


  // Obtem registradores gerais
  function GetEAX : LongWord;
  function GetEBX : LongWord;
  function GetECX : LongWord;
  function GetEDX : LongWord;

  // Obtem registradores de segmentos
  function GetCS : Word;
  function GetDS : Word;
  function GetES : Word;
  function GetSS : Word;
  function GetFS : Word;
  function GetGS : Word;

  // Obtem registradores de indices
  function GetESI : LongWord;
  function GetEDI : LongWord;

  // Obtem registradores de ponteiros
  function GetEIP : Pointer;
  function GetESP : Pointer;
  function GetEBP : Pointer;

  // Obtem eflags
  function GetEFlags : LongWord;

{$IFDEF KERNEL}
  // Obtem registradores de controle
  function GetCR0 : LongWord;
  function GetCR2 : LongWord;
  function GetCR3 : LongWord;
  function GetCR4 : LongWord;
{$ENDIF}

  // Obtem informaçoes sobre a pilha
  function GetSFramesLevels(EBP : Pointer) : LongWord;
  function GetSFrame(EBP : Pointer; SkipFrames : LongWord) : Pointer;
  function GetSFrameReturn(EBP : Pointer) : Pointer;

  // Imprime a pilha de chamada
  procedure PrintStackCalls(Frame : Pointer; FrameIni, Count : LongWord; Cols, Rows : Byte);

  // Converte EFlags para String e IOPL
  function EFlagsToString(EFlags : LongWord; Reserveds : Boolean) : ShortString;
  function EFlagsToIOPL(EFlags : LongWord) : Byte;

  // Obtem diversas informacoes
  function GetDebugInfo : TDebugBas;
  function GetDebugStack(SkipFrames, OffsetESP : LongWord) : TDebugStack;

  {$IFDEF KERNEL}
    function GetDebugEx : TDebugEx;
  {$ENDIF}


implementation

uses SysUtils, ConsoleIO, TTYsDef;


const
  cEFlagsString : array[0..31] of PChar =
  (
    {00-07} 'CF', 'R1', 'PF', 'R3', 'AF', 'R5', 'ZF', 'SF',
    {08-15} 'TF', 'IF', 'DF', 'OF', 'IOPL1', 'IOPL2', 'NT', 'R15',
    {16-23} 'RF', 'VM', 'AC', 'VIF', 'VIP', 'ID', 'R22', 'R23',
    {24-31} 'R24', 'R25', 'R26', 'R27', 'R28', 'R29', 'R30', 'R31'
  );

  cEFlagsReserveds = %11111111110000001000000000101010;
  cEFlagsIOPL = $3000;
  cIOPLShift = 12;


{ Retorna o valor do registrador EAX }
function GetEAX : LongWord; assembler; nostackframe;
asm
  ret
end;

{ Retorna o valor do registrador EBX }
function GetEBX : LongWord; assembler; nostackframe;
asm
  mov eax, ebx
end;

{ Retorna o valor do registrador ECX }
function GetECX : LongWord; assembler; nostackframe;
asm
  mov eax, ecx
end;

{ Retorna o valor do registrador EDX }
function GetEDX : LongWord; assembler; nostackframe;
asm
  mov eax, edx
end;


{ Retorna o valor do registrador CS }
function GetCS : Word; assembler; nostackframe;
asm
  mov ax, cs
end;

{ Retorna o valor do registrador DS }
function GetDS : Word; assembler; nostackframe;
asm
  mov ax, ds
end;

{ Retorna o valor do registrador ES }
function GetES : Word; assembler; nostackframe;
asm
  mov ax, es
end;

{ Retorna o valor do registrador SS }
function GetSS : Word; assembler; nostackframe;
asm
  mov ax, ss
end;


{ Retorna o valor do registrador FS }
function GetFS : Word; assembler; nostackframe;
asm
  mov ax, fs
end;

{ Retorna o valor do registrador GS }
function GetGS : Word; assembler; nostackframe;
asm
  mov ax, gs
end;


{ Retorna o valor do registrador ESI }
function GetESI : LongWord; assembler; nostackframe;
asm
  mov eax, esi
end;

{ Retorna o valor do registrador EDI }
function GetEDI : LongWord; assembler; nostackframe;
asm
  mov eax, edi
end;


{ Retorna o valor do registrador EIP }
function GetEIP : Pointer;
var
  EBPReg : ^Pointer;

begin
  asm
    mov [EBPReg], ebp
  end;

  Inc(EBPReg); // EIP esta um posição acima

  GetEIP := EBPReg^;
end;

{ Retorna o valor do registrador ESP }
function GetESP : Pointer; assembler; nostackframe;
asm
  mov eax, esp
  add eax, 4    // ESP antes da chamada estava 4 bytes acima
end;

{ Retorna o valor do registrador EBP }
function GetEBP : Pointer; assembler; nostackframe;
asm
  mov eax, ebp
end;


{ Retorna o valor de EFLAGS }
function GetEFlags : LongWord; assembler; nostackframe;
asm
  pushf
  pop eax
end;


{$IFDEF KERNEL}
  { Retorna o valor do registrador CR0 }
  function GetCR0 : LongWord; assembler; nostackframe;
  asm
    mov eax, cr0
  end;

  { Retorna o valor do registrador CR2 }
  function GetCR2 : LongWord; assembler; nostackframe;
  asm
    mov eax, cr2
  end;

  { Retorna o valor do registrador CR3 }
  function GetCR3 : LongWord; assembler; nostackframe;
  asm
    mov eax, cr3
  end;

  { Retorna o valor do registrador CR4 }
  function GetCR4 : LongWord; assembler; nostackframe;
  asm
    mov eax, cr4
  end;
{$ENDIF}


{ Retorna quanto niveis de Frames a pilha possui }
function GetSFramesLevels(EBP : Pointer) : LongWord;
var
  I : LongWord;
  CFrame, PFrame : ^Pointer;

begin
  if (EBP = nil) then
    I := 0 // Nao ha nenhum nivel valido
  else
  begin
    I := 1; // Conta o nivel atual
    CFrame := EBP;
    PFrame := CFrame^;

    while (PFrame > CFrame) do
    begin
      Inc(I);
      CFrame := PFrame;
      PFrame := CFrame^;
    end;
  end;

  GetSFramesLevels := I;
end;

{ Retorna o ponteiro (EBP) para um Frame especifico, subindo SkipFrames
  (0 - retorna o proprio ponteiro) }
function GetSFrame(EBP : Pointer; SkipFrames : LongWord) : Pointer;
var
  Frame : ^Pointer;

begin
  Frame := EBP;

  while (SkipFrames > 0) do
    if (Frame = nil) then
      // Nao existe Frame anterior
      SkipFrames := 0
    else
    begin
      Frame := Frame^; // Sobe um Frame
      Dec(SkipFrames);
    end;

  GetSFrame := Frame;
end;

{ Retorna o ponteiro de retorno (EIP) do Frame dado }
function GetSFrameReturn(EBP : Pointer) : Pointer;
var
  Frame : ^Pointer;

begin
  Frame := EBP;

  if (Frame = nil) or (Frame^ = nil) then
    // Esta no primeiro Frame, não existe retorno
    GetSFrameReturn := nil
  else
  begin
    Inc(Frame); // EIP esta uma posicao acima (+4B)
    GetSFrameReturn := Frame^;
  end;
end;


{ Imprime uma tabela contendo a pilha de chamada
    Frame - é o Frame usado como referencia
    FrameIni - é o primeiro Frame a ser impresso (0 é o primeiro)
    Count - indica quantos Frames devem ser impressos (0 indica todos)
    Cols - indica em quantas colunas deve ser impresso (0 - tudo na mesma linha)
    Rows - indica a divisao por linhas (somente valido se Cols > 1)
}
procedure PrintStackCalls(Frame : Pointer; FrameIni, Count : LongWord; Cols, Rows : Byte);
  procedure PrintFrameInfo(LevelNo, Levels : LongWord; Align : Byte);
    var
      CFrame : Pointer;
      vLevel : ShortString;

  begin
    CFrame := GetSFrame(Frame, (Levels - 1) - LevelNo);
    vLevel := IntToStr(LevelNo);

    while (Length(vLevel) < Align) do
      vLevel := ' ' + vLevel;

    CWrite(vLevel);
    CWrite(' : ');
    CWrite(CFrame);
    CWrite(' >> ');
    CWrite(GetSFrameReturn(CFrame));
  end;

var
  I, vLevels, vLevelNo : LongWord;
  vLine, C : Word;
  vAlign : Byte;

begin
  vLevels := GetSFramesLevels(Frame);

  if (Count <> 0) and ((FrameIni + Count) < vLevels) then
    vLevels := (FrameIni + Count);

  vLevelNo := FrameIni;

  vAlign := Length(IntToStr(vLevels));

  if (Cols <> 0) then
  begin
    // Divide em colunas
    if (Rows <> 0) then
    begin
      // Preenche bloco por bloco
      vLine := 0;

      while (vLevelNo < vLevels) do
      begin
        for C := 1 to Cols do
        begin
          I := vLevelNo + ((C - 1) * Rows);

          if (I < vLevels) then
          begin
            if (C > 1) then
            begin
              CWrite(HT);
              CWrite('| ');
            end;

            PrintFrameInfo(I, vLevels, vAlign);
          end;
        end;

        if (Cols = 1) then
        begin
          // Nao divide em blocos
          CWriteln;
          Inc(vLevelNo);
        end
        else {Cols > 1}
        begin
          Inc(vLine);

          if (vLine < Rows) then
          begin
            // Dentro do bloco
            CWriteln;
            Inc(vLevelNo);
          end
          else
          begin
            // Mudando de bloco
            vLine := 0;
            vLevelNo := vLevelNo + ((Cols - 1) * Rows) + 1;

            if (vLevelNo < vLevels) then
              // Bloco intermediario
              CLineFeed(2)
            else
              // Bloco final
              CWriteln;
          end;
        end;
      end;
    end
    else {Rows = 0}
      // Preenche linha por linha
      while (vLevelNo < vLevels) do
      begin
        for C := 1 to Cols do
        begin
          I := vLevelNo + (C - 1);

          if (I < vLevels) then
          begin
            if (C > 1) then
            begin
              CWrite(HT);
              CWrite('| ');
            end;

            PrintFrameInfo(I, vLevels, vAlign);
          end;
        end;

        CWriteln;
        vLevelNo := vLevelNo + Cols;
      end;
  end
  else {Cols = 0}
    // Escreve um valor na frente do outro sem colunas
    while (vLevelNo < vLevels) do
    begin
      if (vLevelNo <> FrameIni) then
        CWrite(' | ');

      PrintFrameInfo(vLevelNo, vLevels, vAlign);

      Inc(vLevelNo);
    end;
end;


function EFlagsToString(EFlags : LongWord; Reserveds : Boolean) : ShortString;
var
  I : Byte;
  vTemp : ShortString;

begin
  if not Reserveds then
    EFlags := EFlags and not (cEFlagsReserveds or cEFlagsIOPL);

  vTemp := '';

  for I := 0 to 31 do
  begin
    if ((EFlags and $1) = $1) then
      if (vTemp = '') then
        vTemp := cEFlagsString[I]
      else
        vTemp := cEFlagsString[I] + ' ' + vTemp;

    EFlags := EFlags shr 1;
  end;

  EFlagsToString := vTemp;
end;

function EFlagsToIOPL(EFlags : LongWord) : Byte;
begin
  EFlagsToIOPL := (EFlags and cEFlagsIOPL) shr cIOPLShift;
end;


{ Pega informacoes basicas de depuracao }
function GetDebugInfo : TDebugBas;
var
  RegEAX, RegEBX, RegECX, RegEDX : LongWord;
  RegCS, RegDS, RegES, RegSS, RegFS, RegGS : Word;
  RegESI, RegEDI : LongWord;
  RegEFlags : LongWord;

begin
  // Busca valores diretamente para otimizar
  asm
    mov [RegEAX], eax
    mov [RegEBX], ebx
    mov [RegECX], ecx
    mov [RegEDX], edx

    mov [RegCS], cs
    mov [RegDS], ds
    mov [RegES], es
    mov [RegSS], ss
    mov [RegFS], fs
    mov [RegGS], gs

    mov [RegESI], esi
    mov [RegEDI], edi

    push eax

    pushf
    pop eax

    mov [RegEFlags], eax

    pop eax
  end;

  GetDebugInfo.EAX := RegEAX;
  GetDebugInfo.EBX := RegEBX;
  GetDebugInfo.ECX := RegECX;
  GetDebugInfo.EDX := RegEDX;


  GetDebugInfo.CS := RegCS;
  GetDebugInfo.DS := RegDS;
  GetDebugInfo.ES := RegES;
  GetDebugInfo.SS := RegSS;
  GetDebugInfo.FS := RegFS;
  GetDebugInfo.GS := RegGS;

  GetDebugInfo.ESI := RegESI;
  GetDebugInfo.EDI := RegEDI;

  GetDebugInfo.EFlags := RegEFlags;
end;

{ Pega informacoes de depuracao da pilha
  SkipFrames - indica qual frame deve ser pesquisado, 0 = atual
  OffsetESP - indica quantos bytes deve ser deslocado esp (lista de parametros
    da funcao em questao), nao valido para o frame atual}
function GetDebugStack(SkipFrames, OffsetESP : LongWord) : TDebugStack;
var
  EBPRef : Pointer;

begin
  if (SkipFrames = 0) then
    // Pega os valores atuais
    OffsetESP := 20
    {+8 eh a posicao minima de esp antes, +12 pelos parametros (1 oculto?)}
  else
    OffsetESP := OffsetESP + 8;
    {+8 eh a posicao minima de esp antes}

  EBPRef := GetSFrame(GetEBP, SkipFrames);

  GetDebugStack.EIP := GetSFrameReturn(EBPRef);
  GetDebugStack.EBP := GetSFrame(EBPRef, 1);
  GetDebugStack.ESP := EBPRef + OffsetESP;
end;


{$IFDEF KERNEL}
function GetDebugEx : TDebugEx;
var
  RegCR0, RegCR2, RegCR3, RegCR4 : LongWord;

begin
  // Busca valores diretamente para otimizar
  asm
    push eax

    mov eax, cr0
    mov [RegCR0], eax

    mov eax, cr2
    mov [RegCR2], eax

    mov eax, cr3
    mov [RegCR3], eax

    mov eax, cr4
    mov [RegCR4], eax

    pop eax
  end;

  GetDebugEx.CR0 := RegCR0;
  GetDebugEx.CR2 := RegCR2;
  GetDebugEx.CR3 := RegCR3;
  GetDebugEx.CR4 := RegCR4;
end;
{$ENDIF}


end.
