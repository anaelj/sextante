unit uDataModule;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.ioutils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.Bind.EngExt, FMX.Bind.DBEngExt,
  Data.DB, FireDAC.Comp.DataSet,
  System.ImageList, FMX.ImgList, FireDAC.Comp.Client, Data.Bind.Components, Data.Bind.DBScope,   Data.Bind.ObjectScope, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.RegularExpressions;

type
  TDataModule = class(TForm)
    Label3: TLabel;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
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
    FDQueryPapelGrid: TFDQuery;
    FDQueryPapelGridID: TIntegerField;
    FDQueryPapelGridDESCRICAO: TWideStringField;
    FDQueryPapelGridCOTACAO_ATUAL: TBCDField;
    FDQueryPapelGridBG_COTACAO_DESEJADA: TBCDField;
    FDQueryPapelGridBG_FATOR: TBCDField;
    FDQueryPapelGridVPA: TBCDField;
    FDQueryPapelGridPL: TBCDField;
    FDQueryPapelGridDIVID_EX_ATUAL: TBCDField;
    FDQueryPapelGridDIVID_EX_ANTERIOR: TBCDField;
    FDQueryPapelGridDIVID_EX_ANTERIOR_PRC: TBCDField;
    FDQueryPapelGridURL_BETA: TStringField;
    FDQueryPapelGridVALOR_BETA: TBCDField;
    FDQueryPapelGridDIVIDA_LIQUIDA_EBITIDA: TBCDField;
    FDQueryPapelGridTAG_ALONG: TBCDField;
    procedure FormCreate(Sender: TObject);
  private
    procedure criaCampoBanco(pTabela, pCampo, pTipo, pValorDefault: String);
    { Private declarations }

  public
    { Public declarations }
    pbLabelHabilitado : Boolean;
    url_default: string;

  end;

var
  DataModule: TDataModule;

const

  cns_sql_papel_field = 'select %s from papel';
  cns_sql_papel_field_where = 'select %s from papel where %s';

  url_ADVFN =
    'https://br.advfn.com/bolsa-de-valores/bovespa/sanepar-on-%S/cotacao';
  url_guiainvest = 'https://www.guiainvest.com.br/raiox/default.aspx?sigla=%s';
  url_dividendos_fundamentus = 'https://www.fundamentus.com.br/proventos.php?papel=%s&tipo=2';
  sql_default_papel_cadastro =
    'select * from papel where ((descricao = :descricao) OR (COALESCE(:descricao, '''') = '''')) %s %s';

  url_statusinvest = 'https://statusinvest.com.br/acoes/%s';

  url_yahoo = 'https://finance.yahoo.com/quote/%s.SA/';

  regExCotacaoYahoo = 'Trsdu.*?\<\/';
  regExStatusInvest = '%s.+?\d\<\/';

implementation

{$R *.fmx}


uses uPrincipal, Loading;

procedure TDataModule.FormCreate(Sender: TObject);
var
  AppPath, FileName: string;
begin

  AppPath := TPath.GetHomePath;
  FileName := TPath.Combine(AppPath, 'dados_sextante.db');
  FDConnection1.Params.Values['Database'] := FileName;

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

  FDQueryPapelGrid.Open();

  pbLabelHabilitado := True;
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
