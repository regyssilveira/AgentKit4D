---
name: delphi-firedac-optimization
description: Persistência e acesso a dados estável com FireDAC no Delphi. Configuração de conexão, transações, performance de queries e cache local.
---

# Persistência e Acesso a Dados com FireDAC no Delphi

Esta guia estabelece boas práticas e padrões para o uso seguro, performático e escalável do framework de persistência nativo do Delphi (FireDAC).

## 1. Pool de Conexões e Isolamento de Thread
O FireDAC suporta nativamente pooling de conexões para evitar a sobrecarga de abrir novas conexões físicas a cada requisição ou chamada de serviço.

*   **Configuração de Pool**: Configure as definições de conexão para utilizar o pool (`Pooled=True`, `Pool_MaximumItems=50`, etc.).
*   **Uma Conexão por Thread**: Ao realizar consultas em threads de segundo plano (ex: Workers, REST APIs), sempre crie ou obtenha uma nova instância de `TFDConnection` associada ao pool. **Nunca compartilhe conexões.**

---

## 2. Performance de Queries (Fetch Options)
Ajuste os parâmetros de busca para otimizar o consumo de memória do servidor e do cliente:

*   **Fetch Completo (`fmAll`)**: Útil para carregar tabelas de cadastro pequenas que precisam ser mantidas em memória rápida.
*   **Fetch Sob Demanda (`fmOnDemand` / `RowSize`)**: Para relatórios ou tabelas volumosas, configure `FetchOptions.Mode := fmOnDemand` e regule o `FetchOptions.RowsetSize` (ex: 50 a 150 registros por lote de rede). Isso impede o estouro de memória no cliente.
*   **Modo Read-Only (`ReadOnly`)**: Se a consulta for apenas para exibição, configure `ReadOnly := True` no DataSet. Isso desativa o cache de atualização interna do FireDAC, economizando processamento local.

---

## 3. Uso do TFDMemTable (Dataset em Memória)
Prefira o uso de `TFDMemTable` para trafegar dados entre as camadas do sistema (Infraestrutura -> Aplicação -> Apresentação).

*   **Desacoplamento de Banco**: Não passe instâncias ativas de `TFDQuery` com conexões físicas para a UI. Em vez disso, copie os dados da query para um `TFDMemTable` desconectado (usando `LMemTable.CopyDataSet(LQuery, [coStructure, coData])`) e envie o `TFDMemTable` para a visualização.
*   **Manipulação Sem Lock**: Como os dados ficam totalmente na memória RAM da aplicação, as operações de filtro, ordenação e pesquisa no `TFDMemTable` não impactam o servidor de banco de dados.

---

## 4. Gestão Segura de Transações
Sempre controle as transações explicitamente através do objeto `TFDTransaction`, envolvendo os blocos de persistência lógica em tratamento de exceções:

```pascal
LTransaction.StartTransaction;
try
  // Execução de múltiplos inserts/updates
  LQuery1.ExecSQL;
  LQuery2.ExecSQL;
  
  LTransaction.Commit;
except
  on E: Exception do
  begin
    LTransaction.Rollback;
    raise EDatabaseException.Create('Falha ao gravar no banco: ' + E.Message);
  end;
end;
```

---

## 5. Convenções de Nomenclatura para Componentes FireDAC

Utilize os seguintes prefixos padronizados ao declarar variáveis ou componentes em DataModules:

| Classe Componente | Descrição | Prefixo Recomendado | Exemplo |
| :--- | :--- | :--- | :--- |
| `TFDConnection` | Conexão física ao banco de dados | `con` | `conMain` |
| `TFDTransaction` | Controle transacional | `trn` | `trnMain` |
| `TFDQuery` | Execução de instruções SQL | `qry` | `qryGetCustomers` |
| `TFDStoredProc` | Execução de Stored Procedures | `prc` | `prcCalculateTax` |
| `TFDMemTable` | Tabela local em memória rápida | `mt` | `mtCustomers` |
| `TFDTable` | Acesso direto a tabela física | `tbl` | `tblProducts` |
