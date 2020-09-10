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
  System.ImageList, FMX.ImgList, FireDAC.Comp.Client, Data.Bind.Components, Data.Bind.DBScope, Data.Bind.ObjectScope,
  FMX.StdCtrls,
{$IF DEFINED(MSWINDOWS)}
  UrlMon,
{$ENDIF}
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.RegularExpressions, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP;

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
    FDQueryPapelGridDIVIDEND_YIELD: TBCDField;
    FDQueryPapelGridINDICADOR_PETER_LYNCH: TBCDField;
    procedure FormCreate(Sender: TObject);
  private
    procedure criaCampoBanco(pTabela, pCampo, pTipo, pValorDefault: String);
    { Private declarations }

  public
    { Public declarations }
    pbLabelHabilitado: Boolean;
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
  url_fundamentus = 'https://www.fundamentus.com.br/detalhes.php?papel=%s';

  sql_default_papel_cadastro =
    'select * from papel where ((descricao = :descricao) OR (COALESCE(:descricao, '''') = '''')) %s %s';

  url_statusinvest = 'https://statusinvest.com.br/acoes/%s';

  url_yahoo = 'https://finance.yahoo.com/quote/%s.SA/';

  regExCotacaoYahoo = 'data-test="OPEN-value".*?\<\/';
  regExStatusInvest = '%s.+?\d\<\/';
  regExFundamentusCrescimento = '%s.+\n*.+\n*.+?<\/';


implementation

{$R *.fmx}


uses uPrincipal, Loading;

procedure TDataModule.FormCreate(Sender: TObject);
var
  AppPath, FileName: string;
  function DownLoadInternetFile(Source, Dest: String): Boolean;
  begin
    try
{$IF DEFINED(MSWINDOWS)}
      Result := URLDownloadToFile(nil, PChar(Source), PChar(Dest), 0, nil) = 0
{$ELSE}
      Result := False // ainda não implementado para android/ios
{$ENDIF}
    except
      Result := False;
    end;
  end;

begin

{$IF DEFINED(ANDROID)}
  AppPath := TPath.GetHomePath;
  FileName := TPath.Combine(AppPath, 'dados_sextante.db');
  FDConnection1.Params.Values['Database'] := FileName;
{$ELSE}
  FDConnection1.Params.Values['Database'] := GetCurrentDir + '\dados_sextante.db';
  if not FileExists(FDConnection1.Params.Values['Database']) then
  begin
    DownLoadInternetFile('https://github.com/anaelj/sextante/raw/master/database/dados_sextante.db', 'dados_sextante.db');
  end;
{$ENDIF}
  FDConnection1.Connected := True;

  criaCampoBanco('PAPEL', 'INDICADOR_PETER_LYNCH', 'NUMERIC(15,2)', '0'); // PL / CRESCIMENTO, QUANDO MENOR MELHOR
  // FDConnection1.Connected := false;
  // FDConnection1.Connected := True;

  FDQueryPapelGrid.Open();

  pbLabelHabilitado := True;
end;

procedure TDataModule.criaCampoBanco(pTabela, pCampo, pTipo,
  pValorDefault: String);
begin

  FDMetaInfoQueryTabela.Close;
  FDMetaInfoQueryTabela.ObjectName := pTabela;
  FDMetaInfoQueryTabela.Open;

  FDMetaInfoQueryTabela.Filtered := False;
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
