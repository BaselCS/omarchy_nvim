local icons_map = {
	-- Actions & Basic
	add = "󰐕",
	add_circle = "󰐖",
	add_circle_outline = "󰐗",
	remove = "󰍴",
	remove_circle = "󰍵",
	remove_circle_outline = "󰍶",
	check = "󰄬",
	check_circle = "󰄲",
	check_circle_outline = "󰄱",
	close = "󰅖",
	clear = "󰅖",
	cancel = "󰅙",
	done = "󰄬",
	done_all = "󰄲",
	edit = "󰏫",
	create = "󰏫",
	delete = "󰆴",
	delete_outline = "󰆴",
	delete_forever = "󰆴",
	refresh = "󰑐",
	sync = "󰑐",
	autorenew = "󰑐",
	search = "󰍉",
	zoom_in = "󰍉",
	zoom_out = "󰍉",

	-- Navigation & Arrows
	home = "󰋜",
	home_outlined = "󰋜",
	menu = "󰍜",
	more_vert = "󰇙",
	more_horiz = "󰇚",
	arrow_back = "󰁍",
	arrow_back_ios = "󰅁",
	arrow_forward = "󰁔",
	arrow_forward_ios = "󰅂",
	arrow_upward = "󰁝",
	arrow_downward = "󰁅",
	arrow_drop_down = "󰅀",
	arrow_drop_up = "󰅃",
	chevron_left = "󰅁",
	chevron_right = "󰅂",
	expand_more = "󰅀",
	expand_less = "󰅃",
	navigate_next = "󰅂",
	navigate_before = "󰅁",
	apps = "󰕰",
	dashboard = "󰕰",

	-- User & Communication
	person = "󰮲",
	person_outline = "󰮲",
	people = "󰮲",
	people_outline = "󰮲",
	account_circle = "󰮲",
	account_box = "󰮲",
	face = "󰮲",
	group = "󰮲",
	email = "󰇮",
	mail = "󰇮",
	mail_outline = "󰇮",
	send = "󰒭",
	chat = "󰍡",
	chat_bubble = "󰍡",
	chat_bubble_outline = "󰍡",
	comment = "󰍡",
	phone = "󰏲",
	call = "󰏲",
	phone_android = "󰏲",
	smartphone = "󰏲",
	contact_phone = "󰏲",
	contact_mail = "󰇮",

	-- Media & Content
	image = "󰋩",
	photo = "󰋩",
	photo_camera = "󰄀",
	camera = "󰄀",
	camera_alt = "󰄀",
	videocam = "󰕧",
	video_library = "󰕧",
	play_arrow = "󰐊",
	play_circle = "󰐊",
	pause = "󰏤",
	pause_circle = "󰏤",
	stop = "󰓛",
	skip_next = "󰒭",
	skip_previous = "󰒮",
	volume_up = "󰕾",
	volume_down = "󰕿",
	volume_mute = "󰝟",
	volume_off = "󰝟",
	music_note = "󰎆",
	mic = "󰍬",
	mic_none = "󰍬",
	mic_off = "󰍭",

	-- Status, Alerts & Badges
	favorite = "󰋑",
	favorite_border = "󰋕",
	favorite_outline = "󰋕",
	heart = "󰋑",
	star = "󰓎",
	star_border = "󰓏",
	star_half = "󰓏",
	thumb_up = "󰍪",
	thumb_down = "󰍫",
	notifications = "󰂚",
	notifications_none = "󰂚",
	notifications_active = "󰂚",
	notifications_off = "󰂛",
	info = "󰋽",
	info_outline = "󰋽",
	help = "󰋖",
	help_outline = "󰋖",
	warning = "󰀦",
	warning_amber = "󰀦",
	error = "󰅚",
	error_outline = "󰅙",

	-- Settings, Security & Device
	settings = "󰒓",
	settings_outlined = "󰒓",
	build = "󰒓",
	lock = "󰌾",
	lock_outline = "󰌾",
	lock_open = "󰌿",
	vpn_key = "󰌿",
	security = "󰒃",
	shield = "󰒃",
	visibility = "󰈈",
	visibility_off = "󰈉",
	share = "󰒍",
	shopping_cart = "󰄐",
	shopping_bag = "󰏿",
	credit_card = "󰏭",
	payment = "󰏭",
	attach_money = "󰏭",
	calendar_today = "󰃭",
	calendar_month = "󰃭",
	date_range = "󰃭",
	access_time = "󰀠",
	schedule = "󰀠",
	timer = "󰀠",
	alarm = "󰀠",
	location_on = "󰍎",
	place = "󰍎",
	map = "󰉋",
	pin_drop = "󰍎",
	folder = "󰉋",
	folder_open = "󰉍",
	file_copy = "󰈢",
	insert_drive_file = "󰈢",
	cloud = "󰅟",
	cloud_upload = "󰕒",
	cloud_download = "󰇚",
	cloud_done = "󰄬",
	download = "󰇚",
	file_download = "󰇚",
	upload = "󰕒",
	file_upload = "󰕒",
	wifi = "󰤨",
	wifi_off = "󰤮",
	bluetooth = "󰂯",
	battery_full = "󰁹",
	battery_alert = "󰁹",
	power = "󰁹",
	dark_mode = "󰖔",
	light_mode = "󰖨",
	brightness_high = "󰖨",
	brightness_low = "󰖔",
	wb_sunny = "󰖨",
	nightlight = "󰖔",
	flutter_dash = "󰈤",
}

local ns_id = vim.api.nvim_create_namespace("flutter_icons_preview")
local enabled = true

-- Highlight groups for Gutter & Inline
vim.api.nvim_set_hl(0, "FlutterIconSign", { fg = "#61afef", bold = true, default = true })
vim.api.nvim_set_hl(0, "FlutterImageSign", { fg = "#e5c07b", bold = true, default = true })

local function update_buffer_icons_and_images(bufnr)
	if not enabled or not vim.api.nvim_buf_is_valid(bufnr) then return end
	if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype ~= "dart" then return end

	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for lnum, line in ipairs(lines) do
		-- 1. Flutter Icons (Material & Cupertino)
		local col = 0
		local first_icon_glyph = nil
		while true do
			local s_start, s_end, icon_name = line:find("Icons%.([%w_]+)", col + 1)
			if not s_start then
				s_start, s_end, icon_name = line:find("CupertinoIcons%.([%w_]+)", col + 1)
			end

			if not s_start then break end

			local glyph = icons_map[icon_name] or icons_map[icon_name:lower()]
			if glyph then
				first_icon_glyph = first_icon_glyph or glyph
				-- Inline preview
				pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, lnum - 1, s_end, {
					virt_text = { { " " .. glyph .. " ", "FlutterIconSign" } },
					virt_text_pos = "inline",
					hl_mode = "combine",
				})
			end
			col = s_end
		end

		-- 2. Image asset paths (.png, .jpg, .svg, .webp, .gif)
		local img_path = line:match("['\"]([^'\"]+%.png)['\"]")
			or line:match("['\"]([^'\"]+%.jpe?g)['\"]")
			or line:match("['\"]([^'\"]+%.webp)['\"]")
			or line:match("['\"]([^'\"]+%.gif)['\"]")
			or line:match("['\"]([^'\"]+%.svg)['\"]")

		local first_img_glyph = nil
		if img_path then
			first_img_glyph = " "
			local _, img_end = line:find(img_path, 1, true)
			if img_end then
				pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, lnum - 1, img_end + 1, {
					virt_text = { { "   ", "FlutterImageSign" } },
					virt_text_pos = "inline",
					hl_mode = "combine",
				})
			end
		end

		-- Gutter Sign: Display in Line Numbers column
		local sign_glyph = first_icon_glyph or first_img_glyph
		local sign_hl = first_icon_glyph and "FlutterIconSign" or "FlutterImageSign"
		if sign_glyph then
			pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, lnum - 1, 0, {
				sign_text = sign_glyph,
				sign_hl_group = sign_hl,
				priority = 15,
			})
		end
	end
end

local function preview_image_under_cursor()
	local line = vim.api.nvim_get_current_line()

	local path = line:match("['\"]([^'\"]+%.png)['\"]")
		or line:match("['\"]([^'\"]+%.jpe?g)['\"]")
		or line:match("['\"]([^'\"]+%.webp)['\"]")
		or line:match("['\"]([^'\"]+%.gif)['\"]")
		or line:match("['\"]([^'\"]+%.svg)['\"]")

	if not path then
		vim.notify("No image asset path found on current line", vim.log.levels.WARN, { title = "Flutter Image" })
		return
	end

	local full_path = path
	if not path:match("^/") then
		local cwd = vim.fn.getcwd()
		full_path = cwd .. "/" .. path
	end

	if vim.fn.filereadable(full_path) == 1 then
		if Snacks and Snacks.win then
			Snacks.win({
				file = full_path,
				width = 0.6,
				height = 0.6,
				border = "rounded",
				title = " 󰋩 " .. vim.fs.basename(full_path) .. " ",
				title_pos = "center",
				keys = {
					q = "close",
					["<Esc>"] = "close",
				},
			})
		else
			vim.cmd("silent! tabnew " .. vim.fn.fnameescape(full_path))
		end
	else
		vim.notify("Image not found on disk: " .. full_path, vim.log.levels.ERROR, { title = "Flutter Image" })
	end
end

return {
	{
		"akinsho/flutter-tools.nvim",
		init = function()
			local group = vim.api.nvim_create_augroup("FlutterIconsPreview", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI", "FileType" }, {
				group = group,
				pattern = { "*.dart" },
				callback = function(args)
					vim.schedule(function()
						update_buffer_icons_and_images(args.buf)
					end)
				end,
			})
		end,
		keys = {
			{
				"<leader>uI",
				function()
					enabled = not enabled
					local bufnr = vim.api.nvim_get_current_buf()
					if not enabled then
						vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
						vim.notify("󰋩 Flutter Icons & Images Gutter Disabled", vim.log.levels.INFO)
					else
						update_buffer_icons_and_images(bufnr)
						vim.notify("󰋩 Flutter Icons & Images Gutter Enabled", vim.log.levels.INFO)
					end
				end,
				desc = "Toggle Flutter Icons & Images in Gutter/Inline",
			},
			{
				"<leader>Fv",
				preview_image_under_cursor,
				desc = "Flutter Preview Image Asset Floating Window",
			},
		},
	},
}
