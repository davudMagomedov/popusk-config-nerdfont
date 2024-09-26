package.path = package.path .. ";/Users/davudmagomedov/.config/popusk/lua/?.lua"

require("rgb")

local function make_header(libentity)
	local header
	if libentity.etype == "document" then
		header = Styled:new_with(
			"\u{f02d}  " .. libentity.name,
			true,
			false,
			false,
			OwnColorMode,
			DefaultColorMode,
			{ 255, 128, 0 }
		):format()
	elseif libentity.etype == "section" then
		header = Styled:new_with(
			"\u{f4d3}  " .. libentity.name,
			true,
			false,
			false,
			OwnColorMode,
			DefaultColorMode,
			{ 255, 128, 0 }
		):format()
	else
		header = Styled:new_with(
			"\u{f15b}  " .. libentity.name,
			true,
			false,
			false,
			OwnColorMode,
			DefaultColorMode,
			{ 255, 128, 0 }
		):format()
	end

	return header
end

local function stringify_inoneline(array)
	local res = ""

	for i, ele in pairs(array) do
		if i == 1 then
			res = ele
		else
			res = res .. " " .. ele
		end
	end

	return res
end

function look_output(libentity, context)
	local res = ""

	local styled_name = make_header(libentity)

	local styled_id_kw = Styled:new_with("ID", false, false, true, DefaultColorMode, DefaultColorMode):format()
	local styled_path_kw = Styled:new_with("Path", false, false, true, DefaultColorMode, DefaultColorMode):format()
	local styled_tags_kw = Styled:new_with("Tags", false, false, true, DefaultColorMode, DefaultColorMode):format()

	local styled_id_val = Styled:new_with(libentity.id, true, false, false, DefaultColorMode, DefaultColorMode):format()
	local styled_path_val = Styled:new_with(libentity.path, true, false, false, DefaultColorMode, DefaultColorMode)
		:format()
	local styled_tags_val =
		Styled:new_with(stringify_inoneline(libentity.tags), true, false, false, DefaultColorMode, DefaultColorMode)
			:format()

	res = res .. styled_name .. "\n"

	if libentity.description ~= nil then
		local styled_description =
			Styled:new_with(libentity.description, false, true, false, OwnColorMode, DefaultColorMode, { 189, 99, 0 })
				:format()

		res = res .. styled_description .. "\n"
	end

	res = res .. "   \u{f4e4}  " .. styled_id_kw .. ": " .. styled_id_val .. "\n"
	res = res .. "   \u{f0d20}  " .. styled_path_kw .. ": " .. styled_path_val .. "\n"
	res = res .. "   \u{f02b}  " .. styled_tags_kw .. ": " .. styled_tags_val

	if libentity.etype == "document" then
		local styled_progress_kw = Styled:new_with("Progress", false, false, true, DefaultColorMode, DefaultColorMode)
			:format()
		local styled_progress_val = Styled:new_with(
			libentity.progress.passed .. "/" .. libentity.progress.ceiling,
			true,
			false,
			false,
			DefaultColorMode,
			DefaultColorMode
		):format()

		res = res .. "\n   \u{f0995}  " .. styled_progress_kw .. ": " .. styled_progress_val
	end

	return res
end

function list_output_narrow(libentities, context)
	local res = ""

	for _, libentity in pairs(libentities) do
		local styled_name = make_header(libentity)

		local styled_path = Styled:new_with(
			"[" .. libentity.path .. "]",
			false,
			true,
			false,
			OwnColorMode,
			DefaultColorMode,
			-- { 92, 92, 92 }
			{ 153, 76, 0 }
		)

		res = res .. styled_name:format() .. " " .. styled_path:format() .. "\n"
	end

	return res
end

function open_libentity(libentity, context)
	os.execute("bash -c 'zathura " .. libentity.path .. "'")

	io.write("Write progress update: "):flush()

	if libentity.etype == "document" then
		local progress_update_string = io.read("l")

		local action = progress_update_string:sub(1, 1)
		local value = tonumber(progress_update_string:sub(2, -1), 10)

		if action == "+" then
			return {
				passed = libentity.progress.passed + value,
				ceiling = libentity.progress.ceiling,
			}
		elseif action == "-" then
			return {
				passed = libentity.progress.passed - value,
				ceiling = libentity.progress.ceiling,
			}
		elseif action == "=" then
			return {
				passed = value,
				ceiling = libentity.progress.ceiling,
			}
		end
	end
end

function list_output_wide(libentities, context)
	local res = ""

	for _, libentity in pairs(libentities) do
		local look_res = look_output(libentity, context)
		res = res .. look_res .. "\n\n"
	end

	return res
end

local function contains_value(array, expected_value) --> boolean
	local contains = false
	for _, value in ipairs(array) do
		if value == expected_value then
			contains = true
			break
		end
	end

	return contains
end

local document_extensions = { "pdf", "html", "md", "epub" }
function is_document(extension) --> boolean
	return contains_value(document_extensions, extension)
end
