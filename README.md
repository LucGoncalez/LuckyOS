# LuckyOS-Full #

**Repositório completo (FULL) do Projeto LOS**

O objetivo do projeto é criar um sistema operacional simples, em Pascal e Assembly, um ToyOS (ou HobbyOS), com a única finalidade de aplicar os conhecimentos teóricos à prática. Portanto não espere que ele substitua os seu OS atual.

------

## Índice ##

[Topo](#luckyos-full)

[O Projeto LOS](#o-projeto-los)

[Versionamento](#versionamento)

[O Repositório](#o-repositório)

  - [Branchs](#branchs)

  - [Labels](#labels)

  - [Issues](#issues)

  - [Pulls Requests](#pulls-requests)

[Diretivas do Projeto](#diretivas-do-projeto)

[Metas](#metas)

[Dicas de git](#dicas-de-git)

------

## O Projeto LOS ##

O Projeto LOS surgiu do estudo de sistemas operacionais, a partir da leitura do livro "Sistemas Operacionais - Projeto e Implementação" do Tanenbaum. O projeto pretende criar um sistema operacional simples de código-fonte aberto. O código-fonte pretende ser o mais didático possível prezando pela clareza à eficiência, para isso é evitado ao máximo o uso de linguagens de baixo nível e arranjos que dificultem o entendimento. Após finalizar a parte inicial, com o sistema estando funcional e usável, todo o código será comentado de maneira mais detalhada possível, explicando cada detalhe do funcionamento do SO.

Para tornar o Projeto único foi escolhido Pascal como linguagem principal tendo em vista que essa linguagem nunca foi utilizada para este fim (pelo menos não é do meu conhecimento) e por preferência pessoal. Inicialmente é um projeto de um-homem-só, porém a algum tempo recebi alguns pedidos de colaboração que estão me fazendo mudar a estrutura original do Projeto para permitir o trabalho em equipe. Essa mudança é trabalhosa e obriga uma melhor documentação de todo o projeto, de forma que os colaboradores possam implementar de forma adequada a ideia original.

O repositório original do projeto é outro, na verdade um conjunto de repositórios. A estrutura original não permite a colaboração e portanto deveria ser modificada. Ao invés de modificar a estrutura original de repositórios criei mais este aqui, que é uma fusão de todos e trabalha como um espelho (mirror), portanto modificações que forem realizadas aparecerão em ambos os sistemas de repositórios, por sincronização manual.

Para a construção (compilação) do sistema é necessário que seja usuário Linux, pois este já possui diversas ferramentas obrigatórias. É provável que o sistema também possa ser construído a partir de outro OS mas acredito que haja mais complicações que benefícios.

Como curiosidade, o nome do projeto/sistema vem de uma contração do meu nome (Luciano => Luc) puxado para um sentido em inglês (Lucky => Sortudo). Espero ter sorte de terminá-lo... :-)

[Índice](#Índice)

------

## Versionamento ##

A numeração de versão do sistema e dos arquivos segue o seguinte padrão:

```
Major.Minor[.Revision][-Extension.Build]
```

Onde:

- **Major** (*Maior Versão*) - Indica mudanças grandes que implicam incompatibilidade com versões anteriores. Versões da mesma série Maior possuem retrocompatibilidade, ou seja, a versão mais recente deve funcionar perfeitamente no lugar da mais antiga. Cada série Maior possuem uma versão de API/ABI que somente pode ser incrementada a cada versão Menor.

- **Minor** (*Menor Versão*) - Indica mudanças pequenas que, normalmente, não implicam em incompatibilidade com versões anteriores. Tais mudanças são em sua maioria a adição de funcionalidades.

- **Revision** (*Revisão*) - São versões que não acrescentam nenhuma mudança de funcionalidades, somente correções de erros e otimizações. Não implicam em incompatibilidades. Quando ainda não há revisões o "0" é sempre suprimido.

- **Extension** (*Extensão*) - Indicam uma versão de teste, release candidate, etc. Normalmente só será utilizada a RC (Release Candidate) junto com a Build para indicar arquivo ou versão que está em desenvolvimento.

- **Build** (*Construção*) - Indicam unicamente uma versão de arquivo ou sistema. Adotei a seguinte formação de Build:

  > **YYYYMMDDhhmm** (YYYY = ano; MM = Mês; DD = Dia; hh = Hora; mm = Minutos)

  > Exemplo, agora é 8 Julho de 2016, 20hs e 39min, o Build ficaria: *201607082039*

Exemplo prático, digamos que agora eu esteja lançando uma release candidate do sistema sendo **v0.6** a última lançada, a release ficaria assim:

```
LOS-v0.7-RC.201607082039
```

Durante o desenvolvimento da primeira série Maior, versões **0.X.X**, não haverá uma API/ABI definida, podendo essa ser modificada a cada release.

[Índice](#Índice)

------

## O Repositório ##

Este repositório, aqui no GitHub, possui algumas funcionalidades a fim de facilitar a organização do trabalho:

### Branchs ###

Os branchs estão distribuídos em:

- **master** - Versão estável. Somente será adicionado algo a este branch quando for realmente relevante para o lançamento de uma nova versão.

- **dev** - Versão instável. É a versão contínua de desenvolvimento. Neste branch será adicionado todas as modificações aprovadas.

- **inbox** - Branch para recebimento de Pulls Requests. Todos os pulls deverão ser direcionados a este branch, que se aprovados serão mergeds para o *dev*.

- **draft** - Branch de rascunho, utilizado durante o teste de novas funcionalidades e pulls. Quando algum pull for parcialmente aceito, as modificações sugeridas serão apresentadas nesse branch (mais informações na seção de Pulls).

- **news** - Branch contendo a funcionalidade atual em desenvolvimento pelo mantenedor.

Os branchs *inbox*, *draft* e *news* são temporários, assim que uma modificação for adicionada ao **dev** estes branchs serão reiniciados.

[Índice](#Índice)

### Labels ###

Para facilitar a organização dos Pulls e Issues utilizarei os seguintes Labels:

1. Quanto ao tipo:

  - **bug** - Indica que o assunto é um bug ou a solução deste.

  - **enhancement** - Indica um melhoramento, uma otimização.

  - **new feature** - Indica a adição de uma nova funcionalidade.

  - **question** - Utilizado somente em Issues quando a questão não se encaixar em nenhuma das anteriores.

2. Quanto ao nível de prioridade e/ou gravidade:

  - **low** - Baixa.

  - **medium** - Média.

  - **high** - Alta.

  - **critical** - Crítica.

3. Quanto à ação tomada:

  - **standby** - Marcado quando o mantenedor tomar conhecimento do Pull porém já tiver outro Pull sendo analisado.

  - **working** - Marcado quando o mantenedor tomar conhecimento do Pull e/ou iniciar a analise deste.

  - **fixed** - Marcado quando um Pull de bug for corrigido.

  - **invalid** - Marcado quando um Pull for considerado inválido por qualquer motivo.

  - **wontfix** - Marcado quando uma sugestão, embora válida, não funcione por alguma característica ainda não divulgada do projeto.

  - **changed** - Marcado quando quando o Pull foi modificado e as modificações enviadas como novo Pull. 

4. Auxiliares:

  - **duplicate** - Marcado quando for verificado que dois ou mais Pulls se referem ao mesmo item/bug.

  - **help wanted** - Marcado pelo mantenedor quando um questão for levantada e ele não tiver a solução.

[Índice](#Índice)

### Issues ###

Funcionalidade que torna o GitHub uma rede social, ou seja, permite a você conversar com o mantenedor e outros colaboradores. Abra uma nova issue para questionar sobre bugs, otimizações, novas características ou dúvidas diversas.

[Índice](#Índice)

### Pulls Requests ###

Pulls Requests é a forma de contribuir com o projeto, para isso você primeiramente cria um fork para sua conta, modifica o seu próprio repositório e envia as modificações ao repositório original.

Antes de enviar um Pull Request leia as ***Diretivas do Projeto*** e as ***Dicas de git***. Economize tempo, se tem dúvida sobre as modificações abra uma **issue** primeiro e questione a dúvida.

Todos os Pulls deverão ser direcionando ao branch ***inbox***. Cada Pull será analisado segundo:

- **Informação das modificações** - A mensagem de commit do Pull deve informar clara e corretamente as modificações.

- **Compilação** - O código dever ser apto de ser compilado.

- **Execução** - O código compilado deve funcionar perfeitamente, sem inclusão de bugs.

- **Clareza de escrita e indentação** - Todas as modificações deverão ser entendidas por "um iniciante".

- **Seguir as diretivas do Projeto** - Deve seguir as demais diretivas.

Um Pull pode ser aprovado total ou parcialmente. No caso de ser aprovado parcialmente a parte aprovada estará disponível no branch ***draft*** para que o autor do Pull possa corrigir e enviar um novo Pull. **Somente Pulls com commits únicos serão mergeds**, e isto será feito no branch ***dev***.

Após enviar um Pull, não adicione mais commits (não faça novos Pulls), aguarde as modificações serem analisadas e se solicitado alguma correção, as faça e, faça novo commit (novo Pull). Quando a discussão sobre o Pull estiver finalizada com modificações no Pull original este será fechado devendo o autor preparar novo Pull com somente um commit, para que este possa ser adicionado ao repositório.

[Índice](#Índice)

------

## Diretivas do Projeto ##

Todas as ações no Projeto deverão seguir as diretivas abaixo:

1. **Voltado ao público de Língua Portuguesa**. É possível encontrar diversos trabalhos semelhantes, e na maioria das vezes até melhores que este, em inglês. Portanto toda a documentação, os comentários, as issues, os pulls requests, etc. serão escritos em português.

2. **Finalidade educacional**. A ideia é que seja utilizado por iniciantes na programação de SOs. (*Considerando que iniciantes em SO já devem ser programadores experientes e com lógica bem desenvolvida*).

3. **Atingir uma versão utilizável**. A principal meta do Projeto é construir um sistema totalmente utilizável para situações básicas.

4. **Código-fonte legível**. Considerando a diretiva **2**, considera-se que o código-fonte foi escrito para ser lido e não para ser executado, isto implica que a clareza tem prioridade sobre a eficiência.

5. **Código-fonte separado**. Para aumentar a legibilidade, o código-fonte de alto e baixo nível sempre estarão em arquivos separados, cabe ao colaborador utilizar um artifício legível para a ligação dos códigos.

6. **Clareza no Pull Request**. O Pull Request deve ser o mais claro possível:

  - Com mensagem de commit descritiva.

  - Destinado ao branch correto.

  - Com apenas um tipo de modificação (ou é correção de bug, ou é otimização, ou é uma nova característica, nunca abrangir duas ou mais).

  - Com apenas um commit por Pull Request.

7. **Seguir as demais dicas constantes neste arquivo**.

[Índice](#Índice)

------

## Metas ##

Metas a cumprir e a serem cumpridas:

- [ ] Sistema utilizável.

[Índice](#Índice)

------

## Dicas de git ##

Para contribuir com este projeto siga as seguintes dicas:

1. Tenha uma conta no GitHub e o git configurado para utilizá-la. (Meio óbvio essa :/ )

2. Crie um **fork** deste repositório no GitHub:

  > https://github.com/LucGoncalez/LuckyOS-Full

3. Faça um **clone** local do seu fork:

  ```
  git clone git@github.com:<suaconta>/LuckyOS-Full.git
  ```

4. Adicione o repositório principal (o meu) ao seu local (usado para sincronização):

  ```
  git remote add main https://github.com/LucGoncalez/LuckyOS-Full.git
  ```

5. Sempre faça **fetch** do repositório principal para verificar se algo foi alterado:

  ```
  git fetch main
  ```

6. Caso a operação anterior indique alguma modificação nos branchs *master* e *dev* faça os devidos pulls:

  ```
  git pull main master:master
  git pull main dev:dev 
  ```

7. Todas as modificações devem partir do branch **dev**. Portanto crie um branch de trabalho a partir de *dev*:

  ```
  git branch work dev
  git checkout work
  ```

  **Obs.: Nunca modifique** os branchs *master* e *dev*. O branch de trabalho pode ter o nome que quiser.

8. Faça as modificações seguindo as Diretivas do Projeto, compile e teste.

9. Antes de enviar suas modificações verifique se o repositório principal foi modificado conforme itens **5** e **6**.

10. Caso o repositório principal tenha sido modificado faça um **rebase** com *dev* e corrija os conflitos:

  ```
  git rebase dev
  ```

11. Crie um branch para conter o commit que será enviado via Pull Request:

  ```
  git branch send dev
  git checkout send
  ```

12. Verifique quantos commits estão à frente de **dev** (ou *send*, pois estão no mesmo ponto):

  ```
  git log dev..work
  ```

13. Caso existam mais de um commit, eles devem ser agrupados em um único. Para isso faça um merge com *--squash* e logo em seguida faça o commit.

  ```
  git merge work --squash
  git commit -m "Mensagem descritiva"
  ```

14. No caso da verificação do item **12** apresentar somente um commit pode-se fazer um merge simples:

  ```
  git merge work
  ```

15. Agora as modificações estão prontas para serem enviadas para o seu repositório no GitHub:

  ```
  git push origin send:send
  ```

16. No GitHub peça um Pull Request do seu branch ***send*** para o branch ***inbox*** do repositório principal. Se for informado que o Pull não permite automerge, indica que houve alguma atualização no repositório principal entre os passos **9** e **este**, cancele o Pull e repita todos os passo desde o **9** e faça o passo **15** (com a opção *--force*):

  ```
  git push origin send:send --force
  ```

17. Agora é só aguardar que o mantenedor faça a analise do seu Pull. Caso alguma modificação tenha sido feita no repositório principal poderá ser pedido que você faça um rebase no seu Pull, neste caso siga os passos do **9** ao **16** e envie um novo Pull.

18. Após ter seu Pull aceito, ou frequentemente, verifique se o repositório principal foi modificado seguindo os passos **5** e **6** e caso esteja trabalhando em algo faça um rebase para manter seu trabalho sincronizado. Isto minimiza trabalho no momento de enviar um Pull Request.

19. Para manter seu repositório remoto (GitHub) também atualizado depois de executar o item anterior faça um push para ele:

  ```
  git push origin master:master
  git push origin dev:dev
  ```

**Obs.:** Lembre-se que só é aceito um tipo de modificação a cada Pull Request (Diretiva do Projeto), portanto se estiver trabalhando em otimizações ou em novas funcionalidade e encontrar um **bug** pare o trabalho atual, crie um novo branch a partir de *dev*, corrija o bug neste branch e envie o Pull Request. Após o Pull ser aceito faça um rebase no seu trabalho (corrija os conflitos) e continue o trabalho...

[Índice](#Índice)

[Topo](#luckyos-full)

