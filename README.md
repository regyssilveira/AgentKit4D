# Delphi Agent Quality Kit (AgentKit4D)

Uma solução completa contendo diretrizes, automações e modelos de configuração para estabelecer um pipeline de qualidade de código estrito e alinhado aos padrões do **SonarQube (DelphiSonar / DelphiLint)** em projetos Delphi.

Este kit foi projetado para unificar os padrões de desenvolvimento entre desenvolvedores humanos e **agentes de IA (coding assistants)**, garantindo conformidade com Clean Code, SOLID, e gestão de memória.

---

## 🎯 O que é este projeto?

A adoção de análises estáticas robustas no ecossistema Delphi frequentemente esbarra em desafios como:
*   **Falsos positivos frequentes**: Parsers de ferramentas analíticas geram alertas incorretos para novos recursos da linguagem, como declarações de variáveis inline ou regras de localização de imports no `uses` (`ImportSpecificity`).
*   **Gestão de Cobertura**: A compilação e mapeamento de testes unitários para a geração de relatórios de cobertura em formato compatível com o SonarQube exigem scripts de normalização customizados.
*   **Falta de contexto para IAs**: Agentes de IA precisam de guias específicos da linguagem e do projeto para evitar a sugestão de construções obsoletas, arcaicas ou propensas a vazamentos de memória (*memory leaks*).

O **Delphi Agent Quality Kit** mitiga esses problemas oferecendo modelos pré-configurados e scripts automatizados de apoio. Ao implantar este kit em um novo repositório, você estabelece de forma imediata um ambiente de desenvolvimento padronizado, automatizado e livre de ruídos na análise estática.

---

## 📦 Estrutura do Kit (Componentes)

| Componente | Descrição |
| :--- | :--- |
| **[sonar-project.properties.template](file:///d:/Projetos/AgentKit4D/sonar-project.properties.template)** | Modelo pronto contendo configurações otimizadas para o SonarQube, supressão de falsos positivos do parser Delphi (variáveis inline/imports) e regras de exclusão de duplicações (CPD) para stubs e telas visuais (`.dfm`). |
| **[AGENTS.md.template](file:///d:/Projetos/AgentKit4D/AGENTS.md.template)** | Diretrizes arquiteturais de Clean Code, SOLID, TDD e boas práticas específicas de Delphi estruturadas para serem consumidas e seguidas por IAs de desenvolvimento. |
| **[run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template)** | Script em lote auxiliar que facilita a execução local da análise estática do SonarQube com gestão segura do token de acesso. |
| **[generate_coverage.ps1.template](file:///d:/Projetos/AgentKit4D/generate_coverage.ps1.template)** | Script PowerShell para calcular, normalizar e gerar o relatório XML de *Generic Coverage* para o SonarQube a partir dos testes executados. |

---

## 🛠️ Como Utilizar em um Novo Projeto

Siga os passos abaixo para implantar a qualidade de código em seu novo projeto Delphi:

### Passo 1: Configurar a Análise Estática (SonarQube)
1. Copie o arquivo [sonar-project.properties.template](file:///d:/Projetos/AgentKit4D/sonar-project.properties.template) para a **raiz** do seu novo projeto Delphi.
2. Renomeie o arquivo para: **`sonar-project.properties`**.
3. Abra o arquivo e configure os metadados iniciais do seu projeto:
   ```properties
   sonar.projectKey=MeuProjeto
   sonar.projectName=Meu Projeto
   sonar.projectVersion=1.0.0
   ```
4. Ajuste os diretórios de fontes (`sonar.sources`) e testes (`sonar.tests`) no arquivo de propriedades caso as pastas do seu projeto não sigam os diretórios padrão `src` e `tests`.

### Passo 2: Configurar o Agent de IA (Antigravity e outros)
Para garantir que as IAs sigam o mesmo padrão de código do repositório:
1. Na **raiz** do seu novo projeto, crie um diretório chamado: **`.agents`**.
2. Copie o arquivo [AGENTS.md.template](file:///d:/Projetos/AgentKit4D/AGENTS.md.template) para dentro dessa pasta.
3. Renomeie o arquivo para: **`AGENTS.md`**.
4. Qualquer assistente de IA que interagir com o seu repositório passará a ler e seguir de forma automática as diretrizes DelphiSonar documentadas nele.

### Passo 3: Executar a Análise Local com Cobertura
1. Crie uma pasta chamada **`scripts`** (ou `scratch`) na raiz do seu projeto.
2. Copie o arquivo [generate_coverage.ps1.template](file:///d:/Projetos/AgentKit4D/generate_coverage.ps1.template) para dentro dela e renomeie-o para **`generate_coverage.ps1`**.
3. Execute o script via PowerShell para mapear as linhas executáveis do seu projeto e gerar o relatório XML estruturado.
4. Copie o arquivo [run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template) para a **raiz** do seu projeto e renomeie-o para **`run_sonar.bat`**.
5. Execute o script `run_sonar.bat`. Na primeira execução, ele solicitará o token do SonarQube e oferecerá salvá-lo no arquivo de configuração local **`sonar_token.txt`** para evitar digitações futuras.

> [!IMPORTANT]
> **Adicione o arquivo `sonar_token.txt` ao seu `.gitignore`!**
> É fundamental garantir que este arquivo com credenciais locais nunca seja comitado para repositórios públicos.

---

## 🌟 Benefícios e Boas Práticas Integradas
*   **Ciclo de TDD Blindado**: Padrões estabelecidos para correção orientada a testes (*TDD para bugs*) e desenvolvimento de novas funcionalidades.
*   **Gerenciamento Inteligente de Falsos Positivos**: Silencia alertas desnecessários de estilo e formatação ao focar no que realmente importa para a segurança do software.
*   **Gestão Anti-Vazamento**: Padronização de destruidores (`override`), construtores (`inherited`) e uso de `try..finally` e `FreeAndNil` de forma limpa.
*   **Compilação Win32 e Win64**: Dicas e contornos práticos para evitar falhas clássicas de compiladores, como inferências incorretas do DUnitX em 64 bits e encerramento indesejado de scripts `.bat` sequenciais.
