page 50201 "EOQ Calculation Log"
{
    Caption = 'EOQ Calculation Log';
    PageType = List;
    SourceTable = "EOQ Calculation Log";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Calculation Date"; Rec."Calculation Date")
                {
                    ApplicationArea = All;
                }
                field("Calculation Time"; Rec."Calculation Time")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Observations Count"; Rec."Observations Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of Item Ledger Entries of type Sale in the demand window.';
                }
                field("Annual Demand"; Rec."Annual Demand")
                {
                    ApplicationArea = All;
                    ToolTip = 'Computed annual demand (D) used in the formula.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Holding Rate"; Rec."Holding Rate")
                {
                    ApplicationArea = All;
                }
                field("Holding Cost"; Rec."Holding Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Holding cost per unit per year (H = Unit Cost x Holding Rate).';
                }
                field("Ordering Cost"; Rec."Ordering Cost")
                {
                    ApplicationArea = All;
                }
                field("Calculated EOQ"; Rec."Calculated EOQ")
                {
                    ApplicationArea = All;
                    ToolTip = 'Raw EOQ from the Wilson formula before rounding or capping.';
                }
                field("Applied Quantity"; Rec."Applied Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'The quantity actually written to the target field (after rounding and capping).';
                }
                field("Previous Value"; Rec."Previous Value")
                {
                    ApplicationArea = All;
                }
                field("Write Target"; Rec."Write Target")
                {
                    ApplicationArea = All;
                }
                field("Result Code"; Rec."Result Code")
                {
                    ApplicationArea = All;
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
