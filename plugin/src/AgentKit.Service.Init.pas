unit AgentKit.Service.Init;

interface

uses
  System.Classes, System.SysUtils, AgentKit.Common.Interfaces;

type
  TLogCallback = reference to procedure(const AMsg: string);

  TAgentKitInitService = class(TInterfacedObject, IAgentKitInitService)
  private
    FNetClient: IAgentKitNetClient;
    FFileSystem: IAgentKitFileSystem;
    FOnLog: TLogCallback;
    procedure Log(const AMsg: string);
    function LoadTemplateContent(const AFileName, AResourceName: string; out AContent: string; out AWarnings: string): Boolean;
    function ProcessSonarProperties(const ATemplateContent: string; const AConfig: TProjectInitConfig): string;
    procedure UpdateGitIgnore(const AProjectPath: string; out AWarnings: string);
  public
    constructor Create(const ANetClient: IAgentKitNetClient;
      const AFileSystem: IAgentKitFileSystem;
      const AOnLog: TLogCallback = nil);

    // Implementação de IAgentKitInitService
    function InitializeProject(const AConfig: TProjectInitConfig; out AWarnings: string): Boolean;
  end;

  TAgentKitRealFileSystem = class(TInterfacedObject, IAgentKitFileSystem)
  public
    function DirectoryExists(const ADirectory: string): Boolean;
    function CreateDir(const ADirectory: string): Boolean;
    function FileExists(const AFileName: string): Boolean;
    procedure WriteAllText(const AFileName, AContent: string);
    function ReadAllText(const AFileName: string): string;
  end;

implementation

uses
  Winapi.Windows, System.IOUtils;

type
  TSkillDefinition = record
    SkillName: string;
    ResourceName: string;
    GitHubPath: string;
  end;

{ TAgentKitInitService }

constructor TAgentKitInitService.Create(const ANetClient: IAgentKitNetClient;
  const AFileSystem: IAgentKitFileSystem; const AOnLog: TLogCallback);
begin
  inherited Create;
  FNetClient := ANetClient;
  FFileSystem := AFileSystem;
  FOnLog := AOnLog;
end;

procedure TAgentKitInitService.Log(const AMsg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg);
end;

function TAgentKitInitService.LoadTemplateContent(const AFileName, AResourceName: string; out AContent: string; out AWarnings: string): Boolean;
begin
  AWarnings := '';
  AContent := '';
  
  if FNetClient.DownloadTemplate(AFileName, AContent) then
  begin
    Log('Template baixado com sucesso do GitHub: ' + AFileName);
    Exit(True);
  end;

  Log('[AVISO] Nao foi possivel obter o template ' + AFileName + ' do GitHub. Utilizando copia local de fallback.');
  AWarnings := '[AVISO] Nao foi possivel obter os templates atualizados do GitHub. Utilizando templates locais de fallback.' + #13#10;
  
  try
    var LStream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
    try
      var LStrings := TStringList.Create;
      try
        LStrings.LoadFromStream(LStream, TEncoding.UTF8);
        AContent := LStrings.Text;
      finally
        LStrings.Free;
      end;
    finally
      LStream.Free;
    end;
  except
    on E: Exception do
    begin
      Log('[ERRO] Falha critica ao carregar o recurso interno de fallback ' + AResourceName + ': ' + E.Message);
      AContent := '';
    end;
  end;
  
  Result := not AContent.IsEmpty;
end;

function TAgentKitInitService.ProcessSonarProperties(const ATemplateContent: string; const AConfig: TProjectInitConfig): string;
begin
  var LStrings := TStringList.Create;
  try
    LStrings.Text := ATemplateContent;
    
    LStrings.Values['sonar.projectKey'] := AConfig.ProjectKey;
    LStrings.Values['sonar.projectName'] := AConfig.ProjectName;
    LStrings.Values['sonar.projectVersion'] := AConfig.ProjectVersion;
    
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

procedure TAgentKitInitService.UpdateGitIgnore(const AProjectPath: string; out AWarnings: string);
begin
  AWarnings := '';
  var LGitIgnorePath := IncludeTrailingPathDelimiter(AProjectPath) + '.gitignore';
  var LRule := 'sonar_token.txt';
  var LGitIgnoreContent := '';
  
  if FFileSystem.FileExists(LGitIgnorePath) then
    LGitIgnoreContent := FFileSystem.ReadAllText(LGitIgnorePath);
    
  var LStrings := TStringList.Create;
  try
    LStrings.Text := LGitIgnoreContent;
    
    var LAlreadyExists := False;
    for var i := 0 to LStrings.Count - 1 do
    begin
      if LStrings[i].Trim = LRule then
      begin
        LAlreadyExists := True;
        Break;
      end;
    end;
    
    if not LAlreadyExists then
    begin
      var LBuilder := TStringBuilder.Create;
      try
        LBuilder.Append(LGitIgnoreContent);
        if (LGitIgnoreContent.Length > 0) and (not LGitIgnoreContent.EndsWith(#10)) and (not LGitIgnoreContent.EndsWith(#13)) then
          LBuilder.AppendLine;
        LBuilder.Append(LRule);
        
        FFileSystem.WriteAllText(LGitIgnorePath, LBuilder.ToString);
        Log('Arquivo .gitignore atualizado com a exclusao de sonar_token.txt.');
      finally
        LBuilder.Free;
      end;
    end;
  finally
    LStrings.Free;
  end;
end;

function TAgentKitInitService.InitializeProject(const AConfig: TProjectInitConfig; out AWarnings: string): Boolean;
var
  LWarningBuilder: TStringBuilder;
  LAgentsDir: string;
  LAgentsContent: string;
  LLocalWarnings: string;
  LAgentsFile: string;
  LSkillsDir: string;
  LSkills: array[0..11] of TSkillDefinition;
  LSkill: TSkillDefinition;
  LTargetDir: string;
  LSkillContent: string;
  LSkillWarnings: string;
  LSkillFile: string;
  LCreateError: string;
  LPropertiesContent: string;
  LProcessedProperties: string;
  LPropertiesFile: string;
  LRunSonarContent: string;
  LRunSonarFile: string;
  LScriptsDir: string;
  LCoverageContent: string;
  LCoverageFile: string;
  LTokenFile: string;
begin
  AWarnings := '';
  LWarningBuilder := TStringBuilder.Create;
  try
    try
      Log('Inicializando projeto em: ' + AConfig.ProjectPath);
      
      if not FFileSystem.DirectoryExists(AConfig.ProjectPath) then
      begin
        if not FFileSystem.CreateDir(AConfig.ProjectPath) then
          raise Exception.Create('Nao foi possivel criar o diretorio do projeto.');
      end;
      
      LAgentsDir := IncludeTrailingPathDelimiter(AConfig.ProjectPath) + '.agents';
      if not FFileSystem.DirectoryExists(LAgentsDir) then
      begin
        if not FFileSystem.CreateDir(LAgentsDir) then
          raise Exception.Create('Nao foi possivel criar a pasta .agents.');
      end;
      
      LAgentsContent := '';
      LLocalWarnings := '';
      if not LoadTemplateContent('.agents/AGENTS.md', 'AGENTS_TEMPLATE', LAgentsContent, LLocalWarnings) then
        raise Exception.Create('Falha ao carregar o template AGENTS.md.');
        
      if not LLocalWarnings.IsEmpty then
        LWarningBuilder.Append(LLocalWarnings);
        
      LAgentsFile := IncludeTrailingPathDelimiter(LAgentsDir) + 'AGENTS.md';
      FFileSystem.WriteAllText(LAgentsFile, LAgentsContent);
      Log('Arquivo AGENTS.md criado.');

      // Criar a pasta .agents/skills
      LSkillsDir := IncludeTrailingPathDelimiter(LAgentsDir) + 'skills';
      if not FFileSystem.DirectoryExists(LSkillsDir) then
      begin
        if not FFileSystem.CreateDir(LSkillsDir) then
          raise Exception.Create('Nao foi possivel criar a pasta .agents/skills.');
      end;

      // Definir as skills
      LSkills[0].SkillName := 'delphi-clean-code-solid';
      LSkills[0].ResourceName := 'SKILL_CC_SOLID';
      LSkills[0].GitHubPath := '.agents/skills/delphi-clean-code-solid/SKILL.md';

      LSkills[1].SkillName := 'delphi-memory-management';
      LSkills[1].ResourceName := 'SKILL_MEMORY';
      LSkills[1].GitHubPath := '.agents/skills/delphi-memory-management/SKILL.md';

      LSkills[2].SkillName := 'delphi-tdd-and-quality';
      LSkills[2].ResourceName := 'SKILL_TDD_QUALITY';
      LSkills[2].GitHubPath := '.agents/skills/delphi-tdd-and-quality/SKILL.md';

      LSkills[3].SkillName := 'delphi-sonar-lint-compliance';
      LSkills[3].ResourceName := 'SKILL_SONAR_LINT';
      LSkills[3].GitHubPath := '.agents/skills/delphi-sonar-lint-compliance/SKILL.md';

      LSkills[4].SkillName := 'delphi-legacy-refactoring';
      LSkills[4].ResourceName := 'SKILL_LEGACY_REF';
      LSkills[4].GitHubPath := '.agents/skills/delphi-legacy-refactoring/SKILL.md';

      LSkills[5].SkillName := 'delphi-ai-contract-design';
      LSkills[5].ResourceName := 'SKILL_AI_CONTRACT';
      LSkills[5].GitHubPath := '.agents/skills/delphi-ai-contract-design/SKILL.md';

      LSkills[6].SkillName := 'delphi-multitarget-compilation';
      LSkills[6].ResourceName := 'SKILL_COMPILATION';
      LSkills[6].GitHubPath := '.agents/skills/delphi-multitarget-compilation/SKILL.md';

      LSkills[7].SkillName := 'delphi-multithreading-async';
      LSkills[7].ResourceName := 'SKILL_THREADING';
      LSkills[7].GitHubPath := '.agents/skills/delphi-multithreading-async/SKILL.md';

      LSkills[8].SkillName := 'delphi-firedac-optimization';
      LSkills[8].ResourceName := 'SKILL_FIREDAC';
      LSkills[8].GitHubPath := '.agents/skills/delphi-firedac-optimization/SKILL.md';

      LSkills[9].SkillName := 'delphi-acbr-integration';
      LSkills[9].ResourceName := 'SKILL_ACBR';
      LSkills[9].GitHubPath := '.agents/skills/delphi-acbr-integration/SKILL.md';

      LSkills[10].SkillName := 'delphi-rest-apis-horse';
      LSkills[10].ResourceName := 'SKILL_HORSE';
      LSkills[10].GitHubPath := '.agents/skills/delphi-rest-apis-horse/SKILL.md';

      LSkills[11].SkillName := 'delphi-dext-framework';
      LSkills[11].ResourceName := 'SKILL_DEXT';
      LSkills[11].GitHubPath := '.agents/skills/delphi-dext-framework/SKILL.md';

      // Inicializar cada skill
      for LSkill in LSkills do
      begin
        LTargetDir := IncludeTrailingPathDelimiter(LSkillsDir) + LSkill.SkillName;
        if not FFileSystem.DirectoryExists(LTargetDir) then
        begin
          if not FFileSystem.CreateDir(LTargetDir) then
            raise Exception.Create('Nao foi possivel criar o diretorio da skill: ' + LSkill.SkillName);
        end;

        LSkillContent := '';
        LSkillWarnings := '';
        if not LoadTemplateContent(LSkill.GitHubPath, LSkill.ResourceName, LSkillContent, LSkillWarnings) then
          raise Exception.Create('Falha ao carregar o template da skill: ' + LSkill.SkillName);

        if not LSkillWarnings.IsEmpty then
          LWarningBuilder.Append(LSkillWarnings);

        LSkillFile := IncludeTrailingPathDelimiter(LTargetDir) + 'SKILL.md';
        FFileSystem.WriteAllText(LSkillFile, LSkillContent);
        Log('Skill ' + LSkill.SkillName + ' inicializada.');
      end;
      
      if AConfig.ConfigureSonar then
      begin
        if AConfig.CreateProjectOnServer and (not AConfig.SonarServerUrl.IsEmpty) and (not AConfig.SonarToken.IsEmpty) then
        begin
          Log('Tentando criar projeto no servidor SonarQube: ' + AConfig.SonarServerUrl);
          LCreateError := '';
          if not FNetClient.CreateSonarProject(AConfig.SonarServerUrl, AConfig.SonarToken, AConfig.ProjectKey, AConfig.ProjectName, LCreateError) then
          begin
            if LCreateError.Contains('already exists') then
            begin
              Log('Projeto ja existe no servidor SonarQube. Configurando arquivos locais...');
            end
            else
            begin
              Log('[AVISO] Falha ao criar projeto no SonarQube via API: ' + LCreateError);
              LWarningBuilder.AppendLine('[AVISO] Nao foi possivel criar o projeto automaticamente no servidor SonarQube. Erro: ' + LCreateError);
            end;
          end
          else
          begin
            Log('Projeto criado com sucesso no servidor SonarQube.');
          end;
        end;
        
        LPropertiesContent := '';
        if not LoadTemplateContent('sonar-project.properties.template', 'SONAR_PROPERTIES_TEMPLATE', LPropertiesContent, LLocalWarnings) then
          raise Exception.Create('Falha ao carregar o template sonar-project.properties.');
          
        if not LLocalWarnings.IsEmpty and (LWarningBuilder.ToString.IndexOf(LLocalWarnings) = -1) then
          LWarningBuilder.Append(LLocalWarnings);
          
        LProcessedProperties := ProcessSonarProperties(LPropertiesContent, AConfig);
        LPropertiesFile := IncludeTrailingPathDelimiter(AConfig.ProjectPath) + 'sonar-project.properties';
        FFileSystem.WriteAllText(LPropertiesFile, LProcessedProperties);
        Log('Arquivo sonar-project.properties criado.');
        
        LRunSonarContent := '';
        if not LoadTemplateContent('run_sonar.bat.template', 'RUN_SONAR_TEMPLATE', LRunSonarContent, LLocalWarnings) then
          raise Exception.Create('Falha ao carregar o template run_sonar.bat.');
          
        if not LLocalWarnings.IsEmpty and (LWarningBuilder.ToString.IndexOf(LLocalWarnings) = -1) then
          LWarningBuilder.Append(LLocalWarnings);
          
        LRunSonarFile := IncludeTrailingPathDelimiter(AConfig.ProjectPath) + 'run_sonar.bat';
        FFileSystem.WriteAllText(LRunSonarFile, LRunSonarContent);
        Log('Arquivo run_sonar.bat criado.');
        
        LScriptsDir := IncludeTrailingPathDelimiter(AConfig.ProjectPath) + 'scripts';
        if not FFileSystem.DirectoryExists(LScriptsDir) then
          FFileSystem.CreateDir(LScriptsDir);
          
        LCoverageContent := '';
        if not LoadTemplateContent('scripts/generate_coverage.ps1', 'COVERAGE_PS_TEMPLATE', LCoverageContent, LLocalWarnings) then
          raise Exception.Create('Falha ao carregar o template generate_coverage.ps1.');
          
        if not LLocalWarnings.IsEmpty and (LWarningBuilder.ToString.IndexOf(LLocalWarnings) = -1) then
          LWarningBuilder.Append(LLocalWarnings);
          
        LCoverageFile := IncludeTrailingPathDelimiter(LScriptsDir) + 'generate_coverage.ps1';
        FFileSystem.WriteAllText(LCoverageFile, LCoverageContent);
        Log('Arquivo generate_coverage.ps1 criado.');
        
        if not AConfig.SonarToken.IsEmpty then
        begin
          LTokenFile := IncludeTrailingPathDelimiter(AConfig.ProjectPath) + 'sonar_token.txt';
          FFileSystem.WriteAllText(LTokenFile, AConfig.SonarToken);
          Log('Arquivo sonar_token.txt criado localmente.');
        end;
        
        UpdateGitIgnore(AConfig.ProjectPath, LLocalWarnings);
      end;
      
      AWarnings := LWarningBuilder.ToString;
      Result := True;
    except
      on E: Exception do
      begin
        Log('[ERRO] Falha na inicializacao: ' + E.Message);
        raise;
      end;
    end;
  finally
    LWarningBuilder.Free;
  end;
end;

{ TAgentKitRealFileSystem }

function TAgentKitRealFileSystem.DirectoryExists(const ADirectory: string): Boolean;
begin
  Result := TDirectory.Exists(ADirectory);
end;

function TAgentKitRealFileSystem.CreateDir(const ADirectory: string): Boolean;
begin
  try
    TDirectory.CreateDirectory(ADirectory);
    Result := True;
  except
    Result := False;
  end;
end;

function TAgentKitRealFileSystem.FileExists(const AFileName: string): Boolean;
begin
  Result := TFile.Exists(AFileName);
end;

procedure TAgentKitRealFileSystem.WriteAllText(const AFileName, AContent: string);
begin
  TFile.WriteAllText(AFileName, AContent, TEncoding.UTF8);
end;

function TAgentKitRealFileSystem.ReadAllText(const AFileName: string): string;
begin
  Result := TFile.ReadAllText(AFileName, TEncoding.UTF8);
end;

end.
