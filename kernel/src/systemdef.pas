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
  Unit SystemDef.pas
  --------------------------------------------------------------------------
  Unit de definicoes gerais do Sistema.
  --------------------------------------------------------------------------
  Versao: 0.2
  Data: 21/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc systemdef.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit SystemDef;

interface

uses DebugInfo;


type
  // Modos de abertura de arquivos
  TFileModes = (fmRead, fmWrite);
  TFileMode = set of TFileModes;

  // Modos de desligamento
  TShutDownModes = (sdHalt, sdReboot, sdForce);
  TShutDownMode = set of TShutDownModes;

  // Registro usado por SysAbort
  PAbortRec = ^TAbortRec;
  TAbortRec = record
    Source : TDebugSource;
    Basic : TDebugBas;
    Stack : TDebugStack;
    StackLevels : LongWord;
  end;


implementation

end.
