return {
	"benomahony/uv.nvim",
	ft = { "python" },
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		picker_integration = true,

		-- Auto-activate virtual envs when found
		auto_activate_venv = true,
		notify_activate_venv = false, -- Show notification when venv activates

		-- Auto-commands for directory changes
		auto_commands = true,

		-- Execution options
		execution = {
			notify_output = true, -- Show command output in notifications
			notification_timeout = 10000, -- 10 second timeout for notifications
		},
	},
}
