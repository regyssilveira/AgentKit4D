unit AgentKit.Mocks.FileSystem;

interface

uses
  System.SysUtils, System.Generics.Collections, AgentKit.Common.Interfaces;

type
  TAgentKitMockFileSystem = class(TInterfacedObject, IAgentKitFileSystem)
  private
    FFiles: TDictionary<string, string>;
    FDirectories: TList<string>;
    function NormalizePath(const APath: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    // Implementação de IAgentKitFileSystem
    function DirectoryExists(const ADirectory: string): Boolean;
    function CreateDir(const ADirectory: string): Boolean;
    function FileExists(const AFileName: string): Boolean;
    procedure WriteAllText(const AFileName, AContent: string);
    function ReadAllText(const AFileName: string): string;

    // Métodos utilitários de asserção para os testes unitários
    property Files: TDictionary<string, string> read FFiles;
    property Directories: TList<string> read FDirectories;
  end;

implementation

{ TAgentKitMockFileSystem }

constructor TAgentKitMockFileSystem.Create;
begin
  inherited Create;
  FFiles := TDictionary<string, string>.Create;
  FDirectories := TList<string>.Create;
end;

destructor TAgentKitMockFileSystem.Destroy;
begin
  FFiles.Free;
  FDirectories.Free;
  inherited Destroy;
end;

function TAgentKitMockFileSystem.NormalizePath(const APath: string): string;
begin
  Result := APath.Replace('/', '\');
end;

function TAgentKitMockFileSystem.DirectoryExists(const ADirectory: string): Boolean;
var
  LDir: string;
begin
  LDir := NormalizePath(ADirectory);
  Result := FDirectories.Contains(LDir);
end;

function TAgentKitMockFileSystem.CreateDir(const ADirectory: string): Boolean;
var
  LDir: string;
begin
  LDir := NormalizePath(ADirectory);
  if not FDirectories.Contains(LDir) then
    FDirectories.Add(LDir);
  Result := True;
end;

function TAgentKitMockFileSystem.FileExists(const AFileName: string): Boolean;
var
  LFile: string;
begin
  LFile := NormalizePath(AFileName);
  Result := FFiles.ContainsKey(LFile);
end;

procedure TAgentKitMockFileSystem.WriteAllText(const AFileName, AContent: string);
var
  LFile: string;
begin
  LFile := NormalizePath(AFileName);
  FFiles.AddOrSetValue(LFile, AContent);
end;

function TAgentKitMockFileSystem.ReadAllText(const AFileName: string): string;
var
  LFile: string;
begin
  LFile := NormalizePath(AFileName);
  if FFiles.ContainsKey(LFile) then
    Result := FFiles.Items[LFile]
  else
    Result := '';
end;

end.
