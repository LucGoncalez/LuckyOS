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
  Unit TTYsDef.pas
  --------------------------------------------------------------------------
  Unit Definicoes de terminais.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 03/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc ttysdef.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit TTYsDef;

interface

type
  TttyTypes = (ttFile, ttInput, ttOutput);
  TttyType = set of TttyTypes;

  TttyCurrType = (ctHidden, ctUnder, ctFull);


const
  cColors = $20; // indica a quantidade de cores, conta o blink

  // Cores do video
  Black         = $00;
  Blue          = $01;
  Green         = $02;
  Cyan          = $03;
  Red           = $04;
  Magenta       = $05;
  Brown         = $06;
  LightGray     = $07;
  DarkGray      = $08;
  LightBlue     = $09;
  LightGreen    = $0A;
  LightCyan     = $0B;
  LightRed      = $0C;
  LightMagenta  = $0D;
  Yellow        = $0E;
  White         = $0F;

  HighColor     = $08;
  Blink         = $10;

  // Constantes de caracteres de controle ASCII
  NUL = #00; // ^@ Null
  SOH = #01; // ^A Start of Heading
  STX = #02; // ^B Start of Text
  ETX = #03; // ^C End of Text
  EOT = #04; // ^D End of Transmission
  ENQ = #05; // ^E Enquiry
  ACK = #06; // ^F Acknowledge
  BEL = #07; // ^G Bell
  BS  = #08; // ^H BackSpace
  HT  = #09; // ^I Horizontal tab
  TAB = #09; // ^I Alias para HT
  LF  = #10; // ^J Line Feed, new line
  VT  = #11; // ^K Vertical Tab
  FF  = #12; // ^L Form Feed, new page
  CR  = #13; // ^M Carriage Return
  SO  = #14; // ^N Shift Out
  SI  = #15; // ^O Shift In
  DLE = #16; // ^P Data Link Escape : ORAW
  DC1 = #17; // ^Q Device Control 1 : XON
  DC2 = #18; // ^R Device Control 2 : IRAW
  DC3 = #19; // ^S Device Control 3 : XOFF
  DC4 = #20; // ^T Device Control 4 : IPROC
  NAK = #21; // ^U Negative Acknowledge
  SYN = #22; // ^V Sinchronous Idle
  ETB = #23; // ^W End of Tranference Block
  CAN = #24; // ^X Cancel
  EM  = #25; // ^Y End of Medium
  SUB = #26; // ^Z Substitute
  ESC = #27; // ^[ Escape
  FS  = #28; // ^\ File Separator
  GS  = #29; // ^] Group Separator
  RS  = #30; // ^^ Record Separator
  US  = #31; // ^_ Unit Separator
  DEL = #127; // ^? Delete

  SP    = #32; // Espaco
  NBSP  = #255; // Espaco nao separavel


  // Consoles padrão Unix-like
  StdTTYs = 3;

  StdIn   = 0;
  StdOut  = 1;
  StdErr  = 2;

  // Comandos
  cCmdReset = 'RESET';
  cCmdInfo = 'INFO';
  cCmdClrEol = 'CLREOL';

  { Sem suporte no terminal ainda
  cCmdDelLine = 'DELLINE';
  cCmdInsLine = 'INSLINE';
  }

  // Padraos
  cNormBackground = Black;
  cNormTextColor = LightGray;


  (*
    Protocolo de terminal:
    * o protocolo tem que ser logico, independente do hardware

    Um terminal pode ser de entrada e/ou saida.

    Quando se escreve para um terminal, normalmente isto eh feito para a saida,
    exceto quando o terminal eh somente de entrada.

    Quando se le de um terminal, normalmente isto eh feito da entrada, exceto
    quando o terminal eh somente de saida.

    Para enviar um comando para a entrada, em um terminal duplo, envia-se
    uma sequencia de escape com o comando, que eh automaticamente interpretado
    e executado.

    Quando um comando, que espera resposta, eh enviado para a saida, automaticamente
    a entrada eh comultada para fornecer essa resposta, retornando ao normal
    em seguida.

    Ambos os terminais possuem dois modos:
    - bruto (raw);
    - processado (input line-mode).

    O modo raw eh normalmente desabilitado com o caracter nulo (#0).

    Para a saida:

      NUL => Comulta o terminal para o modo interpretado
      DLE => Comulta o terminal para o modo raw

    Para habilitar/desabilitar o modo raw da entrada atraves do software e enviado
    uma sequencia de comando.

      DC2 => Modo Raw
      DC4 => Modo processado

    Quando a entrada estiver em modo raw, nenhuma tecla eh interpretada, exceto
    <ESC> que desativa o modo raw do terminal e envia um #0 para o software
    indicando a desativacao.

    Sequencias de escape:

      ESC + '[' + ... + ']' => Sequencia de comando enviada ao terminal
      ESC + '{' + ... + '}' => Sequencia de resposta de um comando previo
      ESC + '(' + ... + ')' => Sequencia de controle enviada da entrada

    Comandos:

      ESC + '[...?]' => GetStatus
      ESC + '[...]' => SetStatus

    * A = // Attrib - atributo especial (blink, negrito, italico... se existir)
    * B = Background - cor de fundo
    * C = Cols - numero de colunas
    * D = Display - cursor type
    * F = Foreground - cor de frente
    * H = horizontal tab
    * M = Mode - modo do terminal (M:i0,o1;)
    * T = Terminal type (T:io;)
    * V = vertical tab
    * R = Rows - numero de linhas
    * X = X - cordenada do cursor, coluna
    * Y = Y - cordenada do cursor, linha
  *)


implementation

end.
