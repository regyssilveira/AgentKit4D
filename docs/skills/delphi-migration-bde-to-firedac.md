# Manual de Migração BDE para FireDAC no Delphi

Este manual apresenta as diretrizes técnicas e o passo a passo prático para a migração e modernização de bases de código Delphi baseadas no mecanismo legado Borland Database Engine (BDE) para o framework de alto desempenho **FireDAC**.

---

## 1. Automatização da Tradução (reFind.exe)
O RAD Studio fornece um utilitário oficial baseado em linha de comando chamado **`reFind.exe`** (localizado no diretório `bin` da instalação do Delphi). Ele processa arquivos fonte `.pas` e de tela `.dfm` aplicando mapeamentos de termos e expressões regulares para traduzir componentes obsoletos automaticamente.

### Linha de Comando Recomendada
No console do Windows, execute o seguinte comando a partir da pasta raiz do seu projeto para iniciar a migração recursiva:

```cmd
"C:\Program Files (x86)\Embarcadero\Studio\<VERSAO>\bin\reFind.exe" /s /d:*.pas /d:*.dfm "C:\Users\Public\Documents\Embarcadero\Studio\<VERSAO>\Samples\Object Pascal\Database\FireDAC\Tool\reFind\BDE2FDMigration\FireDAC_Migrate_BDE.txt"
```
*(Substitua `<VERSAO>` pela versão do Delphi em sua máquina, ex: `22.0` para o Delphi 11, `23.0` para o Delphi 12, ou `37.0` para o Delphi 13)*.

---

## 2. Equivalência de Componentes e Mapeamento

Ao refatorar manualmente ou validar o processamento do `reFind.exe`, substitua as classes do BDE pelas equivalentes no FireDAC:

| Componente Legado BDE | Componente Equivalente FireDAC |
| :--- | :--- |
| `TSession` | `TFDManager` |
| `TDatabase` | `TFDConnection` |
| `TTable` | `TFDTable` |
| `TQuery` | `TFDQuery` |
| `TStoredProc` | `TFDStoredProc` |
| `TUpdateSQL` | `TFDUpdateSQL` |
| `TBatchMove` | `TFDBatchMove` |
| `TParam` / `TParams` | `TFDParam` / `TFDParams` |
| `TBlobStream` | `TFDBlobStream` |
| `EDBEngineError` | `EFDDBEngineException` |

---

## 3. Ajustes de Propriedades e Métodos
*   **DatabaseName**: Substitua pelo nome da conexão correspondente no FireDAC. No FireDAC, os datasets apontam diretamente para a propriedade `Connection` (do tipo `TFDConnection`).
*   **RequestLive**: No BDE, definiu-se `RequestLive := True` para tornar uma query editável. No FireDAC, as consultas SQL são automaticamente atualizáveis por padrão; caso queira configurar explicitamente, use `UpdateOptions.RequestLive`.
*   **Transações**: O isolamento de transação do BDE `tiReadCommitted` é traduzido para `xiReadCommitted` (do tipo `TFDTxIsolation` em `FireDAC.Stan.Option`).
*   **Propriedades Obsoletas a Remover**: Remova as referências a `SessionName` e `PrivateDir`, pois o gerenciamento de sessões físicas não é mais necessário no modelo desacoplado do FireDAC.
