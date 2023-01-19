SLASH_DECLINEDAGAIN1 = '/da';
SLASH_DECLINEDAGAIN2 = '/declinedagain';

local f = CreateFrame("Frame", "DeclinedAgain");
local reset = 0;
local clear = 0;

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

--f:RegisterEvent("ADDON_LOADED");
--f:RegisterEvent("PLAYER_LOGOUT");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED");
f:SetScript("OnEvent", f.OnEvent);


SlashCmdList["DECLINEDAGAIN"] = function(msg)

    local name = UnitName("player");
    local realm = GetRealmName();

    if(msg == "help") then
        print("DeclinedAgain:");
        print("Commands are: /da or /declinedagain")
        print("optional parameters are 'help', 'all', 'clear', and 'reset' - /da all")
        print("Note - This is currently an alpha build with bugs:")
        print(" --- ")
        print("Report bugs to: https://www.curseforge.com/wow/addons/declinedagain")
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
        print("DeclinedAgain:");
        print("Total Applied:   "         , DeclinedAgainDB.TOTAL_APPLY_COUNT );
        print("Total Cancelled: "       , DeclinedAgainDB.TOTAL_CANCEL_COUNT);
        print("Total Delisted:  "        , DeclinedAgainDB.TOTAL_DELIST_COUNT);
        print("Total Declined:  "        , DeclinedAgainDB.TOTAL_DECLINE_COUNT);
        return;
    end

    if(msg == "") then
        print("DeclinedAgain (" , name , " - " , realm , "):");
        print("Applied:   "     , DeclinedAgainCharacterDB.CHARACTER_APPLY_COUNT   );
        print("Cancelled: "   , DeclinedAgainCharacterDB.CHARACTER_CANCEL_COUNT  );
        print("Delisted:  "    , DeclinedAgainCharacterDB.CHARACTER_DELIST_COUNT  );
        print("Declined:  "    , DeclinedAgainCharacterDB.CHARACTER_DECLINE_COUNT );
    end
end
