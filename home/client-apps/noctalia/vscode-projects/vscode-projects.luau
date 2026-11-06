--!nonstrict

-- launcher provider：只读 service.luau 写的 projects.json 缓存再做过滤，
-- 避免在 onQuery 的 CPU 预算内做重扫描。缓存未生成时提示等待。

local MAX_RESULTS = 50

local function loadProjects()
	local raw = noctalia.readFile(noctalia.pluginDataDir() .. "/projects.json")
	if type(raw) ~= "string" or raw == "" then
		return nil
	end
	local ok, projects = pcall(noctalia.json.decode, raw)
	if not ok or type(projects) ~= "table" then
		return nil
	end
	return projects
end

local function resultRows(query)
	local projects = loadProjects()
	if projects == nil then
		return {
			{ id = "", title = "Scanning VSCode projects…", subtitle = "first scan running in background", glyph = "loader" },
		}
	end

	local filter = query:gsub("^%s+", ""):gsub("%s+$", "")
	local rows = {}
	for _, project in ipairs(projects) do
		if filter == "" then
			table.insert(rows, {
				id = project.path,
				title = project.name,
				glyph = "folder",
			})
		else
			local score = noctalia.fuzzyScore(filter, project.name .. " " .. project.path)
			if score then
				table.insert(rows, {
					id = project.path,
					title = project.name,
					glyph = "folder",
					score = score,
				})
			end
		end
		if #rows >= MAX_RESULTS then
			break
		end
	end
	return rows
end

function onQuery(query)
	local rows = resultRows(query)
	if #rows == 0 then
		rows = { { id = "", title = "No matching projects", glyph = "code" } }
	end
	launcher.setResults(query, rows)
end

function onActivate(id)
	if id == "" then
		return
	end
	-- shell 字符串形式 + sleep：等 launcher 关闭后再拉起窗口
	local dir = id:gsub("'", "'\\''")
	if not noctalia.runAsync("sleep 0.15; code '" .. dir .. "'") then
		noctalia.notifyError("VSCode Projects", "Failed to spawn code")
	end
end
