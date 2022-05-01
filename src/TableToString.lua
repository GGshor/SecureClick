--[=[
	Makes given table a string, label can be added or "TABLE" would be used as default.
	Use deepPrint for also adding tables that are in the table!

	@param tbl {[any]: any} -- The table that becomes a string
	@param label string? -- Add a label to string (like a title)
	@deepPrint boolean? -- Also print tables in the given table

	@return string -- Table in form of a string
]=]
return function (tbl: table, label: string?, deepPrint: boolean?): string

	assert(type(tbl) == "table", "First argument must be a table")
	assert(label == nil or type(label) == "string", "Second argument must be a string or nil")

	label = (label or "TABLE")

	local strTbl = {}
	local indent = " - "

	-- Insert(string, indentLevel)
	local function Insert(s, l)
		strTbl[#strTbl + 1] = (indent:rep(l) .. s .. "\n")
	end

	local function AlphaKeySort(a, b)
		return (tostring(a.k) < tostring(b.k))
	end

	local function ToString(t, lvl, lbl)
		Insert(lbl .. ":", lvl - 1)
		local nonTbls = {}
		local tbls = {}
		local keySpaces = 0
		for k,v in pairs(t) do
			if type(v) == "table" then
				table.insert(tbls, {k = k, v = v})
			else
				table.insert(nonTbls, {k = k, v = "[" .. typeof(v) .. "] " .. tostring(v)})
			end
			local spaces = #tostring(k) + 1
			if spaces > keySpaces then
				keySpaces = spaces
			end
		end
		table.sort(nonTbls, AlphaKeySort)
		table.sort(tbls, AlphaKeySort)
		for _,v in ipairs(nonTbls) do
			Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. v.v, lvl)
		end
		if deepPrint then
			for _,v in ipairs(tbls) do
				ToString(v.v, lvl + 1, tostring(v.k) .. (" "):rep(keySpaces - #tostring(v.k)) .. " [Table]")
			end
		else
			for _,v in ipairs(tbls) do
				Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. "[Table]", lvl)
			end
		end
	end

	ToString(tbl, 1, label)

	return (table.concat(strTbl, ""))
end