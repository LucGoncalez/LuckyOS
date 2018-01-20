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
  Programa DetecCRT.pas
  --------------------------------------------------------------------------
    Este programa detecta o tipo do dipositivo de video usado pela BIOS. E
  informacoes adicionais. Mostrando os resultados.
  --------------------------------------------------------------------------
  Versao: 0.1.1
  Data: 12/01/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc /b deteccrt.pas
  ------------------------------------------------------------------------
  Executar: Pode ser executado no DOS/Windows em Modo Real ou Protegido.
  > deteccrt.exe

  * Se voce leu esse aviso acima, entao pode nao querer ficar respendo toda
  vez, para evitar isso basta acrescentar um ' :)' apos o nome, assim:
  > deteccpu.exe :)
============================================================================
  Historico de versões
  ------------------------------------------------------------------------
  [2013-0324-0000] (v0.1) <Luciano Goncalez>

  - Implementação inicial - Programa de teste.
  ------------------------------------------------------------------------
  [2018-0112-2302] (v0.1.1) <Luciano Goncalez>

  - Adicionando historico ao arquivo.
  - Substituindo identação para espaços.
===========================================================================}

program DetecCRT;

uses CopyRigh, Basic, CRTInfo;

begin
  ShowWarning;
  Writeln;
  Writeln('Detectando CRT...');
  Writeln;

  DetectCRT; {Chama o procedimento para detectar a CRT}

  if GetCRT_Error then
    Writeln('Erro durante a deteccao da CRT!')
  else
  begin
    Write('Tipo do adaptador: ');

    case GetCRTType of
      CRTA_MDA : Writeln('MDA');
      CRTA_CGA : Writeln('CGA');
      CRTA_EGA : Writeln('EGA');
      CRTA_VGA : Writeln('VGA');
    else
      Writeln('Desconhecido!');
    end;

    Writeln;
    Writeln('Caracteristicas:');
    Writeln(' - BIOS Mode : 0x', WordToHex(GetCRTMode, 2));
    Writeln(' - Numero de linhas: ', GetCRTRows);
    Writeln(' - Numero de colunas: ', GetCRTCols);
    Writeln(' - Segmento da memoria de video: 0x', WordToHex(GetCRTSeg, 4));
    Writeln(' - Endereco do controlador (porta): 0x', WordToHex(GetCRTAddr6845, 4));
    Writeln;

    if GetCRT_80C then
      Writeln(' - Suporte a 80 colunas');

    if GetCRT_Ex then
      Writeln(' - Suporte a 43/50 linhas');

    if GetCRT_MDA then
      Writeln(' - Monocromatico (Compativel com MDA)')
    else
      if GetCRT_Color then
        Writeln(' - Suporte a cores (16)')
      else
        Writeln(' - Suporte a grayscale (16)');
  end;

  Writeln;
  Finish;
end.
