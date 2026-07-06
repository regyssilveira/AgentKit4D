# Manual de Acesso a Dados com FireDAC no Delphi

Este manual descreve as diretrizes para otimização de banco de dados utilizando o FireDAC, abrangendo pooling de conexões, controle de transações, paginação de consultas e desacoplamento de datasets.

---

## 1. Configuração Otimizada de Conexão e Pooling
Para obter a máxima performance e estabilidade do acesso a dados, principalmente em ambientes concorrentes (APIs Web ou multithread), ative e configure o pool de conexões nativo do FireDAC:

*   **Ativação do Pool**: Defina o parâmetro `Pooled=True` nas definições de conexão da sua aplicação.
*   **Limites de Conexão**: Configure as propriedades `POOL_MaximumItems` (limite máximo de conexões físicas no pool) e `POOL_CleanupTimeout` (tempo para liberar conexões ociosas).
*   **Controle de Ciclo**: Nunca mantenha conexões físicas abertas de forma persistente. Abra, execute a operação de banco de forma rápida, e libere o componente imediatamente para que a conexão retorne ao pool de forma transparente.

---

## 2. Paginação de Consultas (Performance)
Evite carregar dezenas de milhares de registros na memória do cliente de uma única vez. Implemente a paginação de registros tanto a nível de banco de dados (usando limit/offset nas queries) quanto a nível de cursor do FireDAC:

*   **FetchOptions**: Ajuste as propriedades de Cursor do FireDAC na sua `TFDQuery`:
    *   `FetchOptions.Mode := fmOnDemand;` (Carrega os registros sob demanda).
    *   `FetchOptions.RowsetSize := 50;` (Define o tamanho da página de registros por requisição ao banco).

---

## 3. Gestão e Controle de Transações
Transações devem possuir escopos estritamente delimitados e curtos para evitar bloqueios (*locks*) e problemas de concorrência na base de dados.

*   Use blocos `try..except` para realizar o commit ou rollback de forma segura:

```delphi
procedure TOrderRepository.InsertOrder(const AOrder: TOrder);
begin
  FDConnection1.StartTransaction;
  try
    // Inserir Cabeçalho do Pedido
    ExecInsertOrderHeader(AOrder);
    
    // Inserir Itens do Pedido
    ExecInsertOrderItems(AOrder);
    
    FDConnection1.Commit;
  except
    on E: Exception do
    begin
      FDConnection1.Rollback;
      raise Exception.Create('Erro ao gravar pedido: ' + E.Message);
    end;
  end;
end;
```

---

## 4. Desacoplamento com `TFDMemTable` (Cache Local)
Evite trafegar datasets conectados diretamente aos componentes físicos de conexão entre as camadas de controle/visualização da sua aplicação. Use **`TFDMemTable`** como uma tabela em memória isolada e desacoplada:

*   **Vantagem**: A unit de negócio ou visualização recebe apenas os dados copiados na memória (`TFDMemTable`), sem nenhuma dependência física da conexão de banco de dados aberta. Isso simplifica testes de unidade e o isolamento de camadas.
*   **Cópia de Dados**:
    ```delphi
    // Copiar estrutura e dados de uma query para uma MemTable
    FDMemTable1.Data := FDQuery1.Data;
    ```
