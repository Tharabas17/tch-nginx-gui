--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-core')

local format = string.format
local ui_helper = require("web.ui_helper")
local content_helper = require("web.content_helper")
local proxy = require("datamodel")

local session = ngx.ctx.session
local modalPath = "/modals/relay-modal.lp"
if session:hasAccess(modalPath) then

local dhcprelay_state = "connected"

local relay_Params = {
    uci_relay_server_ip = "uci.dhcp.relay.@relay.server_addr",
    uci_relay_local_ip = "uci.dhcp.relay.@relay.local_addr",
    interface = "uci.dhcp.relay.@relay.interface"
}
local getBackUpValues = content_helper.convertResultToObject("uci.dhcp.relaybackup.", proxy.get("uci.dhcp.relaybackup."))
content_helper.getExactContent(relay_Params)

local server_addr = proxy.get("uci.dhcp.relay.@relay.server_addr")

if not server_addr or (server_addr[1].value == "" and proxy.get("uci.dhcp.relay.@relay.local_addr")[1].value == "") then
  dhcprelay_state = "disabled"
  if getBackUpValues and next(getBackUpValues) then
    for _, v in pairs(getBackUpValues) do
      relay_Params["uci_relay_server_ip"] = v.server_addr
      relay_Params["uci_relay_local_ip"]  = v.local_addr
      relay_Params["interface"]  = v.interface
    end
  end
end

local dhcp_light_map = {
  disabled = "off",
  connected = "green",
}
local dhcp_state_map = {
    disabled = T"DHCP Relay disabled",
    connected = T"DHCP Relay enabled",
}

  ngx.print('\
<div class="span3">\
    <div class="smallcard" data-aos="fade-up" data-aos-anchor-placement="center-bottom" data-aos-easing="ease-in-back">\
      ');  ngx.print( ui_helper.createCardHeader(T"Relay Setup", "modals/relay-modal.lp") ); ngx.print('\
      <div class="content card_bg" data-bg-text="&#xf079;">\
        ');  ngx.print(ui_helper.createSimpleLight(nil, dhcp_state_map[dhcprelay_state] , { light = { class = dhcp_light_map[dhcprelay_state], id = "relaysetupcard_dhcprelaystatusled" },  span = { id = "relaysetupcard_dhcprelaystatus" }}))
          if server_addr and not server_addr[1].value == "" then 
		    ngx.print(format('<p class = "subinfos" > Server IP : <strong id="relaysetupcard_relayip">%s</strong></p>',relay_Params["uci_relay_server_ip"] ))
            ngx.print(format('<p class = "subinfos" > Local IP : <strong id="relaysetupcard_relayip">%s</strong></p>',relay_Params["uci_relay_local_ip"] ))
            ngx.print(format('<p class = "subinfos" > Interface : <strong id="relaysetupcard_relayip">%s</strong></p>',relay_Params["interface"] ))
          end
		  ngx.print('\
     </div>\
    </div>\
</div>\
');  
end
  ngx.print('\
'); 