local requests = require('requests')
local url = os.getenv('HA_URL') .. '/api/services/device_tracker/see'
local cjson = require "cjson"
local headers = {
    ["Authorization"] = "Bearer " .. os.getenv('HA_TOKEN'),
    ["Content-Type"] = "application/json",
}

function otr_init()
    otr.log('hooks.lua enabled; posting updates to ' .. os.getenv('HA_URL'))
end

function otr_hook(topic, _type, data)
    msg = otr.strftime('%c') .. '\t' .. data['username'] .. '\t' .. data['device'] .. '\t' .. data['lat'] .. '\t' .. data['lon'] .. '\t' .. data['acc'] .. '\t' .. data['batt']
    otr.log(msg)

    print(cjson.encode(data))
    local body = {
        dev_id = data['device'],
	battery = data['batt'],
	gps = {data['lat'], data['lon']},
	gps_accuracy = data['acc']
    }
    res = requests.post{url, headers = headers, data = body}
    otr.log('Response: ' .. res.status_code)
end

function otr_exit()
    otr.log('hooks.lua disabled')
end



