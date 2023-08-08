--DEFAULT ++ windows colors variables:
--------------------------------------
--params.Menu_Settings.TITTLE_COLOR.value
--params.Menu_Settings.TITTLE_COLOR_A.value
--params.Menu_Settings.TITTLE_TEXT_COLOR.value
--params.Menu_Settings.WINDOW_COLOR.value
--params.Menu_Settings.WINDOW_COLOR_A.value
--params.Menu_Settings.WINDOW_TEXT_COLOR.value
--params.Menu_Settings.BUTTON_COLOR.value
--params.Menu_Settings.BUTTON_BORDER_COLOR.value
--params.Menu_Settings.BUTTON_COLOR_A.value
--params.Menu_Settings.BUTTON_TEXT_COLOR.value
--params.Menu_Settings.WIDGET_TEXT_COLOR.value
--params.Menu_Settings.WIDGET_ANIM_COLOR.value
--params.Menu_Settings.WIDGET_FIXED_COLOR.value

--DEFAULT ++ updated variables:
-------------------------------
--currentTime = num
--inspace = 0 in atmo 1 in space
--xSpeedKPH = num kmph
--ySpeedKPH = num kmph
--zSpeedKPH = num kmph
--xyzSpeedKPH = num kmph
--Az = drift rot angle in deg
--Ax = drift pitch angle in deg
--Ax0 = pitch angle in deg
--Ay0 = roll angle in deg
--ThrottlePos = num
--MasterMode = string ("CRUISE" / "TRAVEL" / "PARKING")
--closestPlanetIndex = num (planet index for Helios library)
--atmofueltank = JSON
--spacefueltank = JSON
--rocketfueltank = JSON
--fueltanks = table (all fueltanks JSON data)
--fueltanks_size = num (total number of fuel tanks)

--DEFAULT ++ keybind variables:
-------------------------------
--CLICK = bool
--CTRL = bool
--ALT = bool
--SHIFT = bool
--pitchInput = num (-1 / 0 / 1)
--rollInput = num (-1 / 0 / 1)
--yawInput = num (-1 / 0 / 1)
--brakeInput = num (-1 / 0 / 1)
--strafeInput = num (-1 / 0 / 1)
--upInput = num (-1 / 0 / 1)
--forwardInput = num (-1 / 0 / 1)
--boosterInput = num (-1 / 0 / 1)

WidgetsPlusPlusCustom = {}
WidgetsPlusPlusCustom.__index = WidgetsPlusPlusCustom

function WidgetsPlusPlusCustom.new(core, unit, DB, antigrav, warpdrive, shield, switch)
    local self = setmetatable({}, WidgetsPlusPlusCustom)
    self.core = core
    self.unit = unit
    self.DB = DB
    self.antigrav = antigrav
    self.warpdrive = warpdrive
    self.shield = shield
    self.switch = switch
    
    self.buttons = {} -- list of buttons to be implemented in widget
    self.name = "CONSTRUCT MANAGER++" -- name of the widget
    self.tittle = self.name
    self.onBoardIds = DUConstruct.getPlayersOnBoard() --22474
    self.onBoardVRIds = DUConstruct.getPlayersOnBoardInVRStation()
    self.dockedIds = DUConstruct.getDockedConstructs()
    self.SVGSize = {x=260,y= 55 + #self.onBoardIds * 30 + #self.onBoardVRIds * 30 + #self.dockedIds * 30 + 60 + 5} -- size of the window to fit the svg, in pixels
    self.pos = {x=500, y=500}
    self.class = "widgetnopadding"  --class = "widgets" (only svg)/ class = "widgetnopadding" (default++ widget style)
    self.draggable = true  --allow widget to be dragged
    self.fixed = false  --prevent widget from going over others
    return self
end

function WidgetsPlusPlusCustom.getSize(self) --returns the svg size
    return self.SVGSize
end

function WidgetsPlusPlusCustom.getName(self) --returns the widget name
    return self.name
end

function WidgetsPlusPlusCustom.getTittle(self) --returns the widget name
    return self.tittle
end

function WidgetsPlusPlusCustom.getPos(self) --returns the widget name
    return self.pos
end

function WidgetsPlusPlusCustom.getButtons(self) --returns buttons list
    return self.buttons
end

function WidgetsPlusPlusCustom.flushOverRide(self) --replace the flush thrust
    return nil
end
--------------------
-- CUSTOM BUTTONS --
--------------------
--local button_function = function() system.print("Hello world!") end

--system.getPlayerName(id)
--radar.getConstructName(id)
----------------
-- WIDGET SVG --
----------------

function WidgetsPlusPlusCustom.SVG_Update(self)
    local ceil = math.ceil
    local WTC = params.Menu_Settings.WIDGET_TEXT_COLOR.value
    local bf = function() end
    local mass = 0
    local name = ""
    local rdr = nil
    self.onBoardIds = DUConstruct.getPlayersOnBoard() --22474
    self.onBoardVRIds = DUConstruct.getPlayersOnBoardInVRStation()
    self.dockedIds = DUConstruct.getDockedConstructs()
    local SVG = ""
    local ind = 0

    if #radar ~= 0 then
        rdr = radar_1 ~= nil and radar_1.getOperationalState() == 1 and radar_1 or radar_2 ~= nil and radar_2.getOperationalState() == 1 and radar_2 or nil
    end

    SVG = SVG .. [[<text x="5" y="10" font-size="20" text-anchor="start" font-family="Play" alignment-baseline="baseline" fill="]]..WTC..[[">On board Players: ]].. #self.onBoardIds ..[[</text>]]
    for i, id in ipairs(self.onBoardIds) do
        mass = type(DUConstruct.getBoardedPlayerMass(id)) == "number" and ceil(DUConstruct.getBoardedPlayerMass(id)) or "Undetermined "
        name = DUSystem.getPlayerName(id) ~= "" and DUSystem.getPlayerName(id) or "Unknown"
        bf = function() return function() DUConstruct.forceDeboard(id) end end
        ind = ind +1
        self.buttons[ind] = {name.."("..mass.."kg)", bf(), {name = name, class = nil, width = 250, height = 25, posX = 5, posY = 55 + (ind-1) * 30}}
    end

    SVG = SVG .. [[<text x="5" y="]].. 10 + ind * 30 + 30 ..[[" font-size="20" text-anchor="start" font-family="Play" alignment-baseline="baseline" fill="]]..WTC..[[">On board in VR Players: ]].. #self.onBoardVRIds ..[[</text>]]
    for i, id in ipairs(self.onBoardVRIds) do
        mass = type(DUConstruct.getBoardedInVRStationAvatarMass(id)) == "number" and ceil(DUConstruct.getBoardedInVRStationAvatarMass(id)) or "Undetermined "
        name = DUSystem.getPlayerName(id) ~= "" and DUSystem.getPlayerName(id) or "Unknown"
        bf = function() return function() DUConstruct.forceInterruptVRSession(id) end end
        ind = ind +1
        self.buttons[ind] = {name .. "(" .. mass .. "kg)", bf(), {name = name, class = nil, width = 250, height = 25, posX = 5, posY = 55 + (ind-1) * 30 + 30}}
    end

    SVG = SVG .. [[<text x="5" y="]].. 15 + ind * 30 + 60 ..[[" font-size="20" text-anchor="start" font-family="Play" alignment-baseline="baseline" fill="]]..WTC..[[">Docked Constructs: ]].. #self.dockedIds ..[[</text>]]
    for i, id in ipairs(self.dockedIds) do
        mass = type(DUConstruct.getDockedConstructMass(id)) == "number" and ceil(DUConstruct.getDockedConstructMass(id)*10)/10000 or "Undetermined "
        name = rdr ~= nil and rdr.getConstructName(id) or "Radar needed"
        bf = function() return function() DUConstruct.forceUndock(id) end end
        ind = ind +1
        self.buttons[ind] = {name .. "(" .. mass .. "tons)", bf(), {name = name, class = nil, width = 250, height = 25, posX = 5, posY = 55 + (ind-1) * 30 + 60}}
    end

    --self.SVGSize = {x=260,y= 55 + #onBoardIds * 30 + #onBoardVRIds * 30 + #dockedIds * 30 + 90 + 5}

    SVG = '<div><svg viewBox="0 0 '.. self.SVGSize.x ..' '.. self.SVGSize.y ..'">'..SVG..'</svg></div>'
    return SVG
end
