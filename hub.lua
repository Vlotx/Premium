local httpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local function notify(text)
	StarterGui:SetCore("SendNotification", {
		Title = "RIMURUHUB", --Yoru Hub
		Text = text,
		Duration = 5,
	})
end

local http_request = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or
                         (krnl and krnl.request) or (request) or (http_request) or (httpc and httpc.request) or
                         (game and game.HttpGet and function(tbl)
        return {
            Body = game:HttpGet(tbl.Url)
        }
    end)
if not http_request then return end

if _G.lastCheck and tick() - _G.lastCheck < 10 then
	notify("กรุณารอสักครู่ก่อนที่จะส่งคำขออีกครั้ง")
	return
end

if typeof(_G.key) ~= "string" or #_G.key < 5 then
	notify("Key Error หรือ Key สั้นเกินไป!")
	return
end

_G.lastCheck = tick()

local data = {
	key = _G.key,
	clientId = game:GetService("RbxAnalyticsService"):GetClientId(),
}

local json = httpService:JSONEncode(data)
local response = http_request({
	Url = "https://backend-keyroblox-production.up.railway.app/check-key",
	Method = "POST",
	Headers = {
		["Content-Type"] = "application/json",
	},
	Body = json,
})

if response and response.Body then
	local decoded = httpService:JSONDecode(response.Body)
	if decoded.success and decoded.token then
		notify("ยืนยัน Key สำเร็จ")

		local scriptRes = http_request({
			Url = "https://backend-keyroblox-production.up.railway.app/load-script?token=" .. decoded.token,
			Method = "GET",
		})

		if scriptRes and scriptRes.Body then
			local scriptUrl = scriptRes.Body
			if type(scriptUrl) == "string" and #scriptUrl > 0 then
				local scriptContentRes = http_request({
					Url = scriptUrl,
					Method = "GET",
				})
				if scriptContentRes and scriptContentRes.Body then
					local success, run = pcall(loadstring(scriptContentRes.Body))
					if success then
						run()
					else
						notify("โหลดสคริปต์ไม่สำเร็จ")
					end
				else
					notify("ดึงเนื้อหาสคริปต์จาก URL ล้มเหลว")
				end
			else
				notify("ไม่พบ URL ของสคริปต์")
			end
		else
			notify("โหลดสคริปต์ล้มเหลว")
		end
	else
		notify("Key ไม่ถูกต้อง")
	end
else
	notify("การติดต่อเซิร์ฟเวอร์ล้มเหลว")
end
