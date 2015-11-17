local Addon = CreateFrame("FRAME", "AlterBags");

local itemTable = {};

-----------------------
--	helpful functions
-----------------------

local function getNumOfBags()
	local numBags = 0;
	for i = 0, 5 do
		if(GetBagName(i)) then
			numBags = numBags + 1;
		end
	end
	return numBags;
end

local function getNumOfSlots()
	local numSlots = 0;
	for i = 0, 5 do
		if(GetContainerNumSlots(i)) then
			numSlots = numSlots + GetContainerNumSlots(i);
		end
	end
end


local function searchBags()
	table.wipe(itemTable[UnitName("player")]);
	local numBags, numSlotBags = getNumOfBags();
	for i = 0, numBags do
		numSlotBags = GetContainerNumSlots(i) or 0; --0 if player has something like this: [X][bag3][X][bag2][bag1]
		for j = 1, numSlotBags do
			if(GetContainerItemLink(i,j)) then
				itemTable[UnitName("player")][GetItemInfo(GetContainerItemLink(i,j))] = GetItemCount(GetContainerItemLink(i,j)); --check GetItemCount and GetContainerItemInfo
			end
		end
	end
end

local function searchBank()


end


Addon:SetScript("OnEvent", function(self, event, ...)
	if (event == "BAG_UPDATE") then
		print("bagupdate")
		searchBags();
	elseif (event == "BANKFRAME_OPENED") then
		searchBank();
	elseif (event == "BAG_CLOSED") then
		searchBags();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local totalElapsed = 0;
		Addon:SetScript("OnUpdate", function(self, elapsed)
			totalElapsed = totalElapsed + elapsed;
			if(totalElapsed > 1) then
				Addon:RegisterEvent("BAG_UPDATE");
				Addon:RegisterEvent("BANKFRAME_OPENED");
				Addon:RegisterEvent("BAG_CLOSED");
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

Addon:RegisterEvent("PLAYER_ENTERING_WORLD")
Addon:RegisterEvent("VARIABLES_LOADED")

local oldScript = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(self, ...)
	for name in pairs(itemTable) do
		local itemCount = itemTable[name][self:GetItem()];
		if(itemCount) then
			self:AddLine(name .. ": " .. itemCount);
		end
	end
	
	if oldScript then 
		return oldScript(self, ...)
	end
end)


function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		else
			print(formatting .. tostring(v))
		end
	end
end
