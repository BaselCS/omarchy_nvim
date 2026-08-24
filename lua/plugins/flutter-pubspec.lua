local function search_and_add_package(is_dev)
	local has_snacks, snacks = pcall(require, "snacks")
	if not has_snacks or not snacks.picker then
		-- Fallback to standard input if snacks not loaded
		vim.ui.input({ prompt = is_dev and "Add Dev Dependency: " or "Add Dependency: " }, function(input)
			if not input or input == "" then return end
			local pkg = vim.trim(input)
			local cmd = { "flutter", "pub", "add" }
			if is_dev then table.insert(cmd, "--dev") end
			table.insert(cmd, pkg)
			vim.fn.jobstart(cmd, {
				on_exit = function(_, code)
					if code == 0 then
						vim.notify("Added " .. pkg .. "!", vim.log.levels.INFO, { title = "Flutter Pub" })
						vim.cmd("checktime")
					else
						vim.notify("Failed to add " .. pkg, vim.log.levels.ERROR, { title = "Flutter Pub" })
					end
				end,
			})
		end)
		return
	end

	snacks.picker({
		title = is_dev and "Pub.dev (Dev Dependency)" or "Pub.dev (Dependency)",
		live = true,
		finder = function(_, ctx)
			local query = ctx.filter.search
			if not query or #query < 2 then
				return {}
			end
			local handle = io.popen("curl -s 'https://pub.dev/api/search?q=" .. vim.fn.escape(query, "'") .. "'")
			if not handle then return {} end
			local res_json = handle:read("*a")
			handle:close()

			local ok, data = pcall(vim.json.decode, res_json)
			local items = {}
			if ok and data and data.packages then
				for _, p in ipairs(data.packages) do
					table.insert(items, {
						text = p.package,
						file = p.package,
					})
				end
			end
			return items
		end,
		format = function(item, _)
			return {
				{ "󰈤 ", "Special" },
				{ item.text, "Title" },
			}
		end,
		confirm = function(picker, item)
			picker:close()
			if not item or not item.text then return end
			local pkg = item.text
			local cmd = { "flutter", "pub", "add" }
			if is_dev then
				table.insert(cmd, "--dev")
			end
			table.insert(cmd, pkg)

			vim.notify("Adding " .. pkg .. " via flutter pub add...", vim.log.levels.INFO, { title = "Flutter Pub" })

			vim.fn.jobstart(cmd, {
				stdout_buffered = true,
				stderr_buffered = true,
				on_exit = function(_, code, _)
					if code == 0 then
						vim.notify("Successfully added " .. pkg .. "!", vim.log.levels.INFO, { title = "Flutter Pub" })
						vim.cmd("checktime")
					else
						vim.notify("Failed to add " .. pkg .. ". Check logs.", vim.log.levels.ERROR, { title = "Flutter Pub" })
					end
				end,
			})
		end,
	})
end

return {
	{
		"folke/which-key.nvim",
		opts = function(_, opts)
			local keys = {
				{ "<leader>Fa", function() search_and_add_package(false) end, desc = "Pubspec: Search & Add Dependency" },
				{ "<leader>FA", function() search_and_add_package(true) end, desc = "Pubspec: Search & Add Dev Dependency" },
			}
			for _, k in ipairs(keys) do
				table.insert(opts.spec or {}, k)
			end
		end,
		keys = {
			{ "<leader>Fa", function() search_and_add_package(false) end, desc = "Pubspec: Search & Add Dependency" },
			{ "<leader>FA", function() search_and_add_package(true) end, desc = "Pubspec: Search & Add Dev Dependency" },
		},
	},
}
