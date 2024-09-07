DefaultColorMode = 0
OwnColorMode = 1

-- Fields:
--     - text: string
--     - fg_color_mode: ColorMode
--     - bg_color_mode: ColorMode
--     - bold: bool
--     - italic: bool
--     - underline: bool
--     - fg_color: (u8, u8, u8) (if fg_color_mode == OwnColorMode)
--     - bg_color: (u8, u8, u8) (if bg_color_mode == OwnColorMode)
Styled = {}

function Styled:new(text)
	local obj = {}

	obj.text = text
	obj.fg_color_mode = DefaultColorMode
	obj.bg_color_mode = DefaultColorMode
	obj.bold = false
	obj.italic = false
	obj.underline = false

	for k, v in pairs(self) do
		obj[k] = v
	end

	return obj
end

function Styled:set_bold()
	self.bold = true
end

function Styled:set_italic()
	self.italic = true
end

function Styled:set_underline()
	self.underline = true
end

function Styled:set_fg(r, g, b)
	self.fg_color_mode = OwnColorMode
	self.fg_color = { r, g, b }
end

function Styled:set_bg(r, g, b)
	self.bg_color_mode = OwnColorMode
	self.bg_color = { r, g, b }
end

function Styled:new_with(text, bold, italic, underline, fg_color_mode, bg_color_mode, fg_color, bg_color)
	local obj = Styled:new(text)

	if bold then
		obj:set_bold()
	end

	if italic then
		obj:set_italic()
	end

	if underline then
		obj:set_underline()
	end

	if fg_color_mode == OwnColorMode then
		obj:set_fg(fg_color[1], fg_color[2], fg_color[3])
	end

	if bg_color_mode == OwnColorMode then
		obj:set_bg(bg_color[1], bg_color[2], bg_color[3])
	end

	return obj
end

function Styled:format()
	local res = ""

	if self.bold then
		res = res .. "\x1b[1m"
	end

	if self.italic then
		res = res .. "\x1b[3m"
	end

	if self.underline then
		res = res .. "\x1b[4m"
	end

	if self.fg_color_mode == OwnColorMode then
		res = res
			.. "\x1b[38;2;" --
			.. self.fg_color[1] --
			.. ";" --
			.. self.fg_color[2] --
			.. ";" --
			.. self.fg_color[3]
			.. "m"
	end

	if self.bg_color_mode == OwnColorMode then
		res = res
			.. "\x1b[48;2;" --
			.. self.bg_color[1] --
			.. ";" --
			.. self.bg_color[2] --
			.. ";" --
			.. self.bg_color[3]
			.. "m"
	end

	res = res .. self.text

	res = res .. "\x1b[0m"

	return res
end
