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
  Programa DetecMem.pas
  --------------------------------------------------------------------------
    Este programa detecta a quantidade de memoria instalada.
  Mostrando os resultados.
  --------------------------------------------------------------------------
  Versao: 0.2.1
  Data: 12/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc /b detecmem.pas
  ------------------------------------------------------------------------
  Executar: Pode ser executado no DOS/Windows em Modo Real ou Protegido.
  > detecmem.exe

  * Se voce leu esse aviso acima, entao pode nao querer ficar respendo toda
  vez, para evitar isso basta acrescentar um ' :)' apos o nome, assim:
  > detecmem.exe :)
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0325-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial.
  ------------------------------------------------------------------------
  [2013-0325-0000] (v0.2) <Luciano Goncalez>

  - Melhorando a resposta da detecção, devolvendo dados trabalhados.
  ------------------------------------------------------------------------
  [2018-0112-2305] (v0.2.1) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

program DetecMem;

uses CopyRigh, MemInfo, Basic;

var
  I : Byte;

begin
  ShowWarning;
  Writeln;
  Writeln('Detectando Memoria...');
  Writeln;

  DetectMem; {Chama o procedimento para detectar a memoria}

  for I := 0 to (GetBlocksCount - 1) do
  begin
    Writeln('Bloco de memoria ', I, ':');
    Writeln(' - Base    : 0x', DWordToHex(GetMemoryBase(I), 8, 4));
    Writeln(' - Limite  : 0x', DWordToHex(GetMemoryLimit(I), 8, 4));
    Writeln(' - Tamanho : ', GetMemorySize(I), ' KB');
    Writeln;
  end;

  Finish;
end.
