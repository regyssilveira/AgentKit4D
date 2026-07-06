# Manual de Conformidade SonarQube e DelphiLint no Delphi

Este manual descreve como adequar códigos Delphi aos padrões de análise estática do SonarQube (usando plugins DelphiSonar ou DelphiLint), tratar code smells comuns, gerenciar a complexidade do projeto e suprimir falsos positivos gerados por limitações de parsers legados.

---

## 1. Tratamento de Falsos Positivos do Parser
Muitos parsers de análise estática de Delphi foram escritos originalmente para a sintaxe do Delphi 7 / Delphi 2007. Quando encontram recursos modernos da linguagem (introduzidos do Delphi Rio 10.3 ao Delphi 12 Athens/Florence), eles geram falsos positivos de análise ou falham ao processar o arquivo.

### Declaração de Variáveis Inline (Inline Variables)
As variáveis inline (`var LValue := 10;` declaradas no corpo do método) causam erros em parsers antigos.

*   **Tratamento**: Se o parser do SonarQube da sua empresa acusar incorretamente variável local não utilizada devido a declarações inline, contorne a limitação movendo a declaração para a seção `var` clássica do método. O template de propriedades (`sonar-project.properties.template`) não ignora essa regra globalmente para manter o controle de código morto ativo.

---

## 2. Gerenciamento e Análise de Complexidade (Quality Gate Forte)
O template padrão de qualidade do SonarQube fornecido por este kit mantém as checagens de complexidade ativas por padrão. Métodos gigantes e ramificados comprometem seriamente o Quality Gate e a cobertura de testes do projeto.

### Regras Ativas:
*   **`CognitiveComplexityRoutine` (Complexidade Cognitiva)**: Mede o quão difícil é para um humano compreender o fluxo do código (estruturas de controle, aninhamento e ramificações).
*   **`CyclomaticComplexityRoutine` (Complexidade Ciclomática)**: Mede o número de caminhos linearmente independentes no fluxo do método.

### Tratamento e Refatoração:
Métodos que acionem esses alertas devem ser divididos utilizando a refatoração "Extract Method", quebrando a unit em métodos pequenos, coesos e autoexplicativos.

### Exceção em Código Legado:
> [!IMPORTANT]
> Se o seu repositório possui uma base legada gigantesca cuja refatoração imediata é inviável, **NUNCA** desative as regras de complexidade de forma global no arquivo `sonar-project.properties` (usando `**/*`).
> Em vez disso, defina regras multicritério que limitem as exclusões estritamente ao diretório ou arquivos legados correspondentes:

```properties
# Exemplo de supressão localizada apenas em pasta legada
sonar.issue.ignore.multicriteria=legado1,legado2

# legado1: Ignora complexidade cognitiva apenas na pasta Legacy
sonar.issue.ignore.multicriteria.legado1.ruleKey=community-delphi:CognitiveComplexityRoutine
sonar.issue.ignore.multicriteria.legado1.resourceKey=src/Legacy/**/*.pas

# legado2: Ignora complexidade ciclomática apenas na pasta Legacy
sonar.issue.ignore.multicriteria.legado2.ruleKey=community-delphi:CyclomaticComplexityRoutine
sonar.issue.ignore.multicriteria.legado2.resourceKey=src/Legacy/**/*.pas
```

---

## 3. Supressão de Duplicações (CPD - Copy-Paste Detector)
O SonarQube possui um validador de duplicações estrito que falha se trechos de código idênticos se repetirem. No desenvolvimento de telas visuais Delphi, os arquivos `.dfm` ou stubs autogerados frequentemente contêm propriedades muito semelhantes que acionam esse alarme.

*   **Exclusões no Projeto**: No arquivo `sonar-project.properties`, utilize a chave `sonar.cpd.exclusions` para ignorar caminhos propensos a falsas duplicações:
    ```properties
    # Exemplo de exclusão CPD para stubs e arquivos autogerados
    sonar.cpd.exclusions=**/*.dfm,**/stubs/**/*.pas
    ```

---

## 4. Resolução de Code Smells Comuns no Delphi

*   **Variáveis Declaradas e Não Utilizadas**: Nunca deixe variáveis declaradas no bloco `var` que não sejam referenciadas no corpo do código. Elas geram alertas de complexidade e confusão.
*   **Comentários de Código Morto**: Trechos de código comentados ativam code smells de "código morto". Remova o código que não está sendo usado. Confie no histórico do seu controle de versão (Git) se precisar resgatá-lo futuramente.
*   **Imports Não Utilizados (Uses)**: Units declaradas na cláusula `uses` (seção `interface` ou `implementation`) que não tenham nenhuma classe ou tipo consumido na unit devem ser removidas para reduzir o tempo de compilação e evitar dependências circulares ocultas.
*   **Complexity (Complexidade Ciclomática)**: Métodos gigantescos com dezenas de ramificações condicionais (`if` / `case`) ativam alarmes do SonarQube. Refatore-os dividindo a lógica em métodos privados menores e com responsabilidades bem definidas.
