# Manual de Diretrizes de Qualidade Delphi (Help das Skills)

Bem-vindo ao centro de documentação de ajuda (**Help**) do **Delphi Agent Quality Kit (AgentKit4D)**. 

Este diretório contém os manuais de referência técnica para desenvolvedores humanos. Enquanto os arquivos `.agents/skills/*.md` são otimizados para leitura por IAs de codificação, as páginas abaixo foram escritas para guiar você sobre como aplicar, de forma correta e idiomática, os padrões de engenharia e qualidade de código em seus projetos Delphi.

---

## 📚 Índice de Skills e Manuais de Referência

Abaixo está a lista completa das 15 skills de qualidade integradas ao kit. Clique nos links para acessar o manual detalhado de cada diretriz:

| Código | Skill de Qualidade | Propósito / Área de Foco | Manual de Ajuda |
| :---: | :--- | :--- | :--- |
| **01** | **SOLID & Clean Code** | Padrões de nomenclatura, arquitetura limpa e responsabilidade única. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-clean-code-solid.md)** |
| **02** | **Gestão de Memória** | Prevenção de memory leaks, try..finally, records e gerenciamento ARC. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-memory-management.md)** |
| **03** | **TDD & Qualidade** | Ciclos de testes unitários DUnitX e fluxo de correção de bugs. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-tdd-and-quality.md)** |
| **04** | **Compilação Multiplataforma** | Automação de compilação Win32/Win64, CLI e geração de cobertura. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-multitarget-compilation.md)** |
| **05** | **SonarQube & DelphiLint** | Conformidade com análise estática e tratamento de falsos positivos. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-sonar-lint-compliance.md)** |
| **06** | **Código Legado & Desacoplamento** | Refatoração incremental, desacoplamento de UI (Humble Object). | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-legacy-refactoring.md)** |
| **07** | **Desenvolvimento Guiado por IA** | Design baseado em contratos, validações prematuras, código sem placeholders. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-ai-contract-design.md)** |
| **08** | **Multithreading & Assincronismo** | Programação paralela (`TTask`/`IFuture`), thread-safety e proteção de recursos. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-multithreading-async.md)** |
| **09** | **Acesso a Dados com FireDAC** | Otimização de queries, pool de conexões, paginação e datasets em cache. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-firedac-optimization.md)** |
| **10** | **Integração Fiscal com ACBr** | Wrappers de componentes fiscais, isolamento de UI e suporte cross-platform. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-acbr-integration.md)** |
| **11** | **APIs REST com Horse** | Controllers, middlewares (Johnson, CORS, Exception) e rotas REST. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-rest-apis-horse.md)** |
| **12** | **Dext Framework** | APIs minimalistas, ORM, injeção de dependências e testes em Dext. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-dext-framework.md)** |
| **13** | **Migração BDE para FireDAC** | Mapeamento de componentes BDE legados, properties e script reFind. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-migration-bde-to-firedac.md)** |
| **14** | **Migração dbExpress para FireDAC** | Mapeamento de datasets DBX, transações de compatibilidade e reFind. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-migration-dbx-to-firedac.md)** |
| **15** | **Web Stencils (Template Engine)** | Renderização HTML dinâmica, `@foreach`, herança de layouts e HTMX. | **[Acessar Manual](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-webstencils-templates.md)** |

---

## 🛠️ Como Utilizar este Help

1. **Consulta Preventiva**: Antes de iniciar o desenvolvimento de uma nova funcionalidade (ex: criar um serviço de dados, escrever testes unitários ou criar um endpoint REST), consulte a skill correspondente no índice acima para adotar o padrão arquitetural homologado.
2. **Correção de Violações**: Se o SonarQube ou o DelphiLint acusarem violações de confiabilidade ou code smells, abra o manual **[05. SonarQube & DelphiLint](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-sonar-lint-compliance.md)** para ver como corrigir ou suprimir falsos positivos do parser Delphi.
3. **Migração de Bases Legadas**: Ao iniciar a modernização de sistemas legados, consulte os manuais **[13. Migração BDE](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-migration-bde-to-firedac.md)** e **[14. Migração dbExpress](file:///d:/Projetos/AgentKit4D/docs/skills/delphi-migration-dbx-to-firedac.md)** para automatizar a tradução com expressões regulares.
