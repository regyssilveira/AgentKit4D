---
name: delphi-dext-framework
description: Diretrizes de qualidade e desenvolvimento de APIs web, ORM, injeção de dependências e testes utilizando o Dext Framework em Delphi.
---

# Diretrizes para Desenvolvimento com o Dext Framework no Delphi

Estas regras definem o contrato de codificação para projetos que utilizam o Dext Framework, garantindo a adoção de padrões de desenvolvimento modernos (inspirados em ASP.NET Core), alto desempenho e ausência de vazamentos de memória.

---

## 1. Cláusula de Usos (Ordem Crítica)
Devido à limitação do compilador Delphi de permitir apenas um class helper ativo por tipo de dados, a ordem das units Dext na cláusula `uses` é **altamente crítica** e deve seguir exatamente esta sequência:
1. `Dext`
2. `Dext.Entity` (opcional, se usar persistência)
3. `Dext.Web` (**sempre por último**)

```delphi
uses
  Dext,
  Dext.Entity, // Opcional
  Dext.Web;    // Sempre por último para garantir prioridade de Helpers Web
```

---

## 2. Desenvolvimento de APIs Web (Dext Web & Server Adapters)
*   **Sintaxe de Rota**: Parâmetros de rota utilizam sempre a sintaxe `{param}` (estilo ASP.NET Core) e **nunca** `:param` (estilo Express/Node.js).
*   **Barra Inicial**: Em controllers, as rotas nos atributos de verbo HTTP devem iniciar obrigatoriamente com barra `/` (ex: `[HttpGet('/{id}')]`).
*   **Injeção Automática (In-Param)**: Nas Minimal APIs (endpoints declarados via `MapGet`, `MapPost`, etc.), o último parâmetro de tipo genérico é sempre `IResult`. Os parâmetros anteriores são resolvidos automaticamente a partir de injeção de dependência (DI), corpo da requisição (records) ou parâmetros de rota:
    ```delphi
    // Injeção de IUserService via DI + binding automático de Id da rota
    Builder.MapGet<IUserService, Integer, IResult>('/api/users/{id}',
      function(Svc: IUserService; Id: Integer): IResult
      begin
        Result := Results.Ok(Svc.GetById(Id));
      end);
    ```
*   **Evite Ctx.RequestServices**: Nunca use chamadas diretas como `Ctx.RequestServices.GetService<T>` ou parsing manual de JSON como `Ctx.Request.BodyAsJson<T>`. Confie nos parâmetros genéricos mapeados no endpoint.
*   **Nomenclatura do Controller**: Nunca nomeie métodos de ação de controllers como `Create`, pois isso cria conflito com os construtores padrões do Delphi (use `CreateUser`, `CreateOrder`, etc.).

---

## 3. Persistência de Dados e Acesso (Dext ORM)
*   **Smart Properties**: Para mapeamento de campos de entidade, utilize sempre os aliases de tipo **IntType**, **StringType**, **DoubleType** e **BoolType** (de `Dext.Core.SmartTypes`) em vez do tipo genérico `Prop<T>`.
*   **Colunas Anuláveis (Nullable)**: Use sempre a composição `Prop<Nullable<T>>` (ex: `Prop<Nullable<Integer>>`) em vez de `Nullable<Prop<T>>` (obsoleta, gera alertas e quebra a ordenação em queries).
*   **Tipos de Coleção**: Nunca retorne `TObjectList<T>` a partir de métodos de acesso a dados ou repositórios ORM. Use sempre `IList<T>` (de `Dext.Collections`), o que favorece o desacoplamento.
*   **WithPooling**: Sempre ative o pool de conexões com `.WithPooling(True)` para DbContexts declarados em APIs Web.
*   **Update Preventivo**: Sempre chame o método `.Update(Entity)` antes de invocar `SaveChanges` ao manipular entidades que estejam desanexadas (detached) do contexto.
*   **Uses Obrigatório**: Lembre-se de adicionar `Dext.Entity.Core` na cláusula `uses` para garantir a compilação correta das propriedades genéricas de `IDbSet<T>`.

---

## 4. Injeção de Dependências (Dext DI)
*   **Tempos de Vida**: Registre os serviços usando os escopos corretos de ciclo de vida na classe de Startup:
    *   `.AddTransient<TInterface, TImpl>`: Para serviços sem estado.
    *   `.AddScoped<TInterface, TImpl>`: Para serviços instanciados uma vez por requisição web (ex: controladores e regras de negócio).
    *   `.AddSingleton<TInterface, TImpl>`: Para estados e caches compartilhados globais.
*   **Injeção Automática**: Dê preferência à injeção via construtor. Caso precise injetar em propriedades de classes existentes, decore-as com o atributo `[Inject]`.

---

## 5. Testes Unitários e Simulações (Dext Testing)
*   **Record Mock**: O objeto de simulação `Mock<T>` (de `Dext.Mocks`) é implementado como um `record` no Delphi. **Nunca chame `.Free` ou tente liberar a memória de um Mock**, pois registros são liberados automaticamente pelo compilador.
*   **Assertions Fluentes**: Use a API de asserção fluente do Dext para tornar os testes legíveis:
    ```delphi
    Value.Should.BeTrue;
    List.Count.Should.Be(10);
    ```
*   **Codificação Console**: Adicione sempre a chamada de console `SetConsoleCharSet` em programas de teste (console test runners) para correta formatação dos logs.

---

## 6. Referência de Skills Originais (Diretrizes Avançadas)
O framework Dext possui um conjunto completo de 22 skills modulares detalhadas para agentes de IA no diretório original do repositório `$(DEXT)\Docs\skills\`. Caso precise implementar recursos específicos e avançados, consulte as diretrizes correspondentes:

*   **Estrutura e Bootstrap**: `dext-app-structure.md`, `dext-server-adapters.md`
*   **Web e Endpoints**: `dext-web.md`, `dext-api-features.md`, `dext-database-as-api.md`
*   **Banco de Dados (ORM)**: `dext-orm.md`, `dext-orm-advanced.md`
*   **Validação e Segurança**: `dext-validation.md`, `dext-auth.md`
*   **Serviços e Resiliência**: `dext-di.md`, `dext-background.md`, `dext-resilience.md`, `dext-logging.md`
*   **Realtime e Comunicação**: `dext-realtime.md`, `dext-networking.md`, `dext-collections.md`, `dext-json.md`
*   **UI e Interações**: `dext-desktop-ui.md`, `dext-mcp.md`
*   **Garantia de Qualidade**: `dext-testing.md`
