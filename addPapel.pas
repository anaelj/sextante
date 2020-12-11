unit addPapel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Edit;

type
  TfrmAddPapel = class(TForm)
    Rectangle1: TRectangle;
    EditPapel: TEdit;
    btnSalvar: TSpeedButton;
    btnClose: TSpeedButton;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAddPapel: TfrmAddPapel;

implementation

{$R *.fmx}


uses uPrincipal, uDataModule;

procedure TfrmAddPapel.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAddPapel.btnSalvarClick(Sender: TObject);
var
  idPapel: Integer;
begin
  TryStrToInt(DataModule.FDConnection1.ExecSQLScalar(format('select id from papel where descricao = ''%s''',
    [EditPapel.Text])), idPapel);
  if idPapel > 0 then
    ShowMessage('Papel Já cadastrado')
  ELSE
  BEGIN
    DataModule.FDConnection1.ExecSQL(format('insert into papel (descricao) values (''%s'')', [EditPapel.Text]));
    Close;
    FormPrincipal.EditPapel.Text := EditPapel.Text;
    FormPrincipal.btnFiltrarClick(self);
    ShowMessage('Papel cadastrado com sucesso!')
  end;
  Close;
end;

end.
