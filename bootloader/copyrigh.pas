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
  Unit CopyRigh.pas
  --------------------------------------------------------------------------
    Esta Unit e responsavel por mostrar o aviso interativo de NAO GARANTIA
  e o Copyright.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 20/03/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc copyrigh.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit CopyRigh;

interface

procedure ShowWarning;
procedure Finish;

implementation

uses CRT;

procedure ShowWarning;
var
  Key : Char;
  Continue : Boolean;

begin
  ClrScr;

  {Digitando um smiley ":)" apos o nome do arquivo evita que a mensagem seja mostrada}
  if (ParamCount > 0) and (ParamStr(1) = ':)') then Exit;

  Writeln;
  Writeln('**************************** AVISO IMPORTANTE ****************************');
  Writeln;
  Writeln('Este programa eh software livre; voce pode redistribui-lo e/ou modifica-lo ');
  Writeln('sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free ');
  Writeln('Software Foundation; na versao 2 da Licenca.');
  Writeln;
  Writeln('Este programa eh distribuido na expectativa de ser util, mas SEM QUALQUER ');
  Writeln('GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de ');
  Writeln('ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica ');
  Writeln('Geral GNU para obter mais detalhes.');
  Writeln;
  Writeln('Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com ');
  Writeln('este programa; se nao, escreva para a Free Software Foundation, Inc., 59 ');
  Writeln('Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do ');
  Writeln('GNU e obtenha sua licenca: http://www.gnu.org/');
  Writeln;
  Writeln;

  Write('Voce quer executar este programa por SUA CONTA E RISCO? (S/N): ');
  Key := ReadKey;
  Continue := (Key = 's') or (Key = 'S');

  ClrScr;

  if not Continue then
  begin
    Writeln('Programa abortado!');
    Writeln('Pressione "S" da proxima vez se quiser executa-lo.');
    Finish;
  end;
end;

procedure Finish; {ShowCopyRight}
var
  Key : Char;

begin
  Writeln;
  Write('Pressione qualquer tecla para continuar... ');
  Key := ReadKey;

  ClrScr;
  Writeln('---------------------------------------------');
  Writeln('*********** Projeto LuckyOS (LOS) ***********');
  Writeln('---------------------------------------------');
  Writeln(' Copyright (C) 2013 - Luciano L. Goncalez');
  Writeln('---------------------------------------------');
  Writeln(' a.k.a.: Master Lucky');
  Writeln(' eMail : master.lucky.br@gmail.com');
  Writeln(' Home  : http://lucky-labs.blogspot.com.br');
  Writeln('---------------------------------------------');
  Halt;
end;

end.
