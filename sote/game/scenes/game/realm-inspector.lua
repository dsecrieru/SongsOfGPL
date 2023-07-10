local re = {}
local tabb = require "engine.table"
local ui = require "engine.ui"
local uit = require "game.ui-utils"

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	local panel = fs:subrect(0, 0, 500, 500, "left", 'down')
	return panel
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function re.mask()
	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

---@param gam table
function re.draw(gam)
	---@diagnostic disable-next-line: assign-type-mismatch
	local rrealm = gam.selected_realm
	if rrealm ~= nil then
		---@type Realm
		local realm = rrealm
		local panel = get_main_panel()
		ui.panel(panel)

		if ui.icon_button(ASSETS.icons["cancel.png"], panel:subrect(0, 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT, "right", 'up')) then
			gam.click_tile(-1)
			gam.selected_realm = nil
			gam.inspector = nil
		end

		-- COA
		uit.coa(realm, panel:subrect(0, 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT, "left", 'up'))
		ui.left_text(realm.name,
			panel:subrect(uit.BASE_HEIGHT + 5, 0, 10 * uit.BASE_HEIGHT, uit.BASE_HEIGHT, "left", 'up'))

		local ui_panel = panel:subrect(5, uit.BASE_HEIGHT * 2, panel.width - 10, panel.height - 10 - uit.BASE_HEIGHT * 2,
			"left", 'up')
		gam.realm_inspector_tab = gam.realm_inspector_tab or "GEN"
		local tabs = {
			{
				text = "GEN",
				tooltip = "General",
				closure = function()
					local panel_rect = ui_panel:subrect(0, 0, uit.BASE_HEIGHT * 6, uit.BASE_HEIGHT, "left", 'up')
					uit.data_entry("Culture: ", realm.primary_culture.name, panel_rect)
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Faith: ", realm.primary_faith.name, panel_rect)
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Race: ", realm.primary_race.name, panel_rect)
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
				end
			},
			{
				text = "TRE",
				tooltip = "Treasury",
				closure = function()
					local panel_rect = ui_panel:subrect(0, 0, uit.BASE_HEIGHT * 6, uit.BASE_HEIGHT, "left", 'up')
					uit.data_entry("Treasury", tostring(math.floor(100 * realm.treasury) / 100) .. MONEY_SYMBOL, panel_rect, "Treasury")
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Voluntary contributions",
						tostring(math.floor(100 * realm.voluntary_contributions) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Voluntary contributions")
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Building upkeep", tostring(math.floor(100 * realm.building_upkeep) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Building upkeep")
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Waste", tostring(math.floor(100 * realm.wasted_treasury) / 100) .. MONEY_SYMBOL, panel_rect,
						"Keeping large stockpiles of wealth is inherently inefficient. Whether through corruption, spoilage, wear or accidents, a small fraction of accumulated wealth is lost. The process can be countered by creation of storage buildings.")
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Inf. investment",
						tostring(math.floor(100 * realm.monthly_infrastructure_investment) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Automatic infrastructure investments each month.")
					if WORLD.player_realm then
						if WORLD.player_realm == realm then
							panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
							local pr = panel_rect:subrect(0, 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT, "left", 'up')
							-- Make a closure for easier button creation
							local function do_one(amount)
								if ui.text_button(tostring(amount) .. MONEY_SYMBOL, pr,
									"Change monthly infrastructure investment by " .. tostring(amount)) then
									WORLD.player_realm.monthly_infrastructure_investment = math.max(0,
										WORLD.player_realm.monthly_infrastructure_investment + amount)
								end
								pr.x = pr.x + uit.BASE_HEIGHT
							end

							do_one(-10)
							do_one(-1)
							do_one(-0.1)
							do_one(0.1)
							do_one(1)
							do_one(10)
						end
					end
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Edu. investment",
						tostring(math.floor(100 * realm.monthly_education_investment) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Automatic education investments each month.")
					if WORLD.player_realm then
						if WORLD.player_realm == realm then
							panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
							local pr = panel_rect:subrect(0, 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT, "left", 'up')
							-- Make a closure for easier button creation
							local function do_one(amount)
								if ui.text_button(tostring(amount) .. MONEY_SYMBOL, pr,
									"Change monthly education investment by " .. tostring(amount)) then
									WORLD.player_realm.monthly_education_investment = math.max(0,
										WORLD.player_realm.monthly_education_investment + amount)
								end
								pr.x = pr.x + uit.BASE_HEIGHT
							end

							do_one(-10)
							do_one(-1)
							do_one(-0.1)
							do_one(0.1)
							do_one(1)
							do_one(10)
						end
					end
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Court investment",
						tostring(math.floor(100 * realm.monthly_court_investment) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Automatic court investments each month.")
					if WORLD.player_realm then
						if WORLD.player_realm == realm then
							panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
							local pr = panel_rect:subrect(0, 0, uit.BASE_HEIGHT, uit.BASE_HEIGHT, "left", 'up')
							-- Make a closure for easier button creation
							local function do_one(amount)
								if ui.text_button(tostring(amount) .. MONEY_SYMBOL, pr,
									"Change monthly court investment by " .. tostring(amount)) then
									WORLD.player_realm.monthly_court_investment = math.max(0,
										WORLD.player_realm.monthly_court_investment + amount)
								end
								pr.x = pr.x + uit.BASE_HEIGHT
							end

							do_one(-10)
							do_one(-1)
							do_one(-0.1)
							do_one(0.1)
							do_one(1)
							do_one(10)
						end
					end
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Military upkeep",
						tostring(math.floor(100 * realm.military_spending) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Costs of upkeep for current units.")
					panel_rect.y = panel_rect.y + uit.BASE_HEIGHT
					uit.data_entry("Treasury change", tostring(math.floor(100 * realm.treasury_real_delta) / 100) .. MONEY_SYMBOL,
						panel_rect,
						"Actual change compared to last month. Takes into account factors that may otherwise be hidden.")
				end
			},
			{
				text = "STO",
				tooltip = "Stockpiles",
				closure = function()
					local goods = {}
					for good, amount in pairs(realm.resources) do
						if good.category == 'good' then
							goods[good] = amount
						end
					end
					gam.realm_stockpile_scrollbar = gam.realm_stockpile_scrollbar or 0
					gam.realm_stockpile_scrollbar = ui.scrollview(ui_panel, function(entry, rect)
						if entry > 0 then
							---@type TradeGood
							local good, amount = tabb.nth(goods, entry)
							local delta = realm.production[good] or 0

							local w = rect.width
							rect.width = rect.height
							ui.image(ASSETS.get_icon(good.icon), rect)

							rect.width = w
							rect.x = rect.x + rect.height
							rect.width = rect.width - rect.height
							ui.left_text(good.name, rect)
							ui.right_text(
								tostring(math.floor(100 * amount) / 100) .. ' (' ..
								tostring(math.floor(100 * delta) / 100) .. ')',
								rect
							)
						end
					end, uit.BASE_HEIGHT, tabb.size(goods), uit.BASE_HEIGHT, gam.realm_stockpile_scrollbar)
				end
			},
			{
				text = "ADM",
				tooltip = "Administration",
				closure = function()
					local goods = {}
					for good, amount in pairs(realm.production) do
						if good.category == 'capacity' then
							goods[good] = amount
						end
					end
					gam.realm_capacities_scrollbar = gam.realm_capacities_scrollbar or 0
					gam.realm_capacities_scrollbar = ui.scrollview(ui_panel, function(entry, rect)
						if entry > 0 then
							---@type TradeGood
							local good, amount = tabb.nth(goods, entry)

							local w = rect.width
							rect.width = rect.height
							ui.image(ASSETS.get_icon(good.icon), rect)

							rect.width = w
							rect.x = rect.x + rect.height
							rect.width = rect.width - rect.height
							ui.left_text(good.name, rect)
							ui.right_text(tostring(math.floor(100 * amount) / 100), rect)
						end
					end, uit.BASE_HEIGHT, tabb.size(goods), uit.BASE_HEIGHT, gam.realm_capacities_scrollbar)
				end
			},
			{
				text = "COU",
				tooltip = "Court",
				closure = function()
					local a = ui_panel:subrect(0, 0, uit.BASE_HEIGHT * 8, uit.BASE_HEIGHT, "left", 'up')
					uit.data_entry("Court wealth: ", tostring(math.floor(100 * realm.court_wealth) / 100) .. MONEY_SYMBOL, a,
						"Investment.")
					a.y = a.y + uit.BASE_HEIGHT

					uit.data_entry("Court wealth. needed: ", tostring(math.floor(100 * realm.court_wealth_needed) / 100) .. MONEY_SYMBOL
						, a,
						"Needed court wealth.")
					a.y = a.y + uit.BASE_HEIGHT
					uit.data_entry("Court investments: ",
						tostring(math.floor(100 * realm.court_investment) / 100) .. MONEY_SYMBOL
						, a,
						"Amount of funds spent supporting the court through any variety of means.")
					a.y = a.y + uit.BASE_HEIGHT
					if WORLD.player_realm == realm then
						local p = a:copy()
						p.width = p.height
						local do_one = function(rect, max_amount)
							local ah = tostring(math.floor(100 * max_amount) / 100)
							if WORLD.player_realm.treasury > 0.1 then
								if ui.text_button(ah .. MONEY_SYMBOL, rect, 'Invest ' .. ah) then
									local inv = math.min(realm.treasury, max_amount)
									realm.treasury = realm.treasury - inv
									realm.court_investment = realm.court_investment + inv
								end
							else
								ui.centered_text(ah .. MONEY_SYMBOL, rect)
							end
							rect.x = rect.x + rect.height
						end
						do_one(p, 0.1)
						do_one(p, 1)
						do_one(p, 10)
						do_one(p, 100)
					end
					a.y = a.y + uit.BASE_HEIGHT
				end
			},
			{
				text = "MAR",
				tooltip = "Market",
				closure = function()
					local goods = {}
					for good, _ in pairs(realm.bought) do
						goods[good] = realm:get_price(good)
					end
					for good, _ in pairs(realm.sold) do
						goods[good] = realm:get_price(good)
					end
					gam.realm_market_scrollbar = gam.realm_market_scrollbar or 0
					gam.realm_market_scrollbar = ui.scrollview(ui_panel, function(entry, rect)
						if entry > 0 then
							---@type TradeGood
							local good, price = tabb.nth(goods, entry)

							local w = rect.width
							rect.width = rect.height
							ui.image(ASSETS.get_icon(good.icon), rect)

							rect.width = w
							rect.x = rect.x + rect.height
							rect.width = rect.width - rect.height
							ui.left_text(good.name, rect)
							ui.right_text(tostring(math.floor(100 * price) / 100) .. MONEY_SYMBOL, rect)
						end
					end, uit.BASE_HEIGHT, tabb.size(goods), uit.BASE_HEIGHT, gam.realm_market_scrollbar)
				end
			},
			{
				text = "EDU",
				tooltip = "Education and research",
				closure = function()
					local a = ui_panel:subrect(0, 0, uit.BASE_HEIGHT * 8, uit.BASE_HEIGHT, "left", 'up')
					uit.data_entry("Endowment: ", tostring(math.floor(100 * realm.education_endowment) / 100) .. MONEY_SYMBOL, a,
						"Investment.")
					a.y = a.y + uit.BASE_HEIGHT

					uit.data_entry("Endwm. needed: ", tostring(math.floor(100 * realm.education_endowment_needed) / 100) .. MONEY_SYMBOL
						, a,
						"Needed endowment to support current technologies.")
					a.y = a.y + uit.BASE_HEIGHT
					uit.data_entry("Education investments: ",
						tostring(math.floor(100 * realm.education_investment) / 100) .. MONEY_SYMBOL
						, a,
						"Amount of funds spent supporting research through any variety of means, ranging from funding private alchemists to gifting tribe shamans.")
					a.y = a.y + uit.BASE_HEIGHT
					if WORLD.player_realm == realm then
						local p = a:copy()
						p.width = p.height
						local do_one = function(rect, max_amount)
							local ah = tostring(math.floor(100 * max_amount) / 100)
							if WORLD.player_realm.treasury > 0.1 then
								if ui.text_button(ah .. MONEY_SYMBOL, rect, 'Invest ' .. ah) then
									local inv = math.min(realm.treasury, max_amount)
									realm.treasury = realm.treasury - inv
									realm.education_investment = realm.education_investment + inv
								end
							else
								ui.centered_text(ah .. MONEY_SYMBOL, rect)
							end
							rect.x = rect.x + rect.height
						end
						do_one(p, 0.1)
						do_one(p, 1)
						do_one(p, 10)
						do_one(p, 100)
					end
					a.y = a.y + uit.BASE_HEIGHT
					uit.data_entry("Education efficiency: ",
						tostring(math.floor(100 * realm:get_education_efficiency())) .. '%'
						, a,
						"A percentage value. Endowment present over endowment needed")
					a.y = a.y + uit.BASE_HEIGHT
				end
			},
			{
				text = "DEC",
				tooltip = "Decisions",
				on_select = function()
					gam.reset_decision_selection()
				end,
				closure = function()
					uit.decision_tab(ui_panel, nil, 'none', gam)
				end
			},
			{
				text = "RDC",
				tooltip = "Realm decisions",
				on_select = function()
					gam.reset_decision_selection()
				end,
				closure = function()
					uit.decision_tab(ui_panel, realm, 'realm', gam)
				end
			},
			{
				text = "WAR",
				tooltip = "Warfare",
				closure = function()
					--ui_panel
					ui.panel(ui_panel)
					local sl = gam.wars_slider_level or 0
					gam.wars_slider_level = ui.scrollview(ui_panel, function(i, rect)
						if i > 0 then
							---@type Rect
							local r = rect
							---@type War
							local war = tabb.nth(realm.wars, i)
							local w = r.width
							r.width = r.height
							if ui.icon_button(ASSETS.get_icon("guards.png"), r) then
								-- Select the war
								gam.inspector = "war"
								gam.selected_war = war
							end
							r.width = w - r.height
							r.x = r.x + r.height
							ui.panel(r)
							r.x = r.x + 5
							r.width = r.width - 5
							---@type Realm
							local att = tabb.nth(war.attackers, 1)
							---@type Realm
							local def = tabb.nth(war.defenders, 1)
							ui.left_text(att.name .. " vs " .. def.name, r)
						end
					end, uit.BASE_HEIGHT, tabb.size(realm.wars), uit.BASE_HEIGHT, sl)
				end
			},
			{
				text="MIL",
				tooltip="Military",
				closure = function()
					-- draw a panel
					ui.panel(ui_panel)

					-- display warbands
					ui_panel.height = ui_panel.height / 2
					local warbands = realm:get_warbands()
					local sl = gam.warbands_slider_level or 0
					-- local height = uit.BASE_HEIGHT
					gam.warbands_slider_level = ui.scrollview(ui_panel, function(i, rect) 
						if i > 0 then
							---@type Rect
							local r = rect
							local width_unit = r.width / 4
							local x = r.x
							
							r.width = width_unit * 2
							---@type Warband
							local warband = warbands[i]
							ui.left_text("Band" .. "  " .. warband.name, r)							
							
							r.width = width_unit
							r.x = x + width_unit * 2
							ui.left_text(warband.status, r)

							r.x = x + width_unit * 3
							ui.left_text("units: ", r)
							ui.right_text(' ' .. warband:size(), r)
						end
					end, uit.BASE_HEIGHT, tabb.size(warbands), uit.BASE_HEIGHT, sl)

					-- display raiding targets
					ui_panel.y = ui_panel.y + ui_panel.height
					ui.text("Raiding targets", ui_panel, "left", 'up')
					ui_panel.y = ui_panel.y + uit.BASE_HEIGHT
					ui_panel.height = ui_panel.height - uit.BASE_HEIGHT
					local targets = realm.raiding_targets
					local sl = gam.raiding_targets_slider_level or 0
					gam.raiding_targets_slider_level = ui.scrollview(ui_panel, function(i, rect)
						if i > 0 then
							---@type Rect
							local r = rect
							local width_unit = r.width / 5
							local x = r.x
							r.width = width_unit

							---@type Province
							local target = tabb.nth(targets, i)
							ui.left_text(target.name, r)


							r.x = x + 4 * width_unit
							ui.left_text("Gathered forces:", r)
							local warbands = realm.raiders_preparing[target]
							local size = 0
							for _, warband in pairs(warbands) do
								size = size  + warband:size()
							end
							ui.right_text(tostring(size), r)
						end
					end,  uit.BASE_HEIGHT, tabb.size(targets), uit.BASE_HEIGHT, sl)
				end
			}
		}
		local layout = ui.layout_builder()
			:position(panel.x, panel.y + uit.BASE_HEIGHT)
			:spacing(2)
			:horizontal()
			:build()
		gam.realm_inspector_tab = uit.tabs(gam.realm_inspector_tab, layout, tabs)
	end
end

return re
