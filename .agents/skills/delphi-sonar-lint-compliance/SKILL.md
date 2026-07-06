---
name: delphi-sonar-lint-compliance
description: Conformidade com regras de análise estática (DelphiSonar/DelphiLint), tratamento de code smells e falsos positivos do parser.
---

# Conformidade com Análise Estática (DelphiSonar / DelphiLint)

Estas diretrizes definem as regras estritas de confiabilidade, legibilidade e manutenibilidade do código Delphi para passar com sucesso nas análises estáticas do SonarQube.

## 1. Regras de Confiabilidade (Prevenção de Bugs)
*   **Retorno de Métodos (`RoutineResultAssigned`)**: Toda função (`function`) deve obrigatoriamente ter um valor atribuído explicitamente a `Result`.
*   **Inicialização Preventiva (`VariableInitialization`)**: Variáveis locais devem ser declaradas e inicializadas antes do uso para prevenir o acesso a valores indefinidos na memória.
*   **Uso de FreeAndNil (`FreeAndNilTObject`)**: A rotina `FreeAndNil` deve ser utilizada exclusivamente com instâncias descendentes de `TObject` (não use com ponteiros genéricos ou interfaces).
*   **Ordenação do TStringList (`StringListDuplicates`)**: Ao utilizar a propriedade `Duplicates` de um `TStringList`, certifique-se de que o objeto está ordenado (`Sorted := True`) para evitar comportamento indefinido nas buscas binárias internas.

---

## 2. Regras de Manutenibilidade e Estilo (Evitar Code Smells)
*   **Validação de Ponteiros/Objetos (`NilComparison`)**: Utilize a função nativa `System.Assigned(LObj)` ou `not System.Assigned(LObj)` para checar referências, em vez de comparar diretamente com `nil` (ex: use `if Assigned(LObj)` em vez de `if LObj <> nil`).
*   **Liberação Limpa (`AssignedAndFree`)**: Não utilize checagens redundantes de atribuição antes de liberar objetos. Chame diretamente `LObj.Free;` em vez de `if Assigned(LObj) then LObj.Free;`. O método `Free` já realiza internamente a validação se a instância é diferente de `nil`.
*   **Espaços em Branco (`TrailingWhitespace`)**: Remova todos os espaços em branco no final de linhas de código ou arquivos.
*   **Seções de Visibilidade em Classes**:
    *   Devem seguir a ordem ascendente de acessibilidade: `private`, `protected`, `public`, `published` (`VisibilitySectionOrder`).
    *   Seções de visibilidade que estejam vazias ou redundantes devem ser removidas (`EmptyVisibilitySection`).
    *   Seções de visibilidade consecutivas de mesmo nível devem ser combinadas em uma única cláusula (`ConsecutiveVisibilitySection`).
*   **Consistência de Nomenclatura (`MixedNames`)**: Mantenha a capitalização de nomes (variáveis, classes, propriedades) estritamente consistente com a declaração original. Ex: use `MainFormOnTaskBar` e não `MainFormOnTaskbar`.
*   **Instrução With (`WithStatement`)**: Nunca utilize a instrução `with` para acessar membros de objetos, pois ela prejudica o rastreamento estático e a legibilidade, além de induzir a erros silenciosos de escopo.

---

## 3. Gestão de Falsos Positivos do Parser Sonar
*   **Imports de Interface vs. Implementation (`ImportSpecificity`)**: Mova as units importadas na cláusula `uses` da interface para a implementação sempre que possível. Caso a unit seja necessária para declarar tipos de campos privados, propriedades ou parâmetros da interface, o import deve permanecer na seção `interface`.
*   **Variáveis Inline (`UnusedLocalVariable` / `UnusedImport`)**: O parser do Sonar para Delphi possui limitações ao rastrear variáveis declaradas de forma inline (`var LVar := ...`), acusando falsos positivos. Em caso de alertas incorretos de variáveis não utilizadas na linha seguinte, mova a declaração para a seção `var` tradicional da rotina.
