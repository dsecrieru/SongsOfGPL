local tabb = require "engine.table"
local ui = require "engine.ui"
local uit = require "game.ui-utils"

local tb = {}

---@return boolean
function tb.mask(gam)
	local tr = ui.rect(0, 0, 800, uit.BASE_HEIGHT)
	if WORLD:does_player_control_realm(WORLD.player_realm) then
		return not ui.trigger(tr)
	else
		return true
	end
end


---@class TreasuryDisplayEffect
---@field reason EconomicReason
---@field amount number
---@field timer number

---@type TreasuryDisplayEffect[]
CURRENT_EFFECTS = {}
MAX_TREASURY_TIMER = 2.0
MIN_DELAY = 0.5


function HANDLE_EFFECTS()
	local counter = 0
	while WORLD.treasury_effects:length() > 0 do
		local temp = WORLD.treasury_effects:dequeue()
		---@type TreasuryDisplayEffect
		local new_effect = {
			reason = temp.reason,
			amount = temp.amount,
			timer = MAX_TREASURY_TIMER + counter * MIN_DELAY
		} 
		table.insert(CURRENT_EFFECTS, new_effect)
		WORLD.old_treasury_effects:enqueue(temp)
		while WORLD.old_treasury_effects:length() > OPTIONS['treasury_ledger'] do
			WORLD.old_treasury_effects:dequeue()
		end
		counter = counter + 1
	end
end

function DRAW_EFFECTS(parent_rect)
	local new_rect = parent_rect:copy()
	for _, effect in pairs(CURRENT_EFFECTS) do
		if (effect.timer < MAX_TREASURY_TIMER) then
			local r, g, b, a = love.graphics.getColor()
			if effect.amount > 0 then
				love.graphics.setColor(1, 1, 0, (effect.timer) / MAX_TREASURY_TIMER)
			else 
				love.graphics.setColor(1, 0, 0, (effect.timer) / MAX_TREASURY_TIMER)
			end

			new_rect.x = parent_rect.x
			new_rect.y = parent_rect.y + uit.BASE_HEIGHT * (1 + 2 * (MAX_TREASURY_TIMER - effect.timer) / MAX_TREASURY_TIMER)
			ui.right_text(uit.to_fixed_point2(effect.amount) .. MONEY_SYMBOL, new_rect)

			new_rect.x = parent_rect.x - parent_rect.width
			ui.left_text(effect.reason, new_rect)
			love.graphics.setColor(r, g, b, a)
		end
	end
end

---@param dt number
function tb.update(dt)
	EFFECTS_TO_REMOVE = {}
	for _, effect in pairs(CURRENT_EFFECTS) do
		effect.timer = effect.timer - dt
		if effect.timer < 0 then
			table.insert(EFFECTS_TO_REMOVE, _)
		end
	end

	for _, key in pairs(EFFECTS_TO_REMOVE) do
		table.remove(CURRENT_EFFECTS, key)
	end
end

---Draws the bar at the top of the screen (if a player realm has been selected...)
---@param gam table
function tb.draw(gam)
	if WORLD.player_realm ~= nil then
		local tr = ui.rect(0, 0, 800, uit.BASE_HEIGHT)
		ui.panel(tr)


		--- current character
		local character_panel = ui.rect(uit.BASE_HEIGHT * 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT * 11.5, uit.BASE_HEIGHT)
		ui.panel(character_panel)
		ui.left_text(WORLD.player_character.name .. "(You)", character_panel)
		character_panel.x = character_panel.x + 6.5 * uit.BASE_HEIGHT
		character_panel.width = uit.BASE_HEIGHT
		ui.image(ASSETS.icons['coins.png'], character_panel)
		character_panel.width = 4 * uit.BASE_HEIGHT
		character_panel.x = character_panel.x + uit.BASE_HEIGHT
		ui.right_text(uit.to_fixed_point2(WORLD.player_character.savings) .. MONEY_SYMBOL, character_panel)

		-- COA + name
		local layout = ui.layout_builder()
			:position(0, 0)
			:horizontal()
			:build()
		if uit.coa(WORLD.player_realm, layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)) then
			print("Player COA Clicked")
			gam.inspector = "realm"
			gam.selected_realm = WORLD.player_realm
			---@type Tile
			local captile = tabb.nth(WORLD.player_realm.capitol.tiles, 1)
			gam.click_tile(captile.tile_id)
		end
		ui.left_text(WORLD.player_realm.name, layout:next(uit.BASE_HEIGHT * 5.5, uit.BASE_HEIGHT))

		-- Treasury
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Treasury"
		ui.image(ASSETS.icons['coins.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 4, uit.BASE_HEIGHT)
		ui.right_text(uit.to_fixed_point2(WORLD.player_realm.treasury) .. MONEY_SYMBOL, trt)
		ui.tooltip(trs, trt)

		HANDLE_EFFECTS()
		DRAW_EFFECTS(trt)

		-- Food
		local amount = WORLD.player_realm.resources[WORLD.trade_goods_by_name['food']] or 0
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Food"
		ui.image(ASSETS.icons['noodles.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 4, uit.BASE_HEIGHT)
		ui.right_text(tostring(math.floor(amount * 100) / 100), trt)
		ui.tooltip(trs, trt)

		-- Technology
		local amount = WORLD.player_realm:get_education_efficiency()
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Current ability to research new technologies. When it's under 100%, technologies will be slowly forgotten, when above 100% they will be researched. Controlled largely through treasury spending on research and education but in most states the bulk of the contribution will come from POPs in the realm instead."
		ui.image(ASSETS.icons['erlenmeyer.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT)
		uit.color_coded_percentage(amount, trt)
		ui.tooltip(trs, trt)

		-- Happiness
		local amount = WORLD.player_realm:get_average_mood()
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Average mood (happiness) of population in our realm. Happy pops contribute more voluntarily to our treasury, whereas unhappy ones contribute less."
		ui.image(ASSETS.icons['duality-mask.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT)
		ui.right_text(tostring(math.floor(amount)), trt)
		ui.tooltip(trs, trt)

		-- POP
		local amount = WORLD.player_realm:get_total_population()
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Current population of our realm."
		ui.image(ASSETS.icons['minions.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT)
		ui.right_text(tostring(math.floor(amount)), trt)
		ui.tooltip(trs, trt)

		-- Army size
		local amount = WORLD.player_realm:get_realm_military()
		local target = WORLD.player_realm:get_realm_military_target() + WORLD.player_realm:get_realm_active_army_size()
		local tr = layout:next(uit.BASE_HEIGHT, uit.BASE_HEIGHT)
		local trs = "Size of our realms armies."
		ui.image(ASSETS.icons['barbute.png'], tr)
		ui.tooltip(trs, tr)
		local trt = layout:next(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT)
		ui.right_text(tostring(math.floor(amount)) .. ' / ' .. tostring(math.floor(target)), trt)
		ui.tooltip(trs, trt)

		layout:next(uit.BASE_HEIGHT * 0.5, uit.BASE_HEIGHT)

		if ui.text_button("Military tab", layout:next(uit.BASE_HEIGHT * 4, uit.BASE_HEIGHT)) then
			gam.inspector = "army"
		end
	end
end

return tb