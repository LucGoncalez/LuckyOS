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
  Programa DetecCPU.pas
  --------------------------------------------------------------------------
    Este programa detecta o tipo basico da CPU, e se ela esta rodando no
  modo real ou protegido. Mostrando os resultados.
  --------------------------------------------------------------------------
  Versao: 0.1.1
  Data: 12/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc /b deteccpu.pas
  ------------------------------------------------------------------------
  Executar: Pode ser executado no DOS/Windows em Modo Real ou Protegido.
  > deteccpu.exe

  * Se voce leu esse aviso acima, entao pode nao querer ficar respendo toda
  vez, para evitar isso basta acrescentar um ' :)' apos o nome, assim:
  > deteccpu.exe :)
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0322-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial.
  - Programa de teste.
  ------------------------------------------------------------------------
  [2018-0112-2301] (v0.1.1) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

program DetecCPU;

uses CopyRigh, CPUInfo;

begin
  ShowWarning;
  Writeln;
  Writeln('Detectando CPU...');
  Writeln;

  DetectCPU; {Chama o procedimento para detectar a CPU}

  case GetCPUType of
    CT8086  : Writeln('CPU 8086 detectado!');
    CT80186 : Writeln('CPU 80186 detectado!');
    CT80286 : Writeln('CPU 80286 detectado!');
    CT80386 : Writeln('CPU 80386 detectado!');
    CT80486 : Writeln('CPU 80486 detectado!');
    CT80586 : Writeln('CPU 80586 detectado!');
  else
    Writeln('CPU Desconhecido...');
  end;

  Writeln;

  Writeln('Caracteristicas:');


  if GetCPU_IA32 then
    Writeln(' - Arquitetura IA32');

  if GetCPU_ID then
    Writeln(' - CPUID diponivel');

  if GetCPU_PM then
  begin
    Writeln(' - Suporta o "Modo Protegido"');
    Write(' - Modo atual: ');

    if GetCPU_PE then
      Writeln('"Modo Protegido"')
    else
      Writeln('"Modo Real"');
  end;

  Writeln;

  Finish;
end.
