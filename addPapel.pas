unit addPapel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Edit;

type
  TfrmAddPapel = class(TForm)
    Rectangle1: TRectangle;
    EditPapel: TEdit;
    btnSalvar: TSpeedButton;
    btnClose: TSpeedButton;
    procedure btnSalvarClick(Sender: TObject);
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

procedure TfrmAddPapel.btnSalvarClick(Sender: TObject);
begin
   DataModule.FDConnection1.ExecSQL(format('insert into papel (descricao) values (''%s'')', [EditPapel.Text]));
   close;
   FormPrincipal.EditPapel.Text :=  EditPapel.Text;
   FormPrincipal.btnFiltrarClick(self);
end;

end.
