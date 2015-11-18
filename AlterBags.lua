local Addon = CreateFrame("FRAME", "AlterBags");

local itemTable = {};					--table that will be a reference to SavedVariable


-------------------------------------
--
-- Search player's bags and stores all items in itemTable
--
-------------------------------------
local function searchBags()
	table.wipe(itemTable[UnitName("player")]);
	local numSlotBags;
	for i = 0, 4 do
		numSlotBags = GetContainerNumSlots(i);
		for j = 1, numSlotBags do
			if(GetContainerItemLink(i,j)) then
				itemTable[UnitName("player")][GetItemInfo(GetContainerItemLink(i,j))] = GetItemCount(GetContainerItemLink(i,j));
			end
		end
	end
end


-------------------------------------
-- TODO
-- Search player's bank and stores all items in itemTable
--
-------------------------------------
local function searchBank()

end


-------------------------------------
-- 
-- Addon event function.
-- The following events are registered:
-- "BAG_UPDATE"
-- "BANKFRAME_OPENED"
-- "PLAYER_ENTERING_WORLD"
-- "VARIABLES_LOADED"
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event, ...)
	if (event == "BAG_UPDATE") then
		searchBags();
	elseif (event == "BANKFRAME_OPENED") then
		searchBank();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local totalElapsed = 0;
		Addon:SetScript("OnUpdate", function(self, elapsed)
			totalElapsed = totalElapsed + elapsed;
			if(totalElapsed > 1) then
				Addon:RegisterEvent("BAG_UPDATE");
				Addon:RegisterEvent("BANKFRAME_OPENED");
				Addon:SetScript("OnUpdate", nil);
			end
		end)
	elseif (event == "VARIABLES_LOADED") then
		if (type(AlterBagsSV[UnitName("player")]) ~= "table") then
			AlterBagsSV[UnitName("player")] = {};
		elseif (type(AlterBagsSV) ~= "table") then
			AlterBagsSV = {};
			AlterBagsSV[UnitName("player")] = {};
		end
		itemTable = AlterBagsSV;
	end
end)


-------------------------------------
-- 
-- HookScript function.
-- This adds a new line for every character that has the item.
--
-------------------------------------
local itemTooltipFunction = function(self)
	for name in pairs(itemTable) do
		local itemCount = itemTable[name][self:GetItem()];
		if(itemCount) then
			self:AddLine(name .. ": " .. itemCount);
		end
	end
end

_G["GameTooltip"]:HookScript("OnTooltipSetItem", itemTooltipFunction)


Addon:RegisterEvent("PLAYER_ENTERING_WORLD")
Addon:RegisterEvent("VARIABLES_LOADED")