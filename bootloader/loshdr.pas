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
  Unit LosHdr.pas
  --------------------------------------------------------------------------
  Esta Unit possui procedimentos de leitura do cabecalho padrao LOS.
  --------------------------------------------------------------------------
  Versao: 0.1
  Data: 18/09/2013
  --------------------------------------------------------------------------
  Compilar: Compilavel pelo Turbo Pascal 5.5 (Free)
  > tpc loshdr.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit LosHdr;

interface

type
  TTypeVersion = packed record
    Major, Minor : Word;
  end;

  PLOSHeader = ^TLOSHeader;
  TLOSHeader = packed record
    FileType : String;
    TypeVersion : TTypeVersion;
    MetaSize : LongInt;
    MetaData : Pointer;
  end;

  function GetLOSHeader(var FileName : String) : PLOSHeader;


implementation

uses Basic;

type
  { tipos internos }
  PLOSSign = ^TLOSSign;
  TLOSSign = array[0..3] of Char;

  PLOSBasHeader = ^TLOSBasHeader;
  TLOSBasHeader = packed record
    LOSSign : TLOSSign;
    HeaderSize : Word;
  end;


const
  cLOSSign : TLOSSign = ('L', 'O', 'S', #0);


{ Obtem informacoes sobre e do cabecalho LOS }
function GetLOSHeader(var FileName : String) : PLOSHeader;
var
  vFile : File;
  vFileSize : LongInt;
  vBasHeader : PLOSBasHeader;
  vTempSize : Word;
  vTemp : PByteArray;
  vFoot : PLOSSign;
  vLOSHeader : PLOSHeader;
  I : Word;

begin
  GetLOSHeader := nil;

  if FileExists(FileName) then
  begin
    { se o arquivo existe}
    Assign(vFile, FileName);
    Reset(vFile, 1);

    vFileSize := FileSize(vFile);

    if (vFileSize > 16) then
    begin
      { se o arquivo tem o tamanho minimo }
      GetMem(vBasHeader, SizeOf(TLOSBasHeader));

      BlockRead(vFile, vBasHeader^, SizeOf(TLOSBasHeader));

      if (vBasHeader^.LOSSign = cLOSSign) and (vBasHeader^.HeaderSize <= vFileSize) then
      begin
        { se cabecalho LOS presente }
        vTempSize := vBasHeader^.HeaderSize - SizeOf(TLOSBasHeader);

        GetMem(vTemp, vTempSize);

        BlockRead(vFile, vTemp^, vTempSize);

        vFoot := Ptr(Seg(vTemp^), Ofs(vTemp^) + (vTempSize - 4));

        if (vFoot^ = cLOSSign) then
        begin
          { assinatura e rodape OK }
          GetMem(vLOSHeader, SizeOf(TLOSHeader));
          GetLOSHeader := vLOSHeader;

          { pega o tipo }
          I := 0;

          while (I < 255) and (I < vTempSize) and (Char(vTemp^[I]) <> #0) do
            Inc(I);

          { copia pro registro }
          Move(vTemp^, vLOSHeader^.FileType[1], I);
          vLOSHeader^.FileType[0] := Char(I);

          Inc(I); { pula #0, aponta para o proximo registro, TypeVersion }

          if ((I + 4) < (vTempSize - 4)) then
          begin
            { se tem espaco para TypeVersion }

            { copia TypeVersion }
            Move(vTemp^[I], vLOSHeader^.TypeVersion, 4);

            { posiciona no metadados }
            I := I + 4;

            vLOSHeader^.MetaSize := (vTempSize - 4) - I;

            GetMem(vLOSHeader^.MetaData, vLOSHeader^.MetaSize);

            Move(vTemp^[I], vLOSHeader^.MetaData^, vLOSHeader^.MetaSize);
          end
          else
          begin
            { se nao tem espaco para TypeVersion }
            vLOSHeader^.TypeVersion.Major := 0;
            vLOSHeader^.TypeVersion.Minor := 0;
            { tambem nao tem metadados }
            vLOSHeader^.MetaSize := 0;
            vLOSHeader^.MetaData := nil;
          end;
        end;

        FreeMem(vTemp, vTempSize);
      end;

      FreeMem(vBasHeader, SizeOf(TLOSBasHeader));
    end;

    Close(vFile);
  end;
end;


end.
