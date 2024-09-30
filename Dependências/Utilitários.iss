#include 'JsonUtils.iss'

[Code]
const EndpointDeAutenticacao = 'https://api.skydigitaliza.skyinfo.co/api/autenticacao/autenticar';

// Exec with output stored in result.
// ResultString will only be altered if True is returned.
function ExecWithResult(
  Filename, Params, WorkingDir: String; ShowCmd: Integer;
  Wait: TExecWait; var ResultCode: Integer; var ResultString: String): Boolean;
var
  TempFilename: String;
  Command: String;
  ResultStringAnsi: AnsiString;
begin
  TempFilename := ExpandConstant('{tmp}\~execwithresult.txt');
  // Exec via cmd and redirect output to file.
  // Must use special string-behavior to work.
  Command :=
    Format('"%s" /S /C ""%s" %s > "%s""', [
      ExpandConstant('{cmd}'), Filename, Params, TempFilename]);
  Result :=
    Exec(ExpandConstant('{cmd}'), Command, WorkingDir, ShowCmd, Wait, ResultCode);
  if not Result then
    Exit;
  LoadStringFromFile(TempFilename, ResultStringAnsi); // Cannot fail
  // See https://stackoverflow.com/q/20912510/850848
  ResultString := ResultStringAnsi;
  DeleteFile(TempFilename);
  // Remove new-line at the end
  if (Length(ResultString) >= 2) and
     (ResultString[Length(ResultString) - 1] = #13) and
     (ResultString[Length(ResultString)] = #10) then
    Delete(ResultString, Length(ResultString) - 1, 2);
end;

// Função para procurar e substituir uma string
function SubstituirString(const S, OldPattern, NewPattern: String): String;
var
  ResultString: String;
  SearchPos: Integer;
begin
  ResultString := S;
  SearchPos := Pos(OldPattern, ResultString);
  while SearchPos > 0 do
  begin
    Delete(ResultString, SearchPos, Length(OldPattern));
    Insert(NewPattern, ResultString, SearchPos);
    SearchPos := Pos(OldPattern, ResultString);
  end;
  Result := ResultString;
end;

// Função que faz divisão de strings baseadas em um delimitador.
function DividirString(const S: String; const Delimiter: String): TArrayOfString;
var
  Count, Position, Start, DelimiterLength: Integer;
begin
  Count := 0;
  Position := 1;
  DelimiterLength := Length(Delimiter);
  while Position <= Length(S) do
  begin
    Start := Position;
    while (Position <= Length(S)) and (Copy(S, Position, DelimiterLength) <> Delimiter) do
    begin
        Inc(Position);
    end;
    SetArrayLength(Result, Count + 1);
    Result[Count] := Copy(S, Start, Position - Start);
    Inc(Count);
    Position := Position + DelimiterLength;
  end;
end;

// Função que extrai o conteúdo de um arquivo de texto.
function ObterTextoDoArquivo(const NomeDoArquivo: String): String;
var
  Linhas: TArrayOfString;
  I: Integer;
begin
  Result := '';
  if LoadStringsFromFile(NomeDoArquivo, Linhas) then
  begin
    for I := 0 to GetArrayLength(Linhas) - 1 do
    begin
      Result := Result + Linhas[I] + #13#10;
    end;
  end
  else
    MsgBox('Falha ao ler o arquivo: ' + NomeDoArquivo, mbError, MB_OK);
end;

// Procedure que salva texto dentro de um arquivo.
procedure SalvarTextoEmArquivo(const NomeDoArquivo, Texto: String);
var
  Linhas: TArrayOfString;
begin
  // Tenho menor ideia de que char é esse, mas tá funcionando 🐱‍💻.
  Linhas := DividirString(Texto, #13#10);
  if not SaveStringsToUTF8File(NomeDoArquivo, Linhas, False) then
  begin
    MsgBox('Falha ao salvar o arquivo: ' + NomeDoArquivo, mbError, MB_OK);
  end
end;

type
    TOrganizacao = record
        Id: String;
        Nome: String;
    end;

type
    TOrganizacoes = array of TOrganizacao;

function EscolherOrganizacao(Organizacoes: TOrganizacoes): Integer;
var
  I, SelectedIndex: Integer;
  ButtonPressed: Integer;
  Msg: String;
begin
  SelectedIndex := -1;
  for I := 0 to Length(Organizacoes) - 1 do
  begin
    Msg := Format('Organização %d: %s', [I + 1, Organizacoes[I].Nome]);
    ButtonPressed := MsgBox(Msg, mbConfirmation, MB_YESNOCANCEL);
    if ButtonPressed = IDYES then
    begin
      SelectedIndex := I;
      Break;
    end;
    if ButtonPressed = IDCANCEL then
    begin
      SelectedIndex := -1;
      Break;
    end;
  end;
  
  Result := SelectedIndex;
end;

function ObterOrganizacoesDoUsuario(Json: String): TOrganizacoes;
var
    JsonParser: TJsonParser;
    JsonRootArray: TJsonArray;
    JsonObject: TJsonObject;
    I: Integer;
    OrganizacaoObject: TJsonObject;
    OrganizacaoId, OrganizacaoNome: TJsonString;
    Organizacao: TOrganizacao;
    Organizacoes: TOrganizacoes;
begin
    SetLength(Organizacoes, 0);

    if ParseJsonAndLogErrors(JsonParser, Json) then
    begin
        JsonRootArray := GetJsonRootArray(JsonParser.Output);

        for I := 0 to Length(JsonRootArray) - 1 do
        begin
        JsonObject := JsonParser.Output.Objects[JsonRootArray[I].Index];

            if FindJsonObject(JsonParser.Output, JsonObject, 'organizacao', OrganizacaoObject) and
                FindJsonString(JsonParser.Output, OrganizacaoObject, 'id', OrganizacaoId) and
                FindJsonString(JsonParser.Output, OrganizacaoObject, 'nome', OrganizacaoNome) then
            begin
                Organizacao.Id := OrganizacaoId;
                Organizacao.Nome := OrganizacaoNome;

                SetLength(Organizacoes, Length(Organizacoes) + 1);
                Organizacoes[High(Organizacoes)] := Organizacao;
                Log(Format('Organizacao ID: %s, Nome: %s', [OrganizacaoId, OrganizacaoNome]));
            end;
        end;
    end;

    ClearJsonParser(JsonParser);
    Result := Organizacoes;
end;

// Função de autenticação via POST.
function ValidarCredenciais(Email, Senha: String): String;
var
  HttpRequest: Variant;
  Data: String;
begin
  Result := '';
  Data := Format('{"email":"%s","senha":"%s"}', [Email, Senha]);

  try
    HttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    HttpRequest.Open('POST', EndpointDeAutenticacao, False);
    HttpRequest.SetRequestHeader('Content-Type', 'application/json');
    HttpRequest.Send(Data);

    if HttpRequest.Status = 200 then
    begin
        Result := HttpRequest.ResponseText;
    end
    else
        MsgBox('Credenciais inválidas, por favor tente novamente.', mbError, MB_OK);
  except
    MsgBox('Falha ao validar as credenciais. Verifique sua conexão com a internet.', mbError, MB_OK);
  end;
end;