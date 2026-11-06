--!nonstrict

-- 周期驱动 scan.py 生成项目缓存；缓存写到 pluginDataDir() 跨重启保留。
-- 重扫描放 service 是因为 launcher 的 onQuery 有严格 CPU 预算，
-- 直接扫 40KiB 的 state.vscdb 会在预算内超时。

local SCAN_INTERVAL_MS = 15000

local function scan(cachePath, pluginDir)
	-- argv 形式（路径原样传递，无需 shell 转义），需要 plugin_api >= 24
	if not noctalia.runAsync({ "python3", pluginDir .. "/scan.py", cachePath }, function(result)
		if result.exitCode ~= 0 then
			noctalia.log(string.format("vscode-projects scan failed: exit=%d %s", result.exitCode, result.stderr))
		end
	end) then
		noctalia.log("vscode-projects: failed to start scan.py")
	end
end

noctalia.setUpdateInterval(SCAN_INTERVAL_MS)

local pluginDir = noctalia.pluginDir()
local cachePath = noctalia.pluginDataDir() .. "/projects.json"

-- 启动立即扫一次，之后每个 interval 重扫
scan(cachePath, pluginDir)

function update()
	scan(cachePath, pluginDir)
end
