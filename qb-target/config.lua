Config = {
	RaycastInterval = 100,                                -- interval for raycast checks (ms)
	RaycastStartOffset = 25.0,                            -- offset from camera to start raycast
	NearbyScanInterval = 500,                             -- interval for nearby entity scans (ms)
	OpenKey = 'LeftAlt',                                  -- enable target
	MenuControlKey = 'RightMouseButton',                  -- enable mouse control
	MaxDistance = 1000,                                   -- max distance for raycast
	HighlightColor = { R = 0.3, G = 0.7, B = 1.0, A = 1.0 }, -- color of objects when holding target key
	SelectColor = { R = 0.0, G = 1.0, B = 0.3, A = 1.0 }, -- color swaps to when hovering target
	InnerlineIntensity = 0.0,                             -- raising this will make the object change color, not just outline
	OutlineIntensity = 0.5,                               -- how thick the outline is
}

return Config
