# Manual de Conformidade SonarQube e DelphiLint no Delphi

Este manual descreve como adequar códigos Delphi aos padrões de análise estática do SonarQube (usando plugins DelphiSonar ou DelphiLint), tratar code smells comuns e suprimir falsos positivos gerados por limitações de parsers legados.

---

## 1. Tratamento de Falsos Positivos do Parser
Muitos parsers de análise estática de Delphi foram escritos originalmente para a sintaxe do Delphi 7 / Delphi 2007. Quando encontram recursos modernos da linguagem (introduzidos do Delphi Rio 10.3 ao Delphi 12 Athens/Florence), eles geram falsos positivos de análise ou falham ao processar o arquivo.

### Declaração de Variáveis Inline (Inline Variables)
As variáveis inline (`var LValue := 10;` declaradas no corpo do método) causam erros em parsers antigos.

*   **Tratamento**: Se a ferramenta de análise da sua empresa falhar ao processar units com variáveis inline, configure o arquivo `sonar-project.properties` para excluir essa pasta ou use comentários de supressão.
*   **Melhor Prática**: O template do SonarQube incluído neste kit (`sonar-project.properties.template`) já vem pré-configurado com expressões regulares e filtros de exclusão de erros de parser para units complexas.

---

## 2. Supressão de Duplicações (CPD - Copy-Paste Detector)
O SonarQube possui um validador de duplicações estrito que falha se trechos de código idênticos se repetirem. No desenvolvimento de telas visuais Delphi, os arquivos `.dfm` ou stubs autogerados frequentemente contêm propriedades muito semelhantes que acionam esse alarme.

*   **Exclusões no Projeto**: No arquivo `sonar-project.properties`, utilize a chave `sonar.cpd.exclusions` para ignorar caminhos propensos a falsas duplicações:
    ```properties
    # Exemplo de exclusão CPD para stubs e arquivos autogerados
    sonar.cpd.exclusions=**/*.dfm,**/stubs/**/*.pas
    ```

---

## 3. Resolução de Code Smells Comuns no Delphi

*   **Variáveis Declaradas e Não Utilizadas**: Nunca deixe variáveis declaradas no bloco `var` que não sejam referenciadas no corpo do código. Elas geram alertas de complexidade e confusão.
*   **Comentários de Código Morto**: Trechos de código comentados ativam code smells de "código morto". Remova o código que não está sendo usado. Confie no histórico do seu controle de versão (Git) se precisar resgatá-lo futuramente.
*   **Imports Não Utilizados (Uses)**: Units declaradas na cláusula `uses` (seção `interface` ou `implementation`) que não tenham nenhuma classe ou tipo consumido na unit devem ser removidas para reduzir o tempo de compilação e evitar dependências circulares ocultas.
*   **Complexity (Complexidade Ciclomática)**: Métodos gigantescos com dezenas de ramificações condicionais (`if` / `case`) ativam alarmes do SonarQube. Refatore-os dividindo a lógica em métodos privados menores e com responsabilidades bem definidas.
