unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Grid, syncObjs,
  Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope,
  FMX.StdCtrls, FMX.Edit, FMX.ListBox, System.RegularExpressions, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFormPrincipal = class(TForm)
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    PanelFiltros: TPanel;
    btnAtualizar: TSpeedButton;
    btnClose: TSpeedButton;
    GroupBox1: TGroupBox;
    EditBetaFinal: TEdit;
    EditBetaInicial: TEdit;
    EditDividaLiquidaEbitida: TEdit;
    EditPapel: TEdit;
    EditPercentualDividendo: TEdit;
    EditPLFinal: TEdit;
    EditPLInicial: TEdit;
    EditTagAlong: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LabelBeta: TLabel;
    Label9: TLabel;
    EditDividendYield: TEdit;
    ComboBoxColuna: TComboBox;
    SpeedButton2: TSpeedButton;
    PanelToolBar: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    StyleBook1: TStyleBook;
    btnFiltrar: TSpeedButton;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    pvFiltroFinal: string;
    pvOrderByFinal: string;
    fCS: TCriticalSection;

    function buscaValor(pExercicio: string; pTexto: string): variant;
    class function criaLabel(const pTop: integer; pParent: TForm): TLabel; static;
    // function buscaValorGeneric(pExpReg, pTexto: string): variant;

  public
    { Public declarations }
    procedure cargaCotacao;
    procedure cargaInicialDividendos;
    procedure cargaBeta;
    procedure cargaPLeDividaLiquida;
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}


uses uDataModule, uPopup, Loading, uFindInHtml;

procedure TFormPrincipal.btnAtualizarClick(Sender: TObject);
begin
  FormPopup.show;
end;

procedure TFormPrincipal.btnCloseClick(Sender: TObject);
begin
  CLOSE;
end;

procedure TFormPrincipal.btnFiltrarClick(Sender: TObject);
begin
  PanelFiltros.Visible := True;
  PanelToolBar.Visible := False;
  Application.ProcessMessages;
end;

function TFormPrincipal.buscaValor(pExercicio, pTexto: string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;

  valorTotal: variant;
begin
  try
    busca := '\/' + pExercicio + '\<\/td\>\s*\<td\>\d*\,\d*';
    RegularExpression.Create(busca);
    Match := RegularExpression.Match(pTexto);
    valorTotal := 0;
    if Match.Success then
      valorTotal := Match.Value.Split(['<td>'])[1] + buscaValor(pExercicio, pTexto.Substring(Match.Index));
  except
    valorTotal := 0;
  end;

  Result := valorTotal;
end;

procedure TFormPrincipal.cargaBeta;
var
  queryLocal: TFDQuery;
  htmlRetorno: TStrings;
  labelLocal: TLabel;
begin
  try
    fCS.Enter;
    queryLocal := TFDQuery.Create(self);
    queryLocal.Connection := DataModule.FDConnection1;
//    queryLocal.Transaction := DataModule.FDTransactionPrincipal;
    queryLocal.SQL.Add(format(cns_sql_papel_field, ['ID,VALOR_BETA,URL_BETA']));
    queryLocal.Open;

    labelLocal := criaLabel(90, FormPrincipal);
    htmlRetorno := TStringList.Create;

    while not queryLocal.eof do
    begin
      if NOT queryLocal.FieldByName('URL_BETA').AsString.IsEmpty then
      begin
        labelLocal.Text := (queryLocal.FieldByName('URL_BETA').AsString);

        htmlRetorno.Clear;
        htmlRetorno := TFindInHtml.downloadHTML('', queryLocal.FieldByName('URL_BETA').AsString);

        if htmlRetorno.Text.Contains('Beta') then
        begin
//          queryLocal.Transaction.StartTransaction;
          queryLocal.Edit;
          queryLocal.FieldByName('VALOR_BETA').Value := TFindInHtml.getValueFromHTMLInvesting('Beta', htmlRetorno.Text);
          queryLocal.Post;
  //        queryLocal.Transaction.Commit;
          sleep(10);
        end;
      end;
      queryLocal.Next;
    end;
    FreeAndNil(htmlRetorno);
    FreeAndNil(labelLocal);
    FreeAndNil(queryLocal);
    fCS.Leave;
  except
    on E: Exception do
    begin
    //  if queryLocal.Transaction.Active then
    //    queryLocal.Transaction.Rollback;
      FreeAndNil(queryLocal);
      FreeAndNil(htmlRetorno);
      FreeAndNil(labelLocal);
    end;
  end;
end;

class function TFormPrincipal.criaLabel(const pTop: integer; pParent: TForm): TLabel;
begin
  Result := TLabel.Create(nil);
  Result.Parent := pParent;
  Result.Align := TAlignLayout.Center;
  Result.Margins.Top := pTop;
  Result.Font.Size := 13;
  Result.Height := 70;
  Result.Width := FormPrincipal.Width - 100;
  Result.FontColor := TAlphaColorRec.White;
  Result.TextSettings.HorzAlign := TTextAlign.Center;
  Result.TextSettings.VertAlign := TTextAlign.Leading;
  Result.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Result.VertTextAlign := TTextAlign.Leading;
  Result.Trimming := TTextTrimming.None;
  Result.TabStop := False;
end;

procedure TFormPrincipal.cargaInicialDividendos;
var
  queryLocal: TFDQuery;
  htmlRetorno: TStrings;
  labelLocal: TLabel;
begin
  try
    fCS.Enter;
    queryLocal := TFDQuery.Create(self);
    queryLocal.Connection := DataModule.FDConnection1;
//    queryLocal.Transaction := DataModule.FDTransactionPrincipal;

    queryLocal.SQL.Add(format(cns_sql_papel_field,
      ['ID,DESCRICAO,DIVID_EX_ATUAL,DIVID_EX_ANTERIOR,COTACAO_ATUAL,DIVID_EX_ANTERIOR_PRC']));
    queryLocal.Open;
    labelLocal := criaLabel(120, FormPrincipal);
    htmlRetorno := TStringList.Create;

    while not queryLocal.eof do
    begin
      htmlRetorno.Clear;
      labelLocal.Text := format(url_dividendos_fundamentus, [queryLocal.FieldByName('DESCRICAO').AsString]);
      htmlRetorno := TFindInHtml.downloadHTML(queryLocal.FieldByName('DESCRICAO').AsString, url_dividendos_fundamentus);

      if htmlRetorno.Text.Contains(FormatDateTime('YYYY', DATE)) then
      begin
//        queryLocal.Transaction.StartTransaction;
        queryLocal.Edit;
        queryLocal.FieldByName('DIVID_EX_ATUAL').Value := buscaValor(FormatDateTime('YYYY', DATE), htmlRetorno.CommaText);
        queryLocal.FieldByName('DIVID_EX_ANTERIOR').Value :=
          buscaValor(inttostr(FormatDateTime('YYYY', DATE).ToInteger - 1), htmlRetorno.CommaText);
        if queryLocal.FieldByName('COTACAO_ATUAL').Value > 0 then
          queryLocal.FieldByName('DIVID_EX_ANTERIOR_PRC').Value := queryLocal.FieldByName('DIVID_EX_ANTERIOR').Value /
            queryLocal.FieldByName('COTACAO_ATUAL').Value * 100;
        queryLocal.Post;
  //      queryLocal.Transaction.Commit;
        sleep(10);
      end;
      queryLocal.Next;
    end;
    FreeAndNil(htmlRetorno);
    FreeAndNil(queryLocal);
    FreeAndNil(labelLocal);
    fCS.Leave;
  except
    on E: Exception do
    begin
    //  if queryLocal.Transaction.Active then
//        queryLocal.Transaction.Rollback;
      htmlRetorno.Clear;
      FreeAndNil(queryLocal);
      FreeAndNil(htmlRetorno);
      FreeAndNil(labelLocal);
    end;
  end;
end;

procedure TFormPrincipal.cargaPLeDividaLiquida;
var
  queryLocal: TFDQuery;
  htmlRetorno: TStrings;
  vpa, lpa, valorIntriseco, margemSeguranca: Real;
  labelLocal: TLabel;
begin
  try
    fCS.Enter;
    queryLocal := TFDQuery.Create(self);
    queryLocal.Connection := DataModule.FDConnection1;
//    queryLocal.Transaction := DataModule.FDTransactionPrincipal;
    queryLocal.SQL.Add(format(cns_sql_papel_field,
      ['ID,DESCRICAO,PL,DIVIDA_LIQUIDA_EBITIDA,DIVIDEND_YIELD,TAG_ALONG,BG_COTACAO_DESEJADA,BG_FATOR,VPA,COTACAO_ATUAL']));
    queryLocal.Open;

    labelLocal := criaLabel(150, FormPrincipal);
    htmlRetorno := TStringList.Create;

    while not queryLocal.eof do
    begin

      labelLocal.Text := format(url_statusinvest, [queryLocal.FieldByName('DESCRICAO').AsString]);

      htmlRetorno.Clear;
      htmlRetorno := TFindInHtml.downloadHTML(queryLocal.FieldByName('DESCRICAO').AsString, url_statusinvest);

      if htmlRetorno.Text.Contains('EBITDA') then
      begin
  //      queryLocal.Transaction.StartTransaction;
        queryLocal.Edit;
        queryLocal.FieldByName('PL').Value := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['P\/L']), htmlRetorno.Text);

        queryLocal.FieldByName('DIVIDA_LIQUIDA_EBITIDA').Value := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['quida\/EBITDA']), htmlRetorno.Text);

        queryLocal.FieldByName('DIVIDEND_YIELD').Value := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['Dividend\sYield']), htmlRetorno.Text);

        queryLocal.FieldByName('TAG_ALONG').Value := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['Tag\sAlong']), htmlRetorno.Text);

        lpa := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['LPA']), htmlRetorno.Text);
        vpa := TFindInHtml.getValueFromHTML(format(regExStatusInvest,['VPA']), htmlRetorno.Text);
        if (lpa > 0) and (vpa > 0) then
        begin
          valorIntriseco := sqrt(22.5 * lpa * vpa);
          margemSeguranca := (valorIntriseco - queryLocal.FieldByName('COTACAO_ATUAL').AsFloat) / valorIntriseco * 100;
        end
        else
        begin
          valorIntriseco := 0;
          margemSeguranca := 0;
        end;

        queryLocal.FieldByName('BG_COTACAO_DESEJADA').AsString := FormatCurr('#.#0', valorIntriseco);
        queryLocal.FieldByName('BG_FATOR').AsString := FormatCurr('#.#0', margemSeguranca);
        queryLocal.FieldByName('VPA').AsString := FormatCurr('#.#0', vpa);

        queryLocal.Post;
//        queryLocal.Transaction.Commit;

        sleep(10);
      end;
      queryLocal.Next;
    end;
    FreeAndNil(htmlRetorno);
    FreeAndNil(labelLocal);
    FreeAndNil(queryLocal);
    fCS.Leave;
  except
    on E: Exception do
    begin
//      if queryLocal.Transaction.Active then
//        queryLocal.Transaction.Rollback;
      htmlRetorno.Clear;
      FreeAndNil(queryLocal);
      FreeAndNil(htmlRetorno);
      FreeAndNil(labelLocal);
    end;
  end;

end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  fCS := TCriticalSection.Create;

end;

procedure TFormPrincipal.FormShow(Sender: TObject);
var
  componente: TObject;
begin

  PanelFiltros.Visible := False;

  DataModule.FDQueryPapelGrid.SQL.Text := format(sql_default_papel_cadastro, [pvFiltroFinal, pvOrderByFinal]);
  DataModule.FDQueryPapelGrid.Open;

  for var i := 0 to self.ComponentCount - 1 do
  begin
    if self.Components[i] is TEdit then
      TEdit(self.Components[i]).Size.Height := 25;
  end;

end;

procedure TFormPrincipal.SpeedButton1Click(Sender: TObject);
begin
  PanelFiltros.Visible := True;
  PanelToolBar.Visible := False;
  Application.ProcessMessages;
end;

procedure TFormPrincipal.SpeedButton3Click(Sender: TObject);
begin
  PanelFiltros.Visible := False;
  PanelToolBar.Visible := True;
  Application.ProcessMessages;
end;

procedure TFormPrincipal.cargaCotacao;
var
  queryLocal: TFDQuery;
  htmlRetorno: TStrings;
  labelLocal: TLabel;
begin
  try
    fCS.Enter;
    queryLocal := TFDQuery.Create(self);
    queryLocal.Connection := DataModule.FDConnection1;
//    queryLocal.Transaction := DataModule.FDTransactionPrincipal;
    queryLocal.SQL.Add(format(cns_sql_papel_field, ['ID,DESCRICAO,COTACAO_ATUAL']));
    queryLocal.Open;

    labelLocal := criaLabel(180, FormPrincipal);

    htmlRetorno := TStringList.Create;
    while not queryLocal.eof do
    begin
      htmlRetorno.Clear;
      labelLocal.Text := format(url_yahoo, [queryLocal.FieldByName('DESCRICAO').AsString]);
      htmlRetorno := TFindInHtml.downloadHTML(queryLocal.FieldByName('DESCRICAO').AsString, url_yahoo);
      if htmlRetorno.Text.Contains('Trsdu') then
      begin
//        queryLocal.Transaction.StartTransaction;
        queryLocal.Edit;
        queryLocal.FieldByName('COTACAO_ATUAL').Value := TFindInHtml.getValueFromHTML(regExCotacaoYahoo, htmlRetorno.Text);
        queryLocal.Post;
  ///      queryLocal.Transaction.Commit;
      end;
      queryLocal.Next;
    end;
    FreeAndNil(htmlRetorno);
    FreeAndNil(labelLocal);
    FreeAndNil(queryLocal);
    fCS.Leave;
  except
    on E: Exception do
    begin
//      if queryLocal.Transaction.Active then
//        queryLocal.Transaction.Rollback;
      htmlRetorno.Clear;
      FreeAndNil(queryLocal);
      FreeAndNil(htmlRetorno);
      FreeAndNil(labelLocal);
    end;
  end;
end;

end.
