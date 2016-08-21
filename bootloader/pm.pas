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
  Unit PM.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos para controle do modo protegido.
  --------------------------------------------------------------------------
  Versao: 0.2
  Data: 14/04/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc pm.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit PM; {Protected Mode}

interface

uses Basic;

type
  TDescrSeg = packed record
    Limit   : Word; {2}
    BaseL   : Word; {2}
    BaseM   : Byte; {1}
    Access  : Byte; {1}
    Attribs : Byte; {1}
    BaseH   : Byte; {1}
  end;  {total = 8 bytes}

  TGdtR = packed record
    Limit : Word;
    Base  : DWord;
  end;

{SegDesc: pg124

  Word:
    Seg Limit 0-15

  Word:
    Base Addr 0-15

  Byte:
    Base Addr 16-23

  Byte:
    4 bits  = Type
    1 bit   = S
    2 bits  = DPL
    1 bit   = P

  Byte:
    4 bits  = Seg Limit 16-19
    1 bit   = AVL
    1 bit   = *
    1 bit   = D/B
    1 bit   = G

  Byte:
    Base Addr 24-31

  *******

  Segment Limit (20 bits) - Indica o limite do segmento
  Base Address (32 bits) - Indica a base do segmento
  DPL - Descriptor Privilege-Level (2 bits) - Indica o nivel de protecao 0-3
  P - Present (1 bits) - Indica que o segmento referente esta na memoria (Memoria virtual?)
  AVL - Available To Software (1 bit) - Disponivel para software
  G - Granularity (1 bit) - Indica quando o Limite esta expresso em bytes(0) ou em pagina(1) de 4 KB
}

const
  {*** Flags de acesso ***}
  F_ACS_PRESENT = $80; {1000.0000}

  F_ACS_DPL0    = $00; {-}
  F_ACS_DPL1    = $20; {0010.0000}
  F_ACS_DPL2    = $40; {0100.0000}
  F_ACS_DPL3    = $60; {0110.0000}

  F_ACS_SYSTEM  = $00; {-}
  F_ACS_USER    = $10; {0001.0000}

  {-User Segments}
  F_ACS_CODE    = $08; {0000.1000}
  F_ACS_DATA    = $00; {-}

  {--Code Segments}
  F_ACS_CONFORM = $04; {0000.0100}
  F_ACS_READABL = $02; {0000.0010}

  {--Data Segments}
  F_ACS_EXPDOWN = $04; {0000.0100}
  F_ACS_WRITABL = $02; {0000.0010}

  {---Code/Data Segments}
  F_ACS_ACCESS  = $01; {0000.0001}

  {Segments}
  ACS_CSEG      = F_ACS_USER + F_ACS_CODE; { $10 + $08 = $18 }
  ACS_DSEG      = F_ACS_USER + F_ACS_DATA; { $10 + $00 = $10 }

  {Ready-made}
  ACS_CODE      = F_ACS_PRESENT + ACS_CSEG + F_ACS_READABL;
  ACS_DATA      = F_ACS_PRESENT + ACS_DSEG + F_ACS_WRITABL;
  ACS_STACK     = F_ACS_PRESENT + ACS_DSEG + F_ACS_WRITABL;

  {*** Flags de atributo ***}
  F_ATR_GRANUL  = $80; {1000.0000}
  F_ATR_OPSIZE  = $40; {0100.0000}
  F_ATR_AVLSOFT = $10; {0001.0000}

  {Ready-made}
  ATR_REALM     = 0;
  ATR_FLAT32    = F_ATR_GRANUL + F_ATR_OPSIZE;


  procedure LoadGDT(GDTR : Pointer);

  procedure SetupGDT(var Item : TDescrSeg; Base, Limit : DWord;
                      Access, Attribs : Byte);


implementation

{$L PM.OBJ}

{==========================================================================}
  procedure LoadGDT(GDTR : Pointer); external; {far}
{ --------------------------------------------------------------------------
  Carrega a GDT
===========================================================================}

{Configura o descritor especificado}
procedure SetupGDT(var Item : TDescrSeg; Base, Limit : DWord;
                      Access, Attribs : Byte);
begin
  Item.BaseL   := LoWord(Base);
  Item.BaseM   := HiWord(Base) mod $100;
  Item.BaseH   := HiWord(Base) div $100;
  Item.Limit   := LoWord(Limit);
  Item.Attribs := (Attribs and $F0) or (HiWord(Limit) and $000F);
  Item.Access  := Access;
end;

end.
