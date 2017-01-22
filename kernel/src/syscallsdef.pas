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
  Unit SysCallsDef.pas
  --------------------------------------------------------------------------
  Unit com "a tabela" de chamadas de sistema.
  --------------------------------------------------------------------------
  Versao: 0.2
  Data: 21/12/2014
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc syscallsdef.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit SysCallsDef;

interface

type
  TSysCall =
  (
    {0}   Sys_Abort {Error : TErrorCode; ErrorMsg : PChar; AbortRec : PAbortRec},
    {1}   Sys_Exit {Status : SInt},

    {2}   Sys_Open {Name : PChar; Mode : TFileMode => SInt} ,
    {3}   Sys_Close {FD : UInt => SInt},

    {4}   Sys_Read {FD : UInt; Buffer : Pointer; Count : SInt => SInt},
    {5}   Sys_Write {FD : UInt; Buffer : Pointer; Count : SInt => SInt}
  );


implementation


{ Descricao de chamadas:

    TODAS as chamadas retornam um SInt, valores negativos SEMPRE indicam
    condicao de erro, valores positivos sao retornos especificos de cada
    chamada.


    Obs: Algumas chamadas como SysAbort e SysExit, nunca retornam, portanto
    nao retornam qualquer valor.
}

{ SysAbort - Finaliza o processo, provocando saida de depuracao;

    Error : TErrorCode => Inteiro sem sinal, indica o codigo de erro referente ao
                          motivo do abort;

    ErrorMsg : PChar => Ponteiro para uma string terminada em zero contendo uma
                        mensagem de erro opcional;

    AbortRec : PAbortRec => Ponteiro para TAbortRec, record com informacoes
                            precisas de depuracao. Se informado NUL a
                            depuracao eh feita pelos valores obtidos no final
                            da chamada;
}

{ SysExit - Finaliza o processo normalmente;

    Status : SInt => Inteiro com sinal, indica o codigo de status de saida
                      do processo, que é retornado ao processo pai.
}

{ SysOpen - Abre arquivo, retornando um descritor ou codigo de erro,

    Name : PChar  => Ponteiro para uma string terminada em zero contendo o
                      nome do arquivo;

    Mode : TFileMode  => Tipo SET com os modos de abertura;

    Result : SInt => Inteiro com sinal, se zero ou positivo indica o numero
                      do descritor do arquivo, se negativo indica o codigo
                      de erro;
}

{ SysClose - Fecha arquivo, retornando o codigo de erro,

    FD : UInt => Inteiro sem sinal, descritor de arquivo;

    Result : SInt => Inteiro com sinal, informa por erro ocorrido;
}

{ SysRead - Le a partir de um arquivo aberto, retornando a quantidade lida

    FD : UInt => Inteiro sem sinal, descritor de arquivo;

    Buffer : Pointer => Ponteiro, apontando para a variavel utilizada como
                        Buffer;

    Count : SInt => Inteiro com sinal, indica a quantidade maxima de bytes
                    a serem lidos, normalmente o tamanho do buffer;

    Result : SInt => Inteiro com sinal, indica a quantidade efetivamente lida,
                      valores negativos indicam erro;
}

{ SysWrite - Escreve para um arquivo aberto, retornando a quantidade gravada

    FD : UInt => Inteiro sem sinal, descritor de arquivo;

    Buffer : Pointer => Ponteiro, apontando para a variavel utilizada como
                        Buffer;

    Count : SInt => Inteiro com sinal, indica a quantidade maxima de bytes
                    a serem gravados, normalmente o tamanho do buffer;

    Result : SInt => Inteiro com sinal, indica a quantidade efetivamente
                      gravada, valores negativos indicam erro;
}


end.
