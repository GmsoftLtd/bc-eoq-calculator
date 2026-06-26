/// <summary>
/// Tests for the BC EOQ Calculator ("EOQ Calculator" codeunit).
/// </summary>
codeunit 59200 "EOQ Calculator Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure ReturnsItemBlockedForBlockedItem()
    var
        Item: Record Item;
        Calc: Codeunit "EOQ Calculator";
        ResultCode: Enum "EOQ Result Code";
        AppliedQty: Decimal;
        Ok: Boolean;
    begin
        // [GIVEN] A blocked item
        CreateItem(Item, 10);
        Item.Blocked := true;

        // [WHEN] Calculating EOQ
        Ok := Calc.Calculate(Item, false, ResultCode, AppliedQty);

        // [THEN] It fails with the Item Blocked result code
        LibraryAssert.IsFalse(Ok, 'Calculate should return false for a blocked item');
        LibraryAssert.AreEqual(ResultCode::"Item Blocked", ResultCode, 'Blocked item should yield Item Blocked');
    end;

    [Test]
    procedure ReturnsInsufficientObservationsWithoutDemand()
    var
        Item: Record Item;
        Calc: Codeunit "EOQ Calculator";
        ResultCode: Enum "EOQ Result Code";
        AppliedQty: Decimal;
    begin
        // [GIVEN] An item with cost but no sales history (default Min Observations = 60)
        CreateItem(Item, 10);

        // [WHEN] Calculating EOQ
        Calc.Calculate(Item, false, ResultCode, AppliedQty);

        // [THEN] It fails due to insufficient observations
        LibraryAssert.AreEqual(ResultCode::"Insufficient Observations", ResultCode, 'No demand should yield Insufficient Observations');
    end;

    [Test]
    procedure CalculatesPositiveEOQForValidItem()
    var
        Item: Record Item;
        Setup: Record "EOQ Setup";
        Calc: Codeunit "EOQ Calculator";
        ResultCode: Enum "EOQ Result Code";
        AppliedQty: Decimal;
        Ok: Boolean;
    begin
        // [GIVEN] Setup that accepts 1 observation with no cap, an item with cost and sales demand
        Setup.GetSetup();
        Setup."Min Observations" := 1;
        Setup."Max EOQ Months" := 0;
        Setup.Modify();

        CreateItem(Item, 10);
        CreateSale(Item."No.", CalcDate('<-5D>', WorkDate()), 100);

        // [WHEN] Calculating EOQ (without applying)
        Ok := Calc.Calculate(Item, false, ResultCode, AppliedQty);

        // [THEN] A positive order quantity is produced
        LibraryAssert.IsTrue(Ok, 'Calculate should succeed for a valid item');
        LibraryAssert.AreEqual(ResultCode::OK, ResultCode, 'A valid item should yield OK');
        LibraryAssert.IsTrue(AppliedQty > 0, 'EOQ should be greater than zero');
    end;

    local procedure CreateItem(var Item: Record Item; LastDirectCost: Decimal)
    begin
        Item.Init();
        Item."No." := CopyStr('EOQTEST-' + Format(Random(999999)), 1, MaxStrLen(Item."No."));
        Item.Type := Item.Type::Inventory;
        Item."Replenishment System" := Item."Replenishment System"::Purchase;
        Item."Last Direct Cost" := LastDirectCost;
        Item.Insert(true);
    end;

    local procedure CreateSale(ItemNo: Code[20]; PostingDate: Date; Qty: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        LastEntry: Record "Item Ledger Entry";
        NextEntryNo: Integer;
    begin
        if LastEntry.FindLast() then
            NextEntryNo := LastEntry."Entry No." + 1
        else
            NextEntryNo := 1;
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." := NextEntryNo;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
        ItemLedgerEntry.Quantity := -Qty; // sales post as negative quantity
        ItemLedgerEntry.Insert(false);
    end;
}
