enum 50200 "EOQ Result Code"
{
    Extensible = true;

    value(0; OK)
    {
        Caption = 'OK';
    }
    value(10; "Insufficient Observations")
    {
        Caption = 'Insufficient Observations';
    }
    value(20; "Zero Demand")
    {
        Caption = 'Zero Demand';
    }
    value(30; "Zero Unit Cost")
    {
        Caption = 'Zero Unit Cost';
    }
    value(40; "Zero Ordering Cost")
    {
        Caption = 'Zero Ordering Cost';
    }
    value(50; "Item Blocked")
    {
        Caption = 'Item Blocked';
    }
    value(60; "Cap Applied")
    {
        Caption = 'Maximum EOQ Cap Applied';
    }
    value(99; "Update Failed")
    {
        Caption = 'Update Failed';
    }
}
