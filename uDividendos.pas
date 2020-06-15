unit uDividendos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.RegularExpressions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti, FMX.Grid.Style, FMX.Grid, System.ImageList,
  FMX.ImgList, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope;

type
  TFormDividendos = class(TForm)
    Panel1: TPanel;
    EditPapel: TEdit;
    ComboBoxPapel: TComboBox;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    ComboBoxColuna: TComboBox;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    lblUrlAtual: TLabel;
    LinkPropertyToFieldText: TLinkPropertyToField;
    EditPLInicial: TEdit;
    EditPLFinal: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EditPercentualDividendo: TEdit;
    Label6: TLabel;
    EditDividaLiquidaEbitida: TEdit;
    Label7: TLabel;
    EditTagAlong: TEdit;
    Label2: TLabel;
    Button1: TButton;
    EditBetaInicial: TEdit;
    LabelBeta: TLabel;
    EditBetaFinal: TEdit;
    Label8: TLabel;
    btnAtualizar: TSpeedButton;
    StyleBook1: TStyleBook;
    Panel2: TPanel;
    Panel3: TPanel;
    btnClose: TSpeedButton;
    GroupBox1: TGroupBox;
    Label9: TLabel;
    EditDividendYield: TEdit;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure ComboBoxColunaChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

    pvFiltroFinal: string;
    pvOrderByFinal: string;

    function buscaValor(pExercicio: string; pTexto: string): variant;
    { Private declarations }
  public
    { Public declarations }
    procedure cargaInicialDividendos;
    procedure cargaBeta;
    procedure cargaPLeDividaLiquida;
    function buscaValorInvesting(pValor: string; pTexto: string): variant;
    function buscaValorStatusInvest(pValor, pTexto: string): variant;
    procedure AtualizaPapeis;
  end;

var
  FormDividendos: TFormDividendos;

implementation

{$R *.fmx}


uses uDataModule, uPopup, Loading;

function TFormDividendos.buscaValor(pExercicio: string; pTexto: string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;

  valorTotal: variant;
begin
  busca := '\/' + pExercicio + '\<\/td\>\s*\<td\>\d*\,\d*';

  RegularExpression.Create(busca);
  Match := RegularExpression.Match(pTexto);

  valorTotal := 0;

  if Match.Success then
    valorTotal := Match.Value.Split(['<td>'])[1] + buscaValor(pExercicio, pTexto.Substring(Match.Index));

  Result := valorTotal;

end;

function TFormDividendos.buscaValorInvesting(pValor: string; pTexto: string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;
  valorEcontrado: variant;
  valorAux: double;
begin
  busca := format('%s.+?\d\<', [pValor]);

  RegularExpression.Create(busca);
  Match := RegularExpression.Match(DataModule.Memo1.Lines.CommaText);

  valorEcontrado := 0;

  if Match.Success then
    valorEcontrado := Match.Value.Split(['>'])[2].Replace('<', '');

  TryStrToFloat(VarToStr(valorEcontrado), valorAux);

  Result := valorAux;

end;

function TFormDividendos.buscaValorStatusInvest(pValor: string; pTexto: string): variant;
var
  RegularExpression: TRegEx;
  Match: TMatch;
  busca: string;
  valorEcontrado: variant;
  valorAux: double;
  i: Integer;
  findResult: string;
begin
  busca := format('%s.*?\<\/strong', [pValor.Replace('/', '\/').Replace('.', '\.')]);

  RegularExpression.Create(busca);
  Match := RegularExpression.Match(pTexto.Replace('%', ''));

  valorEcontrado := 0;
  valorAux := 0;

  if Match.Success then
  begin
    i := 3;
    while valorAux = 0 do
    begin
      findResult := Match.Value;
      valorEcontrado := findResult.Split(['>'])[i].Replace('</strong', '').Trim;
      TryStrToFloat(VarToStr(valorEcontrado), valorAux);
      if Length(findResult.Split(['>'])) = i then
        Break;
      Inc(i);
    end;
  end;

  Result := valorAux;

end;

procedure TFormDividendos.Button1Click(Sender: TObject);
begin
  DataModule.FDQueryPapelCadastro.CLOSE;
  DataModule.FDQueryPapelCadastro.ParamByName('descricao').AsString := EditPapel.Text;
  DataModule.FDQueryPapelCadastro.Open;
  DataModule.FDQueryPapelLista.CLOSE;
  DataModule.FDQueryPapelLista.ParamByName('descricao').AsString := EditPapel.Text;
  DataModule.FDQueryPapelLista.Open;

  DataModule.FDQueryPapelCadastro.CLOSE;;
  DataModule.FDQueryPapelLista.CLOSE;
  DataModule.FDQueryPapelCadastro.Open;
end;

procedure TFormDividendos.cargaBeta;
begin
  with DataModule do
  begin
    IF NOT FDQueryPapelCadastro.Active THEN
      FDQueryPapelCadastro.Open;
    FDQueryPapelCadastro.First;
    while not FDQueryPapelCadastro.eof do
    begin
      if NOT FDQueryPapelCadastroURL_BETA.AsString.IsEmpty then
      begin
        Application.ProcessMessages;
        buscaDados('', FDQueryPapelCadastroURL_BETA.AsString);
        FDQueryPapelCadastro.Edit;
        FDQueryPapelCadastroVALOR_BETA.Value := buscaValorInvesting('Beta', DataModule.Memo1.Lines.CommaText);
        FDQueryPapelCadastro.Post;
        // Sleep(100);
      end;
      FDQueryPapelCadastro.Next;
    end;
    // FDQueryPapelCadastro.Close;
  end;

end;

procedure TFormDividendos.cargaInicialDividendos;
begin
  with DataModule do
  begin
    FDQueryPapelCadastro.First;
    while not FDQueryPapelCadastro.eof do
    begin
      Application.ProcessMessages;
      buscaDados(FDQueryPapelCadastroDESCRICAO.AsString, url_dividendos_fundamentus);
      FDQueryPapelCadastro.Edit;
      FDQueryPapelCadastroDIVID_EX_ATUAL.Value := buscaValor(FormatDateTime('YYYY', DATE), Memo1.Lines.CommaText);
      FDQueryPapelCadastroDIVID_EX_ANTERIOR.Value := buscaValor(inttostr(FormatDateTime('YYYY', DATE).ToInteger - 1),
        Memo1.Lines.CommaText);
      if FDQueryPapelCadastroCOTACAO_ATUAL.Value > 0 then
        FDQueryPapelCadastroDIVID_EX_ANTERIOR_PRC.Value := FDQueryPapelCadastroDIVID_EX_ANTERIOR.Value /
          FDQueryPapelCadastroCOTACAO_ATUAL.Value * 100;
      FDQueryPapelCadastro.Post;
      FDQueryPapelCadastro.Next;
    end;
  end;
end;


procedure TFormDividendos.cargaPLeDividaLiquida;
begin
  with DataModule do
  begin
    if not FDQueryPapelCadastro.Active then
      FDQueryPapelCadastro.Open;
    FDQueryPapelCadastro.First;
    while not FDQueryPapelCadastro.eof do
    begin
      if NOT FDQueryPapelCadastroURL_BETA.AsString.IsEmpty then
      begin
        Application.ProcessMessages;
        buscaDados(FDQueryPapelCadastroDESCRICAO.AsString, url_statusinvest);
        FDQueryPapelCadastro.Edit;

        FDQueryPapelCadastroPL.Value := buscaValorStatusInvest('P/L', DataModule.Memo1.Lines.Text);
        FDQueryPapelCadastroCOTACAO_ATUAL.Value := buscaValorStatusInvest('Valor atual do ativo',
          DataModule.Memo1.Lines.Text);

        FDQueryPapelCadastroDIVIDA_LIQUIDA_EBITIDA.Value := buscaValorStatusInvest('quida/EBITDA',
          DataModule.Memo1.Lines.Text);

        FDQueryPapelCadastroDIVIDEND_YIELD.Value := buscaValorStatusInvest('Dividend\sYield',
          DataModule.Memo1.Lines.Text);

        FDQueryPapelCadastroTAG_ALONG.Value := buscaValorStatusInvest('Tag Along',
          DataModule.Memo1.Lines.Text);

        FDQueryPapelCadastro.Post;
        // Sleep(500);
      end;

      FDQueryPapelCadastro.Next;
    end;

  end;

end;

procedure TFormDividendos.AtualizaPapeis;
begin
  try
    with DataModule do
    begin
      if NOT EditPapel.Text.IsEmpty then
      BEGIN
        DataModule.FDQueryPapelCadastro.CLOSE;
        DataModule.FDQueryPapelCadastro.ParamByName('descricao').AsString := EditPapel.Text;
        DataModule.FDQueryPapelCadastro.Open;
        DataModule.addPapel(EditPapel.Text, DataModule.FDQueryPapelCadastroID.AsInteger);
      END
      ELSE
      begin
        IF NOT FDQueryPapelLista.Active THEN
          FDQueryPapelLista.Open;
        FDQueryPapelLista.First;
        while not FDQueryPapelLista.eof do
        begin
          try
            Application.ProcessMessages;
            DataModule.addPapel(FDQueryPapelListaDESCRICAO.AsString, FDQueryPapelListaID.AsInteger);
          except
          end;
          FDQueryPapelLista.Next;
        end;
      end;
    end;
  except
  end;
end;

procedure TFormDividendos.ComboBoxColunaChange(Sender: TObject);
begin
  WITH DataModule DO
  begin
    case ComboBoxColuna.ItemIndex of
      0:
        pvOrderByFinal := 'order by DIVID_EX_ANTERIOR_PRC desc';
      1:
        pvOrderByFinal := 'order by PL ';
      2:
        pvOrderByFinal := 'order by VPA ';
      3:
        pvOrderByFinal := 'order by valor_beta desc';
    end;

    FDQueryPapelCadastro.SQL.Text := format(sql_default_papel_cadastro, [pvFiltroFinal, pvOrderByFinal]);

    FDQueryPapelCadastro.Open;

  end;
end;

procedure TFormDividendos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TFormDividendos.FormShow(Sender: TObject);
begin
  DataModule.Hide;

  pvFiltroFinal := '';
  pvOrderByFinal := '';

  DataModule.FDQueryPapelCadastro.SQL.Text := format(sql_default_papel_cadastro, [pvFiltroFinal, pvOrderByFinal]);
  DataModule.FDQueryPapelCadastro.Open;

end;

procedure TFormDividendos.SpeedButton1Click(Sender: TObject);
begin
  DataModule.FDQueryPapelCadastro.CLOSE;
  DataModule.FDQueryPapelCadastro.ParamByName('descricao').AsString := '';

  if NOT EditPapel.Text.IsEmpty then
    pvFiltroFinal := format(' and (DESCRICAO like ''%s%s%s'' )', ['%', EditPapel.Text, '%'])
  else
  begin
    pvFiltroFinal := format(' and (pl >= %s and pl <= %s)', [EditPLInicial.Text, EditPLFinal.Text]);
    pvFiltroFinal := pvFiltroFinal + format(' and (DIVID_EX_ANTERIOR_PRC >= %s )', [EditPercentualDividendo.Text]);
    pvFiltroFinal := pvFiltroFinal + format(' and (DIVIDA_LIQUIDA_EBITIDA <= %s )', [EditDividaLiquidaEbitida.Text]);
    pvFiltroFinal := pvFiltroFinal + format(' and (TAG_ALONG >= %s )', [EditTagAlong.Text]);
    pvFiltroFinal := pvFiltroFinal + format(' and (DIVIDEND_YIELD >= %s )', [EditDividendYield.Text]);
    pvFiltroFinal := pvFiltroFinal + format(' and (VALOR_BETA >= %s AND VALOR_BETA <= %s )',
      [EditBetaInicial.Text, EditBetaFinal.Text]);

  end;

  DataModule.FDQueryPapelCadastro.SQL.Text := format(sql_default_papel_cadastro, [pvFiltroFinal, pvOrderByFinal]);
  DataModule.FDQueryPapelCadastro.Open;

end;

procedure TFormDividendos.StringGrid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
  const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  vl_preco_atual: Currency;
  vl_vpa: Currency;
  vl_fator: Currency;
  vl_alvo: Currency;

  S: TGridDrawState;
  R: TRectF;
  OldKind: TBrushKind;

begin

  if (Column.Index = 0) then
  begin
    Column.Header := '';
  end;

  TryStrToCurr(TStringGrid(Sender).Cells[2, Row], vl_preco_atual);
  TryStrToCurr(TStringGrid(Sender).Cells[3, Row], vl_alvo);
  TryStrToCurr(TStringGrid(Sender).Cells[4, Row], vl_fator);
  TryStrToCurr(TStringGrid(Sender).Cells[5, Row], vl_vpa);

  OldKind := Canvas.Stroke.Kind;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  R := Bounds;
  R.Inflate(1 / 2 * Canvas.Scale, 1 / 2 * Canvas.Scale);

  if (vl_preco_atual < vl_vpa) and (Column.Index = 5) then
    Canvas.Stroke.Color := TAlphaColorRec.Green
  else if (vl_preco_atual < vl_alvo) and (Column.Index = 3) then
    Canvas.Stroke.Color := TAlphaColorRec.Green
  else if (vl_fator < 22.6) and (Column.Index = 4) then
    Canvas.Stroke.Color := TAlphaColorRec.Green
  else
    Canvas.Stroke.Color := TAlphaColorRec.Null;

  Canvas.DrawRect(R, 0, 0, AllCorners, 1);
  Canvas.Stroke.Kind := OldKind;
  OldKind := Canvas.Fill.Kind;

end;

procedure TFormDividendos.btnAtualizarClick(Sender: TObject);
begin
  FormPopup.Show;
end;

procedure TFormDividendos.btnCloseClick(Sender: TObject);
begin
  close;
end;

end.
