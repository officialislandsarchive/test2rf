local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
    InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = false,
        Transparency = true,
        MenuKeybind = "LeftControl"
    }

    local function ensureFoldersExist(folder)
        local paths = {}
        for _, sub in ipairs(folder:split("/")) do
            paths[#paths + 1] = table.concat(paths, "/", 1, _) .. sub
        end
        paths[#paths + 1] = folder
        paths[#paths + 1] = folder .. "/settings"

        for _, path in ipairs(paths) do
            if not isfolder(path) then
                makefolder(path)
            end
        end
    end

    local function saveSettings()
        writefile(InterfaceManager.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    local function loadSettings()
        local path = InterfaceManager.Folder .. "/options.json"
        if isfile(path) then
            local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(path))
            if success then
                for k, v in pairs(decoded) do
                    InterfaceManager.Settings[k] = v
                end
            end
        end
    end

    function InterfaceManager:SetFolder(folder)
        self.Folder = folder
        ensureFoldersExist(folder)
    end

    function InterfaceManager:SetLibrary(library)
        self.Library = library
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "InterfaceManager.Library must be set.")
        local Library = self.Library
        local Settings = InterfaceManager.Settings

        loadSettings()

        local section = tab:AddSection("Interface")

        local themeDropdown = section:AddDropdown("ThemeDropdown", {
            Title = "Theme",
            Description = "Set the interface theme.",
            Values = Library.Themes,
            Default = Settings.Theme,
            Callback = function(value)
                Library:SetTheme(value)
                Settings.Theme = value
                saveSettings()
            end
        })

        themeDropdown:SetValue(Settings.Theme)

        if Library.UseAcrylic then
            section:AddToggle("AcrylicToggle", {
                Title = "Acrylic",
                Description = "Blurred background (requires graphics quality 8+).",
                Default = Settings.Acrylic,
                Callback = function(value)
                    Library:ToggleAcrylic(value)
                    Settings.Acrylic = value
                    saveSettings()
                end
            })
        end

        section:AddToggle("TransparencyToggle", {
            Title = "Transparency",
            Description = "Enable transparent interface.",
            Default = Settings.Transparency,
            Callback = function(value)
                Library:ToggleTransparency(value)
                Settings.Transparency = value
                saveSettings()
            end
        })

        local keybind = section:AddKeybind("MenuKeybind", {
            Title = "Menu Keybind",
            Default = Settings.MenuKeybind,
            Callback = function(value)
                Settings.MenuKeybind = value
                saveSettings()
            end
        })

        keybind:SetValue(Settings.MenuKeybind)
        Library.MinimizeKeybind = keybind
    end
end

return InterfaceManager
