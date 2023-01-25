SLASH_DECLINEDAGAIN1 = '/da';
SLASH_DECLINEDAGAIN2 = '/declinedagain';

local f = CreateFrame("Frame", "DeclinedAgain");
local reset = 0;
local clear = 0;
local name = UnitName("player");
local realm = GetRealmName();
local DaUIFrame = CreateFrame("Frame", "DeclinedAgainUI", UIParent)
--DaUIFrame:Hide();
DaUIFrame:SetParent(PVEFrame);

function DeclinedAgainGetAllData()
    local message = 
        "Total Applied:   "..DeclinedAgainDB.TOTAL_APPLY_COUNT..
        "\nTotal Cancelled: "..DeclinedAgainDB.TOTAL_CANCEL_COUNT..
        "\nTotal Delisted:  "..DeclinedAgainDB.TOTAL_DELIST_COUNT..
        "\nTotal Declined:  "..DeclinedAgainDB.TOTAL_DECLINE_COUNT
    return message
end

function DeclinedAgainGetPlayerData()
    local message = 
        name.." - "..realm..
        "\nApplied:   "..DeclinedAgainCharacterDB.CHARACTER_APPLY_COUNT..
        "\nCancelled: "..DeclinedAgainCharacterDB.CHARACTER_CANCEL_COUNT..
        "\nDelisted:  "..DeclinedAgainCharacterDB.CHARACTER_DELIST_COUNT..
        "\nDeclined:  "..DeclinedAgainCharacterDB.CHARACTER_DECLINE_COUNT
    return message
end

function DeclinedAgainGetHelpData()
    print("DeclinedAgain:");
    print("Commands are: /da or /declinedagain")
    print("optional parameters are 'help', 'all', 'clear', and 'reset' - /da all")
    print("You can also use /da show/hide to enable/disable the on text anchored to the lfg window")
    print(" --- ")
    print("Note - This is currently beta build with bugs likely:")
    print("Report bugs to: https://www.curseforge.com/wow/addons/declinedagain")
end

function DeclinedAgainPlayerEnteringWorld()
    DeclinedAgainDB = DeclinedAgainDB or {
        TOTAL_APPLY_COUNT    = 0,
        TOTAL_CANCEL_COUNT   = 0,
        TOTAL_DELIST_COUNT   = 0,
        TOTAL_DECLINE_COUNT  = 0
    };
    DeclinedAgainCharacterDB = DeclinedAgainCharacterDB or {
        CHARACTER_APPLY_COUNT   = 0,
        CHARACTER_CANCEL_COUNT  = 0,
        CHARACTER_DELIST_COUNT  = 0,
        CHARACTER_DECLINE_COUNT = 0
    };
end

function DeclinedAgainClearPlayerData()
    DeclinedAgainCharacterDB = {
        CHARACTER_APPLY_COUNT   = 0,
        CHARACTER_CANCEL_COUNT  = 0,
        CHARACTER_DELIST_COUNT  = 0,
        CHARACTER_DECLINE_COUNT = 0
    };
    clear = 0;
    reset = 0;
end

function DeclinedAgainResetAllData()
    DeclinedAgainDB = {
        TOTAL_APPLY_COUNT    = 0,
        TOTAL_CANCEL_COUNT   = 0,
        TOTAL_DELIST_COUNT   = 0,
        TOTAL_DECLINE_COUNT  = 0
    };
    DeclinedAgainCharacterDB = {
        CHARACTER_APPLY_COUNT   = 0,
        CHARACTER_CANCEL_COUNT  = 0,
        CHARACTER_DELIST_COUNT  = 0,
        CHARACTER_DECLINE_COUNT = 0
    };
    reset = 0;
    clear = 0;
end


function DeclinedAgainApplicationStatusUpdated(...)
    local newStatus = ...;
    --print("newStatusinfunction: ", newStatus);
    if (newStatus == "declined") then
        DeclinedAgainCharacterDB.CHARACTER_DECLINE_COUNT = DeclinedAgainCharacterDB.CHARACTER_DECLINE_COUNT + 1;
        DeclinedAgainDB.TOTAL_DECLINE_COUNT              = DeclinedAgainDB.TOTAL_DECLINE_COUNT              + 1;
    end
    if (newStatus == "applied") then
        DeclinedAgainCharacterDB.CHARACTER_APPLY_COUNT   = DeclinedAgainCharacterDB.CHARACTER_APPLY_COUNT   + 1;
        DeclinedAgainDB.TOTAL_APPLY_COUNT                = DeclinedAgainDB.TOTAL_APPLY_COUNT                + 1;
    elseif (newStatus == "cancelled") then
        DeclinedAgainCharacterDB.CHARACTER_CANCEL_COUNT  = DeclinedAgainCharacterDB.CHARACTER_CANCEL_COUNT  + 1;
        DeclinedAgainDB.TOTAL_CANCEL_COUNT               = DeclinedAgainDB.TOTAL_CANCEL_COUNT               + 1;
    elseif (newStatus == "declined_delisted") or (newStatus == "declined_full") or (newStatus == "timedout") then
        DeclinedAgainCharacterDB.CHARACTER_DELIST_COUNT  = DeclinedAgainCharacterDB.CHARACTER_DELIST_COUNT  + 1;
        DeclinedAgainDB.TOTAL_DELIST_COUNT               = DeclinedAgainDB.TOTAL_DELIST_COUNT               + 1;
    end
end

function f:OnEvent(event, ...)
	self[event](self, event, ...);
end

function DaUIFrame:OnEvent(event, ...)
	self[event](self, event, ...);
end
--function f:ADDON_LOADED(event, addOnName)
--	--print(event, addOnName);
--end

function f:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	--print(event, isLogin, isReload);
    DeclinedAgainPlayerEnteringWorld();
end

function f:LFG_LIST_APPLICATION_STATUS_UPDATED(...)
    --   local _,_,_,newStatus = ...;

    local _,searchResultID,newStatus,oldStatus,groupName = ...;
    --print("New LFG Event: ");
    --print("Search ResultID: ",searchResultID);
    --print("New Status: ",newStatus);
    --print("Old Status: ",oldStatus);
    --print("Group Name: ",groupName);
    DeclinedAgainApplicationStatusUpdated(newStatus);
    
end

function DaUIFrame:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	--print(event, isLogin, isReload);
    --DeclinedAgainPlayerEnteringWorld();
    DaUIFrame:SetSize(100, 100)
    local point, relativeFrame, relativePoint, xOffset, yOffset = 0
    --DaUIFrame:SetPoint("CENTER", -200, 0)
    DaUIFrame:SetPoint("BOTTOMLEFT", PVEFrame.NineSlice, "BOTTOMRIGHT", 20, 10)
    local myText = DaUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    myText:SetPoint("CENTER", DaUIFrame, "CENTER")
    myText:SetText(
        DeclinedAgainGetPlayerData()..
        " \n "..
        "All:\n"..
        DeclinedAgainGetAllData()
    )
    myText:SetJustifyH("Left")
end

function DaUIFrame:LFG_LIST_APPLICATION_STATUS_UPDATED(...)
    --   local _,_,_,newStatus = ...;

    --local _,searchResultID,newStatus,oldStatus,groupName = ...;
    --print("New LFG Event: ");
    --print("Search ResultID: ",searchResultID);
    --print("New Status: ",newStatus);
    --print("Old Status: ",oldStatus);
    --print("Group Name: ",groupName);
    DeclinedAgainApplicationStatusUpdated(newStatus);
    DaUIFrame:SetSize(100, 100)
    local point, relativeFrame, relativePoint, xOffset, yOffset = 0
    --DaUIFrame:SetPoint("CENTER", -200, 0)
    DaUIFrame:SetPoint("BOTTOMLEFT", PVEFrame.NineSlice, "BOTTOMRIGHT", 20, 10)
    local myText = DaUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    myText:SetPoint("CENTER", DaUIFrame, "CENTER")
    myText:SetText(
        DeclinedAgainGetPlayerData()..
        " \n "..
        "All:\n"..
        DeclinedAgainGetAllData()
    )
    myText:SetJustifyH("Left")
end


--f:RegisterEvent("ADDON_LOADED");
--f:RegisterEvent("PLAYER_LOGOUT");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED");
f:SetScript("OnEvent", f.OnEvent);

DaUIFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
DaUIFrame:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED");
DaUIFrame:SetScript("OnEvent", f.OnEvent);

SlashCmdList["DECLINEDAGAIN"] = function(msg)

    if(msg == "show") then
        DaUIFrame:SetSize(100, 100)
        local point, relativeFrame, relativePoint, xOffset, yOffset = 0
        --DaUIFrame:SetPoint("CENTER", -200, 0)
        DaUIFrame:SetPoint("BOTTOMLEFT", PVEFrame.NineSlice, "BOTTOMRIGHT", 20, 10)
        local myText = DaUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        myText:SetPoint("CENTER", DaUIFrame, "CENTER")
        myText:SetText(
            DeclinedAgainGetPlayerData()..
            " \n "..
            "All:\n"..
            DeclinedAgainGetAllData()
        )
        myText:SetJustifyH("Left")
        DaUIFrame:Show();
    end

    if(msg == "hide") then
        DaUIFrame:Hide()
    end


    if(msg == "help") then
        DeclinedAgainGetHelpData()
        return;
    end

    if(msg == "reset") then
        if(reset == 1) then
            print("Resetting all DeclinedAgain data");
            DeclinedAgainResetAllData();
        end
        if(reset == 0) then
            print("Reset removes ALL totals and counts across all characters - run /da reset again to continue")
            reset = 1;
        end
        return;
    end

    if(msg == "clear") then
        if(clear == 1) then
            print("Resetting all DeclinedAgain data");
            DeclinedAgainClearPlayerData();
        end
        if(clear == 0) then
            print("Clear removes current player counts, but leaves running totals - run /da clear again to continue")
            clear = 1;
        end
        return;
    end

    if(msg == "all") then
        print("DeclinedAgain - All")
        print(DeclinedAgainGetAllData())
        return;
    end

    if(msg == "") then
        print("DeclinedAgain - Player")
        print(DeclinedAgainGetPlayerData())
    end
end
