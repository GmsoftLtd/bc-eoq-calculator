permissionset 50200 "EOQ Calculator"
{
    Assignable = true;
    Caption = 'EOQ Calculator';

    Permissions =
        tabledata "EOQ Setup" = RIMD,
        tabledata "EOQ Calculation Log" = RIMD,
        table "EOQ Setup" = X,
        table "EOQ Calculation Log" = X,
        page "EOQ Setup" = X,
        page "EOQ Calculation Log" = X,
        codeunit "EOQ Calculator" = X,
        codeunit "EOQ Job Queue Run" = X;
}
