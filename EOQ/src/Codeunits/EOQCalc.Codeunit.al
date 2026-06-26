codeunit 50200 "EOQ Calculator"
{
    var
        Setup: Record "EOQ Setup";
        SetupLoaded: Boolean;

    procedure Calculate(var Item: Record Item; Apply: Boolean; var ResultCode: Enum "EOQ Result Code"; var AppliedQty: Decimal): Boolean
    var
        Log: Record "EOQ Calculation Log";
        AnnualDemand: Decimal;
        ObsCount: Integer;
        UnitCost: Decimal;
        HoldingCost: Decimal;
        OrderingCost: Decimal;
        RawEOQ: Decimal;
        CappedEOQ: Decimal;
        PreviousValue: Decimal;
        WriteTarget: Option "Reorder Quantity","Order Multiple";
        Notes: Text[250];
    begin
        EnsureSetup();

        // Validate item
        if Item.Blocked then begin
            ResultCode := Enum::"EOQ Result Code"::"Item Blocked";
            LogResult(Item."No.", 0, 0, 0, 0, 0, 0, 0, 0, 0, Setup."Write Target", ResultCode, 'Item is blocked.');
            exit(false);
        end;

        // Step 1: Get demand observations
        GetDemandFromILE(Item."No.", AnnualDemand, ObsCount);

        if ObsCount < Setup."Min Observations" then begin
            ResultCode := Enum::"EOQ Result Code"::"Insufficient Observations";
            Notes := StrSubstNo('Found %1 observations, need %2.', ObsCount, Setup."Min Observations");
            LogResult(Item."No.", ObsCount, AnnualDemand, 0, 0, 0, 0, 0, 0, 0, Setup."Write Target", ResultCode, Notes);
            exit(false);
        end;

        if AnnualDemand <= 0 then begin
            ResultCode := Enum::"EOQ Result Code"::"Zero Demand";
            LogResult(Item."No.", ObsCount, 0, 0, 0, 0, 0, 0, 0, 0, Setup."Write Target", ResultCode, 'Annual demand is zero or negative.');
            exit(false);
        end;

        // Step 2: Resolve unit cost
        UnitCost := GetUnitCost(Item);
        if UnitCost <= 0 then begin
            ResultCode := Enum::"EOQ Result Code"::"Zero Unit Cost";
            LogResult(Item."No.", ObsCount, AnnualDemand, 0, Setup."Holding Rate", 0, Setup."Ordering Cost", 0, 0, 0, Setup."Write Target", ResultCode, 'Unit cost is zero. Cannot compute holding cost.');
            exit(false);
        end;

        HoldingCost := UnitCost * Setup."Holding Rate";

        // Step 3: Resolve ordering cost
        OrderingCost := Setup."Ordering Cost";
        if OrderingCost <= 0 then begin
            ResultCode := Enum::"EOQ Result Code"::"Zero Ordering Cost";
            LogResult(Item."No.", ObsCount, AnnualDemand, UnitCost, Setup."Holding Rate", HoldingCost, 0, 0, 0, 0, Setup."Write Target", ResultCode, 'Ordering cost is zero in Setup.');
            exit(false);
        end;

        // Step 4: Wilson formula
        RawEOQ := Sqrt((2 * AnnualDemand * OrderingCost) / HoldingCost);

        // Step 5: Apply maximum cap (months of demand)
        CappedEOQ := RawEOQ;
        if (Setup."Max EOQ Months" > 0) and (AnnualDemand > 0) then begin
            if CappedEOQ > (AnnualDemand * Setup."Max EOQ Months" / 12) then begin
                CappedEOQ := Round(AnnualDemand * Setup."Max EOQ Months" / 12, 1);
                ResultCode := Enum::"EOQ Result Code"::"Cap Applied";
                Notes := StrSubstNo('Raw EOQ %1 capped to %2 (%3 months of demand).', Format(RawEOQ, 0, 9), Format(CappedEOQ, 0, 9), Setup."Max EOQ Months");
            end;
        end;

        // Step 6: Round to integer (most BC items track integer units; adjust if rounding precision matters)
        CappedEOQ := Round(CappedEOQ, 1);

        // Step 7: Respect Item Order Multiple if set and writing to Reorder Quantity
        if (Setup."Write Target" = Setup."Write Target"::"Reorder Quantity") and (Item."Order Multiple" > 0) then
            CappedEOQ := Round(CappedEOQ / Item."Order Multiple", 1, '>') * Item."Order Multiple";

        AppliedQty := CappedEOQ;

        // Step 8: Apply if requested
        WriteTarget := Setup."Write Target";
        if Apply then
            ApplyToItem(Item, CappedEOQ, WriteTarget, PreviousValue);

        if ResultCode <> Enum::"EOQ Result Code"::"Cap Applied" then
            ResultCode := Enum::"EOQ Result Code"::OK;

        LogResult(Item."No.", ObsCount, AnnualDemand, UnitCost, Setup."Holding Rate", HoldingCost, OrderingCost, RawEOQ, CappedEOQ, PreviousValue, Setup."Write Target", ResultCode, Notes);
        exit(true);
    end;

    local procedure GetDemandFromILE(ItemNo: Code[20]; var AnnualDemand: Decimal; var ObsCount: Integer)
    var
        ILE: Record "Item Ledger Entry";
        WindowStart: Date;
        TotalQty: Decimal;
        Multiplier: Decimal;
    begin
        AnnualDemand := 0;
        ObsCount := 0;
        TotalQty := 0;

        WindowStart := CalcDate(StrSubstNo('<-%1D>', Setup."Demand Window Days"), WorkDate());

        ILE.SetCurrentKey("Item No.", "Entry Type", "Posting Date");
        ILE.SetRange("Item No.", ItemNo);
        ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
        ILE.SetRange("Posting Date", WindowStart, WorkDate());
        if ILE.FindSet() then
            repeat
                // Sales create negative quantities in ILE
                TotalQty += Abs(ILE.Quantity);
                ObsCount += 1;
            until ILE.Next() = 0;

        // Annualise: total qty in window scaled to 365 days
        if Setup."Demand Window Days" > 0 then begin
            Multiplier := 365 / Setup."Demand Window Days";
            AnnualDemand := TotalQty * Multiplier;
        end;
    end;

    local procedure GetUnitCost(Item: Record Item): Decimal
    begin
        case Setup."Default Cost Source" of
            Setup."Default Cost Source"::"Last Direct Cost":
                exit(Item."Last Direct Cost");
            Setup."Default Cost Source"::"Standard Cost":
                exit(Item."Standard Cost");
            Setup."Default Cost Source"::"Unit Cost":
                exit(Item."Unit Cost");
        end;
        exit(Item."Last Direct Cost");
    end;

    local procedure ApplyToItem(var Item: Record Item; NewQty: Decimal; WriteTarget: Option "Reorder Quantity","Order Multiple"; var PreviousValue: Decimal)
    begin
        case WriteTarget of
            WriteTarget::"Reorder Quantity":
                begin
                    PreviousValue := Item."Reorder Quantity";
                    Item.Validate("Reorder Quantity", NewQty);
                    if Setup."Update Reordering Policy" and (Item."Reordering Policy" = Item."Reordering Policy"::" ") then
                        Item.Validate("Reordering Policy", Item."Reordering Policy"::"Fixed Reorder Qty.");
                    Item.Modify(true);
                end;
            WriteTarget::"Order Multiple":
                begin
                    PreviousValue := Item."Order Multiple";
                    Item.Validate("Order Multiple", NewQty);
                    Item.Modify(true);
                end;
        end;
    end;

    local procedure LogResult(ItemNo: Code[20]; ObsCount: Integer; AnnualDemand: Decimal; UnitCost: Decimal; HoldingRate: Decimal; HoldingCost: Decimal; OrderingCost: Decimal; RawEOQ: Decimal; AppliedQty: Decimal; PreviousValue: Decimal; WriteTarget: Option "Reorder Quantity","Order Multiple"; ResultCode: Enum "EOQ Result Code"; Notes: Text[250])
    var
        Log: Record "EOQ Calculation Log";
    begin
        Log.Init();
        Log."Item No." := ItemNo;
        Log."Calculation Date" := WorkDate();
        Log."Calculation Time" := Time();
        Log."Demand Window Days" := Setup."Demand Window Days";
        Log."Observations Count" := ObsCount;
        Log."Annual Demand" := AnnualDemand;
        Log."Unit Cost" := UnitCost;
        Log."Holding Rate" := HoldingRate;
        Log."Holding Cost" := HoldingCost;
        Log."Ordering Cost" := OrderingCost;
        Log."Calculated EOQ" := RawEOQ;
        Log."Applied Quantity" := AppliedQty;
        Log."Previous Value" := PreviousValue;
        Log."Write Target" := WriteTarget;
        Log."Result Code" := ResultCode;
        Log.Notes := Notes;
        Log."User ID" := CopyStr(UserId(), 1, MaxStrLen(Log."User ID"));
        Log.Insert();
    end;

    local procedure EnsureSetup()
    begin
        if SetupLoaded then exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;

    local procedure Sqrt(x: Decimal): Decimal
    var
        guess: Decimal;
        i: Integer;
    begin
        if x <= 0 then exit(0);
        guess := x / 2;
        // Newton-Raphson, 20 iterations is more than enough for double precision
        for i := 1 to 20 do
            guess := (guess + x / guess) / 2;
        exit(guess);
    end;
}
