return {
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			local flutter_component = {
				function()
					local has_decorations, decorations = pcall(require, "flutter-tools.decorations")
					if not has_decorations then
						return ""
					end
					local device = decorations.get_device()
					if not device or device == "" then
						return "󰈤 Flutter"
					end
					return "󰈤 " .. device
				end,
				cond = function()
					return vim.bo.filetype == "dart" or vim.fn.filereadable("pubspec.yaml") == 1
				end,
				color = { fg = "#02569B", gui = "bold" },
				on_click = function(clicks, button, _)
					if button == "l" then
						vim.cmd("FlutterReload")
					elseif button == "r" then
						vim.cmd("FlutterDevices")
					end
				end,
			}

			table.insert(opts.sections.lualine_x, 2, flutter_component)
		end,
	},
}
