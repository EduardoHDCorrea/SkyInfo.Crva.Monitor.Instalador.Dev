#define NomeDaAplicacao "SkyInfo.Crva.Detran.Digitaliza.Monitor"
#define VersaoDaAplicacao "1.0.1.52"
#define NomeDaEmpresa "Sky Informática Ltda."
#define UrlDaAplicacao "https://github.com/SkyInformatica/CRVA.Monitor.Instalacao"
#define NomeDoExecutavelDaAplicacao "SkyInfo.Crva.Detran.Digitaliza.Monitor.exe"
#define CaminhoDaFonteDaAplicacao "D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\src"
#define public Dependency_Path_NetCoreCheck "D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\Dependências\NetCoreCheck\"

#include "D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\Dependências\CodeDependencies.iss"
#include "D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\Dependências\UtilitáriosDeAdministraçãoWindows.iss"
#include "D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\Dependências\Utilitários.iss"

[Setup]
AppId={{9907afbb-90dd-40c4-837b-d0110e845d5d}}
AppName={#NomeDaAplicacao}
AppVersion={#VersaoDaAplicacao}
AppPublisher={#NomeDaEmpresa}
AppPublisherURL={#UrlDaAplicacao}
AppSupportURL={#UrlDaAplicacao}
AppUpdatesURL={#UrlDaAplicacao}
DefaultDirName={autopf}\{#NomeDaAplicacao}
ArchitecturesInstallIn64BitMode=win64
DefaultGroupName={#NomeDaAplicacao}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputBaseFilename={#NomeDaAplicacao}.Instalador
Compression=lzma
SolidCompression=yes
OutputDir=D:\SkyInfo.Crva.Monitor.Instalador.Dev\SkyInfo.Crva.Monitor.Instalador.Dev\Instalador
WizardStyle=modern
CloseApplications=force
MergeDuplicateFiles=no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

; --> Arquivos x64
[Files]
Source: "{#CaminhoDaFonteDaAplicacao}\x64\{#NomeDoExecutavelDaAplicacao}"; DestDir: "{app}"; Flags: replacesameversion; Check: Is64BitInstallMode;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\appsettings.json"; DestDir: "{app}"; Flags: replacesameversion; Check: Is64BitInstallMode;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\*"; DestDir: "{app}"; Excludes: "appsettings.Development.json"; Flags: recursesubdirs createallsubdirs replacesameversion; Check: Is64BitInstallMode;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\Armazenamento\Registros.db"; DestDir: "{app}"; Flags: noencryption nocompression; Check: Is64BitInstallMode;

; --> Arquivos x86
[Files]
Source: "{#CaminhoDaFonteDaAplicacao}\x86\{#NomeDoExecutavelDaAplicacao}"; DestDir: "{app}"; Flags: replacesameversion; Check: InstalacaoEm32Bits;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\appsettings.json"; DestDir: "{app}"; Flags: replacesameversion; Check: InstalacaoEm32Bits;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\*"; DestDir: "{app}"; Excludes: "appsettings.Development.json"; Flags: recursesubdirs createallsubdirs replacesameversion; Check: InstalacaoEm32Bits;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\Armazenamento\Registros.db"; DestDir: "{app}"; Flags: noencryption nocompression; Check: InstalacaoEm32Bits;

[UninstallDelete]
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x64\Chave.txt"; Check: Is64BitInstallMode;
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x86\Chave.txt"; Check: InstalacaoEm32Bits;

[InstallDelete]
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x64\Chave.txt"; Check: Is64BitInstallMode;
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x86\Chave.txt"; Check: InstalacaoEm32Bits;
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x86\appsettings.json"; Check: Is64BitInstallMode;
Type: files; Name: "{#CaminhoDaFonteDaAplicacao}\x64\appsettings.json"; Check: InstalacaoEm32Bits;

[Code]
const Debug = True;

var
  PaginaInicial: TOutputMsgWizardPage;
  PaginaDeSelecaoDoDiretorioDeDocumentos: TInputDirWizardPage;
  PaginaDeSelecaoDoDiretorioDeDocumentosEnviados: TInputDirWizardPage;
  PaginaDeCredenciaisDoUsuario: TInputQueryWizardPage;
  PaginaDeSelecaoDaOrganizacao: TInputOptionWizardPage;
  PaginaDeCredenciaisDoWindows: TInputQueryWizardPage;
  Organizacoes: TOrganizacoes;
  OrganizacaoId, DiretorioDeDocumentosEnviados, DiretorioDeDocumentos, Email, Senha, DominioValido: String;

function DevePularPaginaDeOrganizacao(Page: TWizardPage): Boolean;
begin
  Result := Length(Organizacoes) = 1;
  if Result then
  begin
    OrganizacaoId := Organizacoes[0].Id;
  end;
end;

function InstalacaoEm32Bits: Boolean;
begin
  Result := Is64BitInstallMode() = False;
end;

procedure InitializeWizard();
begin
  PaginaInicial := CreateOutputMsgPage(
    wpWelcome,
    'Bem-vindo ao instalador do Monitor de Documentos do Sky Digitaliza!',
    'Para que a instalação seja concluída com sucesso, certifique-se que não há nenhuma versão anterior (ou igual) da aplicação instalada no sistema.',
    ''
  );

  PaginaDeSelecaoDoDiretorioDeDocumentos := CreateInputDirPage(
    PaginaInicial.ID,
    'Diretório de Documentos do Scanner',
    'Por favor, selecione o local onde o scanner irá depositar os documentos digitalizados.',
    '',
    True,
    ''
  );

  PaginaDeSelecaoDoDiretorioDeDocumentosEnviados := CreateInputDirPage(
    PaginaDeSelecaoDoDiretorioDeDocumentos.ID,
    'Diretório de Documentos do Enviados',
    'Por favor, selecione o local onde o monitor irá enviar os documentos que já foram enviados para o servidor.',
    '',
    True,
    ''
  );

  PaginaDeCredenciaisDoWindows := CreateInputQueryPage(
    PaginaDeSelecaoDoDiretorioDeDocumentosEnviados.ID,
    'Credenciais de Administrador do Windows',
    'Por favor, preencha os campos a seguir com as credenciais de administrador da sua máquina. Isso é necessário para que a aplicação funcione como esperado.',
    'Caso seja uma máquina em domínio local, e a conta administratica também esteja na mesma máquina, pode-se deixar o campo "Domínio" vazio.'
  );

  PaginaDeCredenciaisDoUsuario := CreateInputQueryPage(
    PaginaDeCredenciaisDoWindows.ID,
    'Credenciais de Usuário Sky Sistemas',
    'Por favor, preencha as suas credenciais do Sky Sistemas:',
    ''
  );

  PaginaDeSelecaoDaOrganizacao := CreateInputOptionPage(
      PaginaDeCredenciaisDoUsuario.Id,
      'Organização do Usuário',
      'Por favor, escolha a organização que estará utilizando esta aplicação.',
      'Escolher a organização errada irá impedir a aplicação de funcionar corretamente.',
      False,
      False
  );

  PaginaDeSelecaoDaOrganizacao.OnShouldSkipPage := @DevePularPaginaDeOrganizacao;
  
  PaginaDeSelecaoDoDiretorioDeDocumentos.Add('');
  PaginaDeSelecaoDoDiretorioDeDocumentosEnviados.Add('');

  PaginaDeCredenciaisDoUsuario.Add('Email:', False);
  PaginaDeCredenciaisDoUsuario.Add('Senha:', True);

  PaginaDeCredenciaisDoWindows.Add('Usuário:', False);
  PaginaDeCredenciaisDoWindows.Add('Senha:', True);
end;

function InitializeSetup: Boolean;
begin
  Dependency_AddDotNet80;
  Result := True;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  NomeUsuarioWindows, SenhaWindows, JsonResponse: string;
  I, OrganizacoesSelecionadas: Integer;
begin
  Result := True;
  if CurPageID = PaginaDeCredenciaisDoUsuario.ID then
  begin
    Email := PaginaDeCredenciaisDoUsuario.Values[0];
    Senha := PaginaDeCredenciaisDoUsuario.Values[1];

    JsonResponse := ValidarCredenciais(Email, Senha);
    if JsonResponse = '' then
    begin
      Result := False;
    end
    else
    begin
      if Length(Organizacoes) < 1 then
      begin
        Organizacoes := ObterOrganizacoesDoUsuario(JsonResponse);
        if Length(Organizacoes) >= 1 then
        begin
          for I := 0 to Length(Organizacoes) - 1 do
          begin
              PaginaDeSelecaoDaOrganizacao.Add(Organizacoes[I].Nome);
              PaginaDeSelecaoDaOrganizacao.Values[I] := False;
          end;
        end;
      end;

      if Length(Organizacoes) < 1 then
        Result := False;
    end;
  end
  else if CurPageID = PaginaDeSelecaoDaOrganizacao.ID then
  begin
    OrganizacoesSelecionadas := 0;
    for I := 0 to Length(Organizacoes) - 1 do
    begin
      if PaginaDeSelecaoDaOrganizacao.Values[I] = True then
        OrganizacoesSelecionadas := OrganizacoesSelecionadas + 1;
    end;

    if OrganizacoesSelecionadas <> 1 then
    begin
      MsgBox('Escolha apenas UMA organização.', mbInformation, MB_OK);
      Result := False;
      Exit;
    end;
    
    OrganizacaoId := Organizacoes[PaginaDeSelecaoDaOrganizacao.SelectedValueIndex].Id;
  end
  else if CurPageID = PaginaDeCredenciaisDoWindows.ID then
  begin
    if not IsAdmin() then
    begin
      Exit;
    end;
  
    NomeUsuarioWindows := PaginaDeCredenciaisDoWindows.Values[0];
    SenhaWindows := PaginaDeCredenciaisDoWindows.Values[1];

    DominioValido := '';
    if not VerificarCredenciaisWindows(NomeUsuarioWindows, SenhaWindows) then
    begin
      Result := False;
      MsgBox('Credenciais inválidas. Verifique as credenciais inseridas e tente novamente.', mbInformation, MB_OK);
      Exit;
    end;
  end;
end;

procedure ObterDominioDoUsuario(out Resultado: String);
var 
  ResultCode: Integer;
  ListaDeStrings: TArrayOfString;
begin
  if ExecWithResult('whoami', '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, Resultado) then
  begin
    if ResultCode = 0 then
    begin
      ListaDeStrings := DividirString(Resultado, '\');
      Resultado := ListaDeStrings[0];
    end;
  end;
end;

procedure AtualizarAppSettings();
var
  JSONString, CaminhoDoAppSettings: String;
begin
  CaminhoDoAppSettings := ExpandConstant('{app}\appsettings.json');
  DiretorioDeDocumentos := SubstituirString(PaginaDeSelecaoDoDiretorioDeDocumentos.Values[0], '\', '/');
  DiretorioDeDocumentosEnviados := SubstituirString(PaginaDeSelecaoDoDiretorioDeDocumentosEnviados.Values[0], '\', '/');
  JSONString := ObterTextoDoArquivo(CaminhoDoAppSettings);
  if JSONString = '' then
  begin
    MsgBox('Falha ao ler o appsettings.json ou o arquivo está vazio.', mbError, MB_OK);
    Exit;
  end;
  
  JSONString := SubstituirString(JSONString, '"DIRETORIO_DE_DOCUMENTOS"', '"' + DiretorioDeDocumentos + '"');
  JSONString := SubstituirString(JSONString, '"DIRETORIO_DE_ENVIOS"', '"' + DiretorioDeDocumentosEnviados + '"');
  JSONString := SubstituirString(JSONString, '"EMAIL_DO_USUARIO"', '"' + Email + '"');
  JSONString := SubstituirString(JSONString, '"SENHA_DO_USUARIO"', '"' + Senha + '"');
  JSONString := SubstituirString(JSONString, '"ORGANIZACAO_DO_USUARIO"', '"' + OrganizacaoId + '"');

  SalvarTextoEmArquivo(CaminhoDoAppSettings, JSONString);
end;

procedure ExibirMensagemComResultCode(Mensagem: String; ResultCode: Integer);
var
  MensagemFormatada: String;
begin
  if Debug = True then
  begin
    MensagemFormatada := Mensagem+'. [CODIGO: '+IntToStr(ResultCode)+']';
    MsgBox(MensagemFormatada, mbInformation, MB_OK);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  NomeUsuarioWindows, SenhaWindows, Dominio: string;
begin
  if CurStep = ssInstall then
  begin
    if Exec('sc', 'stop {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Windows foi parado', ResultCode);
    end;
    Sleep(1000);
  end;

  if CurStep = ssPostInstall then
  begin
    AtualizarAppSettings();
  end;
  
  if CurStep = ssDone then
  begin
    NomeUsuarioWindows := PaginaDeCredenciaisDoWindows.Values[0];
    SenhaWindows := PaginaDeCredenciaisDoWindows.Values[1];
    ObterDominioDoUsuario(Dominio);

    if Exec('sc', 'create {#NomeDaAplicacao} binPath= "' + ExpandConstant('{app}\{#NomeDoExecutavelDaAplicacao}') +
      '" start= auto obj= "' + Dominio + '\' + NomeUsuarioWindows + '" password= "' + SenhaWindows + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço criado', ResultCode);
      Sleep(1500);
      if Exec('sc', 'start {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin
        ExibirMensagemComResultCode('Serviço iniciado', ResultCode);
      end
      else
      begin
        ExibirMensagemComResultCode('Erro ao tentar iniciar o serviço no Windows', ResultCode);
      end;
    end
    else
    begin
      ExibirMensagemComResultCode('Erro ao tentar criar o serviço no Windows', ResultCode);
      Abort;
    end;
  end;
end;


procedure CurUninstallStepChanged(CurStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurStep = usUninstall then
  begin
    if Exec('sc', 'stop {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço no Windows foi Parado', ResultCode);
      Sleep(1000);
    end;
    
    if Exec('sc', 'delete {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço no Windows foi deletado', ResultCode);
    end;
    
    Sleep(1000);
  end;
end;