[Code]
const
  LOGON32_LOGON_INTERACTIVE = 2;
  LOGON32_PROVIDER_DEFAULT = 0;

function LogonUser(lpUsername: string; lpDomain: string; lpPassword: string;
  dwLogonType: Integer; dwLogonProvider: Integer; var phToken: Integer): Boolean;
  external 'LogonUserW@advapi32.dll stdcall';

function CloseHandle(hObject: Integer): Boolean;
  external 'CloseHandle@kernel32.dll stdcall';
  
function VerificarCredenciaisWindows(NomeUsuario, Senha: string): Boolean;
var
  TokenHandle: Integer;
begin
  Result := False;
  TokenHandle := 0;

  if LogonUser(NomeUsuario, '', Senha, LOGON32_LOGON_INTERACTIVE,
    LOGON32_PROVIDER_DEFAULT, TokenHandle) then
  begin
    CloseHandle(TokenHandle);
    Result := True;
  end
  else
  begin
    MsgBox('Nome de usuário, senha ou domínio inválidos.', mbError, MB_OK);
  end;
end;