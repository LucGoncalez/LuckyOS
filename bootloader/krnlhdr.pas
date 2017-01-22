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
  Unit KrnlHdr.pas
  --------------------------------------------------------------------------
  Esta Unit possui a estrutura do cabecalho do arquivo do kernel.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 18/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc krnlhdr.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit KrnlHdr;

interface

uses  Basic, LosHdr;

type
  { Metadados independente de arquitetura }
  PKrnlHdrArch = ^TKrnlHdrArch;
  TKrnlHdrArch = packed record
    ArchBase : Byte;
    ArchBits : Byte;
  end;

  { Metadados para Intel x86 de 32 bits v1.0}
  PKrnlHdr_x86_32 = ^TKrnlHdr_x86_32;
  TKrnlHdr_x86_32 = packed record
    {Metadados - qrquitetura}
    Arch : TKrnlHdrArch; {"herda" o tipo TKrnlImgArch }
    {Metadados - requisitos}
    CPUModel  : Byte; {Informa o modelo da CPUMin x86}
    CPUMode   : Byte; {Informa o modo de operacao x86}
    MemAlign  : Byte; {Bits 2^X}
    StackSize : DWord;
    HeapSize  : DWord;
    {Metadados - imagem}
    KernelStart : DWord; {Endereco de inicio da imagem em memoria}
    KernelEnd   : DWord; {Endereco de termino da imagem em memoria}
    EntryPoint  : DWord; {Endereco do procedimento principal}
    {Metadados - segmentos}
    Code  : DWord; {Inicio do segmento de codigo}
    Data  : DWord; {Inicio do segmento de dados}
    BSS   : DWord; {Inicio do segmento BSS}
  end;

const
  cKrnlHdrVersion : TTypeVersion = (Major : 1; Minor : 0);


implementation

end.
