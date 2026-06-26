codeunit 50201 "EOQ Job Queue Run"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Item: Record Item;
        Calc: Codeunit "EOQ Calculator";
        ResultCode: Enum "EOQ Result Code";
        AppliedQty: Decimal;
        ParamString: Text;
        Processed: Integer;
        Applied: Integer;
        Skipped: Integer;
    begin
        ParamString := Rec."Parameter String";
        ApplyParameterFilters(Item, ParamString);

        if Item.FindSet() then
            repeat
                Processed += 1;
                if Calc.Calculate(Item, true, ResultCode, AppliedQty) then
                    Applied += 1
                else
                    Skipped += 1;
            until Item.Next() = 0;

        // Surface a summary in the Job Queue log
        Error('Summary: Processed %1, Applied %2, Skipped %3. (This is informational; Job Queue treats it as a soft summary.)', Processed, Applied, Skipped);
    end;

    local procedure ApplyParameterFilters(var Item: Record Item; ParamString: Text)
    var
        FilterPart: Text;
        FilterPairs: List of [Text];
        Pair: Text;
        ColonPos: Integer;
        FieldName: Text;
        FilterValue: Text;
        Parts: List of [Text];
        WorkingString: Text;
        SemiPos: Integer;
    begin
        // Expected format: FILTER=Item Category Code:FERT;Vendor No.:V0001
        if ParamString = '' then exit;

        if StrPos(UpperCase(ParamString), 'FILTER=') = 1 then begin
            WorkingString := CopyStr(ParamString, 8);
            while StrLen(WorkingString) > 0 do begin
                SemiPos := StrPos(WorkingString, ';');
                if SemiPos = 0 then begin
                    FilterPart := WorkingString;
                    WorkingString := '';
                end else begin
                    FilterPart := CopyStr(WorkingString, 1, SemiPos - 1);
                    WorkingString := CopyStr(WorkingString, SemiPos + 1);
                end;
                ColonPos := StrPos(FilterPart, ':');
                if ColonPos > 0 then begin
                    FieldName := CopyStr(FilterPart, 1, ColonPos - 1);
                    FilterValue := CopyStr(FilterPart, ColonPos + 1);
                    ApplyOneFilter(Item, FieldName, FilterValue);
                end;
            end;
        end;
    end;

    local procedure ApplyOneFilter(var Item: Record Item; FieldName: Text; FilterValue: Text)
    begin
        case UpperCase(FieldName) of
            'ITEM CATEGORY CODE':
                Item.SetFilter("Item Category Code", FilterValue);
            'VENDOR NO.':
                Item.SetFilter("Vendor No.", FilterValue);
            'NO.':
                Item.SetFilter("No.", FilterValue);
            'INVENTORY POSTING GROUP':
                Item.SetFilter("Inventory Posting Group", FilterValue);
            'GEN. PROD. POSTING GROUP':
                Item.SetFilter("Gen. Prod. Posting Group", FilterValue);
            else
                ; // Unknown field, silently skip
        end;
    end;
}
