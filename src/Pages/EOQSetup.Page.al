page 50200 "EOQ Setup"
{
    Caption = 'EOQ Setup';
    PageType = Card;
    SourceTable = "EOQ Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Costs)
            {
                Caption = 'Costs';
                field("Ordering Cost"; Rec."Ordering Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default ordering cost (S) per purchase order, used in the Wilson EOQ formula. Typical range: 25 to 200 in your local currency.';
                }
                field("Holding Rate"; Rec."Holding Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the annual holding rate as a decimal (e.g. 0.25 for 25 percent). Multiplied by Unit Cost to get the holding cost (H) per unit per year.';
                }
                field("Default Cost Source"; Rec."Default Cost Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which field on the Item card is used as Unit Cost. Last Direct Cost is typical for FIFO/Average; Standard Cost for items costed with the Standard method.';
                }
            }
            group(Demand)
            {
                Caption = 'Demand';
                field("Demand Window Days"; Rec."Demand Window Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many days of history to use when computing annual demand. Default 365 days. Shorten for items with strong growth or decline trends.';
                }
                field("Min Observations"; Rec."Min Observations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum number of Item Ledger Entries of type Sale required before EOQ will be calculated. Below this threshold the calculation is skipped.';
                }
            }
            group(Output)
            {
                Caption = 'Output';
                field("Write Target"; Rec."Write Target")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Item field the calculated EOQ is written to. Reorder Quantity for Fixed Reorder Qty. policy; Order Multiple for Lot-for-Lot with economic batch rounding.';
                }
                field("Update Reordering Policy"; Rec."Update Reordering Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Reordering Policy on the Item should be switched to Fixed Reorder Qty. when the current policy is None. Only applies when Write Target is Reorder Quantity.';
                }
                field("Max EOQ Months"; Rec."Max EOQ Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cap on EOQ expressed as months of demand. Prevents extreme quantities for slow movers. Default 6 months.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
