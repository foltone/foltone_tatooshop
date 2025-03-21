---@type table
local Colour = {
    Background = { Dictionary = "commonmenu", Texture = "gradient_bgd", Y = 4, Width = 431, Height = 112 },
    LeftArrow = { Dictionary = "commonmenu", Texture = "arrowleft", X = 7.5, Y = 15, Width = 30, Height = 30 },
    RightArrow = { Dictionary = "commonmenu", Texture = "arrowright", X = 393.5, Y = 15, Width = 30, Height = 30 },
    Header = { X = 215.5, Y = 15, Scale = 0.35 },
    Box = { X = 15, Y = 55, Width = 44.5, Height = 44.5 },
    SelectedRectangle = { X = 15, Y = 47, Width = 44.5, Height = 8 },
    Seperator = { Text = "sur" }
}

-- Variable globale pour garder la trace du panneau actif
local ActivePanel = nil

---ColourPanel
---@param Title string
---@param Colours table
---@param MinimumIndex number
---@param CurrentIndex number
---@param Callback function
---@param Index number
---@param Style table
---@return nil
---@public
function Items:ColourPanel(Title, Colours, MinimumIndex, CurrentIndex, Actions, Index, Style)
    local CurrentMenu = RageUI.CurrentMenu
    
    -- Vérifie si le panneau doit être affiché (l'index actuel correspond à l'index du panneau)
    if CurrentMenu.Index == Index then
        ActivePanel = Index  -- Met à jour le panneau actif

        -- Logique d'affichage du panneau
        local Maximum = (#Colours > 9) and 9 or #Colours
        local Hovered = Graphics.IsMouseInBounds(
            CurrentMenu.X + Colour.Box.X + CurrentMenu.SafeZoneSize.X + (CurrentMenu.WidthOffset / 2),
            CurrentMenu.Y + Colour.Box.Y + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset,
            (Colour.Box.Width * Maximum), Colour.Box.Height
        )
        local LeftArrowHovered = Graphics.IsMouseInBounds(
            CurrentMenu.X + Colour.LeftArrow.X + CurrentMenu.SafeZoneSize.X + (CurrentMenu.WidthOffset / 2),
            CurrentMenu.Y + Colour.LeftArrow.Y + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset,
            Colour.LeftArrow.Width, Colour.LeftArrow.Height
        )
        local RightArrowHovered = Graphics.IsMouseInBounds(
            CurrentMenu.X + Colour.RightArrow.X + CurrentMenu.SafeZoneSize.X + (CurrentMenu.WidthOffset / 2),
            CurrentMenu.Y + Colour.RightArrow.Y + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset,
            Colour.RightArrow.Width, Colour.RightArrow.Height
        )
        
        local Selected = false

        -- Affichage des éléments du panneau
        RenderSprite(Colour.Background.Dictionary, Colour.Background.Texture, CurrentMenu.X, CurrentMenu.Y + Colour.Background.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.Background.Width + CurrentMenu.WidthOffset, Colour.Background.Height)
        RenderSprite(Colour.LeftArrow.Dictionary, Colour.LeftArrow.Texture, CurrentMenu.X + Colour.LeftArrow.X + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + Colour.LeftArrow.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.LeftArrow.Width, Colour.LeftArrow.Height)
        RenderSprite(Colour.RightArrow.Dictionary, Colour.RightArrow.Texture, CurrentMenu.X + Colour.RightArrow.X + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + Colour.RightArrow.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.RightArrow.Width, Colour.RightArrow.Height)
        RenderRectangle(CurrentMenu.X + Colour.SelectedRectangle.X + (Colour.Box.Width * (CurrentIndex - MinimumIndex)) + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + Colour.SelectedRectangle.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.SelectedRectangle.Width, Colour.SelectedRectangle.Height, 245, 245, 245, 255)

        for i = 1, Maximum do
            RenderRectangle(CurrentMenu.X + Colour.Box.X + (Colour.Box.Width * (i - 1)) + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + Colour.Box.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.Box.Width, Colour.Box.Height, table.unpack(Colours[MinimumIndex + i - 1]))
        end

        local ColourSeperator = type(Style) == "table" and type(Style.Seperator) == "table" and Style.Seperator or Colour.Seperator
        RenderText((Title and Title or "") .. " (" .. CurrentIndex .. " " .. ColourSeperator.Text .. " " .. #Colours .. ")", CurrentMenu.X + RageUI.Settings.Panels.Grid.Text.Top.X + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + RageUI.Settings.Panels.Grid.Text.Top.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, RageUI.Settings.Panels.Grid.Text.Top.Scale, 245, 245, 245, 255, 1)

        if Hovered or LeftArrowHovered or RightArrowHovered then
            if RageUI.Settings.Controls.Click.Active then
                Selected = true
                if LeftArrowHovered then
                    CurrentIndex = CurrentIndex - 1
                    if CurrentIndex < 1 then
                        CurrentIndex = #Colours
                        MinimumIndex = #Colours - Maximum + 1
                    elseif CurrentIndex < MinimumIndex then
                        MinimumIndex = MinimumIndex - 1
                    end
                elseif RightArrowHovered then
                    CurrentIndex = CurrentIndex + 1
                    if CurrentIndex > #Colours then
                        CurrentIndex = 1
                        MinimumIndex = 1
                    elseif CurrentIndex > MinimumIndex + Maximum - 1 then
                        MinimumIndex = MinimumIndex + 1
                    end
                elseif Hovered then
                    for i = 1, Maximum do
                        if Graphics.IsMouseInBounds(CurrentMenu.X + Colour.Box.X + (Colour.Box.Width * (i - 1)) + CurrentMenu.SafeZoneSize.X + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + Colour.Box.Y + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Colour.Box.Width, Colour.Box.Height) then
                            CurrentIndex = MinimumIndex + i - 1
                        end
                    end
                end
                Actions(MinimumIndex, CurrentIndex, Actions)
            end
        end

        RageUI.ItemOffset = RageUI.ItemOffset + Colour.Background.Height + Colour.Background.Y

        if (Hovered or LeftArrowHovered or RightArrowHovered) and RageUI.Settings.Controls.Click.Active then
            Audio.PlaySound(RageUI.Settings.Audio.Select.audioName, RageUI.Settings.Audio.Select.audioRef)
        end
    else
        -- Réinitialise ActivePanel si l'index ne correspond plus
        if ActivePanel == Index then
            ActivePanel = nil
        end
    end
end
