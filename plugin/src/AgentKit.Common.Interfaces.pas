unit AgentKit.Common.Interfaces;

interface

uses
  System.Classes, System.SysUtils;

type
  TProjectInitConfig = record
    ProjectKey: string;
    ProjectName: string;
    ProjectVersion: string;
    SonarServerUrl: string;
    SonarToken: string;
    ConfigureSonar: Boolean;
    CreateProjectOnServer: Boolean;
    ProjectPath: string;
  end;

  IAgentKitNetClient = interface
    ['{6E71994D-2CE4-4E57-BF68-BE6FE0D3C9D5}']
    function DownloadTemplate(const AFileName: string; out AContent: string): Boolean;
    function CreateSonarProject(const AServerUrl, AToken, AProjectKey, AProjectName: string; out AErrorMsg: string): Boolean;
  end;

  IAgentKitFileSystem = interface
    ['{8A9598CA-0C9A-40C6-91D0-128BF5EEF568}']
    function DirectoryExists(const ADirectory: string): Boolean;
    function CreateDir(const ADirectory: string): Boolean;
    function FileExists(const AFileName: string): Boolean;
    procedure WriteAllText(const AFileName, AContent: string);
    function ReadAllText(const AFileName: string): string;
  end;

  IAgentKitInitService = interface
    ['{B8A6133F-1349-4FFD-BC63-6EFBE1651B6A}']
    function InitializeProject(const AConfig: TProjectInitConfig; out AWarnings: string): Boolean;
  end;

implementation

end.
