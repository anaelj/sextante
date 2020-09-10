unit uFindInHtml;

interface

uses System.RegularExpressions, System.SysUtils, System.Variants, System.Classes, REST.Types, REST.Client, IdHTTP,
  IdSSLOpenSSL, System.Net.HttpClientComponent;

type

  IFindInHtml = interface
    ['{518A6559-859B-4AAB-BDD8-B722F2CF14AC}']

  end;

  TFindInHtml = class(TInterfacedObject, IFindInHtml)

  private

  public
    class function downloadHTML(const pValue: string; const pUrl: string = ''): TStrings;
    class function getValueFromHTML(const pExpReg: string; const pTexto: string): variant;
    class function getValueFromHTMLInvesting(const pValor: string; const pTexto: string): variant;
  end;

implementation

{ TFindInHtml }

class function TFindInHtml.downloadHTML(const pValue: string; const pUrl: string = ''): TStrings;
var
  RESTClientLocal: TRESTClient;
  RESTRequestLocal: TRESTRequest;
  RESTResponseLocal: TRESTResponse;
  http: TIdHTTP;
  stream: TMemoryStream;
  url: string;
  handle: TIdSSLIOHandlerSocketOpenSSL;
  NetHTTPClient: TNetHTTPClient;
begin
  try

    http := TIdHTTP.Create(nil);

    NetHTTPClient := TNetHTTPClient.Create(nil);

    result := TStringList.Create;
    result.Clear;

    RESTRequestLocal := TRESTRequest.Create(nil);
    RESTClientLocal := TRESTClient.Create(nil);
    RESTResponseLocal := TRESTResponse.Create(nil);

    RESTRequestLocal.Client := RESTClientLocal;
    RESTRequestLocal.Response := RESTResponseLocal;

    if pUrl.IsEmpty then
      Exit;

    stream := TMemoryStream.Create;

    NetHTTPClient.Get(Format(pUrl, [pValue]), stream);
    stream.Position := 0;
    result.LoadFromStream(stream);

    handle := TIdSSLIOHandlerSocketOpenSSL.Create(http);

    with handle do
    begin
      SSLOptions.Method := sslvSSLv3;
      SSLOptions.Mode := sslmClient;
      SSLOptions.VerifyMode := [];
      SSLOptions.VerifyDepth := 0;
      SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    end;

    with http do
    begin
      IOHandler := handle;
      ReadTimeout := 0;
      AllowCookies := true;
      ProxyParams.BasicAuthentication := true;
      ProxyParams.ProxyPort := 0;
      request.ContentLength := -1;
      request.ContentRangeEnd := 0;
      request.ContentRangeStart := 0;
      request.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
      request.ContentType := 'text/xml';
      request.CharSet := 'utf-8';
      request.UserAgent := 'Mozilla/3.0 (compatible; Indy Library)';
    end;
    url := Format(pUrl.Replace('https', 'http'), [pValue]);
    result.Clear;
    http.Get(url, stream);
    stream.Position := 0;
    result.LoadFromStream(stream);

    result.Text := result.Text.Replace(''#10'', '', [rfReplaceAll])
      .Replace(''#13'', '', [rfReplaceAll]).Replace(''#10''#13'', '',
      [rfReplaceAll]);

    //
    // // RESTRequestLocal.ContentType := 'application/json;odata=light;charset=utf-8;';
    // RESTClientLocal.UserAgent :=
    // 'User-Agent:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36';
    // RESTRequestLocal.HandleRedirects := true;
    // RESTRequestLocal.AcceptEncoding := 'gzip, deflate';
    //
    // // RESTRequestLocal.AddParameter('Content-Type', 'application/text', TRESTRequestParameterKind.pkHTTPHEADER,
    // // [poDoNotEncode]);
    // // RESTRequestLocal.AddParameter('Accept', 'application/text', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
    // // RESTRequestLocal.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8';
    // RESTRequestLocal.Execute;
    // result.Clear;
    // result.Add(RESTResponseLocal.Content.Replace(''#10'', '', [rfReplaceAll])
    // .Replace(''#13'', '', [rfReplaceAll]).Replace(''#10''#13'', '',
    // [rfReplaceAll]));

    handle.Free;
    FreeAndNil(http);
    stream.Free;

    FreeAndNil(RESTResponseLocal);
    FreeAndNil(RESTClientLocal);
    FreeAndNil(RESTRequestLocal);
  except
    on E: Exception do
    BEGIN
      try
        RESTClientLocal.BaseURL := Format(pUrl, [pValue]);
        RESTRequestLocal.Execute;
        result.Clear;
        result.Add(RESTResponseLocal.Content.Replace(''#10'', '', [rfReplaceAll])
          .Replace(''#13'', '', [rfReplaceAll]).Replace(''#10''#13'', '',
          [rfReplaceAll]));
      except
        on E: Exception do
        begin
          result.Clear;
          result.Add(E.Message);
          handle.Free;
          FreeAndNil(http);
          stream.Free;
          FreeAndNil(RESTResponseLocal);
          FreeAndNil(RESTClientLocal);
          FreeAndNil(RESTRequestLocal);
        end;
      end;

      result.Clear;
      result.Add(E.Message);
      handle.Free;
      FreeAndNil(http);
      stream.Free;
      FreeAndNil(RESTResponseLocal);
      FreeAndNil(RESTClientLocal);
      FreeAndNil(RESTRequestLocal);
    END;
  end;

end;

class function TFindInHtml.getValueFromHTML(const pExpReg: string; const pTexto: string): variant;
var
  RegularExpression: TRegEx;
  MatchParcial, MatchFinal: TMatch;
  buscaParcial, buscaFinal: string;
  valorEcontrado: variant;
  valorAux: double;
begin
  try
    buscaParcial := pExpReg;
    buscaFinal := '(\>\d+\<\/)|((\>\d+)(\,|\.)(\d+\<\/))';
    RegularExpression.Create(buscaParcial);
    MatchParcial := RegularExpression.Match(pTexto.Replace('%', ''));
    valorEcontrado := 0;
    valorAux := 0;
    if MatchParcial.Success then
    begin
      RegularExpression.Create(buscaFinal);
      MatchFinal := RegularExpression.Match(MatchParcial.Value.Replace(' ', ''));
      if MatchFinal.Success then
        valorEcontrado := MatchFinal.Value.Replace('>', '').Replace('<', '').Replace('/', '').Replace('.', ',');
      TryStrToFloat(VarToStr(valorEcontrado), valorAux);
    end;
  except
    valorAux := 0;
    FreeAndNil(RegularExpression);
  end;
  result := valorAux;
end;

class function TFindInHtml.getValueFromHTMLInvesting(const pValor: string; const pTexto: string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;
  valorEcontrado: variant;
  valorAux: double;
begin
  try
    busca := Format('%s.+?\d\<', [pValor]);
    RegularExpression.Create(busca);
    Match := RegularExpression.Match(pTexto);
    valorEcontrado := 0;
    if Match.Success then
    begin
      if Length(Match.Value.Split(['>'])) > 2 then
        valorEcontrado := Match.Value.Split(['>'])[2].Replace('<', '');
    end;
    TryStrToFloat(VarToStr(valorEcontrado), valorAux);
  except
    valorAux := 0;
  end;
  result := valorAux;
end;

end.
