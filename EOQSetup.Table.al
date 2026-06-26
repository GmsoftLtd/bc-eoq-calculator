table 50200 "EOQ Setup"
{
    Caption = 'EOQ Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Ordering Cost"; Decimal)
        {
            Caption = 'Ordering Cost (S)';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            InitValue = 50;
        }
        field(20; "Holding Rate"; Decimal)
        {
            Caption = 'Holding Rate';
            DecimalPlaces = 4 : 4;
            MinValue = 0;
            MaxValue = 1;
            InitValue = 0.25;
        }
        field(30; "Demand Window Days"; Integer)
        {
            Caption = 'Demand Window (Days)';
            MinValue = 30;
            InitValue = 365;
        }
        field(40; "Min Observations"; Integer)
        {
            Caption = 'Minimum Observations';
            MinValue = 1;
            InitValue = 60;
        }
        field(50; "Write Target"; Option)
        {
            Caption = 'Write Target';
            OptionMembers = "Reorder Quantity","Order Multiple";
            OptionCaption = 'Reorder Quantity,Order Multiple';
            InitValue = "Reorder Quantity";
        }
        field(60; "Update Reordering Policy"; Boolean)
        {
            Caption = 'Update Reordering Policy When None';
            InitValue = true;
        }
        field(70; "Max EOQ Months"; Decimal)
        {
            Caption = 'Maximum EOQ (Months of Demand)';
            DecimalPlaces = 1 : 2;
            MinValue = 0.5;
            InitValue = 6;
        }
        field(80; "Default Cost Source"; Option)
        {
            Caption = 'Default Unit Cost Source';
            OptionMembers = "Last Direct Cost","Standard Cost","Unit Cost";
            OptionCaption = 'Last Direct Cost,Standard Cost,Unit Cost';
            InitValue = "Last Direct Cost";
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
