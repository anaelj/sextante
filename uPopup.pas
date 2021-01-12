unit uPopup;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, syncObjs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts;

type
  TFormPopup = class(TForm)
    Rectangle1: TRectangle;
    btnPLDividaLiquida: TSpeedButton;
    btnCotacao: TSpeedButton;
    btnTodos: TSpeedButton;
    btnDividendos: TSpeedButton;
    btnBeta: TSpeedButton;
    btnClose: TSpeedButton;
    StyleBook1: TStyleBook;
    Panel1: TPanel;
    Rectangle2: TRectangle;
    btnPeterLynch: TSpeedButton;
    btnIncluirEmpresas: TSpeedButton;
    ScrollBox1: TScrollBox;
    SpeedButtonCalculaPontuacao: TSpeedButton;
    procedure btnPLDividaLiquidaClick(Sender: TObject);
    procedure btnBetaClick(Sender: TObject);
    procedure btnCotacaoClick(Sender: TObject);
    procedure btnDividendosClick(Sender: TObject);
    procedure btnTodosClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPeterLynchClick(Sender: TObject);
    procedure btnIncluirEmpresasClick(Sender: TObject);
    procedure SpeedButtonCalculaPontuacaoClick(Sender: TObject);
  private
    { Private declarations }
    fCS: TCriticalSection;

  public
    { Public declarations }
  end;

var
  FormPopup: TFormPopup;

implementation

{$R *.fmx}


uses uDataModule, Loading, uPrincipal;

procedure TFormPopup.btnPeterLynchClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaPeterLynch(FormPrincipal.EditPapel.Text.Trim);
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);
    end).Start;
  close;

end;

procedure TFormPopup.btnPLDividaLiquidaClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaPLeDividaLiquida(FormPrincipal.EditPapel.Text.Trim);
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);
    end).Start;
  close;
end;

procedure TFormPopup.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFormPopup.btnCotacaoClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;

  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        FormPrincipal.cargaCotacao(FormPrincipal.EditPapel.Text.Trim);

      except
      end;

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);

    end).Start;
  close;

end;

procedure TFormPopup.btnTodosClick(Sender: TObject);
begin
  close;


  // TLoading.Show(FormPrincipal, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaCotacao;
      FormPrincipal.cargaInicialDividendos;
      FormPrincipal.cargaBeta;
      FormPrincipal.cargaPLeDividaLiquida;

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
          DataModule.FDQueryPapelGrid.Refresh;
        end);
    end).Start;

end;

procedure TFormPopup.FormCreate(Sender: TObject);
begin
  fCS := TCriticalSection.Create;

end;

procedure TFormPopup.SpeedButtonCalculaPontuacaoClick(Sender: TObject);
var sql : string;
begin



  FormPrincipal.StringGrid1.Visible := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      with DataModule do
      begin
        FDQueryPontuacao.Open;
        FDQueryPontuacao.First;
        while not FDQueryPontuacao.Eof do
        begin
          sql := format('update papel set pontuacao = %s where id = %d', [
            FloatToStrF (FDQueryPontuacaopontos_cotacao.AsFloat +
            FDQueryPontuacaopontos_vpa.AsFloat +
            FDQueryPontuacaopontos_pl.AsFloat +
            FDQueryPontuacaopontos_dividendos.AsFloat +
            FDQueryPontuacaopontos_divida.AsFloat +
            FDQueryPontuacaopontos_crescimento.AsFloat, ffFixed, 8,4).Replace(',','.')
            , FDQueryPontuacaoID.AsInteger]);
          FDConnection1.ExecSQL(sql);
          FDQueryPontuacao.Next;
        end;
      end;
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);
    end).Start;
  close;

end;

procedure TFormPopup.btnDividendosClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaInicialDividendos(FormPrincipal.EditPapel.Text.Trim);
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);
    end).Start;
  close;
end;

procedure TFormPopup.btnIncluirEmpresasClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.addAllCompanies(url_indexes_smallcaps, 'INDICE_SMALLCAPS');
      FormPrincipal.addAllCompanies(url_indexes_bovespa, 'INDICE_BOVESPA');

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);

    end).Start;

  close;

end;

procedure TFormPopup.btnBetaClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaBeta(FormPrincipal.EditPapel.Text.Trim);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);

    end).Start;

  close;
end;

end.
