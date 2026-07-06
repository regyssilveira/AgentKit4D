---
name: delphi-memory-management
description: Gestão de memória, ciclo de vida de objetos (constructors/destructors), ARC e Value Objects (records) no Delphi.
---

# Gestão de Memória e Boas Práticas Delphi

Estas diretrizes definem as regras e padrões para garantir que a aplicação seja livre de vazamentos de memória (memory leaks) e use os recursos de forma eficiente.

## 1. Garantia contra Memory Leaks
Sempre envolva a criação de instâncias de classes locais em blocos `try..finally` para assegurar sua liberação segura, mesmo em caso de exceções:
```pascal
LMyObj := TMyClass.Create;
try
  // operações com o objeto
finally
  LMyObj.Free;
end;
```

---

## 2. Interfaces (ARC - Auto Reference Counting)
*   Instâncias associadas a variáveis do tipo interface (`IMyInterface`) possuem contagem automática de referência e são liberadas automaticamente pelo compilador quando perdem o escopo.
*   **Nunca** invoque `.Free` ou tente liberar manualmente variáveis do tipo interface.
*   Evite referências cíclicas entre objetos gerenciados por interfaces (use a diretiva `[weak]` ou remova a referência manualmente ao destruir o objeto base).

---

## 3. Preferência por Records (Value Objects e RAII)
*   Para estruturas de dados simples, DTOs (Data Transfer Objects) ou objetos de valor imutáveis, dê preferência ao uso de `record` em vez de `class`.
*   Os `records` são alocados na *stack* e desalocados automaticamente quando saem de escopo, eliminando a necessidade de blocos `try..finally` e simplificando a gestão de ciclo de vida.

---

## 4. Construtores e Destrutores
*   **Construtores**: Todo construtor deve invocar `inherited;` (ou `inherited Create;`) na primeira linha ou onde for adequado para a inicialização da classe base.
*   **Destrutores**: Todo destrutor de classe personalizada deve obrigatoriamente sobrescrever `TObject.Destroy` usando a diretiva `override;` e invocar `inherited;` (ou `inherited Destroy;`) como sua última instrução.
```pascal
constructor TMyService.Create;
begin
  inherited Create;
  // inicializações da classe filha
end;

destructor TMyService.Destroy;
begin
  // liberação de recursos da classe filha
  inherited Destroy;
end;
```
