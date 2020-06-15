unit uDataModule;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.Edit,
  FMX.StdCtrls,
  FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.Forms, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ListBox, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid,
  System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Grid, Data.Bind.DBScope,
  System.RegularExpressions, System.ioutils, FMX.graphics, FMX.Dialogs,
  System.ImageList, FMX.ImgList, FMX.Objects, System.Notification,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart;

type
  TDataModule = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDQueryPapel: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    Memo1: TMemo;
    FDMetaInfoQueryTabela: TFDMetaInfoQuery;
    FDMetaInfoQueryTabelaRECNO: TIntegerField;
    FDMetaInfoQueryTabelaCATALOG_NAME: TWideStringField;
    FDMetaInfoQueryTabelaSCHEMA_NAME: TWideStringField;
    FDMetaInfoQueryTabelaTABLE_NAME: TWideStringField;
    FDMetaInfoQueryTabelaCOLUMN_NAME: TWideStringField;
    FDMetaInfoQueryTabelaCOLUMN_POSITION: TIntegerField;
    FDMetaInfoQueryTabelaCOLUMN_DATATYPE: TIntegerField;
    FDMetaInfoQueryTabelaCOLUMN_TYPENAME: TWideStringField;
    FDMetaInfoQueryTabelaCOLUMN_ATTRIBUTES: TLongWordField;
    FDMetaInfoQueryTabelaCOLUMN_PRECISION: TIntegerField;
    FDMetaInfoQueryTabelaCOLUMN_SCALE: TIntegerField;
    FDMetaInfoQueryTabelaCOLUMN_LENGTH: TIntegerField;
    ImageList1: TImageList;
    FDQueryPapelID: TIntegerField;
    FDQueryPapelPAPEL_ATUAL: TWideStringField;
    Label1: TLabel;
    Panel2: TPanel;
    ComboBoxServidor: TComboBox;
    Label3: TLabel;
    LabeLPorcessamento: TLabel;
    FDQueryPar: TFDQuery;
    FDQueryParID: TFDAutoIncField;
    FDQueryParPAPEL_ON: TWideStringField;
    FDQueryParPAPEL_PN: TWideStringField;
    FDQueryParVALOR_DIF_MENOR: TBCDField;
    FDQueryParVALOR_DIF_MAIOR: TBCDField;
    FDQueryParVALOR_DIF_ATUAL: TBCDField;
    FDQueryParHistorico: TFDQuery;
    FDQueryParHistoricoID: TFDAutoIncField;
    FDQueryParHistoricoCOTACAO_ON: TBCDField;
    FDQueryParHistoricoCOTACAO_PN: TBCDField;
    FDQueryParHistoricoID_PAR: TIntegerField;
    FDQueryParHistoricoDIFERENCA: TCurrencyField;
    FDQueryParHistoricoMAX_DIF: TAggregateField;
    FDQueryParHistoricoMIN_DIF: TAggregateField;
    FDQueryPapelCadastro: TFDQuery;
    FDQueryPapelid_imagem: TIntegerField;
    FDQueryPapelCadastroID: TIntegerField;
    FDQueryPapelCadastroDESCRICAO: TWideStringField;
    FDQueryPapelCadastroCOTACAO_ATUAL: TBCDField;
    FDQueryPapelCadastroBG_COTACAO_DESEJADA: TBCDField;
    FDQueryPapelCadastroBG_FATOR: TBCDField;
    FDQueryPapelCadastroVPA: TBCDField;
    FDQueryPapelCadastroPL: TBCDField;
    FDQueryPapelCadastroDIVID_EX_ATUAL: TBCDField;
    FDQueryPapelCadastroDIVID_EX_ANTERIOR: TBCDField;
    FDQueryPapelCadastroDIVID_EX_ANTERIOR_PRC: TBCDField;
    FDQueryPapelCadastroURL_BETA: TStringField;
    FDQueryPapelCadastroVALOR_BETA: TBCDField;
    FDQueryPapelLista: TFDQuery;
    FDQueryPapelListaID: TIntegerField;
    FDQueryPapelListaDESCRICAO: TWideStringField;
    FDQueryPapelListaCOTACAO_ATUAL: TBCDField;
    FDQueryPapelListaBG_COTACAO_DESEJADA: TBCDField;
    FDQueryPapelListaBG_FATOR: TBCDField;
    FDQueryPapelListaVPA: TBCDField;
    FDQueryPapelListaPL: TBCDField;
    FDQueryPapelListaDIVID_EX_ATUAL: TBCDField;
    FDQueryPapelListaDIVID_EX_ANTERIOR: TBCDField;
    FDQueryPapelListaDIVID_EX_ANTERIOR_PRC: TBCDField;
    FDQueryPapelListaURL_BETA: TStringField;
    FDQueryPapelListaVALOR_BETA: TBCDField;
    FDQueryPapelCadastroDIVIDA_LIQUIDA_EBITIDA: TBCDField;
    FDQueryPapelListaDIVIDA_LIQUIDA_EBITIDA: TBCDField;
    FDQueryPapelCadastroTAG_ALONG: TBCDField;
    FDQueryPapelListaTAG_ALONG: TBCDField;
    FDQueryPapelCadastroDIVIDEND_YIELD: TBCDField;
    FDQueryPapelAdd: TFDQuery;
    FDQueryPapelAddID: TIntegerField;
    FDQueryPapelAddDESCRICAO: TWideStringField;
    FDQueryPapelAddCOTACAO_ATUAL: TBCDField;
    FDQueryPapelAddBG_COTACAO_DESEJADA: TBCDField;
    FDQueryPapelAddBG_FATOR: TBCDField;
    FDQueryPapelAddVPA: TBCDField;
    FDQueryPapelAddPL: TBCDField;
    FDQueryPapelAddDIVID_EX_ATUAL: TBCDField;
    FDQueryPapelAddDIVID_EX_ANTERIOR: TBCDField;
    FDQueryPapelAddDIVID_EX_ANTERIOR_PRC: TBCDField;
    FDQueryPapelAddURL_BETA: TStringField;
    FDQueryPapelAddVALOR_BETA: TBCDField;
    FDQueryPapelAddDIVIDA_LIQUIDA_EBITIDA: TBCDField;
    FDQueryPapelAddTAG_ALONG: TBCDField;
    FDQueryPapelAddDIVIDEND_YIELD: TBCDField;

    procedure FormCreate(Sender: TObject);

    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure ComboBoxServidorChange(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure criaCampoBanco(pTabela, pCampo, pTipo, pValorDefault: String);

    { Private declarations }
  public

    url_default: string;

    function BuscaTagHtml(pIdElemento: array of string): variant;
    procedure addPapel(pValue: string; pValueID: integer);
    procedure buscaDados(pValue: string; pUrl: string = '');
    { Public declarations }
  end;

var
  DataModule: TDataModule;

const
  url_ADVFN =
    'https://br.advfn.com/bolsa-de-valores/bovespa/sanepar-on-%S/cotacao';
  url_guiainvest = 'https://www.guiainvest.com.br/raiox/default.aspx?sigla=%s';
  url_dividendos_fundamentus = 'https://www.fundamentus.com.br/proventos.php?papel=%s&tipo=2';
  sql_default_papel_cadastro =
    'select * from papel where ((descricao = :descricao) OR (COALESCE(:descricao, '''') = '''')) %s %s';

  url_statusinvest = 'https://statusinvest.com.br/acoes/%s';

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}


uses uDividendos, Loading;

function TDataModule.BuscaTagHtml(pIdElemento: array of string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;
begin

  try
    busca := Format
      ('(id\=\"*%s\"*\s*\w*\W*\w*\=*\w*\s*\w*\W*\w*\=*\w*\s*\w*\W*\w*\=*\w*\>)(\d*\,\d*)',
      [pIdElemento[0]]);

    // Memo1.Lines.SaveToFile('c:\sql\teste.txt');

    RegularExpression.Create(busca);
    Match := RegularExpression.Match(Memo1.Lines.CommaText);
    if Match.Success then
    begin
      Result := Match.Value.Split(['>'])[1];
    end
    else if Length(pIdElemento) > 1 then
    begin
      Result := BuscaTagHtml([pIdElemento[1]]);
    end
    else
      Result := '0.00';
  except
      Result := '0.00';
  end;
end;

procedure TDataModule.ComboBoxServidorChange(Sender: TObject);
begin
  if ComboBoxServidor.ItemIndex = 0 then
    url_default := url_guiainvest
  else if ComboBoxServidor.ItemIndex = 1 then
    url_default := url_ADVFN;

end;

procedure TDataModule.addPapel(pValue: string; pValueID: integer);
var
  preco_atual: variant;
  preco_desejado: Currency;
  preco_fator: variant;
  valor_patrimonial_acao: variant;
  preco_ValorPatrimonialAcao: variant;
  preco_LucroAcao: variant;
  preco_LucroAtual: variant;
  preco_PatrimonialAcao: variant;

begin
  try
    try
      buscaDados(pValue, url_guiainvest);
    except
    end;
    // try
    preco_atual := BuscaTagHtml(['prec_' + pValue]);
    preco_LucroAcao := BuscaTagHtml(['lbLucroAcao3']);

    // preço atual
    preco_LucroAtual := BuscaTagHtml(['lbPrecoLucroAtual', 'lbPrecoLucro3']);

    // preço sobre o valor patrimonial por ação
    preco_ValorPatrimonialAcao := BuscaTagHtml(['lbValorPatrimonialAcaoAtual',
      'lbValorPatrimonialAcao3']);

    // preço patrimonial por ação
    preco_PatrimonialAcao := BuscaTagHtml(['lbPrecoValorPatrimonialAtual',
      'lbPrecoValorPatrimonial3']);

    // valor patrimonial da ação
    valor_patrimonial_acao := BuscaTagHtml(['lbValorPatrimonialAcaoAtual',
      'lbValorPatrimonialAcao3']);

    preco_fator := preco_PatrimonialAcao * preco_LucroAtual;

    if (preco_LucroAcao > 0) and (preco_ValorPatrimonialAcao > 0) then
      preco_desejado := sqrt(22.5 * preco_LucroAcao * preco_ValorPatrimonialAcao)
    else
      preco_desejado := 0;

    FDQueryPapelAdd.Close;
    FDQueryPapelAdd.parambyname('id').AsInteger := pValueID;
    FDQueryPapelAdd.Open;

    if FDQueryPapelAdd.IsEmpty then
      FDQueryPapelAdd.Append
    else
      FDQueryPapelAdd.Edit;

    if (FDQueryPapelAdd.State in [dsInsert, dsEdit]) then
    begin
      FDQueryPapelAddDESCRICAO.AsString := pValue;
      FDQueryPapelAddCOTACAO_ATUAL.Value := preco_atual;
      FDQueryPapelAddBG_COTACAO_DESEJADA.AsString :=
        FormatCurr('#.#0', preco_desejado);
      FDQueryPapelAddBG_FATOR.AsString := FormatCurr('#.#0', preco_fator);
      FDQueryPapelAddVPA.AsString :=
        FormatCurr('#.#0', valor_patrimonial_acao);
      FDQueryPapelAdd.Post;
    end;
    Memo1.Lines.Clear;
  except
    Memo1.Lines.Clear;

  end;
end;

procedure TDataModule.buscaDados(pValue: string; pUrl: string = '');
begin
  try
    Memo1.Lines.Clear;
    if pUrl.IsEmpty then
      RESTClient1.BaseURL := Format(url_default, [pValue])
    else
      RESTClient1.BaseURL := Format(pUrl, [pValue]);

    FormDividendos.lblUrlAtual.Text := RESTClient1.BaseURL;

    TLoading.Hide;
    TLoading.Show(FormDividendos, Format('Buscando dados em: %s', [RESTClient1.BaseURL]));

    // TLoading.trocaMensagem( Format('Buscando dados em: %s', [RESTClient1.BaseURL]));

    Application.ProcessMessages;

    RESTRequest1.Execute;
    Memo1.Lines.Add(RESTResponse1.Content.Replace(''#10'', '', [rfReplaceAll])
      .Replace(''#13'', '', [rfReplaceAll]).Replace(''#10''#13'', '',
      [rfReplaceAll]));
  except
  end;

end;

procedure TDataModule.FDConnection1BeforeConnect(Sender: TObject);
begin
{$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  FDConnection1.Params.Values['Database'] := TPath.GetHomePath +
    TPath.DirectorySeparatorChar + 'dados_arb.db';
{$ENDIF}
end;

procedure TDataModule.FormCreate(Sender: TObject);
begin

  url_default := url_ADVFN;

  FDConnection1.Connected := false;
  FDConnection1.Params.Database := GetHomePath + PathDelim + 'dados_arb.db';
  FDConnection1.Connected := True;

  FDConnection1.ExecSQL
    (' create table if not exists PAR( ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, PAPEL_ON STRING(8), PAPEL_PN STRING(8)  ); ');
  FDConnection1.ExecSQL
    (' create table if not exists PAR_HISTORICO( ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ID_PAR integer, COTACAO_ON NUMERIC(15,2) , COTACAO_PN NUMERIC(15,2)  ); ');
  FDConnection1.ExecSQL(' create table if not exists PAPEL( ' +
    ' ID integer primary key, ' + ' DESCRICAO STRING(6), ' +
    ' COTACAO_ATUAL numeric(15,2), ' + ' BG_COTACAO_DESEJADA numeric(15,2), ' +
    ' BG_FATOR numeric(15,2) , VPA NUMERIC(15,2), ' + ' PL NUMERIC(15,2) , ' +
    ' DIVID_EX_ATUAL NUMERIC(15,2), ' + ' DIVID_EX_ANTERIOR NUMERIC(15,2), ' +
    ' DIVID_EX_ANTERIOR_PRC NUMERIC(15,2) ' + '); ');

  FDConnection1.ExecSQL(' create table if not exists ALERTA( ' +
    ' ID integer primary key, ' +
    ' PAPEL_A STRING(6), PAPEL_B STRING(6),' +
    ' COTACAO_A numeric(15,2), ' +
    ' COTACAO_B numeric(15,2), ' +
    ' A_MENOS_B_ALERTA numeric(15,2), ' +
    ' B_MENOS_A_ALERTA numeric(15,2) ' +
    '); ');

  FDConnection1.Commit;

  FDConnection1.Connected := false;
  FDConnection1.Connected := True;
  criaCampoBanco('PAR', 'VALOR_DIF_MENOR', 'NUMERIC(15,2)', '0');
  criaCampoBanco('PAR', 'VALOR_DIF_MAIOR', 'NUMERIC(15,2)', '0');
  criaCampoBanco('PAR', 'VALOR_DIF_ATUAL', 'NUMERIC(15,2)', '0');

  criaCampoBanco('PAPEL', 'URL_BETA', 'varchar(250)', 'https://br.investing.com/equities/???');
  criaCampoBanco('PAPEL', 'VALOR_BETA', 'NUMERIC(15,2)', '0');
  criaCampoBanco('PAPEL', 'DIVIDA_LIQUIDA_EBITIDA', 'NUMERIC(15,2)', '0');
  criaCampoBanco('PAPEL', 'TAG_ALONG', 'NUMERIC(15,2)', '0');
  criaCampoBanco('PAPEL', 'DIVIDEND_YIELD', 'NUMERIC(15,2)', '0');

  FDConnection1.Connected := false;
  FDConnection1.Connected := True;

end;

procedure TDataModule.FormShow(Sender: TObject);
begin
  FormDividendos.Show;
end;

procedure TDataModule.criaCampoBanco(pTabela, pCampo, pTipo,
  pValorDefault: String);
begin

  FDMetaInfoQueryTabela.Close;
  FDMetaInfoQueryTabela.ObjectName := pTabela;
  FDMetaInfoQueryTabela.Open;

  FDMetaInfoQueryTabela.Filtered := false;
  FDMetaInfoQueryTabela.Filter := Format('COLUMN_NAME = ''%s''', [pCampo.ToUpper]);
  FDMetaInfoQueryTabela.Filtered := True;

  if FDMetaInfoQueryTabelaCOLUMN_NAME.AsString.IsEmpty then
  begin
    if pValorDefault.IsEmpty then
      FDConnection1.ExecSQL(Format('ALTER TABLE %s ADD %s %s ', [pTabela, pCampo, pTipo]))
    else
    begin
      if pTipo.ToUpper.Contains('CHAR') then
        FDConnection1.ExecSQL(Format('ALTER TABLE %s ADD %s %s DEFAULT ''%s'' ', [pTabela, pCampo, pTipo, pValorDefault]))
      else
        FDConnection1.ExecSQL(Format('ALTER TABLE %s ADD %s %s DEFAULT %s ', [pTabela, pCampo, pTipo, pValorDefault]));
    end;
  end;

end;

end.
