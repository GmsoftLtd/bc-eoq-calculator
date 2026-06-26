table 50201 "EOQ Calculation Log"
{
    Caption = 'EOQ Calculation Log';
    DataClassification = CustomerContent;
    DrillDownPageId = "EOQ Calculation Log";
    LookupPageId = "EOQ Calculation Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(20; "Calculation Date"; Date)
        {
            Caption = 'Calculation Date';
        }
        field(21; "Calculation Time"; Time)
        {
            Caption = 'Calculation Time';
        }
        field(30; "Demand Window Days"; Integer)
        {
            Caption = 'Demand Window (Days)';
        }
        field(40; "Observations Count"; Integer)
        {
            Caption = 'Observations Count';
        }
        field(50; "Annual Demand"; Decimal)
        {
            Caption = 'Annual Demand (D)';
            DecimalPlaces = 0 : 4;
        }
        field(60; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 2 : 4;
        }
        field(70; "Holding Rate"; Decimal)
        {
            Caption = 'Holding Rate';
            DecimalPlaces = 4 : 4;
        }
        field(80; "Holding Cost"; Decimal)
        {
            Caption = 'Holding Cost (H)';
            DecimalPlaces = 2 : 4;
        }
        field(90; "Ordering Cost"; Decimal)
        {
            Caption = 'Ordering Cost (S)';
            DecimalPlaces = 2 : 4;
        }
        field(100; "Calculated EOQ"; Decimal)
        {
            Caption = 'Calculated EOQ (raw)';
            DecimalPlaces = 0 : 4;
        }
        field(110; "Applied Quantity"; Decimal)
        {
            Caption = 'Applied Quantity';
            DecimalPlaces = 0 : 4;
        }
        field(120; "Previous Value"; Decimal)
        {
            Caption = 'Previous Value';
            DecimalPlaces = 0 : 4;
        }
        field(130; "Write Target"; Option)
        {
            Caption = 'Write Target';
            OptionMembers = "Reorder Quantity","Order Multiple";
            OptionCaption = 'Reorder Quantity,Order Multiple';
        }
        field(140; "Result Code"; Enum "EOQ Result Code")
        {
            Caption = 'Result Code';
        }
        field(150; Notes; Text[250])
        {
            Caption = 'Notes';
        }
        field(160; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Item; "Item No.", "Calculation Date") { }
    }
}
