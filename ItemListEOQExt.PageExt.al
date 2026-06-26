pageextension 50201 "Item List EOQ Ext" extends "Item List"
{
    actions
    {
        addafter(Functions)
        {
            group(EOQActions)
            {
                Caption = 'EOQ';
                Image = Calculate;

                action("Calculate EOQ Bulk")
                {
                    Caption = 'Calculate EOQ (Bulk)';
                    ToolTip = 'Runs the Wilson EOQ calculation across the filtered set of items, applies the result, and writes a log entry for each.';
                    ApplicationArea = All;
                    Image = CalculateLines;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        Calc: Codeunit "EOQ Calculator";
                        ResultCode: Enum "EOQ Result Code";
                        AppliedQty: Decimal;
                        Dlg: Dialog;
                        Processed: Integer;
                        Applied: Integer;
                        Skipped: Integer;
                        Total: Integer;
                    begin
                        CurrPage.SetSelectionFilter(Item);
                        if Item.IsEmpty() then begin
                            Item.Reset();
                            Item.CopyFilters(Rec);
                        end;

                        Total := Item.Count;
                        if Total = 0 then begin
                            Message('No items in the current filter.');
                            exit;
                        end;

                        if not Confirm(StrSubstNo('Calculate EOQ for %1 items and apply the values? This cannot be undone (but is logged).', Total), false) then
                            exit;

                        Dlg.Open('Calculating EOQ\#1######## of #2########\Applied: #3########  Skipped: #4########');
                        Dlg.Update(2, Total);

                        if Item.FindSet() then
                            repeat
                                Processed += 1;
                                Dlg.Update(1, Processed);
                                if Calc.Calculate(Item, true, ResultCode, AppliedQty) then
                                    Applied += 1
                                else
                                    Skipped += 1;
                                Dlg.Update(3, Applied);
                                Dlg.Update(4, Skipped);
                            until Item.Next() = 0;

                        Dlg.Close();
                        Message('EOQ bulk run complete.\Processed: %1\Applied: %2\Skipped: %3\See EOQ Calculation Log for details.', Processed, Applied, Skipped);
                    end;
                }
                action("Open EOQ Log")
                {
                    Caption = 'EOQ Calculation Log';
                    ToolTip = 'Opens the EOQ calculation log.';
                    ApplicationArea = All;
                    Image = Log;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"EOQ Calculation Log");
                    end;
                }
                action("EOQ Setup")
                {
                    Caption = 'EOQ Setup';
                    ToolTip = 'Opens the EOQ Setup card.';
                    ApplicationArea = All;
                    Image = Setup;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"EOQ Setup");
                    end;
                }
            }
        }
    }
}
