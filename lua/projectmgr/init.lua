local db = require("projectmgr.db_adapter")
local window = require("projectmgr.window")
local manage = require("projectmgr.manage")
local helpers = require("projectmgr.helpers")

local M = {}
local setup_completed = false

local default_config = {
	autogit = false,
	reopen = false,
	session = { enabled = true, file = "Session.vim" },
	shada = { enabled = false, file = "main.shada" },
	scripts = {
		enabled = true,
		file_startup = "startup.sh",
		file_shutdown = "shutdown.sh",
	},
}

function M.setup(config)
	if setup_completed then
		return
	end
	config = config or {}
	vim.validate({
		autogit = { config.autogit, "b", true },
		reopen = { config.reopen, "b", true },
		session = { config.session, "t", true },
		shada = { config.shada, "t", true },
		scripts = { config.scripts, "t", true },
	})

	M.config = vim.tbl_deep_extend("keep", config, default_config)
	manage.config = M.config
	setup_completed = true
end

function M.startup()
	M.setup()
	db.prepare_db()
	if M.config.reopen and not next(vim.fn.argv()) then
		local last_open = db.get_current_project()
		manage.open_project(last_open)
	end
end

function M.shutdown()
	manage.close_project()
end

M.open_project = manage.open_project
M.close_project = manage.close_project

M.open_window = window.open_window
M.close_window = window.close_window
M.create_project = window.create_project
M.update_project = window.update_project
M.delete_project = window.delete_project

M.get_highlighted_name = helpers.get_highlighted_name

return M
