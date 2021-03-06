-- THX Jacek ;)
function getTecTimeTv_m3u8(url)
	local box, ret, feed_data = downloadFile(url, '', true, user_agent2)
	if feed_data then
		local m3u_url = feed_data:match('hlsvp.:.(https:\\.-m3u8)')	-- no NLS
		m3u_url = m3u_url:gsub('\\', '')	-- no NLS
		return m3u_url
	end
	return nil
end -- function getTecTimeTv_m3u8

function playLivestream(_id)
	i = tonumber(_id)
	local title = videoTable[i][1] .. ' ' .. l.lifeTitle	-- no NLS
	local url = videoTable[i][2]
	local parse_m3u8 = tonumber(videoTable[i][3])

-- for backward compatibility
--	if ((videoTable[i][1] == "ORF-1") or (videoTable[i][1] == "ORF-2")) then
--		parse_m3u8 = 3
--	end

	local bw
	local res
	local qual
	if (conf.streamQuality == 'max') then	-- no NLS
		qual = 'max'	-- no NLS
	elseif (conf.streamQuality == 'normal') then	-- no NLS
		qual = 'normal'	-- no NLS
	else
		qual = 'min'	-- no NLS
	end
	if ((parse_m3u8 == 1) or (parse_m3u8 == 2) or (parse_m3u8 == 3)) then
		local mode = parse_m3u8
		m3u8Ret	= get_m3u8url(url, mode)
		url	= m3u8Ret['url']			-- no NLS
		bw	= tonumber(m3u8Ret['bandwidth'])	-- no NLS
		res	= m3u8Ret['resolution']			-- no NLS
		qual	= m3u8Ret['qual']			-- no NLS
	else
		bw = nil
		res = '-'	-- no NLS
	end
	if (bw == nil) then
		bw = '-'	-- no NLS
	else
		bw = tostring(math.floor(bw/1000 + 0.5)) .. 'K'	-- no NLS
	end
	local msg1 = string.format(l.lifeBitRate .. ': %s, ' .. l.lifeResolution .. ': %s, ' .. l.lifeQuality .. ': %s', bw, res, qual)

	local screen = saveFullScreen()
	hideMenu(m_live)
	hideMainWindow()

	playMovie(url, title, msg1, url, false)

	if forcePluginExit == true then
		menuRet = MENU_RETURN.EXIT_ALL
		return menuRet
	end

	restoreFullScreen(screen, true)
	return MENU_RETURN.REPAINT
end -- function playLivestream

function playLivestream2(_id)
	i = tonumber(_id)
	local title = 'TecTime TV'	-- no NLS
	local url = 'https://www.youtube.com/watch?v=dvblFe1W5Q8'	-- no NLS
	local parse_m3u8 = 10

	local bw
	local res
	local qual
	if (conf.streamQuality == 'max') then	-- no NLS
		qual = 'max'	-- no NLS
	elseif (conf.streamQuality == 'normal') then	-- no NLS
		qual = 'normal'	-- no NLS
	else
		qual = 'min'	-- no NLS
	end
	if (parse_m3u8 == 10) then
		local mode = 1
		if (parse_m3u8 == 10) then
			-- TecTime TV
			url = getTecTimeTv_m3u8(url)
			if url == nil then
				return MENU_RETURN.REPAINT
			end
		end
		m3u8Ret	= get_m3u8url(url, mode)
		url		= m3u8Ret['url']			-- no NLS
		bw		= tonumber(m3u8Ret['bandwidth'])	-- no NLS
		res		= m3u8Ret['resolution']			-- no NLS
		qual	= m3u8Ret['qual']				-- no NLS
	else
		bw = nil
		res = '-'	-- no NLS
	end
	if (bw == nil) then
		bw = '-'	-- no NLS
	else
		bw = tostring(math.floor(bw/1000 + 0.5)) .. 'K'	-- no NLS
	end
	local msg1 = string.format(l.lifeBitRate .. ': %s, ' .. l.lifeResolution .. ': %s, ' .. l.lifeQuality .. ': %s', bw, res, qual)

	local screen = saveFullScreen()
	hideMenu(m_live)
	hideMainWindow()

	playMovie(url, title, msg1, url, false)

	if forcePluginExit == true then
		menuRet = MENU_RETURN.EXIT_ALL
		return menuRet
	end

	restoreFullScreen(screen, true)
	return MENU_RETURN.REPAINT
end -- function playLivestream2

function getLivestreams()
	local s = getJsonData2(url_new .. actionCmd_livestream, nil, nil, queryMode_listLivestreams)
--	H.printf("\nretData:\n%s\n", tostring(s))
	local j_table = decodeJson(s)
	if checkJsonError(j_table) == false then
		return false
	end

	for i=1, #j_table.entry do
		local name = j_table.entry[i].title
--		name = string.gsub(name, " Livestream", "")
		local configName = 'livestream_' .. name	-- no NLS
		configName = string.gsub(configName, '[. -]', '_')	-- no NLS
		videoTable[i] = {}
		videoTable[i][1] = name
		videoTable[i][2] = j_table.entry[i].url
		videoTable[i][3] = j_table.entry[i].parse_m3u8
		videoTable[i][4] = configName
	end
	return true
end -- function getLivestreams

function livestreamMenu()
	if (#videoTable == 0) then
		getLivestreamConfig()
	end

	m_live = menu.new{name=pluginName .. ' - ' .. l.lifestreamsHeader, icon=pluginIcon}	-- no NLS
	m_live:addItem{type="subhead", name=l.livestreamsSubHeader}	-- no NLS
	m_live:addItem{type="separator"}	-- no NLS
	m_live:addItem{type="back", hint_icon="hint_back", hint=l.backH}	-- no NLS
	m_live:addItem{type="separatorline"}	-- no NLS
--	m_live:addKey{directkey=RC["home"], id="home", action="key_home"}
--	m_live:addKey{directkey=RC["setup"], id="setup", action="key_setup"}
	addKillKey(m_live)

	local i
	for i=1, #videoTable do
		if (conf.livestream[i] == 'on') then	-- no NLS
			m_live:addItem{type='forwarder', action='playLivestream', hint_icon="hint_service", hint=l.lifestreamsEntryH, id=i, name=videoTable[i][1]}	-- no NLS
		end
	end

--	m_live:addItem{type="forwarder", action="playLivestream2", id=100, name="TecTime TV"}

	m_live:exec()
	restoreFullScreen(mainScreen, false)
	if menuRet == MENU_RETURN.EXIT_ALL then
		return menuRet
	end
	return MENU_RETURN.REPAINT
end -- function livestreamMenu
