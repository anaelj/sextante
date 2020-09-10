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
  NetHTTPClient: TNetHTTPClient;
  stream: TMemoryStream;
begin
  try
    NetHTTPClient := TNetHTTPClient.Create(nil);

    result := TStringList.Create;
    result.Clear;

    if pUrl.IsEmpty then
      Exit;

    stream := TMemoryStream.Create;

    NetHTTPClient.Get(Format(pUrl, [pValue]), stream);
    stream.Position := 0;
    result.LoadFromStream(stream);
    result.Text := result.Text.
      Replace(''#10'', '', [rfReplaceAll]).
      Replace(''#13'', '', [rfReplaceAll]).
      Replace(''#10''#13'', '',
      [rfReplaceAll]);

    stream.Free;
    FreeAndNil(NetHTTPClient);
  except
    on E: Exception do
    BEGIN
      result.Clear;
      result.Add(E.Message);
      stream.Free;
      FreeAndNil(NetHTTPClient);
    end;
  end;
end;

class
  function TFindInHtml.getValueFromHTML(
  const
  pExpReg:
  string;
  const
  pTexto:
  string): variant;
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

class
  function TFindInHtml.getValueFromHTMLInvesting(
  const
  pValor:
  string;
  const
  pTexto:
  string): variant;
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
