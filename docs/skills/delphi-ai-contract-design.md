# Manual de Desenvolvimento Guiado por IA no Delphi

Este manual descreve o contrato de desenvolvimento colaborativo entre humanos e assistentes de IA (coding assistants), focando no design baseado em contratos (Contract-First), validações prematuras e clareza de implementação.

---

## 1. Design por Contratos (Contract-First)
No desenvolvimento guiado por IA, defina as interfaces de abstração e as assinaturas públicas antes de iniciar qualquer lógica de execução concreta. 

*   **Por que usar?**: Ao estabelecer um contrato claro de antemão (interface), a IA e o desenvolvedor humano podem programar e testar diferentes partes do sistema em paralelo de forma totalmente isolada.
*   **Contrato de Parâmetros**: Defina as diretivas de passagem de parâmetros adequadas nas assinaturas de métodos:
    *   Use `const` para parâmetros somente-leitura (melhora a performance e evita modificações colaterais indesejadas pelo compilador).
    *   Use `out` para parâmetros de retorno adicionais.
    *   Use `var` apenas para parâmetros de entrada/saída que sofrerão alteração na instância referenciada.

---

## 2. Validações Prematuras (Fail-Fast)
Métodos devem ser projetados para falhar imediatamente se as condições de contorno ou argumentos não forem satisfeitos. Isso previne o aninhamento excessivo de blocos de decisão (`if/else`) e facilita a depuração pelo desenvolvedor e pela IA.

### Padrão Homologado (Antes e Depois)

#### Incorreto (Código "Arrow" Aninhado):
```delphi
procedure TOrderService.ProcessOrder(const AOrder: TOrder);
begin
  if AOrder <> nil then
  begin
    if AOrder.Items.Count > 0 then
    begin
      if AOrder.Total > 0 then
      begin
        // Executa o processamento principal
      end;
    end;
  end;
end;
```

#### Correto (Fail-Fast / Guard Clauses):
```delphi
procedure TOrderService.ProcessOrder(const AOrder: TOrder);
begin
  // Guard Clauses de validação prematura
  if AOrder = nil then
    raise Exception.Create('Pedido nao pode ser nulo.');
    
  if AOrder.Items.Count = 0 then
    raise Exception.Create('Pedido nao possui itens.');
    
  if AOrder.Total <= 0 then
    raise Exception.Create('Total do pedido deve ser maior que zero.');

  // Código de processamento principal (sem aninhamento)
end;
```

---

## 3. Código Sem Placeholders (Zero To-Do)
Ao solicitar ou escrever alterações de código, nunca deixe ou aceite marcadores de placeholder (como `// TODO: implementar lógica aqui` ou `// ... resto do código`). 

*   **Regra estrita**: Todo código gerado ou refatorado deve ser entregue com a implementação **100% completa**, permitindo cópia, compilação direta e execução em testes unitários.
*   **Comentários de valor**: Comentários no código devem explicar o **porquê** de uma decisão de design não óbvia (o motivo técnico), e não o **o que** o código faz (o que é trivial ao ler a sintaxe da linguagem).
