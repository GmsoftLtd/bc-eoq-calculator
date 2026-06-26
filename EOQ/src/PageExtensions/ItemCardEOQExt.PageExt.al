pageextension 50200 "Item Card EOQ Ext" extends "Item Card"
{
    actions
    {
        addafter(Functions)
        {
            group(EOQActions)
            {
                Caption = 'EOQ';
                Image = Calculate;

                action("Calculate EOQ")
                {
                    Caption = 'Calculate EOQ (Wilson)';
                    ToolTip = 'Computes Economic Order Quantity from posted demand and unit cost, then asks before writing the value to Reorder Quantity or Order Multiple.';
                    ApplicationArea = All;
                    Image = Calculate;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        Calc: Codeunit "EOQ Calculator";
                        ResultCode: Enum "EOQ Result Code";
                        AppliedQty: Decimal;
                        Confirm: Boolean;
                        Msg: Text;
                    begin
                        Item := Rec;
                        if Calc.Calculate(Item, false, ResultCode, AppliedQty) then begin
                            Msg := StrSubstNo('EOQ for %1: %2 units.\Previous value: %3.\Result: %4. Apply to %5?',
                                Item."No.", Format(AppliedQty, 0, 9), Format(GetCurrentTarget(Item), 0, 9), Format(ResultCode), GetTargetFieldCaption());
                            Confirm := Dialog.Confirm(Msg, true);
                            if Confirm then begin
                                Calc.Calculate(Item, true, ResultCode, AppliedQty);
                                CurrPage.Update(true);
                                Message('EOQ applied: %1 units.', Format(AppliedQty, 0, 9));
                            end;
                        end else begin
                            Message('EOQ not applied. Result: %1. See EOQ Calculation Log for details.', Format(ResultCode));
                        end;
                    end;
                }
                action("View EOQ Log")
                {
                    Caption = 'View EOQ Log';
                    ToolTip = 'Opens the calculation log filtered to this item.';
                    ApplicationArea = All;
                    Image = ViewDetails;

                    trigger OnAction()
                    var
                        Log: Record "EOQ Calculation Log";
                    begin
                        Log.SetRange("Item No.", Rec."No.");
                        Page.RunModal(Page::"EOQ Calculation Log", Log);
                    end;
                }
            }
        }
    }

    local procedure GetCurrentTarget(Item: Record Item): Decimal
    var
        Setup: Record "EOQ Setup";
    begin
        Setup.GetSetup();
        if Setup."Write Target" = Setup."Write Target"::"Reorder Quantity" then
            exit(Item."Reorder Quantity")
        else
            exit(Item."Order Multiple");
    end;

    local procedure GetTargetFieldCaption(): Text
    var
        Setup: Record "EOQ Setup";
    begin
        Setup.GetSetup();
        if Setup."Write Target" = Setup."Write Target"::"Reorder Quantity" then
            exit('Reorder Quantity')
        else
            exit('Order Multiple');
    end;
}
