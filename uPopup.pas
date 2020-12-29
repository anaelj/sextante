unit uPopup;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, syncObjs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls;

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
    procedure btnPLDividaLiquidaClick(Sender: TObject);
    procedure btnBetaClick(Sender: TObject);
    procedure btnCotacaoClick(Sender: TObject);
    procedure btnDividendosClick(Sender: TObject);
    procedure btnTodosClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPeterLynchClick(Sender: TObject);
    procedure btnIncluirEmpresasClick(Sender: TObject);
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
      TThread.Synchronize(nil,
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
      TThread.Synchronize(nil,
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

      TThread.Synchronize(nil,
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

      TThread.Synchronize(nil,
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

procedure TFormPopup.btnDividendosClick(Sender: TObject);
begin
  FormPrincipal.StringGrid1.Visible := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      FormPrincipal.cargaInicialDividendos(FormPrincipal.EditPapel.Text.Trim);
      TThread.Synchronize(nil,
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
      FormPrincipal.addAllCompanies (url_indexes_smallcaps);
      FormPrincipal.addAllCompanies (url_indexes_bovespa);

      TThread.Synchronize(nil,
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

      TThread.Synchronize(nil,
        procedure
        begin
          FormPrincipal.StringGrid1.Visible := true;
        end);

    end).Start;

  close;
end;

end.
